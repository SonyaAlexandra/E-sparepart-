package handler

import (
	"fmt"
	"net/http"
	"regexp"
	"strconv"
	"strings"

	"github.com/gin-gonic/gin"

	"sparepart-mgmt/internal/model"
	"sparepart-mgmt/internal/repository"
	"sparepart-mgmt/internal/service"
)

func ShowPengambilanForm(c *gin.Context) {
	renderTemplate(c, "pengambilan/form.html", gin.H{
		"Title":     "Pengambilan Sparepart",
		"Divisions": []string{"MTC1", "MTC2", "UTL", "BM"},
	})
}

func ScanRFID(c *gin.Context) {
	rfid := strings.TrimSpace(c.PostForm("rfid_code"))
	if rfid == "" {
		c.String(http.StatusBadRequest, "Kode RFID kosong")
		return
	}

	sp, err := repository.GetSparepartByRFID(rfid)
	if err != nil {
		renderHTMX(c, "pengambilan/partials/rfid_not_found.html", gin.H{
			"RFID": rfid,
		})
		return
	}

	renderHTMX(c, "pengambilan/partials/item_row.html", gin.H{
		"Sparepart": sp,
		"Index":     c.PostForm("row_index"),
	})
}

func SubmitRequest(c *gin.Context) {
	userID, _, userName, division := GetSessionUser(c)

	noWRWO := strings.TrimSpace(c.PostForm("no_wr_wo"))
	requesterName := strings.TrimSpace(c.PostForm("requester_name"))
	requesterSource := c.PostForm("requester_source")
	divisionInput := c.PostForm("division")
	mesinArea := strings.TrimSpace(c.PostForm("mesin_area"))

	if !isValidWRWO(noWRWO) {
		renderTemplate(c, "pengambilan/form.html", gin.H{
			"Title":     "Pengambilan Sparepart",
			"Error":     "Format No WR/WO tidak valid. Gunakan: WO-BAD-311273 (WO) atau 237830 (WR 6 digit)",
			"Divisions": []string{"MTC1", "MTC2", "UTL", "BM"},
		})
		return
	}

	if requesterName == "" {
		requesterName = userName
	}
	if divisionInput != "" {
		division = divisionInput
	}

	sparepartIDs := c.PostFormArray("sparepart_id[]")
	jumlahArr := c.PostFormArray("jumlah[]")
	lokasiArr := c.PostFormArray("lokasi[]")

	if len(sparepartIDs) == 0 {
		renderTemplate(c, "pengambilan/form.html", gin.H{
			"Title":     "Pengambilan Sparepart",
			"Error":     "Minimal harus ada 1 item sparepart",
			"Divisions": []string{"MTC1", "MTC2", "UTL", "BM"},
		})
		return
	}

	req := &model.Request{
		NoWRWO:          noWRWO,
		PemohonID:       userID,
		RequesterName:   requesterName,
		RequesterSource: requesterSource,
		Division:        division,
		MesinArea:       mesinArea,
	}

	var items []model.RequestItem
	for i, sidStr := range sparepartIDs {
		sid, _ := strconv.Atoi(sidStr)
		jumlah := 1
		if i < len(jumlahArr) {
			jumlah, _ = strconv.Atoi(jumlahArr[i])
		}
		item := model.RequestItem{
			SparepartID: sid,
			Jumlah:      jumlah,
		}
		if i < len(lokasiArr) {
			item.NoBaki = lokasiArr[i]
		}
		items = append(items, item)
	}

	var warnings []string
	for i := range items {
		sp, err := repository.GetSparepartByID(items[i].SparepartID)
		if err != nil {
			continue
		}
		if sp.Stok == 0 {
			renderTemplate(c, "pengambilan/form.html", gin.H{
				"Title":     "Pengambilan Sparepart",
				"Error":     fmt.Sprintf(" Stok %s sudah habis (0). Tidak dapat direquest.", sp.NamaItem),
				"Divisions": []string{"MTC1", "MTC2", "UTL", "BM"},
			})
			return
		}
		if items[i].Jumlah > sp.Stok {
			warnings = append(warnings,
				fmt.Sprintf(" %s: stok hanya tersedia %d pcs. Jumlah disesuaikan menjadi %d.",
					sp.NamaItem, sp.Stok, sp.Stok))
			items[i].Jumlah = sp.Stok
		}
	}

	requestID, err := service.SubmitRequest(req, items)
	if err != nil {
		renderTemplate(c, "pengambilan/form.html", gin.H{
			"Title":     "Pengambilan Sparepart",
			"Error":     "Gagal mengirim request: " + err.Error(),
			"Divisions": []string{"MTC1", "MTC2", "UTL", "BM"},
		})
		return
	}

	_ = warnings
	c.Redirect(http.StatusFound, "/pengambilan/status/"+strconv.Itoa(requestID))
}

func ShowRequestStatus(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.Redirect(http.StatusFound, "/dashboard")
		return
	}

	req, err := repository.GetRequestByID(id)
	if err != nil {
		c.Redirect(http.StatusFound, "/dashboard")
		return
	}

	validations, _ := repository.GetValidationsByRequest(id)

	renderTemplate(c, "pengambilan/status.html", gin.H{
		"Title":       "Status Request " + req.NoWRWO,
		"Request":     req,
		"Validations": validations,
	})
}

func isValidWRWO(s string) bool {
	woPattern := regexp.MustCompile(`^[A-Za-z]{2}-[A-Za-z]{3}-\d{6}$`)
	wrPattern := regexp.MustCompile(`^\d{6}$`)
	return woPattern.MatchString(s) || wrPattern.MatchString(s)
}

