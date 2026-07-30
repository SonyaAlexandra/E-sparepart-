package handler

import (
	"net/http"
	"time"

	"github.com/gin-gonic/gin"

	"sparepart-mgmt/internal/model"
	"sparepart-mgmt/internal/repository"
)

func ShowLaporan(c *gin.Context) {
	fromStr := c.Query("from")
	toStr := c.Query("to")

	from := time.Now().AddDate(0, -1, 0)
	to := time.Now()

	if fromStr != "" {
		if t, err := time.Parse("2006-01-02", fromStr); err == nil {
			from = t
		}
	}
	if toStr != "" {
		if t, err := time.Parse("2006-01-02", toStr); err == nil {
			to = t.Add(23*time.Hour + 59*time.Minute) // end of day
		}
	}

	receivings, err := repository.GetStockReceivingsByPeriod(from, to)
	if err != nil {
		receivings = []model.StockReceiving{}
	}

	var totalValue float64
	for _, r := range receivings {
		totalValue += float64(r.Jumlah) * r.Harga
	}

	renderTemplate(c, "laporan/index.html", gin.H{
		"Title":      "Monitoring Sparepart",
		"Receivings": receivings,
		"TotalValue": totalValue,
		"FromDate":   from.Format("2006-01-02"),
		"ToDate":     to.Format("2006-01-02"),
	})
}

func ExportLaporanPDF(c *gin.Context) {
	fromStr := c.Query("from")
	toStr := c.Query("to")

	from := time.Now().AddDate(0, -1, 0)
	to := time.Now()

	if fromStr != "" {
		if t, err := time.Parse("2006-01-02", fromStr); err == nil {
			from = t
		}
	}
	if toStr != "" {
		if t, err := time.Parse("2006-01-02", toStr); err == nil {
			to = t.Add(23*time.Hour + 59*time.Minute)
		}
	}

	receivings, _ := repository.GetStockReceivingsByPeriod(from, to)

	var totalValue float64
	for _, r := range receivings {
		totalValue += float64(r.Jumlah) * r.Harga
	}

	pdfBytes, err := generateLaporanPDF(receivings, totalValue, from, to)
	if err != nil {
		c.String(http.StatusInternalServerError, "Gagal generate PDF: "+err.Error())
		return
	}

	c.Header("Content-Disposition", "attachment; filename=laporan.pdf")
	c.Data(http.StatusOK, "application/pdf", pdfBytes)
}

var entityLabels = map[string]string{
	"request":       "Request Pengambilan",
	"sparepart":     "Katalog Sparepart",
	"stock":         "Stok",
	"penerimaan":    "Penerimaan Stok",
	"validation":    "Validasi",
	"user":          "User",
	"non_inventory": "Non-Inventory",
}

func ShowLogAktivitas(c *gin.Context) {
	entityFilter := c.Query("entity")

	logs, err := repository.GetActivityLogsByEntity(entityFilter)
	if err != nil {
		logs = []model.ActivityLog{}
	}

	renderTemplate(c, "log/index.html", gin.H{
		"Title":        "Log Aktivitas",
		"Logs":         logs,
		"EntityFilter": entityFilter,
		"EntityLabels": entityLabels,
	})
}

func ShowNotifications(c *gin.Context) {
	userID, _, _, _ := GetSessionUser(c)
	notifs, _ := repository.GetUnreadNotifications(userID)

	repository.MarkNotificationsRead(userID)

	renderHTMX(c, "partials/notifications.html", gin.H{
		"Notifications": notifs,
	})
}
