package handler

import (
	"net/http"
	"strconv"
	"strings"

	"github.com/gin-gonic/gin"

	"sparepart-mgmt/internal/repository"
	"sparepart-mgmt/internal/service"
)

func ShowValidasiList(c *gin.Context) {
	userID, role, _, division := GetSessionUser(c)

	var requests interface{}

	switch role {
	case "admin_sp":
		requests, _ = repository.GetRequestsByStage(1)
		renderTemplate(c, "validasi/list.html", gin.H{
			"Title":    "Validasi Pengambilan",
			"Requests": requests,
			"Stage":    1,
		})

	case "spv_pemohon":
		// Read fresh division from DB so changes by admin are reflected immediately.
		division = getLiveDivision(c, userID)
		requests, _ = repository.GetRequestsByStageAndDivision(2, division)
		renderTemplate(c, "validasi/list.html", gin.H{
			"Title":    "Validasi Pengambilan",
			"Requests": requests,
			"Stage":    2,
		})

	case "spv_sp":
		// Read fresh division from DB so changes by admin are reflected immediately.
		division = getLiveDivision(c, userID)
		requests, _ = repository.GetRequestsByStageForSPVSP(division)
		renderTemplate(c, "validasi/list.html", gin.H{
			"Title":    "Validasi Pengambilan",
			"Requests": requests,
			"Stage":    0,
		})

	default:
		c.Redirect(http.StatusFound, "/dashboard")
	}
}

func ShowValidasiDetail(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.Redirect(http.StatusFound, "/validasi")
		return
	}

	req, err := repository.GetRequestByID(id)
	if err != nil {
		c.Redirect(http.StatusFound, "/validasi")
		return
	}

	validations, _ := repository.GetValidationsByRequest(id)
	_, role, _, _ := GetSessionUser(c)

	renderTemplate(c, "validasi/detail.html", gin.H{
		"Title":       "Detail Request " + req.NoWRWO,
		"Request":     req,
		"Validations": validations,
		"UserRole":    role,
	})
}

func DoApprove(c *gin.Context) {
	id, _ := strconv.Atoi(c.Param("id"))
	userID, role, _, _ := GetSessionUser(c)

	req, err := repository.GetRequestByID(id)
	if err != nil {
		c.Redirect(http.StatusFound, "/validasi")
		return
	}

	if req.Status == "approved" || req.Status == "rejected" {
		c.Redirect(http.StatusFound, "/validasi")
		return
	}

	itemIDs := c.PostFormArray("item_id[]")
	jumlahArr := c.PostFormArray("jumlah_disetujui[]")
	for i, itemIDStr := range itemIDs {
		itemID, _ := strconv.Atoi(itemIDStr)
		if i < len(jumlahArr) {
			qty, _ := strconv.Atoi(jumlahArr[i])
			if qty > 0 {
				item, itemErr := repository.GetRequestItemByID(itemID)
				if itemErr == nil && item.SparepartID > 0 {
					sp, spErr := repository.GetSparepartByID(item.SparepartID)
					if spErr == nil && qty > sp.Stok {
						validations, _ := repository.GetValidationsByRequest(id)
						renderTemplate(c, "validasi/detail.html", gin.H{
							"Title":       "Detail Request " + req.NoWRWO,
							"Request":     req,
							"Validations": validations,
							"Error":       "Stok tidak mencukupi. Stok tersedia hanya " + strconv.Itoa(sp.Stok) + " pcs untuk " + sp.NamaItem + ".",
							"UserRole":    role,
						})
						return
					}
				}
			}
			repository.UpdateRequestItemQty(itemID, qty)
		}
	}

	// SPV SP has dual role: Stage 2 for their division(s), Stage 3 for all others.
	var svcErr error
	switch role {
	case "admin_sp":
		svcErr = service.ApproveStage1(id, userID, req.NoWRWO, req.Division)
	case "spv_pemohon":
		svcErr = service.ApproveStage2(id, userID, req.NoWRWO)
	case "spv_sp":
		_, _, _, spvDivision := GetSessionUser(c)
		// spvDivision may be "MTC1,MTC2" — check if req.Division is in that list
		if req.CurrentStage == 2 && spvDivision != "" && divisionContains(spvDivision, req.Division) {
			svcErr = service.ApproveStage2(id, userID, req.NoWRWO)
		} else if req.CurrentStage == 3 {
			svcErr = service.ApproveStage3(id, userID, req.NoWRWO)
		} else {
			validations, _ := repository.GetValidationsByRequest(id)
			renderTemplate(c, "validasi/detail.html", gin.H{
				"Title":       "Detail Request " + req.NoWRWO,
				"Request":     req,
				"Validations": validations,
				"Error":       "Tidak dapat memvalidasi request ini: stage atau divisi tidak sesuai.",
				"UserRole":    role,
			})
			return
		}
	}

	if svcErr != nil {
		validations, _ := repository.GetValidationsByRequest(id)
		renderTemplate(c, "validasi/detail.html", gin.H{
			"Title":       "Detail Request",
			"Request":     req,
			"Validations": validations,
			"Error":       "Gagal menyetujui: " + svcErr.Error(),
			"UserRole":    role,
		})
		return
	}

	c.Redirect(http.StatusFound, "/validasi")
}

