package handler

import (
	"log"
	"net/http"
	"sync"
	"time"

	"github.com/gin-gonic/gin"
)

type scanRequestState struct {
	mu          sync.Mutex
	active      bool
	capturing   bool
	purpose     string
	employeeID  string
	requestedAt time.Time
}

var scanState = &scanRequestState{}

const scanRequestTTL = 30 * time.Second

func FingerprintScanRequest(c *gin.Context) {
	var req struct {
		Purpose    string `json:"purpose"`
		EmployeeID string `json:"employee_id"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "body tidak valid"})
		return
	}
	if req.Purpose != "identify" && req.Purpose != "enroll" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "purpose harus 'identify' atau 'enroll'"})
		return
	}
	if req.Purpose == "enroll" && req.EmployeeID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "employee_id wajib untuk purpose=enroll"})
		return
	}

	scanState.mu.Lock()
	scanState.active = true
	scanState.purpose = req.Purpose
	scanState.employeeID = req.EmployeeID
	scanState.requestedAt = time.Now()
	scanState.mu.Unlock()

	log.Printf("[Fingerprint/ScanControl] Permintaan scan baru: purpose=%s employee_id=%s",
		req.Purpose, req.EmployeeID)

	c.JSON(http.StatusOK, gin.H{"status": "ok", "message": "Menunggu listener mengambil permintaan"})
}

func FingerprintScanStatus(c *gin.Context) {
	scanState.mu.Lock()
	defer scanState.mu.Unlock()
	if scanState.active && time.Since(scanState.requestedAt) > scanRequestTTL {
		log.Printf("[Fingerprint/ScanControl] Flag scan basi (TTL lewat), direset")
		scanState.active = false
	}

	if !scanState.active {
		c.JSON(http.StatusOK, gin.H{
			"active":    false,
			"capturing": scanState.capturing,
		})
		return
	}

	purpose := scanState.purpose
	employeeID := scanState.employeeID

	scanState.active = false
	scanState.capturing = true

	log.Printf("[Fingerprint/ScanControl] Listener mengambil permintaan: purpose=%s", purpose)

	c.JSON(http.StatusOK, gin.H{
		"active":      true,
		"capturing":   false,
		"purpose":     purpose,
		"employee_id": employeeID,
	})
}

func FingerprintScanCancel(c *gin.Context) {
	scanState.mu.Lock()
	scanState.active = false
	scanState.capturing = false
	scanState.mu.Unlock()

	broadcastToAllSessions("fingerprint_cancelled", map[string]string{
		"reason": "dibatalkan",
	})

	log.Printf("[Fingerprint/ScanControl] Permintaan scan dibatalkan")
	c.JSON(http.StatusOK, gin.H{"status": "ok"})
}

func FingerprintCaptureDone(c *gin.Context) {
	scanState.mu.Lock()
	scanState.capturing = false
	scanState.mu.Unlock()
	log.Printf("[Fingerprint/ScanControl] Listener melaporkan capture selesai")
	c.JSON(http.StatusOK, gin.H{"status": "ok"})
}
