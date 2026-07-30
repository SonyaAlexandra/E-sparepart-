package handler

import (
	"fmt"
	"net/http"
	"strconv"
	"strings"
	"time"

	"github.com/gin-gonic/gin"

	"sparepart-mgmt/internal/model"
	"sparepart-mgmt/internal/repository"
	"sparepart-mgmt/internal/service"
)

func ShowNIPermintaan(c *gin.Context) {
	userID, _, _, _ := GetSessionUser(c)

	now := time.Now()
	from := c.DefaultQuery("from", now.Format("2006-01-"+"01"))
	to := c.DefaultQuery("to", now.Format("2006-01-")+fmt.Sprintf("%02d", daysInMonth(now)))

	requests, _ := repository.GetNonInventoryByPemohonFiltered(userID, from, to)

	renderTemplate(c, "non_inventory/permintaan_list.html", gin.H{
		"Title":    "Permintaan Non-Inventory",
		"Requests": requests,
		"From":     from,
		"To":       to,
	})
}

func daysInMonth(t time.Time) int {
	return time.Date(t.Year(), t.Month()+1, 0, 0, 0, 0, 0, t.Location()).Day()
}

func ShowNIFormBaru(c *gin.Context) {
	noBPJT, err := repository.PredictNextNoBPJT(time.Now())
	if err != nil {
		noBPJT = "-"
	}

	renderTemplate(c, "non_inventory/permintaan_form.html", gin.H{
		"Title":  "Tambah Permintaan Non-Inventory",
		"NoBPJT": noBPJT,
	})
}

func SubmitNIPermintaan(c *gin.Context) {
	userID, _, userName, _ := GetSessionUser(c)

	namaPemohon := strings.TrimSpace(c.PostForm("nama_pemohon"))
	seksiDivisi := c.PostForm("seksi_divisi")
	tanggalStr := c.PostForm("tanggal_pemakaian")

	tanggal, err := time.Parse("2006-01-02", tanggalStr)
	if err != nil {
		c.String(http.StatusBadRequest, "Format tanggal salah")
		return
	}

	validDivisi := map[string]bool{"MTC1": true, "MTC2": true, "UTL": true, "BM": true}
	if !validDivisi[seksiDivisi] {
		c.String(http.StatusBadRequest, "Divisi tidak valid")
		return
	}

	if namaPemohon == "" {
		namaPemohon = userName
	}

	// Parse multi items
	descs := c.PostFormArray("deskripsi[]")
	qtys := c.PostFormArray("qty[]")
	peruntukans := c.PostFormArray("peruntukan[]")
	lampirans := c.PostFormArray("lampiran[]")

	if len(descs) == 0 {
		c.String(http.StatusBadRequest, "Minimal 1 item permintaan diperlukan")
		return
	}

	noBPJT, errGen := repository.GenerateNoBPJT(time.Now())
	if errGen != nil {
		c.String(http.StatusInternalServerError, "Gagal generate No BPJT")
		return
	}

	req := &model.NonInventoryRequest{
		NoBPJT:           noBPJT,
		PemohonID:        userID,
		NamaPemohon:      namaPemohon,
		SeksiDivisi:      seksiDivisi,
		TanggalPemakaian: tanggal,
		Keterangan:       "",
		LampiranURL:      "",
	}

	newID, err := repository.CreateNonInventoryRequest(req)
	if err != nil {
		c.String(http.StatusInternalServerError, "Gagal menyimpan permintaan: "+err.Error())
		return
	}

	// Insert items
	for i, desc := range descs {
		desc = strings.TrimSpace(desc)
		if desc == "" {
			continue
		}
		qty := 1
		if i < len(qtys) {
			if q, e := strconv.Atoi(qtys[i]); e == nil && q > 0 {
				qty = q
			}
		}
		peruntukan := ""
		if i < len(peruntukans) {
			peruntukan = strings.TrimSpace(peruntukans[i])
		}
		lampiranVal := ""
		if i < len(lampirans) {
			lampiranVal = strings.TrimSpace(lampirans[i])
		}
		repository.AddNonInventoryItem(&model.NonInventoryItem{
			RequestID:  newID,
			Deskripsi:  desc,
			Qty:        qty,
			Peruntukan: peruntukan,
			Lampiran:   lampiranVal,
		})
	}

	c.Redirect(http.StatusFound, "/non-inventory/permintaan?toast=create_success")

	// Log aktivitas: request dibuat
	repository.CreateActivityLog(&model.ActivityLog{
		UserID:     userID,
		Action:     "create",
		EntityType: "non_inventory",
		EntityID:   newID,
		Detail:     fmt.Sprintf("Permintaan Non-Inventory %s dibuat (%s, %d item)", noBPJT, seksiDivisi, len(descs)),
	})

	go service.NotifySPVPemohon(seksiDivisi, noBPJT)
	go service.NotifyAdminSP(newID, noBPJT, namaPemohon)
}