func DoReject(c *gin.Context) {
	id, _ := strconv.Atoi(c.Param("id"))
	userID, role, _, _ := GetSessionUser(c)
	reason := c.PostForm("reason")

	req, err := repository.GetRequestByID(id)
	if err != nil {
		c.Redirect(http.StatusFound, "/validasi")
		return
	}

	// SPV SP rejects at whichever stage the request is currently at.
	var stage int
	switch role {
	case "admin_sp":
		stage = 1
	case "spv_pemohon":
		stage = 2
	case "spv_sp":
		stage = req.CurrentStage
	}

	service.RejectRequest(id, userID, stage, req.NoWRWO, reason)
	c.Redirect(http.StatusFound, "/validasi")
}

// ShowAllRequestDetail shows a single request in read-only mode (Riwayat Pengambilan menu).
func ShowAllRequestDetail(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.Redirect(http.StatusFound, "/pengambilan/semua")
		return
	}

	req, err := repository.GetRequestByID(id)
	if err != nil {
		c.Redirect(http.StatusFound, "/pengambilan/semua")
		return
	}

	validations, _ := repository.GetValidationsByRequest(id)
	_, role, _, _ := GetSessionUser(c)

	renderTemplate(c, "validasi/all_requests_detail.html", gin.H{
		"Title":       "Detail Request " + req.NoWRWO,
		"Request":     req,
		"Validations": validations,
		"UserRole":    role,
	})
}

func ShowAllRequests(c *gin.Context) {
	from, to := parseDateRange(c)
	userID, role, _, _ := GetSessionUser(c)

	var requests interface{}
	if role == "pemohon" {
		if !from.IsZero() && !to.IsZero() {
			requests, _ = repository.GetRequestsByPemohonByPeriod(userID, from, to)
		} else {
			requests, _ = repository.GetRequestsByPemohon(userID)
		}
	} else if from.IsZero() || to.IsZero() {
		requests, _ = repository.GetAllRequests()
	} else {
		requests, _ = repository.GetAllRequestsByPeriod(from, to)
	}

	renderTemplate(c, "validasi/all_requests.html", gin.H{
		"Title":    "Riwayat Pengambilan",
		"Requests": requests,
		"FromDate": c.Query("from"),
		"ToDate":   c.Query("to"),
		"UserRole": role,
	})
}

func UpdateItemQty(c *gin.Context) {
	itemID, _ := strconv.Atoi(c.Param("id"))
	qty, _ := strconv.Atoi(c.PostForm("qty"))

	if qty < 1 {
		qty = 1
	}

	item, err := repository.GetRequestItemByID(itemID)
	if err == nil && item.SparepartID > 0 {
		sp, err := repository.GetSparepartByID(item.SparepartID)
		if err == nil && qty > sp.Stok {
			c.Header("HX-Trigger", `{"showStockError":"`+strconv.Itoa(sp.Stok)+`"}`)
			c.String(http.StatusOK, strconv.Itoa(sp.Stok))
			return
		}
	}

	repository.UpdateRequestItemQty(itemID, qty)
	c.String(http.StatusOK, strconv.Itoa(qty))
}

func DeleteItem(c *gin.Context) {
	itemID, _ := strconv.Atoi(c.Param("id"))
	repository.DeleteRequestItem(itemID)
	c.Status(http.StatusOK)
}

func DownloadStrukPDF(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.String(http.StatusBadRequest, "ID tidak valid")
		return
	}

	req, err := repository.GetRequestByID(id)
	if err != nil {
		c.String(http.StatusNotFound, "Request tidak ditemukan")
		return
	}

	if req.Status != "approved" {
		c.String(http.StatusForbidden, "Struk hanya tersedia setelah request disetujui penuh")
		return
	}

	validations, _ := repository.GetValidationsByRequest(id)

	pdfBytes, err := generateStrukPDF(req, validations)
	if err != nil {
		c.String(http.StatusInternalServerError, "Gagal generate PDF: "+err.Error())
		return
	}

	filename := "struk-" + req.NoWRWO + ".pdf"
	c.Header("Content-Disposition", "attachment; filename="+filename)
	c.Data(http.StatusOK, "application/pdf", pdfBytes)
}

// divisionContains checks if `needle` is present in a comma-separated `haystack`.
// e.g. divisionContains("MTC1,MTC2", "MTC2") → true
func divisionContains(haystack, needle string) bool {
	for _, d := range strings.Split(haystack, ",") {
		if strings.TrimSpace(d) == strings.TrimSpace(needle) {
			return true
		}
	}
	return false
}
