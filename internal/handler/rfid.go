package handler

import (
	"encoding/json"
	"fmt"
	"net/http"
	"sync"
	"time"

	"github.com/gin-gonic/gin"

	"sparepart-mgmt/internal/repository"
)

var (
	sseHub   = make(map[string]chan string)
	sseHubMu sync.Mutex
)

func registerSSE(sessionID string) chan string {
	ch := make(chan string, 10)
	sseHubMu.Lock()
	sseHub[sessionID] = ch
	sseHubMu.Unlock()
	return ch
}

func unregisterSSE(sessionID string) {
	sseHubMu.Lock()
	if ch, ok := sseHub[sessionID]; ok {
		close(ch)
		delete(sseHub, sessionID)
	}
	sseHubMu.Unlock()
}

func pushSSE(sessionID, eventType, data string) {
	sseHubMu.Lock()
	ch, ok := sseHub[sessionID]
	sseHubMu.Unlock()
	if !ok {
		return
	}
	msg := fmt.Sprintf("event: %s\ndata: %s\n\n", eventType, data)
	select {
	case ch <- msg:
	default:
	}
}

// CreateRFIDSession creates a new scan session when the pemohon opens the scan page.
// POST /api/rfid/session
func CreateRFIDSession(c *gin.Context) {
	userID, _, _, _ := GetSessionUser(c)

	sessionID := generateSessionID()
	expiresAt := time.Now().Add(30 * time.Minute)

	_, err := repository.CreateRFIDSession(sessionID, userID, expiresAt)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal membuat sesi RFID"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"session_id": sessionID,
		"expires_at": expiresAt.Format(time.RFC3339),
	})
}

// ScanRFIDFromDevice receives EPC tag data from the Chainway R1 device (not the browser).
// POST /api/rfid/scan — body: { "epc": "...", "session_id": "..." }
func ScanRFIDFromDevice(c *gin.Context) {
	var req struct {
		EPC       string `json:"epc"`
		SessionID string `json:"session_id"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Format body tidak valid, butuh: {epc, session_id}"})
		return
	}

	if req.EPC == "" || req.SessionID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "epc dan session_id wajib diisi"})
		return
	}

	session, err := repository.GetRFIDSession(req.SessionID)
	if err != nil || !session.IsActive || time.Now().After(session.ExpiresAt) {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Sesi RFID tidak valid atau sudah expired"})
		return
	}

	sp, err := repository.GetSparepartByRFID(req.EPC)
	if err != nil {
		errData, _ := json.Marshal(gin.H{
			"epc":     req.EPC,
			"message": fmt.Sprintf("RFID tidak dikenali: %s", req.EPC),
		})
		pushSSE(req.SessionID, "rfid_error", string(errData))
		c.JSON(http.StatusOK, gin.H{"status": "not_found", "epc": req.EPC})
		return
	}

	itemData, _ := json.Marshal(gin.H{
		"sparepart_id": sp.ID,
		"nama_item":    sp.NamaItem,
		"kode_oracle":  sp.KodeOracle,
		"no_part":      sp.NoPart,
		"deskripsi":    sp.Deskripsi,
		"epc":          req.EPC,
		"stok":         sp.Stok,
		"lokasi":       sp.Lokasi,
	})
	pushSSE(req.SessionID, "rfid_scanned", string(itemData))

	c.JSON(http.StatusOK, gin.H{
		"status":      "ok",
		"nama_item":   sp.NamaItem,
		"kode_oracle": sp.KodeOracle,
	})
}

func StreamRFID(c *gin.Context) {
	sessionID := c.Query("session_id")
	if sessionID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "session_id wajib diisi"})
		return
	}

	c.Header("Content-Type", "text/event-stream")
	c.Header("Cache-Control", "no-cache")
	c.Header("Connection", "keep-alive")
	c.Header("X-Accel-Buffering", "no") // prevent nginx from buffering SSE

	ch := registerSSE(sessionID)
	defer unregisterSSE(sessionID)

	fmt.Fprintf(c.Writer, "event: connected\ndata: {\"session_id\":\"%s\"}\n\n", sessionID)
	c.Writer.Flush()

	ticker := time.NewTicker(20 * time.Second)
	defer ticker.Stop()

	clientGone := c.Request.Context().Done()

	for {
		select {
		case <-clientGone:
			return

		case msg, ok := <-ch:
			if !ok {
				return
			}
			fmt.Fprint(c.Writer, msg)
			c.Writer.Flush()

		case <-ticker.C:
			fmt.Fprintf(c.Writer, ": heartbeat\n\n")
			c.Writer.Flush()
		}
	}
}

func generateSessionID() string {
	return fmt.Sprintf("rfid-%d", time.Now().UnixNano())
}
