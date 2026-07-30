package handler

import (
	"bytes"
	"context"
	"encoding/base64"
	"fmt"
	"html/template"
	"os"
	"time"

	"github.com/chromedp/cdproto/page"
	"github.com/chromedp/chromedp"

	"sparepart-mgmt/internal/model"
)

func localFuncs() template.FuncMap {
	return template.FuncMap{
		"formatDate": func(t time.Time) string {
			return t.Format("02-01-2006")
		},
		"formatDateTime": func(t time.Time) string {
			return t.Format("02 Jan 2006 15:04")
		},
		"formatRupiah": func(f float64) string {
			return formatRupiah(f)
		},
		"add": func(a, b int) int { return a + b },
		"mul": func(qty int, price float64) float64 { return float64(qty) * price },
		"imgSrc": func(webPath string) template.URL {
			if webPath == "" {
				return ""
			}
			fsPath := "web" + webPath
			data, err := os.ReadFile(fsPath)
			if err != nil {
				return ""
			}
			mime := "image/jpeg"
			if len(webPath) > 4 && webPath[len(webPath)-4:] == ".png" {
				mime = "image/png"
			} else if len(webPath) > 5 && webPath[len(webPath)-5:] == ".webp" {
				mime = "image/webp"
			}
			encoded := base64.StdEncoding.EncodeToString(data)
			return template.URL("data:" + mime + ";base64," + encoded)
		},
		"logoB64": func() template.URL {
			data, err := os.ReadFile("web/static/images/logo.png")
			if err != nil {
				return ""
			}
			return template.URL("data:image/png;base64," + base64.StdEncoding.EncodeToString(data))
		},
	}
}

func generateKatalogPDF(sp *model.Sparepart) ([]byte, error) {
	tmpl, err := template.New("katalog").Funcs(localFuncs()).Parse(katalogHTMLTemplate)
	if err != nil {
		return nil, fmt.Errorf("template parse error: %w", err)
	}
	var buf bytes.Buffer
	err = tmpl.Execute(&buf, map[string]interface{}{
		"Sparepart": sp,
		"PrintedAt": time.Now().Format("02 January 2006 15:04"),
	})
	if err != nil {
		return nil, fmt.Errorf("template execute error: %w", err)
	}
	return renderHTMLtoPDF(buf.String())
}

func generateStrukPDF(req *model.Request, validations []model.Validation) ([]byte, error) {
	tmpl, err := template.New("struk").Funcs(localFuncs()).Parse(strukHTMLTemplate)
	if err != nil {
		return nil, fmt.Errorf("template parse error: %w", err)
	}

	var buf bytes.Buffer
	err = tmpl.Execute(&buf, map[string]interface{}{
		"Request":     req,
		"Validations": validations,
		"PrintedAt":   time.Now().Format("02 January 2006 15:04"),
		"PrintDate":   req.SubmittedAt.Format("02-01-2006"),
	})
	if err != nil {
		return nil, fmt.Errorf("template execute error: %w", err)
	}

	return renderHTMLtoFitContent(buf.String())
}

func generateLaporanPDF(receivings []model.StockReceiving, totalValue float64, from, to time.Time) ([]byte, error) {
	tmpl, err := template.New("laporan").Funcs(localFuncs()).Parse(laporanHTMLTemplate)
	if err != nil {
		return nil, err
	}

	var totalQty int
	for _, r := range receivings {
		totalQty += r.Jumlah
	}

	var buf bytes.Buffer
	err = tmpl.Execute(&buf, map[string]interface{}{
		"Receivings": receivings,
		"TotalValue": totalValue,
		"TotalQty":   totalQty,
		"FromDate":   from.Format("02 January 2006"),
		"ToDate":     to.Format("02 January 2006"),
		"PrintedAt":  time.Now().Format("02 January 2006 15:04"),
	})
	if err != nil {
		return nil, err
	}

	return renderHTMLtoPDF(buf.String())
}

