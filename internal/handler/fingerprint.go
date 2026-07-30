package handler

import (
	"log"
	"net/http"

	"github.com/gin-gonic/gin"

	"sparepart-mgmt/internal/repository"
)

type FingerprintIdentifyRequest struct {
	IDCard string `json:"id_card"`
}

func FingerprintIdentify(c *gin.Context) {
	var req FingerprintIdentifyRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "body wajib: {\"id_card\":\"...\"}"})
		return
	}

	if req.IDCard == "" {
		log.Printf("[Fingerprint/U.areU] Scan tidak dikenal (id_card kosong dari listener)")
		broadcastToAllSessions("biometric_error", map[string]string{
			"error": "Sidik jari tidak terdaftar di sistem",
		})
		c.JSON(http.StatusOK, gin.H{"status": "not_found"})
		return
	}

	idCard := req.IDCard
	log.Printf("[Fingerprint/U.areU] Identify request — id_card=%s", idCard)

	var foundName, foundSource string
	var found bool

	if emp, err := repository.GetEmployeeByFingerprintID(idCard); err == nil {
		foundName = emp.FullName
		foundSource = "fingerprint"
		found = true
		log.Printf("[Fingerprint/U.areU] Match fingerprint_id: %s → %s", idCard, foundName)
	}

	if !found {
		if emp, err := repository.GetEmployeeByIDCard(idCard); err == nil {
			foundName = emp.FullName
			foundSource = "fingerprint"
			found = true
			log.Printf("[Fingerprint/U.areU] Match id_card_number: %s → %s", idCard, foundName)
		}
	}

	if !found {
		if user, err := repository.GetUserByIDCard(idCard); err == nil {
			foundName = user.FullName
			foundSource = "fingerprint"
			found = true
			log.Printf("[Fingerprint/U.areU] Match user id_card: %s → %s", idCard, foundName)
		}
	}

	if !found {
		log.Printf("[Fingerprint/U.areU] ID tidak dikenal: %s", idCard)
		broadcastToAllSessions("biometric_error", map[string]string{
			"error":   "ID tidak terdaftar di sistem",
			"user_id": idCard,
		})
		c.JSON(http.StatusOK, gin.H{"status": "not_found", "id_card": idCard})
		return
	}

	broadcastToAllSessions("biometric_ok", map[string]string{
		"name":   foundName,
		"source": foundSource,
	})

	log.Printf("[Fingerprint/U.areU] SSE biometric_ok dikirim: %s (%s)", foundName, foundSource)
	c.JSON(http.StatusOK, gin.H{
		"status": "ok",
		"name":   foundName,
		"source": foundSource,
	})
}

type FingerprintTemplateItem struct {
	ID                  int    `json:"ID"`
	IDCardNumber        string `json:"IDCardNumber"`
	FullName            string `json:"FullName"`
	FingerprintTemplate string `json:"FingerprintTemplate"`
}

func FingerprintGetTemplates(c *gin.Context) {
	employees, err := repository.GetAllEmployeesWithFingerprint()
	if err != nil {
		log.Printf("[Fingerprint/U.areU] Gagal load templates: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "gagal load templates"})
		return
	}

	result := make([]FingerprintTemplateItem, 0, len(employees))
	for _, emp := range employees {
		if emp.FingerprintTemplate == "" {
			continue
		}
		result = append(result, FingerprintTemplateItem{
			ID:                  emp.ID,
			IDCardNumber:        emp.IDCardNumber,
			FullName:            emp.FullName,
			FingerprintTemplate: emp.FingerprintTemplate,
		})
	}

	log.Printf("[Fingerprint/U.areU] Mengirim %d template ke listener", len(result))
	c.JSON(http.StatusOK, result)
}

type FingerprintEnrollRequest struct {
	IDCard   string `json:"id_card"`
	Template string `json:"template"`
}

func HandleFingerprintEnroll(c *gin.Context) {
	var req FingerprintEnrollRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid request"})
		return
	}

	err := repository.SaveFingerprintTemplate(req.IDCard, req.Template)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "enrollment berhasil"})
}

func HandleGetFingerprintTemplates(c *gin.Context) {
	FingerprintGetTemplates(c)
}

type FingerprintRegisterScanRequest struct {
	Template   string `json:"template"`
	EmployeeID string `json:"employee_id"`
	Error      string `json:"error"`
}

func FingerprintRegisterScan(c *gin.Context) {
	var req FingerprintRegisterScanRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid request body"})
		return
	}

	if req.Error != "" {
		log.Printf("[Fingerprint/RegisterScan] Error reported by listener: %s", req.Error)
		broadcastToAllSessions("fingerprint_scanned", map[string]string{
			"employee_id": req.EmployeeID,
			"status":      "error",
			"message":     req.Error,
		})
		c.JSON(http.StatusOK, gin.H{"status": "error_broadcasted"})
		return
	}

	if req.Template == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "template wajib diisi"})
		return
	}

	if req.EmployeeID != "" && req.EmployeeID != "0" {
		if err := repository.SaveFingerprintTemplateByID(req.EmployeeID, req.Template); err != nil {
			log.Printf("[Fingerprint/RegisterScan] Gagal simpan template: %v", err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": "gagal simpan template"})
			return
		}
		log.Printf("[Fingerprint/RegisterScan] Template tersimpan untuk employee_id=%s", req.EmployeeID)
	}

	broadcastToAllSessions("fingerprint_scanned", map[string]string{
		"employee_id": req.EmployeeID,
		"template":    req.Template,
		"status":      "ok",
	})

	log.Printf("[Fingerprint/RegisterScan] Template diterima & dibroadcast untuk employee_id=%s", req.EmployeeID)
	c.JSON(http.StatusOK, gin.H{"status": "ok"})
}
