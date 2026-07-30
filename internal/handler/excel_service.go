package handler

import (
	"fmt"
	"net/http"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/xuri/excelize/v2"

	"sparepart-mgmt/internal/model"
	"sparepart-mgmt/internal/repository"
)

// Export: Semua Request Pengambilan → XLSX
func ExportAllRequestsExcel(c *gin.Context) {
	from, to := parseDateRange(c)
	userID, role, _, _ := GetSessionUser(c)

	var requests []model.Request
	var err error

	if role == "pemohon" {
		if !from.IsZero() && !to.IsZero() {
			requests, err = repository.GetRequestsByPemohonByPeriod(userID, from, to)
		} else {
			requests, err = repository.GetRequestsByPemohon(userID)
		}
	} else if from.IsZero() || to.IsZero() {
		requests, err = repository.GetAllRequests()
	} else {
		requests, err = repository.GetAllRequestsByPeriod(from, to)
	}
	if err != nil {
		c.String(http.StatusInternalServerError, "Gagal mengambil data: "+err.Error())
		return
	}

	f := excelize.NewFile()
	defer f.Close()
	sheet := "Request Pengambilan"
	f.SetSheetName("Sheet1", sheet)

	titleStyle, _ := f.NewStyle(&excelize.Style{
		Font: &excelize.Font{Bold: true, Size: 13, Color: "0B2D59"},
	})
	metaStyle, _ := f.NewStyle(&excelize.Style{
		Font: &excelize.Font{Size: 10, Color: "555555"},
	})
	headerStyle, _ := f.NewStyle(&excelize.Style{
		Font:      &excelize.Font{Bold: true, Color: "FFFFFF", Size: 10},
		Fill:      excelize.Fill{Type: "pattern", Color: []string{"568C20"}, Pattern: 1},
		Alignment: &excelize.Alignment{Horizontal: "center", Vertical: "center", WrapText: true},
		Border: []excelize.Border{
			{Type: "left", Color: "FFFFFF", Style: 1},
			{Type: "right", Color: "FFFFFF", Style: 1},
			{Type: "bottom", Color: "FFFFFF", Style: 1},
		},
	})
	dataStyle, _ := f.NewStyle(&excelize.Style{
		Font:      &excelize.Font{Size: 10},
		Alignment: &excelize.Alignment{Vertical: "center"},
		Border: []excelize.Border{
			{Type: "left", Color: "DDDDDD", Style: 1},
			{Type: "right", Color: "DDDDDD", Style: 1},
			{Type: "bottom", Color: "DDDDDD", Style: 1},
		},
	})
	dataCenterStyle, _ := f.NewStyle(&excelize.Style{
		Font:      &excelize.Font{Size: 10},
		Alignment: &excelize.Alignment{Horizontal: "center", Vertical: "center"},
		Border: []excelize.Border{
			{Type: "left", Color: "DDDDDD", Style: 1},
			{Type: "right", Color: "DDDDDD", Style: 1},
			{Type: "bottom", Color: "DDDDDD", Style: 1},
		},
	})
	totalStyle, _ := f.NewStyle(&excelize.Style{
		Font:      &excelize.Font{Bold: true, Size: 10, Color: "0B2D59"},
		Fill:      excelize.Fill{Type: "pattern", Color: []string{"EAF4D8"}, Pattern: 1},
		Alignment: &excelize.Alignment{Vertical: "center"},
		Border: []excelize.Border{
			{Type: "top", Color: "568C20", Style: 2},
			{Type: "bottom", Color: "568C20", Style: 1},
		},
	})

	f.SetColWidth(sheet, "A", "A", 5)
	f.SetColWidth(sheet, "B", "B", 20)
	f.SetColWidth(sheet, "C", "C", 22)
	f.SetColWidth(sheet, "D", "D", 18)
	f.SetColWidth(sheet, "E", "E", 22)
	f.SetColWidth(sheet, "F", "F", 18)
	f.SetColWidth(sheet, "G", "G", 20)

	f.MergeCell(sheet, "A1", "G1")
	f.SetCellValue(sheet, "A1", "LAPORAN SEMUA REQUEST PENGAMBILAN SPAREPART")
	f.SetCellStyle(sheet, "A1", "G1", titleStyle)
	f.SetRowHeight(sheet, 1, 22)

	f.SetCellValue(sheet, "A2", "Periode")
	f.SetCellValue(sheet, "B2", formatPeriod(from, to))
	f.SetCellStyle(sheet, "A2", "G2", metaStyle)

	f.SetCellValue(sheet, "A3", "Dicetak")
	f.SetCellValue(sheet, "B3", time.Now().Format("02 January 2006 15:04"))
	f.SetCellStyle(sheet, "A3", "G3", metaStyle)

	headers := []string{"No", "No WR/WO", "Pemohon", "Divisi", "Tanggal Pengajuan", "Status", "Progress (Tahap)"}
	for i, h := range headers {
		col, _ := excelize.ColumnNumberToName(i + 1)
		f.SetCellValue(sheet, col+"5", h)
		f.SetCellStyle(sheet, col+"5", col+"5", headerStyle)
	}
	f.SetRowHeight(sheet, 5, 18)

	for i, r := range requests {
		row := strconv.Itoa(i + 6)
		f.SetCellValue(sheet, "A"+row, i+1)
		f.SetCellValue(sheet, "B"+row, r.NoWRWO)
		f.SetCellValue(sheet, "C"+row, r.RequesterName)
		f.SetCellValue(sheet, "D"+row, r.Division)
		f.SetCellValue(sheet, "E"+row, r.SubmittedAt.Format("02/01/2006 15:04"))
		f.SetCellValue(sheet, "F"+row, statusLabelGo(r.Status))
		f.SetCellValue(sheet, "G"+row, "Tahap "+strconv.Itoa(r.CurrentStage))

		f.SetCellStyle(sheet, "A"+row, "A"+row, dataCenterStyle)
		f.SetCellStyle(sheet, "B"+row, "G"+row, dataStyle)
		f.SetCellStyle(sheet, "G"+row, "G"+row, dataCenterStyle)
		f.SetRowHeight(sheet, i+6, 16)
	}

	totalRow := strconv.Itoa(len(requests) + 7)
	f.MergeCell(sheet, "A"+totalRow, "F"+totalRow)
	f.SetCellValue(sheet, "A"+totalRow, "Total Request")
	f.SetCellValue(sheet, "G"+totalRow, len(requests))
	f.SetCellStyle(sheet, "A"+totalRow, "G"+totalRow, totalStyle)

	f.SetPanes(sheet, &excelize.Panes{
		Freeze:      true,
		Split:       false,
		XSplit:      0,
		YSplit:      5,
		TopLeftCell: "A6",
		ActivePane:  "bottomLeft",
	})

	filename := fmt.Sprintf("request-pengambilan-%s.xlsx", time.Now().Format("20060102"))
	c.Header("Content-Disposition", "attachment; filename="+filename)
	c.Header("Content-Type", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
	if err := f.Write(c.Writer); err != nil {
		c.String(http.StatusInternalServerError, "Gagal menulis Excel: "+err.Error())
	}
}

// Export: Penerimaan Stok → XLSX
func ExportPenerimaanExcel(c *gin.Context) {
	from, to := parseDateRange(c)

	var receivings []model.StockReceiving
	var err error
	if from.IsZero() || to.IsZero() {
		receivings, err = repository.GetAllStockReceivings()
	} else {
		receivings, err = repository.GetStockReceivingsByPeriod(from, to)
	}
	if err != nil {
		c.String(http.StatusInternalServerError, "Gagal mengambil data: "+err.Error())
		return
	}

	f := excelize.NewFile()
	defer f.Close()
	sheet := "Penerimaan Stok"
	f.SetSheetName("Sheet1", sheet)

	// Styles
	titleStyle, _ := f.NewStyle(&excelize.Style{
		Font: &excelize.Font{Bold: true, Size: 13, Color: "0B2D59"},
	})
	metaStyle, _ := f.NewStyle(&excelize.Style{
		Font: &excelize.Font{Size: 10, Color: "555555"},
	})
	headerStyle, _ := f.NewStyle(&excelize.Style{
		Font:      &excelize.Font{Bold: true, Color: "FFFFFF", Size: 10},
		Fill:      excelize.Fill{Type: "pattern", Color: []string{"568C20"}, Pattern: 1},
		Alignment: &excelize.Alignment{Horizontal: "center", Vertical: "center", WrapText: true},
		Border: []excelize.Border{
			{Type: "left", Color: "FFFFFF", Style: 1},
			{Type: "right", Color: "FFFFFF", Style: 1},
			{Type: "bottom", Color: "FFFFFF", Style: 1},
		},
	})
	dataStyle, _ := f.NewStyle(&excelize.Style{
		Font:      &excelize.Font{Size: 10},
		Alignment: &excelize.Alignment{Vertical: "center"},
		Border: []excelize.Border{
			{Type: "left", Color: "DDDDDD", Style: 1},
			{Type: "right", Color: "DDDDDD", Style: 1},
			{Type: "bottom", Color: "DDDDDD", Style: 1},
		},
	})
	dataCenterStyle, _ := f.NewStyle(&excelize.Style{
		Font:      &excelize.Font{Size: 10},
		Alignment: &excelize.Alignment{Horizontal: "center", Vertical: "center"},
		Border: []excelize.Border{
			{Type: "left", Color: "DDDDDD", Style: 1},
			{Type: "right", Color: "DDDDDD", Style: 1},
			{Type: "bottom", Color: "DDDDDD", Style: 1},
		},
	})
	dataRightStyle, _ := f.NewStyle(&excelize.Style{
		Font:      &excelize.Font{Size: 10},
		Alignment: &excelize.Alignment{Horizontal: "right", Vertical: "center"},
		Border: []excelize.Border{
			{Type: "left", Color: "DDDDDD", Style: 1},
			{Type: "right", Color: "DDDDDD", Style: 1},
			{Type: "bottom", Color: "DDDDDD", Style: 1},
		},
		NumFmt: 3,
	})
	totalStyle, _ := f.NewStyle(&excelize.Style{
		Font:      &excelize.Font{Bold: true, Size: 10, Color: "0B2D59"},
		Fill:      excelize.Fill{Type: "pattern", Color: []string{"EAF4D8"}, Pattern: 1},
		Alignment: &excelize.Alignment{Horizontal: "center", Vertical: "center"},
		Border: []excelize.Border{
			{Type: "top", Color: "568C20", Style: 2},
			{Type: "bottom", Color: "568C20", Style: 1},
		},
	})
	totalRightStyle, _ := f.NewStyle(&excelize.Style{
		Font:      &excelize.Font{Bold: true, Size: 10, Color: "0B2D59"},
		Fill:      excelize.Fill{Type: "pattern", Color: []string{"EAF4D8"}, Pattern: 1},
		Alignment: &excelize.Alignment{Horizontal: "right", Vertical: "center"},
		Border: []excelize.Border{
			{Type: "top", Color: "568C20", Style: 2},
			{Type: "bottom", Color: "568C20", Style: 1},
		},
		NumFmt: 3,
	})

	f.SetColWidth(sheet, "A", "A", 5)
	f.SetColWidth(sheet, "B", "B", 14)
	f.SetColWidth(sheet, "C", "C", 18)
	f.SetColWidth(sheet, "D", "D", 16)
	f.SetColWidth(sheet, "E", "E", 28)
	f.SetColWidth(sheet, "F", "F", 20)
	f.SetColWidth(sheet, "G", "G", 8)
	f.SetColWidth(sheet, "H", "H", 16)
	f.SetColWidth(sheet, "I", "I", 16)
	f.SetColWidth(sheet, "J", "J", 10)
	f.SetColWidth(sheet, "K", "K", 25)

	f.MergeCell(sheet, "A1", "K1")
	f.SetCellValue(sheet, "A1", "LAPORAN PENERIMAAN STOK SPAREPART")
	f.SetCellStyle(sheet, "A1", "K1", titleStyle)
	f.SetRowHeight(sheet, 1, 22)

	f.SetCellValue(sheet, "A2", "Periode")
	f.SetCellValue(sheet, "B2", formatPeriod(from, to))
	f.SetCellStyle(sheet, "A2", "K2", metaStyle)

	f.SetCellValue(sheet, "A3", "Dicetak")
	f.SetCellValue(sheet, "B3", time.Now().Format("02 January 2006 15:04"))
	f.SetCellStyle(sheet, "A3", "K3", metaStyle)

	headers := []string{
		"No", "Tanggal", "No PO", "Kode Oracle", "Nama Sparepart",
		"Vendor", "Qty", "Harga Satuan", "Nilai Total", "Tipe", "Keterangan",
	}
	for i, h := range headers {
		col, _ := excelize.ColumnNumberToName(i + 1)
		f.SetCellValue(sheet, col+"5", h)
		f.SetCellStyle(sheet, col+"5", col+"5", headerStyle)
	}
	f.SetRowHeight(sheet, 5, 18)

	var totalQty int
	var totalNilai float64

	for i, r := range receivings {
		nilai := float64(r.Jumlah) * r.Harga
		totalQty += r.Jumlah
		totalNilai += nilai

		row := strconv.Itoa(i + 6)
		f.SetCellValue(sheet, "A"+row, i+1)
		f.SetCellValue(sheet, "B"+row, r.ReceivedAt.Format("02/01/2006"))
		f.SetCellValue(sheet, "C"+row, r.NoPO)
		f.SetCellValue(sheet, "D"+row, r.KodeOracle)
		f.SetCellValue(sheet, "E"+row, r.NamaItem)
		f.SetCellValue(sheet, "F"+row, r.Vendor)
		f.SetCellValue(sheet, "G"+row, r.Jumlah)
		f.SetCellValue(sheet, "H"+row, r.Harga)
		f.SetCellValue(sheet, "I"+row, nilai)
		f.SetCellValue(sheet, "J"+row, r.Tipe)
		f.SetCellValue(sheet, "K"+row, r.Keterangan)

		f.SetCellStyle(sheet, "A"+row, "A"+row, dataCenterStyle)
		f.SetCellStyle(sheet, "B"+row, "F"+row, dataStyle)
		f.SetCellStyle(sheet, "G"+row, "G"+row, dataCenterStyle)
		f.SetCellStyle(sheet, "H"+row, "I"+row, dataRightStyle)
		f.SetCellStyle(sheet, "J"+row, "J"+row, dataCenterStyle)
		f.SetCellStyle(sheet, "K"+row, "K"+row, dataStyle)
		f.SetRowHeight(sheet, i+6, 16)
	}

	totalRow := strconv.Itoa(len(receivings) + 7)
	f.MergeCell(sheet, "A"+totalRow, "F"+totalRow)
	f.SetCellValue(sheet, "A"+totalRow, "TOTAL")
	f.SetCellValue(sheet, "G"+totalRow, totalQty)
	f.SetCellValue(sheet, "H"+totalRow, "")
	f.SetCellValue(sheet, "I"+totalRow, totalNilai)
	f.SetCellStyle(sheet, "A"+totalRow, "H"+totalRow, totalStyle)
	f.SetCellStyle(sheet, "I"+totalRow, "I"+totalRow, totalRightStyle)
	f.SetCellStyle(sheet, "J"+totalRow, "K"+totalRow, totalStyle)

	f.SetPanes(sheet, &excelize.Panes{
		Freeze:      true,
		Split:       false,
		XSplit:      0,
		YSplit:      5,
		TopLeftCell: "A6",
		ActivePane:  "bottomLeft",
	})

	filename := fmt.Sprintf("penerimaan-stok-%s.xlsx", time.Now().Format("20060102"))
	c.Header("Content-Disposition", "attachment; filename="+filename)
	c.Header("Content-Type", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
	if err := f.Write(c.Writer); err != nil {
		c.String(http.StatusInternalServerError, "Gagal menulis Excel: "+err.Error())
	}
}

// Export: Monitoring Sparepart (Laporan) → XLSX

func ExportLaporanExcel(c *gin.Context) {
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
			to = t.Add(23*time.Hour + 59*time.Minute + 59*time.Second)
		}
	}

	receivings, err := repository.GetStockReceivingsByPeriod(from, to)
	if err != nil {
		c.String(http.StatusInternalServerError, "Gagal mengambil data: "+err.Error())
		return
	}

	var totalValue float64
	var totalQty int
	for _, r := range receivings {
		totalValue += float64(r.Jumlah) * r.Harga
		totalQty += r.Jumlah
	}

	f := excelize.NewFile()
	defer f.Close()
	sheet := "Monitoring Sparepart"
	f.SetSheetName("Sheet1", sheet)

	// Styles
	titleStyle, _ := f.NewStyle(&excelize.Style{
		Font:      &excelize.Font{Bold: true, Size: 14, Color: "0B2D59"},
		Alignment: &excelize.Alignment{Horizontal: "center"},
	})
	metaStyle, _ := f.NewStyle(&excelize.Style{
		Font:      &excelize.Font{Size: 10, Color: "555555"},
		Alignment: &excelize.Alignment{Horizontal: "center"},
	})
	headerStyle, _ := f.NewStyle(&excelize.Style{
		Font:      &excelize.Font{Bold: true, Color: "FFFFFF", Size: 10},
		Fill:      excelize.Fill{Type: "pattern", Color: []string{"568C20"}, Pattern: 1},
		Alignment: &excelize.Alignment{Horizontal: "center", Vertical: "center", WrapText: true},
		Border: []excelize.Border{
			{Type: "left", Color: "FFFFFF", Style: 1},
			{Type: "right", Color: "FFFFFF", Style: 1},
			{Type: "bottom", Color: "FFFFFF", Style: 1},
		},
	})
	dataStyle, _ := f.NewStyle(&excelize.Style{
		Font:      &excelize.Font{Size: 10},
		Alignment: &excelize.Alignment{Vertical: "center"},
		Border: []excelize.Border{
			{Type: "left", Color: "DDDDDD", Style: 1},
			{Type: "right", Color: "DDDDDD", Style: 1},
			{Type: "bottom", Color: "DDDDDD", Style: 1},
		},
	})
	dataCenterStyle, _ := f.NewStyle(&excelize.Style{
		Font:      &excelize.Font{Size: 10},
		Alignment: &excelize.Alignment{Horizontal: "center", Vertical: "center"},
		Border: []excelize.Border{
			{Type: "left", Color: "DDDDDD", Style: 1},
			{Type: "right", Color: "DDDDDD", Style: 1},
			{Type: "bottom", Color: "DDDDDD", Style: 1},
		},
	})
	dataRightStyle, _ := f.NewStyle(&excelize.Style{
		Font:      &excelize.Font{Size: 10},
		Alignment: &excelize.Alignment{Horizontal: "right", Vertical: "center"},
		Border: []excelize.Border{
			{Type: "left", Color: "DDDDDD", Style: 1},
			{Type: "right", Color: "DDDDDD", Style: 1},
			{Type: "bottom", Color: "DDDDDD", Style: 1},
		},
		NumFmt: 3,
	})
	totalStyle, _ := f.NewStyle(&excelize.Style{
		Font:      &excelize.Font{Bold: true, Size: 10, Color: "0B2D59"},
		Fill:      excelize.Fill{Type: "pattern", Color: []string{"EAF4D8"}, Pattern: 1},
		Alignment: &excelize.Alignment{Horizontal: "right", Vertical: "center"},
		Border: []excelize.Border{
			{Type: "top", Color: "568C20", Style: 2},
			{Type: "bottom", Color: "568C20", Style: 1},
		},
	})
	totalRightStyle, _ := f.NewStyle(&excelize.Style{
		Font:      &excelize.Font{Bold: true, Size: 10, Color: "0B2D59"},
		Fill:      excelize.Fill{Type: "pattern", Color: []string{"EAF4D8"}, Pattern: 1},
		Alignment: &excelize.Alignment{Horizontal: "right", Vertical: "center"},
		Border: []excelize.Border{
			{Type: "top", Color: "568C20", Style: 2},
			{Type: "bottom", Color: "568C20", Style: 1},
		},
		NumFmt: 3,
	})

	f.SetColWidth(sheet, "A", "A", 5)
	f.SetColWidth(sheet, "B", "B", 18)
	f.SetColWidth(sheet, "C", "C", 16)
	f.SetColWidth(sheet, "D", "D", 28)
	f.SetColWidth(sheet, "E", "E", 8)
	f.SetColWidth(sheet, "F", "F", 18)
	f.SetColWidth(sheet, "G", "G", 18)
	f.SetColWidth(sheet, "H", "H", 10)
	f.SetColWidth(sheet, "I", "I", 16)

	f.MergeCell(sheet, "A1", "I1")
	f.SetCellValue(sheet, "A1", "LAPORAN TRANSAKSI SPAREPART")
	f.SetCellStyle(sheet, "A1", "I1", titleStyle)
	f.SetRowHeight(sheet, 1, 24)

	f.MergeCell(sheet, "A2", "I2")
	f.SetCellValue(sheet, "A2", "Periode: "+from.Format("02 Jan 2006")+" s/d "+to.Format("02 Jan 2006"))
	f.SetCellStyle(sheet, "A2", "I2", metaStyle)

	f.MergeCell(sheet, "A3", "I3")
	f.SetCellValue(sheet, "A3", "Dicetak: "+time.Now().Format("02 January 2006 15:04"))
	f.SetCellStyle(sheet, "A3", "I3", metaStyle)

	headers := []string{"No", "No PO", "Kode Oracle", "Deskripsi Item", "Qty", "Harga Satuan", "Nilai Transaksi", "Tipe", "Tanggal Transaksi"}
	for i, h := range headers {
		col, _ := excelize.ColumnNumberToName(i + 1)
		f.SetCellValue(sheet, col+"5", h)
		f.SetCellStyle(sheet, col+"5", col+"5", headerStyle)
	}
	f.SetRowHeight(sheet, 5, 18)

	for i, r := range receivings {
		nilai := float64(r.Jumlah) * r.Harga
		row := strconv.Itoa(i + 6)

		f.SetCellValue(sheet, "A"+row, i+1)
		f.SetCellValue(sheet, "B"+row, r.NoPO)
		f.SetCellValue(sheet, "C"+row, r.KodeOracle)
		f.SetCellValue(sheet, "D"+row, r.NamaItem)
		f.SetCellValue(sheet, "E"+row, r.Jumlah)
		f.SetCellValue(sheet, "F"+row, r.Harga)
		f.SetCellValue(sheet, "G"+row, nilai)
		f.SetCellValue(sheet, "H"+row, r.Tipe)
		f.SetCellValue(sheet, "I"+row, r.ReceivedAt.Format("02/01/2006"))

		f.SetCellStyle(sheet, "A"+row, "A"+row, dataCenterStyle)
		f.SetCellStyle(sheet, "B"+row, "D"+row, dataStyle)
		f.SetCellStyle(sheet, "E"+row, "E"+row, dataCenterStyle)
		f.SetCellStyle(sheet, "F"+row, "G"+row, dataRightStyle)
		f.SetCellStyle(sheet, "H"+row, "H"+row, dataCenterStyle)
		f.SetCellStyle(sheet, "I"+row, "I"+row, dataStyle)
		f.SetRowHeight(sheet, i+6, 16)
	}

	totalRow := strconv.Itoa(len(receivings) + 7)
	f.MergeCell(sheet, "A"+totalRow, "D"+totalRow)
	f.SetCellValue(sheet, "A"+totalRow, "TOTAL")
	f.SetCellValue(sheet, "E"+totalRow, totalQty)
	f.SetCellValue(sheet, "F"+totalRow, "")
	f.SetCellValue(sheet, "G"+totalRow, totalValue)
	f.SetCellStyle(sheet, "A"+totalRow, "F"+totalRow, totalStyle)
	f.SetCellStyle(sheet, "G"+totalRow, "G"+totalRow, totalRightStyle)
	f.SetCellStyle(sheet, "H"+totalRow, "I"+totalRow, totalStyle)

	f.SetPanes(sheet, &excelize.Panes{
		Freeze:      true,
		Split:       false,
		XSplit:      0,
		YSplit:      5,
		TopLeftCell: "A6",
		ActivePane:  "bottomLeft",
	})

	filename := fmt.Sprintf("monitoring-sparepart-%s.xlsx", time.Now().Format("20060102"))
	c.Header("Content-Disposition", "attachment; filename="+filename)
	c.Header("Content-Type", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
	if err := f.Write(c.Writer); err != nil {
		c.String(http.StatusInternalServerError, "Gagal menulis Excel: "+err.Error())
	}
}

// Helper
func parseDateRange(c *gin.Context) (from, to time.Time) {
	if f := c.Query("from"); f != "" {
		if t, err := time.ParseInLocation("2006-01-02", f, time.Local); err == nil {
			from = t
		}
	}
	if t := c.Query("to"); t != "" {
		if parsed, err := time.ParseInLocation("2006-01-02", t, time.Local); err == nil {
			to = parsed.Add(23*time.Hour + 59*time.Minute + 59*time.Second)
		}
	}
	return
}

func formatPeriod(from, to time.Time) string {
	if from.IsZero() || to.IsZero() {
		return "Semua periode"
	}
	return from.Format("02 Jan 2006") + " s/d " + to.Format("02 Jan 2006")
}

func formatFloat(f float64) string {
	return fmt.Sprintf("%.0f", f)
}

func statusLabelGo(status string) string {
	switch status {
	case "pending":
		return "Menunggu"
	case "stage1":
		return "Tahap 1 - Admin SP"
	case "stage2":
		return "Tahap 2 - SPV Pemohon"
	case "stage3":
		return "Tahap 3 - SPV SP"
	case "approved":
		return "Disetujui"
	case "rejected":
		return "Ditolak"
	default:
		return status
	}
}
