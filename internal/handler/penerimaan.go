package handler

import (
	"net/http"
	"strconv"
	"strings"
	"time"

	"github.com/gin-gonic/gin"

	"sparepart-mgmt/internal/model"
	"sparepart-mgmt/internal/repository"
	"sparepart-mgmt/internal/service"
)

func ShowPenerimaan(c *gin.Context) {
	fromStr := c.Query("from")
	toStr := c.Query("to")
	if fromStr == "" && toStr == "" {
		now := time.Now()
		defaultFrom := time.Date(now.Year(), now.Month(), 1, 0, 0, 0, 0, time.Local)
		defaultTo := defaultFrom.AddDate(0, 1, -1)
		fromStr = defaultFrom.Format("2006-01-02")
		toStr = defaultTo.Format("2006-01-02")
		toastRedirect := "/penerimaan?from=" + fromStr + "&to=" + toStr
		if toast := c.Query("toast"); toast != "" {
			toastRedirect += "&toast=" + toast
		}
		c.Redirect(http.StatusFound, toastRedirect)
		return
	}

	from, to := parseDateRange(c)

	var receivings []model.StockReceiving
	var err error
	if from.IsZero() || to.IsZero() {
		receivings, err = repository.GetAllStockReceivings()
	} else {
		receivings, err = repository.GetStockReceivingsByPeriod(from, to)
	}
	if err != nil {
		receivings = []model.StockReceiving{}
	}

	spareparts, _ := repository.GetAllSpareparts("", "")

	var totalValue float64
	for _, r := range receivings {
		if r.Tipe == "tambah" {
			totalValue += r.Harga * float64(r.Jumlah)
		}
	}

	renderTemplate(c, "penerimaan/index.html", gin.H{
		"Title":      "Penerimaan Stok",
		"Receivings": receivings,
		"Spareparts": spareparts,
		"FromDate":   fromStr,
		"ToDate":     toStr,
		"TotalValue": totalValue,
	})
}

func SavePenerimaan(c *gin.Context) {
	userID, _, _, _ := GetSessionUser(c)

	sparepartID, _ := strconv.Atoi(c.PostForm("sparepart_id"))
	jumlah, _ := strconv.Atoi(c.PostForm("jumlah"))
	harga, _ := strconv.ParseFloat(c.PostForm("harga"), 64)
	tipe := c.PostForm("tipe") // tambah | retur
	namaItem := strings.TrimSpace(c.PostForm("nama_item"))
	kodeOracle := strings.TrimSpace(c.PostForm("kode_oracle"))
	deskripsi := strings.TrimSpace(c.PostForm("deskripsi"))

	if sparepartID > 0 {
		sp, err := repository.GetSparepartByID(sparepartID)
		if err == nil {
			changed := false
			if namaItem != "" && namaItem != sp.NamaItem {
				sp.NamaItem = namaItem
				changed = true
			}
			if kodeOracle != "" && kodeOracle != sp.KodeOracle {
				sp.KodeOracle = kodeOracle
				changed = true
			}
			if deskripsi != "" && deskripsi != sp.Deskripsi {
				sp.Deskripsi = deskripsi
				changed = true
			}
			if harga > 0 && harga != sp.Harga {
				sp.Harga = harga
				changed = true
			}
			if changed {
				repository.UpdateSparepart(sp)
			}
		}
	} else if namaItem != "" {
		if kodeOracle == "" {
			kodeOracle = "MANUAL-" + strconv.FormatInt(time.Now().UnixNano(), 36)
		}
		newSp := &model.Sparepart{
			NamaItem:   namaItem,
			KodeOracle: kodeOracle,
			Deskripsi:  deskripsi,
			Harga:      harga,
		}
		newID, createErr := repository.CreateSparepartReturningID(newSp)
		if createErr == nil {
			sparepartID = newID
		}
	}

	sr := &model.StockReceiving{
		SparepartID: sparepartID,
		NoPO:        c.PostForm("no_po"),
		Vendor:      c.PostForm("vendor"),
		Jumlah:      jumlah,
		Harga:       harga,
		Tipe:        tipe,
		Keterangan:  c.PostForm("keterangan"),
		ReceivedBy:  userID,

		NamaItem:   namaItem,
		KodeOracle: kodeOracle,
	}

	if err := repository.CreateStockReceiving(sr); err != nil {
		c.Redirect(http.StatusFound, "/penerimaan?toast=error")
		return
	}

	if sparepartID > 0 {
		if tipe == "tambah" || tipe == "retur" {
			repository.AddStock(sparepartID, jumlah)
		}
	}

	service.LogActivity(userID, "penerimaan", "penerimaan", sparepartID,
		"Penerimaan stok ("+tipe+"): "+strconv.Itoa(jumlah)+" unit — "+namaItem)

	toastParam := "tambah_success"
	if tipe == "retur" {
		toastParam = "retur_success"
	}
	c.Redirect(http.StatusFound, "/penerimaan?toast="+toastParam)
}