func renderHTMLtoPDF(htmlContent string) ([]byte, error) {
	return chromedpPrint(htmlContent, 8.27, 11.69, false)
}

func renderHTMLtoFitContent(htmlContent string) ([]byte, error) {
	encoded := base64.StdEncoding.EncodeToString([]byte(htmlContent))
	dataURL := "data:text/html;base64," + encoded

	ctx, cancel := chromedp.NewContext(context.Background())
	defer cancel()
	ctx, cancel = context.WithTimeout(ctx, 60*time.Second)
	defer cancel()

	var contentHeightPx float64
	var pdfBuf []byte

	err := chromedp.Run(ctx,
		chromedp.Navigate(dataURL),
		chromedp.WaitVisible("body", chromedp.ByQuery),
		chromedp.Sleep(500*time.Millisecond),

		chromedp.Evaluate(`
			(function() {
				var els = document.body.querySelectorAll('*');
				var maxBottom = 0;
				for (var i = 0; i < els.length; i++) {
					var r = els[i].getBoundingClientRect();
					if (r.bottom > maxBottom) maxBottom = r.bottom;
				}
				return maxBottom;
			})()
		`, &contentHeightPx),
		chromedp.ActionFunc(func(ctx context.Context) error {
			heightInch := contentHeightPx/96.0 + 1.5
			if heightInch < 5.0 {
				heightInch = 5.0
			}
			var err error
			pdfBuf, _, err = page.PrintToPDF().
				WithPaperWidth(11.69).
				WithPaperHeight(heightInch).
				WithLandscape(false).
				WithPrintBackground(true).
				WithMarginTop(0.4).
				WithMarginBottom(0.4).
				WithMarginLeft(0.5).
				WithMarginRight(0.5).
				Do(ctx)
			return err
		}),
	)

	return pdfBuf, err
}

func renderHTMLtoFitContentPortrait(htmlContent string) ([]byte, error) {
	encoded := base64.StdEncoding.EncodeToString([]byte(htmlContent))
	dataURL := "data:text/html;base64," + encoded

	ctx, cancel := chromedp.NewContext(context.Background())
	defer cancel()
	ctx, cancel = context.WithTimeout(ctx, 60*time.Second)
	defer cancel()

	var contentHeightPx float64
	var pdfBuf []byte

	err := chromedp.Run(ctx,
		chromedp.Navigate(dataURL),
		chromedp.WaitVisible("body", chromedp.ByQuery),
		chromedp.Sleep(500*time.Millisecond),

		chromedp.Evaluate(`
			(function() {
				var els = document.body.querySelectorAll('*');
				var maxBottom = 0;
				for (var i = 0; i < els.length; i++) {
					var r = els[i].getBoundingClientRect();
					if (r.bottom > maxBottom) maxBottom = r.bottom;
				}
				return maxBottom;
			})()
		`, &contentHeightPx),
		chromedp.ActionFunc(func(ctx context.Context) error {
			heightInch := contentHeightPx/96.0 + 1.5
			if heightInch < 5.5 {
				heightInch = 5.5
			}
			var err error
			pdfBuf, _, err = page.PrintToPDF().
				WithPaperWidth(8.27).
				WithPaperHeight(heightInch).
				WithLandscape(false).
				WithPrintBackground(true).
				WithMarginTop(0.4).
				WithMarginBottom(0.4).
				WithMarginLeft(0.5).
				WithMarginRight(0.5).
				Do(ctx)
			return err
		}),
	)

	return pdfBuf, err
}