func ShowNIDetail(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.Redirect(http.StatusFound, "/non-inventory/permintaan")
		return
	}

	req, err := repository.GetNonInventoryByID(id)
	if err != nil {
		c.Redirect(http.StatusFound, "/non-inventory/permintaan")
		return
	}

	userID, role, _, _ := GetSessionUser(c)
	division := getLiveDivision(c, userID)

	canAct := false
	approverStage := 0
	switch role {
	case "spv_pemohon":
		if req.Status == "pending" && divisionContains(division, req.SeksiDivisi) {
			canAct = true
			approverStage = 1
		}
	case "admin_sp":
		if req.Status == "stage1" {
			canAct = true
			approverStage = 2
		}
	case "spv_sp":
		if req.Status == "stage2" {
			canAct = true
			approverStage = 3
		}
		if req.Status == "pending" && division != "" && divisionContains(division, req.SeksiDivisi) {
			canAct = true
			approverStage = 1
		}
	}

	renderTemplate(c, "non_inventory/detail.html", gin.H{
		"Title":         "Detail Permintaan " + req.NoBPJT,
		"Request":       req,
		"CanAct":        canAct,
		"ApproverStage": approverStage,
	})
}

func NIRelease(c *gin.Context) {
	id, _ := strconv.Atoi(c.Param("id"))
	userID, role, _, _ := GetSessionUser(c)
	division := getLiveDivision(c, userID)

	req, err := repository.GetNonInventoryByID(id)
	if err != nil {
		c.Redirect(http.StatusFound, "/non-inventory/validasi")
		return
	}

	approverStage := niApproverStage(role, req, division)
	if approverStage == 0 {
		c.Redirect(http.StatusFound, "/non-inventory/validasi")
		return
	}

	repository.ReleaseNonInventory(id, userID, approverStage)

	actionLabel := map[int]string{1: "SPV Pemohon", 2: "Admin SP", 3: "SPV SP"}
	repository.CreateActivityLog(&model.ActivityLog{
		UserID:     userID,
		Action:     "approve",
		EntityType: "non_inventory",
		EntityID:   id,
		Detail:     fmt.Sprintf("Disetujui oleh %s — %s", actionLabel[approverStage], req.NoBPJT),
	})

	switch approverStage {
	case 1:
		go service.NotifyAdminSP(id, req.NoBPJT, req.NamaPemohon)
		go service.NotifyPemohon(req.PemohonID, req.NoBPJT, "stage1")
	case 2:
		go service.NotifySPVSP(id, req.NoBPJT)
		go service.NotifyPemohon(req.PemohonID, req.NoBPJT, "stage2")
	case 3:
		go service.NotifyPemohon(req.PemohonID, req.NoBPJT, "approved")
	}
	c.Redirect(http.StatusFound, "/non-inventory/validasi")
}

