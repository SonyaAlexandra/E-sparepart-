package handler

import (
	"fmt"
	"net/http"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/xuri/excelize/v2"

	"sparepart-mgmt/internal/repository"
)

func parseDateFilter(c *gin.Context) (from, to time.Time) {
	if s := c.Query("from"); s != "" {
		if t, err := time.ParseInLocation("2006-01-02", s, time.Local); err == nil {
			from = t
		}
	}
	if s := c.Query("to"); s != "" {
		if t, err := time.ParseInLocation("2006-01-02", s, time.Local); err == nil {
			to = t
		}
	}
	return
}

func ShowSparepartKeluar(c *gin.Context) {
	division := c.Query("divisi")
	fromStr := c.Query("from")
	toStr := c.Query("to")

	if fromStr == "" && toStr == "" {
		now := time.Now()
		defaultFrom := time.Date(now.Year(), now.Month(), 1, 0, 0, 0, 0, time.Local)
		defaultTo := defaultFrom.AddDate(0, 1, -1)
		fromStr = defaultFrom.Format("2006-01-02")
		toStr = defaultTo.Format("2006-01-02")
		redirect := "/pengambilan/keluar?from=" + fromStr + "&to=" + toStr
		if division != "" {
			redirect += "&divisi=" + division
		}
		c.Redirect(http.StatusFound, redirect)
		return
	}

	from, to := parseDateFilter(c)

	items, err := repository.GetApprovedRequestItems(division, from, to)
	if err != nil {
		items = nil
	}

	var totalValue float64
	for _, it := range items {
		totalValue += it.TransactionValue
	}

	renderTemplate(c, "pengambilan/sparepart_keluar.html", gin.H{
		"Title":        "Sparepart Keluar",
		"Items":        items,
		"TotalValue":   totalValue,
		"DivisiFilter": division,
		"DivisiList":   []string{"MTC1", "MTC2", "UTL", "BM"},
		"FromFilter":   fromStr,
		"ToFilter":     toStr,
	})
}

// ExportSparepartKeluarExcel exports sparepart keluar as Excel.
func ExportSparepartKeluarExcel(c *gin.Context) {
	division := c.Query("divisi")
	from, to := parseDateFilter(c)

	items, err := repository.GetApprovedRequestItems(division, from, to)
	if err != nil {
		c.String(http.StatusInternalServerError, "Gagal mengambil data")
		return
	}

	f := excelize.NewFile()
	defer f.Close()
	sheet := "Sparepart Keluar"
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

	f.SetColWidth(sheet, "A", "A", 20)
	f.SetColWidth(sheet, "B", "B", 10)
	f.SetColWidth(sheet, "C", "C", 18)
	f.SetColWidth(sheet, "D", "D", 30)
	f.SetColWidth(sheet, "E", "E", 8)
	f.SetColWidth(sheet, "F", "F", 20)
	f.SetColWidth(sheet, "G", "G", 16)

	periodLabel := formatPeriod(from, to)
	if division != "" {
		periodLabel += " — Divisi: " + division
	}

	f.MergeCell(sheet, "A1", "G1")
	f.SetCellValue(sheet, "A1", "LAPORAN SPAREPART KELUAR")
	f.SetCellStyle(sheet, "A1", "G1", titleStyle)
	f.SetRowHeight(sheet, 1, 22)

	f.SetCellValue(sheet, "A2", "Periode")
	f.SetCellValue(sheet, "B2", periodLabel)
	f.SetCellStyle(sheet, "A2", "G2", metaStyle)

	f.SetCellValue(sheet, "A3", "Dicetak")
	f.SetCellValue(sheet, "B3", time.Now().Format("02 January 2006 15:04"))
	f.SetCellStyle(sheet, "A3", "G3", metaStyle)

	headers := []string{"No WR/WO", "Divisi", "Kode Oracle", "Deskripsi", "Qty", "Nilai Transaksi", "Tanggal"}
	for i, h := range headers {
		col, _ := excelize.ColumnNumberToName(i + 1)
		f.SetCellValue(sheet, col+"5", h)
		f.SetCellStyle(sheet, col+"5", col+"5", headerStyle)
	}
	f.SetRowHeight(sheet, 5, 18)

	var totalQty int
	var totalValue float64

	for i, it := range items {
		row := strconv.Itoa(i + 6)
		totalQty += it.Jumlah
		totalValue += it.TransactionValue

		var tDate string
		if t, ok := it.SubmittedAt.(time.Time); ok {
			tDate = t.Format("02/01/2006")
		} else {
			tDate = fmt.Sprintf("%v", it.SubmittedAt)
		}

		f.SetCellValue(sheet, "A"+row, it.NoWRWO)
		f.SetCellValue(sheet, "B"+row, it.Division)
		f.SetCellValue(sheet, "C"+row, it.KodeOracle)
		f.SetCellValue(sheet, "D"+row, it.NamaItem)
		f.SetCellValue(sheet, "E"+row, it.Jumlah)
		f.SetCellValue(sheet, "F"+row, it.TransactionValue)
		f.SetCellValue(sheet, "G"+row, tDate)

		f.SetCellStyle(sheet, "A"+row, "D"+row, dataStyle)
		f.SetCellStyle(sheet, "E"+row, "E"+row, dataCenterStyle)
		f.SetCellStyle(sheet, "F"+row, "F"+row, dataRightStyle)
		f.SetCellStyle(sheet, "G"+row, "G"+row, dataStyle)
		f.SetRowHeight(sheet, i+6, 16)
	}

	totalRow := strconv.Itoa(len(items) + 7)
	f.MergeCell(sheet, "A"+totalRow, "D"+totalRow)
	f.SetCellValue(sheet, "A"+totalRow, "TOTAL")
	f.SetCellValue(sheet, "E"+totalRow, totalQty)
	f.SetCellValue(sheet, "F"+totalRow, totalValue)
	f.SetCellValue(sheet, "G"+totalRow, "")
	f.SetCellStyle(sheet, "A"+totalRow, "E"+totalRow, totalStyle)
	f.SetCellStyle(sheet, "F"+totalRow, "F"+totalRow, totalRightStyle)
	f.SetCellStyle(sheet, "G"+totalRow, "G"+totalRow, totalStyle)

	f.SetPanes(sheet, &excelize.Panes{
		Freeze:      true,
		Split:       false,
		XSplit:      0,
		YSplit:      5,
		TopLeftCell: "A6",
		ActivePane:  "bottomLeft",
	})

	filename := "sparepart-keluar"
	if division != "" {
		filename += "-" + division
	}
	if c.Query("from") != "" {
		filename += "-" + c.Query("from")
	}
	if c.Query("to") != "" {
		filename += "_sd_" + c.Query("to")
	}
	filename += "-" + time.Now().Format("20060102") + ".xlsx"

	c.Header("Content-Type", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
	c.Header("Content-Disposition", "attachment; filename="+filename)
	if err := f.Write(c.Writer); err != nil {
		c.String(http.StatusInternalServerError, "Gagal membuat Excel: "+err.Error())
	}
}