func chromedpPrint(htmlContent string, width, height float64, landscape bool) ([]byte, error) {
	encoded := base64.StdEncoding.EncodeToString([]byte(htmlContent))
	dataURL := "data:text/html;base64," + encoded

	ctx, cancel := chromedp.NewContext(context.Background())
	defer cancel()

	ctx, cancel = context.WithTimeout(ctx, 60*time.Second)
	defer cancel()

	var pdfBuf []byte

	err := chromedp.Run(ctx,
		chromedp.Navigate(dataURL),
		chromedp.WaitVisible("body", chromedp.ByQuery),
		chromedp.Sleep(500*time.Millisecond),
		chromedp.ActionFunc(func(ctx context.Context) error {
			var err error
			pdfBuf, _, err = page.PrintToPDF().
				WithPaperWidth(width).
				WithPaperHeight(height).
				WithLandscape(landscape).
				WithPrintBackground(true).
				WithMarginTop(0.4).
				WithMarginBottom(0.4).
				WithMarginLeft(0.5).
				WithMarginRight(0.5).
				Do(ctx)
			return err
		}),
	)

	return pdfBuf, err
}

// HTML Templates

const strukHTMLTemplate = `<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<style>
  * { box-sizing: border-box; }
  body {
    font-family: Arial, sans-serif;
    font-size: 10px;
    margin: 0;
    padding: 10px 16px;
    color: #000;
  }
  .page-header {
    display: grid;
    grid-template-columns: 110px 1fr 170px;
    align-items: center;
    border: 1.5px solid #000;
    margin-bottom: 6px;
  }
  .logo-cell {
    padding: 5px 8px;
    border-right: 1.5px solid #000;
    display: flex;
    align-items: center;
    justify-content: center;
    min-height: 52px;
  }
  .logo-cell img { max-width: 90px; max-height: 42px; object-fit: contain; }
  .title-cell {
    text-align: center;
    padding: 5px 12px;
  }
  .title-cell h1 {
    margin: 0;
    font-size: 13px;
    font-weight: bold;
    text-transform: uppercase;
    letter-spacing: 0.5px;
  }
  .doc-cell {
    border-left: 1.5px solid #000;
    font-size: 8px;
    padding: 4px 6px;
    line-height: 1.6;
  }
  .info-block {
    display: flex;
    gap: 40px;
    margin-bottom: 6px;
  }
  .info-row {
    display: flex;
    align-items: baseline;
    font-size: 10px;
  }
  .info-row .lbl { min-width: 72px; font-weight: normal; }
  .info-row .colon { margin: 0 5px; }
  .info-row .val {
    border-bottom: 1px solid #000;
    min-width: 160px;
    padding-bottom: 1px;
  }
  table {
    width: 100%;
    border-collapse: collapse;
    margin-bottom: 8px;
    font-size: 9.5px;
  }
  table th {
    border: 1px solid #000;
    padding: 3px 3px;
    text-align: center;
    font-weight: bold;
    background: #fff;
  }
  table td {
    border: 1px solid #000;
    padding: 3px 4px;
    vertical-align: middle;
  }
  .th-no    { width: 3%; }
  .th-baki  { width: 8%; }
  .th-part  { width: 12%; }
  .th-nama  { width: 22%; }
  .th-desk  { width: 25%; }
  .th-mesin { width: 20%; }
  .th-jml   { width: 10%; }
  .sig-table {
    width: 100%;
    border-collapse: collapse;
    margin-top: 6px;
  }
  .sig-table td {
    border: 1px solid #000;
    padding: 0;
    vertical-align: top;
    width: 33.33%;
  }
  .sig-cell {
    display: flex;
    flex-direction: column;
    height: 100%;
    padding: 5px 8px 0 8px;
  }
  .sig-header {
    font-weight: bold;
    font-size: 9.5px;
    text-align: center;
    margin-bottom: 3px;
    padding-bottom: 3px;
    border-bottom: 1px solid #ccc;
  }
  .sig-sub {
    font-size: 8px;
    color: #555;
    text-align: center;
    margin-bottom: 4px;
  }
  .sig-content {
    flex: 1;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: flex-start;
  }
  .sig-name {
    font-size: 8.5px;
    text-align: center;
    border-top: 1px solid #000;
    padding-top: 2px;
    padding-bottom: 4px;
    margin-top: 18px;
    width: 100%;
  }
  .approved-by-box {
    display: block;
    border: 1.5px solid #c00;
    color: #c00;
    font-weight: bold;
    font-size: 7.5px;
    padding: 2px 8px;
    letter-spacing: 0.5px;
    text-align: center;
    margin: 4px auto 0 auto;
    line-height: 1.6;
    width: fit-content;
  }
  .approved-by-box .appr-label {
    font-size: 7px;
    letter-spacing: 1px;
    display: block;
  }
  .sig-timestamp {
    font-size: 8px;
    font-weight: bold;
    color: #000;
    text-align: right;
    width: 100%;
    margin-bottom: 2px;
    display: block;
  }
  .mengetahui-inner-table {
    width: 100%;
    border-collapse: collapse;
    height: 100%;
  }
  .mengetahui-inner-table td {
    border: none;
    border-top: none;
    padding: 0;
    vertical-align: top;
    width: 50%;
  }
  .mengetahui-inner-table td.divider-col {
    border-left: 1px solid #000;
    width: 0;
    padding: 0;
  }
  .note {
    font-style: italic;
    font-size: 8px;
    color: #333;
    margin-top: 4px;
    margin-bottom: 4px;
  }
  .doc-footer {
    margin-top: 6px;
    font-size: 7.5px;
    color: #555;
    border-top: 1px solid #ccc;
    padding-top: 4px;
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
  }
  .approved-badge {
    display: inline-block;
    border: 2px solid #c00;
    color: #c00;
    font-weight: bold;
    font-size: 8.5px;
    padding: 1px 10px;
    letter-spacing: 1px;
    margin-top: 2px;
  }
</style>
</head>
<body>

<div class="page-header">
  <div class="logo-cell">
    <img src="{{logoB64}}" alt="Bintang 7" />
  </div>
  <div class="title-cell">
    <h1>Bukti Pemakaian Part Mesin</h1>
  </div>
  <div class="doc-cell">
    <div>No. Dok : CR-TK-SP-1001.02</div>
  </div>
</div>

<div class="info-block">
  <div class="info-row">
    <span class="lbl">Tanggal</span>
    <span class="colon">:</span>
    <span class="val">{{.PrintDate}}</span>
  </div>
  <div class="info-row">
    <span class="lbl">No WR/WO</span>
    <span class="colon">:</span>
    <span class="val">{{.Request.NoWRWO}}</span>
  </div>
  <div class="info-row">
    <span class="lbl">Mesin (Area)</span>
    <span class="colon">:</span>
    <span class="val">{{.Request.MesinArea}}</span>
  </div>
</div>

<table>
  <thead>
    <tr>
      <th class="th-no">No</th>
      <th class="th-baki">No. Baki</th>
      <th class="th-part">No. Part</th>
      <th class="th-nama">Nama Part</th>
      <th class="th-desk">Deskripsi Part</th>
      <th class="th-mesin">Mesin (Area)</th>
      <th class="th-jml">Jumlah</th>
    </tr>
  </thead>
  <tbody>
    {{range $i, $item := .Request.Items}}
    <tr>
      <td style="text-align:center">{{add $i 1}}</td>
      <td>{{$item.NoBaki}}</td>
      <td style="font-size:8.5px">{{$item.NoPart}}</td>
      <td>{{$item.NamaItem}}</td>
      <td style="font-size:8.5px">{{$item.Deskripsi}}</td>
      <td>{{$.Request.MesinArea}}</td>
      <td style="text-align:center;font-weight:bold">{{if $item.JumlahDisetujui}}{{$item.JumlahDisetujui}}{{else}}{{$item.Jumlah}}{{end}}</td>
    </tr>
    {{end}}
    {{$n := len .Request.Items}}
    {{if lt $n 5}}
    <tr><td>&nbsp;</td><td></td><td></td><td></td><td></td><td></td><td></td></tr>
    {{end}}
    {{if lt $n 4}}
    <tr><td>&nbsp;</td><td></td><td></td><td></td><td></td><td></td><td></td></tr>
    {{end}}
  </tbody>
</table>

<table class="sig-table">
  <tr>
    <td style="vertical-align:top">
      <div class="sig-cell">
        <div class="sig-header">Yang Menyerahkan</div>
        <div class="sig-sub">(Petugas Spare part)</div>
        <div class="sig-content">
          {{range .Validations}}{{if and (eq .Stage 1) (eq .Action "approved")}}
          <span class="sig-timestamp">{{formatDate .ValidatedAt}}</span>
          <div class="approved-by-box">
            <span class="appr-label">APPROVED BY</span>
          </div>
          {{end}}{{end}}
        </div>
        <div class="sig-name">{{range .Validations}}{{if and (eq .Stage 1) (eq .Action "approved")}}{{.ValidatorName}}{{end}}{{end}}</div>
      </div>
    </td>
    <td style="padding:0;vertical-align:top">
      <table class="mengetahui-inner-table">
        <tr>
          <td colspan="3" style="padding:5px 8px 3px;border-bottom:1px solid #ccc;font-weight:bold;font-size:9.5px;text-align:center;width:100%">Mengetahui</td>
        </tr>
        <tr>
          <td colspan="3" style="font-size:8px;color:#555;text-align:center;padding:2px 8px 4px">&#40;Spv. Pemohon&#41; &#40;Spv. Engineering&#41;</td>
        </tr>
        <tr style="height:100%">
          <td style="vertical-align:top;width:50%">
            <div class="sig-cell" style="padding:4px 6px 0 6px">
              <div class="sig-content">
                {{range .Validations}}{{if and (eq .Stage 2) (eq .Action "approved")}}
                <span class="sig-timestamp" style="width:100%">{{formatDate .ValidatedAt}}</span>
                <div class="approved-by-box" style="margin:0 auto">
                  <span class="appr-label">APPROVED BY</span>
                </div>
                {{end}}{{end}}
              </div>
              <div class="sig-name">{{range .Validations}}{{if and (eq .Stage 2) (eq .Action "approved")}}{{.ValidatorName}}{{end}}{{end}}</div>
            </div>
          </td>
          <td class="divider-col" style="width:1px;padding:0;border-left:1px solid #000"></td>
          <td style="vertical-align:top;width:50%">
            <div class="sig-cell" style="padding:4px 6px 0 6px">
              <div class="sig-content">
                {{range .Validations}}{{if and (eq .Stage 3) (eq .Action "approved")}}
                <span class="sig-timestamp" style="width:100%">{{formatDate .ValidatedAt}}</span>
                <div class="approved-by-box" style="margin:0 auto">
                  <span class="appr-label">APPROVED BY</span>
                </div>
                {{end}}{{end}}
              </div>
              <div class="sig-name">{{range .Validations}}{{if and (eq .Stage 3) (eq .Action "approved")}}{{.ValidatorName}}{{end}}{{end}}</div>
            </div>
          </td>
        </tr>
      </table>
    </td>
    <td style="vertical-align:top">
      <div class="sig-cell">
        <div class="sig-header">Pemohon</div>
        <div class="sig-sub">(Teknisi / Operator Mesin / Lainnya)</div>
        <div class="sig-content">
          <span class="sig-timestamp">{{.PrintDate}}</span>
          <div class="approved-by-box">
            <span class="appr-label">REQUESTED BY</span>
          </div>
        </div>
        <div class="sig-name">{{.Request.RequesterName}}</div>
      </div>
    </td>
  </tr>
</table>

<p class="note">Note : formulir yang sudah terisi lengkap disimpan pada R. Arsip Teknik selama 3 tahun.</p>

<div class="doc-footer">
  <div style="max-width:68%">
    Dokumen ini telah ditandatangani secara elektronik menggunakan aplikasi E-Sparepart dengan melampirkan lembar
    persetujuan elektronik milik PT. Bintang Toedjoe (A Kalbe Company)
  </div>
  <div style="text-align:right">
    <div style="margin-bottom:2px">CR-TK-SP-1001.02 (29 April 2024)</div>
    <div style="margin-bottom:2px">Halaman : 1/1</div>
    <div class="approved-badge">APPROVED</div>
  </div>
</div>

</body>
</html>`