func NICancel(c *gin.Context) {
	id, _ := strconv.Atoi(c.Param("id"))
	userID, role, _, _ := GetSessionUser(c)
	division := getLiveDivision(c, userID)

	req, err := repository.GetNonInventoryByID(id)
	if err != nil {
		c.Redirect(http.StatusFound, "/non-inventory/validasi")
		return
	}

	approverStage := niApproverStage(role, req, division)
	if approverStage == 0 {
		c.Redirect(http.StatusFound, "/non-inventory/validasi")
		return
	}

	repository.CancelNonInventory(id, userID, approverStage)
	actionLabel := map[int]string{1: "SPV Pemohon", 2: "Admin SP", 3: "SPV SP"}
	repository.CreateActivityLog(&model.ActivityLog{
		UserID:     userID,
		Action:     "cancel",
		EntityType: "non_inventory",
		EntityID:   id,
		Detail:     fmt.Sprintf("Dibatalkan oleh %s — %s", actionLabel[approverStage], req.NoBPJT),
	})

	go service.NotifyPemohon(req.PemohonID, req.NoBPJT, "rejected")
	c.Redirect(http.StatusFound, "/non-inventory/validasi")
}

func niApproverStage(role string, req *model.NonInventoryRequest, division string) int {
	switch role {
	case "spv_pemohon":
		if req.Status == "pending" && divisionContains(division, req.SeksiDivisi) {
			return 1
		}
	case "admin_sp":
		if req.Status == "stage1" {
			return 2
		}
	case "spv_sp":
		if req.Status == "stage2" {
			return 3
		}
		if req.Status == "pending" && division != "" && divisionContains(division, req.SeksiDivisi) {
			return 1
		}
	}
	return 0
}

func ShowNIValidasi(c *gin.Context) {
	userID, role, _, division := GetSessionUser(c)

	var requests []model.NonInventoryRequest
	var stageLabel string

	switch role {
	case "spv_pemohon":
		division = getLiveDivision(c, userID)
		requests, _ = repository.GetNonInventoryByStageAndDivision(division)
		stageLabel = "Menunggu Persetujuan Anda (SPV Pemohon)"
	case "admin_sp":
		requests, _ = repository.GetNonInventoryByStage(2)
		stageLabel = "Menunggu Persetujuan Anda (Admin SP)"
	case "spv_sp":
		division = getLiveDivision(c, userID)
		stage3, _ := repository.GetNonInventoryByStage(3)
		requests = stage3
		stageLabel = "Menunggu Persetujuan Anda (SPV SP)"
		if division != "" {
			pendingDiv, _ := repository.GetNonInventoryByStageAndDivision(division)
			requests = append(requests, pendingDiv...)
		}
	default:
		c.Redirect(http.StatusFound, "/dashboard")
		return
	}

	renderTemplate(c, "non_inventory/validasi_list.html", gin.H{
		"Title":      "Validasi Non-Inventory",
		"Requests":   requests,
		"StageLabel": stageLabel,
	})
}

func ShowNIRiwayat(c *gin.Context) {
	filter := repository.NIFilter{
		DateFrom: c.Query("date_from"),
		DateTo:   c.Query("date_to"),
		Divisi:   c.Query("divisi"),
	}

	requests, _ := repository.GetNonInventoryRiwayat(filter)

	renderTemplate(c, "non_inventory/riwayat.html", gin.H{
		"Title":    "Riwayat Non-Inventory",
		"Requests": requests,
		"Filter":   filter,
	})
}

// Download PDF

func NIDownloadPDF(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.String(http.StatusBadRequest, "ID tidak valid")
		return
	}

	req, err := repository.GetNonInventoryByID(id)
	if err != nil {
		c.String(http.StatusNotFound, "Permintaan tidak ditemukan")
		return
	}

	pdfBytes, err := generateNIPDF(req)
	if err != nil {
		c.String(http.StatusInternalServerError, "Gagal generate PDF: "+err.Error())
		return
	}

	filename := fmt.Sprintf("BPJT_%s.pdf", strings.ReplaceAll(req.NoBPJT, "/", "-"))
	c.Header("Content-Disposition", "attachment; filename="+filename)
	c.Data(http.StatusOK, "application/pdf", pdfBytes)
}

func ToggleNIDone(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "ID tidak valid"})
		return
	}

	var input struct {
		IsDone bool `json:"is_done"`
	}
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Payload tidak valid"})
		return
	}

	err = repository.ToggleNonInventoryDone(id, input.IsDone)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal update status"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"success": true, "is_done": input.IsDone})
}