const katalogHTMLTemplate = `<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<style>
  body { font-family: Arial, sans-serif; font-size: 11px; margin: 24px; color: #111; }
  .header { display: flex; justify-content: space-between; align-items: flex-start; border-bottom: 2px solid #111; padding-bottom: 10px; margin-bottom: 16px; }
  .header-left h2 { margin: 0; font-size: 16px; color: #111; }
  .header-left p { margin: 2px 0; font-size: 9px; color: #666; }
  .top-section { display: flex; gap: 16px; margin-bottom: 14px; align-items: flex-start; }
  .top-text { flex: 1; }
  .item-photo { width: 140px; height: 110px; object-fit: contain; border: 1px solid #ccc; border-radius: 6px; background: #f9f9f9; flex-shrink: 0; }
  .item-photo-placeholder { width: 140px; height: 110px; border: 1px dashed #ccc; border-radius: 6px; background: #f9f9f9; display: flex; align-items: center; justify-content: center; font-size: 9px; color: #aaa; flex-shrink: 0; }
  .section-title { font-weight: bold; font-size: 10px; color: #111; text-transform: uppercase; letter-spacing: .5px; border-bottom: 1px solid #ccc; padding-bottom: 3px; margin-bottom: 8px; }
  .row { display: flex; gap: 4px; margin-bottom: 6px; font-size: 10px; }
  .lbl { color: #555; min-width: 120px; flex-shrink: 0; }
  .val { font-weight: 500; color: #111; }
  .stock-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 8px; margin-top: 12px; }
  .stock-card { border: 1px solid #ccc; border-radius: 6px; padding: 8px; text-align: center; }
  .stock-card .num { font-size: 22px; font-weight: bold; color: #111; }
  .stock-card .lbl2 { font-size: 9px; color: #888; }
  .footer { margin-top: 20px; border-top: 1px solid #ccc; padding-top: 6px; display: flex; justify-content: space-between; font-size: 8px; color: #888; }
</style>
</head>
<body>
<div class="header">
  <div class="header-left">
    <img src="{{logoB64}}" alt="Logo" style="height:36px;margin-bottom:4px;display:block" />
    <h2>Data Sheet Sparepart</h2>
    <p>Sistem Manajemen Sparepart — PT. Bintang Toedjoe</p>
  </div>
  <div style="text-align:right;font-size:9px;color:#555">
    <div>Dicetak: {{.PrintedAt}}</div>
  </div>
</div>
<div class="top-section">
  <div class="top-text">
    <div class="section-title">Identitas Item</div>
    <div class="row"><span class="lbl">Kode Oracle</span><span class="val">{{.Sparepart.KodeOracle}}</span></div>
    <div class="row"><span class="lbl">Nama Item</span><span class="val">{{.Sparepart.NamaItem}}</span></div>
    <div class="row"><span class="lbl">No. Part</span><span class="val">{{.Sparepart.NoPart}}</span></div>
    <div class="row"><span class="lbl">Kode RFID</span><span class="val">{{.Sparepart.KodeRFID}}</span></div>
    <div class="row"><span class="lbl">Jenis Mesin</span><span class="val">{{.Sparepart.JenisMesin}}</span></div>
    <div class="row"><span class="lbl">Lokasi</span><span class="val">{{.Sparepart.Lokasi}}</span></div>
    <div class="row"><span class="lbl">Harga Satuan</span><span class="val">{{formatRupiah .Sparepart.Harga}}</span></div>
  </div>
  {{if .Sparepart.FotoURL}}
  <img class="item-photo" src="{{imgSrc .Sparepart.FotoURL}}" alt="Foto" />
  {{else}}
  <div class="item-photo-placeholder">Tidak ada foto</div>
  {{end}}
</div>
<div class="section-title">Deskripsi</div>
<p style="font-size:10px;color:#333;margin:0 0 14px">{{if .Sparepart.Deskripsi}}{{.Sparepart.Deskripsi}}{{else}}—{{end}}</p>
<div class="section-title">Informasi Stok</div>
<div class="stock-grid">
  <div class="stock-card"><div class="num">{{.Sparepart.Stok}}</div><div class="lbl2">Stok Sekarang</div></div>
  <div class="stock-card"><div class="num">{{.Sparepart.MinStok}}</div><div class="lbl2">Min Stok</div></div>
  <div class="stock-card"><div class="num">{{.Sparepart.MaxStok}}</div><div class="lbl2">Max Stok</div></div>
</div>
<div class="footer">
  <span>E-Sparepart — PT. Bintang Toedjoe</span>
  <span>Kode Oracle: {{.Sparepart.KodeOracle}}</span>
</div>
</body>
</html>`

const laporanHTMLTemplate = `<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<style>
  body { font-family: Arial, sans-serif; font-size: 10px; margin: 20px; }
  .header { text-align: center; margin-bottom: 14px; border-bottom: 2px solid #111; padding-bottom: 8px; }
  .header h2 { margin: 0; font-size: 14px; color: #111; }
  .period { font-size: 10px; color: #555; margin: 3px 0; }
  table { width: 100%; border-collapse: collapse; }
  th { background: #333; color: white; padding: 5px 4px; border: 1px solid #333; font-size: 9px; text-align: center; }
  td { padding: 3px 5px; border: 1px solid #ddd; font-size: 9px; }
  .total-row td { font-weight: bold; background: #f5f5f5; }
  .footer { margin-top: 10px; font-size: 8px; color: #999; border-top: 1px solid #ccc; padding-top: 4px; display: flex; justify-content: space-between; }
</style>
</head>
<body>
<div class="header">
  <h2>LAPORAN TRANSAKSI SPAREPART</h2>
  <div class="period">Periode: {{.FromDate}} s/d {{.ToDate}}</div>
  <div class="period">Dicetak: {{.PrintedAt}}</div>
</div>
<table>
  <thead>
    <tr>
      <th>No</th><th>No PO</th><th>Kode Oracle</th><th>Deskripsi Item</th>
      <th>Qty</th><th>Harga Satuan</th><th>Nilai Transaksi</th><th>Tipe</th><th>Tanggal</th>
    </tr>
  </thead>
  <tbody>
    {{range $i, $r := .Receivings}}
    <tr>
      <td style="text-align:center">{{add $i 1}}</td>
      <td>{{$r.NoPO}}</td><td>{{$r.KodeOracle}}</td><td>{{$r.NamaItem}}</td>
      <td style="text-align:center">{{$r.Jumlah}}</td>
      <td style="text-align:right">{{formatRupiah $r.Harga}}</td>
      <td style="text-align:right">{{formatRupiah (mul $r.Jumlah $r.Harga)}}</td>
      <td style="text-align:center">{{$r.Tipe}}</td>
      <td>{{formatDate $r.ReceivedAt}}</td>
    </tr>
    {{end}}
    <tr class="total-row">
      <td colspan="4" style="text-align:right">TOTAL</td>
      <td style="text-align:center">{{.TotalQty}}</td>
      <td></td>
      <td style="text-align:right">{{formatRupiah .TotalValue}}</td>
      <td colspan="2"></td>
    </tr>
  </tbody>
</table>
<div class="footer">
  <span>E-Sparepart — PT. Bintang Toedjoe</span>
  <span>Dicetak: {{.PrintedAt}}</span>
</div>
</body>
</html>`
