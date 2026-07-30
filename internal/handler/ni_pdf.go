package handler

import (
	"bytes"
	"fmt"
	"html/template"
	"strings"

	"sparepart-mgmt/internal/model"
)

func generateNIPDF(req *model.NonInventoryRequest) ([]byte, error) {
	funcMap := localFuncs()

	funcMap["niStatusLabel"] = func(s string) string {
		switch s {
		case "pending":
			return "Menunggu SPV Pemohon"
		case "stage1":
			return "Menunggu Admin SP"
		case "stage2":
			return "Menunggu SPV SP"
		case "approved":
			return "Disetujui"
		case "cancelled":
			return "Dibatalkan"
		}
		return s
	}
	funcMap["add1"] = func(i int) int { return i + 1 }
	funcMap["safeHTML"] = func(s string) template.HTML { return template.HTML(s) }

	type templateData struct {
		*model.NonInventoryRequest
		PaddedItems []model.NonInventoryItem
	}
	padded := req.Items
	for len(padded) < 4 {
		padded = append(padded, model.NonInventoryItem{})
	}

	data := templateData{
		NonInventoryRequest: req,
		PaddedItems:         padded,
	}

	tmpl, err := template.New("ni_pdf").Funcs(funcMap).Parse(niPDFTemplate)
	if err != nil {
		return nil, fmt.Errorf("parse template: %w", err)
	}

	var buf bytes.Buffer
	if err := tmpl.Execute(&buf, data); err != nil {
		return nil, fmt.Errorf("execute template: %w", err)
	}

	return renderHTMLtoFitContentPortrait(buf.String())
}

func niApprovalName(approvals []model.NonInventoryApproval, stage int, action string) string {
	for _, a := range approvals {
		if a.Stage == stage && strings.EqualFold(a.Action, action) {
			return a.ApproverName
		}
	}
	return ""
}

func niApprovalDate(approvals []model.NonInventoryApproval, stage int) string {
	for _, a := range approvals {
		if a.Stage == stage {
			return a.ActionedAt.Format("02/01/06")
		}
	}
	return ""
}

const niPDFTemplate = `<!DOCTYPE html>
<html lang="id">
<head>
<meta charset="UTF-8"/>
<style>
  * { margin:0; padding:0; box-sizing:border-box; }
  body {
    font-family: Arial, sans-serif;
    font-size: 10px;
    color: #000;
    padding: 14px 18px;
  }

  /* ── Header ── */
  .page-header {
    width: 100%;
    border-collapse: collapse;
    border: 1.5px solid #000;
    margin-bottom: 6px;
  }
  .page-header td { vertical-align: middle; }
  .logo-cell {
    width: 130px;
    padding: 6px 10px;
    border-right: 1.5px solid #000;
  }
  .logo-cell img { max-height: 44px; max-width: 110px; object-fit: contain; }
  .title-cell {
    text-align: center;
    padding: 6px 12px;
  }
  .title-cell h1 {
    font-size: 14px;
    font-weight: bold;
    margin: 0;
  }

  /* ── Meta row: Tanggal + No BPJT ── */
  .meta-row {
    width: 100%;
    border-collapse: collapse;
    margin-bottom: 6px;
    font-size: 10px;
  }
  .meta-row td { padding: 2px 0; }
  .meta-row .underline {
    border-bottom: 1px solid #000;
    display: inline-block;
    min-width: 140px;
    padding-bottom: 1px;
  }
  .meta-row .nobpjt-cell { text-align: right; font-size: 9px; }

  /* ── Items table ── */
  table.items {
    width: 100%;
    border-collapse: collapse;
    margin-bottom: 0;
  }
  table.items th, table.items td {
    border: 1px solid #000;
    padding: 4px 5px;
    vertical-align: top;
    font-size: 10px;
  }
  table.items th {
    text-align: center;
    font-weight: bold;
    background: #fff;
  }
  table.items td.center { text-align: center; }
  .col-no    { width: 28px; }
  .col-desc  { width: auto; }
  .col-qty   { width: 50px; }
  .col-perun { width: 28%; }
  .col-lamp  { width: 18%; }

  /* ── Bottom info row ── */
  table.bottom-info {
    width: 100%;
    border-collapse: collapse;
    border-top: none;
  }
  table.bottom-info td {
    border: 1px solid #000;
    border-top: none;
    padding: 4px 6px;
    font-size: 10px;
    vertical-align: top;
  }
  .bi-label { font-size: 9px; color: #555; margin-bottom: 2px; }
  .bi-value { font-weight: bold; font-size: 10.5px; }
  .bi-underline {
    border-bottom: 1px solid #000;
    min-height: 16px;
    margin-top: 2px;
  }

  /* ── Sparepart section ── */
  .sp-header {
    font-weight: bold;
    font-size: 10px;
    border: 1px solid #000;
    border-top: none;
    padding: 3px 6px;
    background: #fff;
  }
  table.sp-table {
    width: 100%;
    border-collapse: collapse;
    border-top: none;
  }
  table.sp-table td {
    border: 1px solid #000;
    border-top: none;
    padding: 5px 8px;
    vertical-align: top;
    font-size: 10px;
  }
  .sp-col-penerima { width: 28%; }
  .sp-col-status   { width: 24%; }
  .sp-col-setuju   { width: 28%; }
  .sp-col-lamp     { width: 20%; }

  /* ── Approval stamp ── */
  .approval-box {
    border: 1px solid #c00;
    color: #c00;
    font-weight: bold;
    font-size: 7.5px;
    padding: 1px 6px;
    text-align: center;
    display: inline-block;
    margin-top: 4px;
    letter-spacing: 0.5px;
  }
  .sign-space { min-height: 40px; }
  .signer-name {
    border-top: 1px solid #000;
    padding-top: 2px;
    margin-top: 4px;
    font-size: 9px;
    text-align: center;
    min-width: 80px;
  }
  .sign-date { font-size: 8px; color: #333; margin-bottom: 2px; }

  /* ── Footer note ── */
  .footer-note {
    margin-top: 8px;
    font-size: 8.5px;
    color: #333;
    text-align: center;
  }
  .doc-footer {
    margin-top: 6px;
    display: flex;
    justify-content: space-between;
    align-items: flex-end;
    font-size: 8px;
    color: #666;
    border-top: 1px solid #ccc;
    padding-top: 4px;
  }
  .approved-badge {
    border: 2px solid #c00;
    color: #c00;
    font-weight: bold;
    font-size: 9px;
    padding: 1px 10px;
    letter-spacing: 1px;
    display: inline-block;
    margin-top: 3px;
  }

  /* ── Lampiran note ── */
  .lamp-note { font-size: 8px; color: #333; margin-top: 6px; line-height: 1.6; }
</style>
</head>
<body>

<!-- ══ HEADER ══ -->
<table class="page-header">
  <tr>
    <td class="logo-cell">
      <img src="{{logoB64}}" alt="Logo"/>
    </td>
    <td class="title-cell">
      <h1>Permintaan Barang / Jasa Teknik</h1>
    </td>
  </tr>
</table>

<!-- ══ TANGGAL + NO BPJT ══ -->
<table class="meta-row">
  <tr>
    <td>Tanggal : <span class="underline">{{formatDate .TanggalPemakaian}}</span></td>
    <td class="nobpjt-cell">No. BPJT : <strong>{{.NoBPJT}}</strong></td>
  </tr>
</table>

<!-- ══ ITEMS TABLE ══ -->
<table class="items">
  <thead>
    <tr>
      <th class="col-no">No.</th>
      <th class="col-desc">Penjelasan Barang/Jasa</th>
      <th class="col-qty">Qty</th>
      <th class="col-perun">Peruntukan</th>
      <th class="col-lamp">Lampiran *</th>
    </tr>
  </thead>
  <tbody>
    {{range $i, $item := .PaddedItems}}
    <tr>
      <td class="center">{{if $item.Deskripsi}}{{add1 $i}}{{end}}</td>
      <td>{{$item.Deskripsi}}&nbsp;</td>
      <td class="center">{{if $item.Qty}}{{$item.Qty}}{{end}}&nbsp;</td>
      <td>{{$item.Peruntukan}}&nbsp;</td>
      <td>{{$item.Lampiran}}&nbsp;</td>
    </tr>
    {{end}}
  </tbody>
</table>

<!-- ══ BOTTOM INFO ROW: Pemohon | Dept | Tgl Pemakaian | Mengetahui | Keterangan ══ -->
<table class="bottom-info">
  <tr>
    <td style="width:22%">
      <div class="bi-label">Pemohon :</div>
      <div class="sign-space">
        <div class="sign-date">{{formatDate .SubmittedAt}}</div>
        <div class="approval-box">APPROVED BY</div>
      </div>
      <div class="signer-name">
        {{.NamaPemohon}}
      </div>
    </td>
    <td style="width:18%">
      <div class="bi-label">Dept/ seksi :</div>
      <div class="bi-underline">{{.SeksiDivisi}}</div>
    </td>
    <td style="width:18%">
      <div class="bi-label">Tanggal pemakaian</div>
      <div class="bi-underline">{{formatDate .TanggalPemakaian}}</div>
    </td>
    <td style="width:22%">
      <div class="bi-label">Mengetahui :</div>
      <div class="sign-space">
        {{range .Approvals}}{{if eq .Stage 1}}
        <div class="sign-date">{{formatDate .ActionedAt}}</div>
        <div class="approval-box">APPROVED BY</div>
        {{end}}{{end}}
      </div>
      <div class="signer-name">
        {{range .Approvals}}{{if eq .Stage 1}}{{.ApproverName}}{{end}}{{end}}
      </div>
    </td>
    <td style="width:20%">
      <div class="bi-label">Keterangan</div>
      <div style="min-height:40px">{{.Keterangan}}</div>
    </td>
  </tr>
</table>

<!-- ══ SPAREPART SECTION ══ -->
<div class="sp-header">Sparepart</div>
<table class="sp-table">
  <tr>
    <!-- Penerima -->
    <td class="sp-col-penerima">
      <div class="bi-label">Penerima :</div>
      <div class="sign-space">
        {{range .Approvals}}{{if eq .Stage 2}}
        <div class="sign-date">{{formatDate .ActionedAt}}</div>
        <div class="approval-box">APPROVED BY</div>
        {{end}}{{end}}
      </div>
      <div class="signer-name">
        {{range .Approvals}}{{if eq .Stage 2}}{{.ApproverName}}{{end}}{{end}}
      </div>
    </td>

    <!-- Status -->
    <td class="sp-col-status">
      <div class="bi-label">status:</div>
      <div style="margin-top:4px;line-height:2">
        1. Baru<br/>
        2. Tgl terakhir<br/>
        <span style="font-size:9px;color:#555">............</span>
      </div>
    </td>

    <!-- Menyetujui (SPV SP - stage 3) -->
    <td class="sp-col-setuju">
      <div class="bi-label">Menyetujui :</div>
      <div class="sign-space">
        {{range .Approvals}}{{if eq .Stage 3}}
        <div class="sign-date">{{formatDate .ActionedAt}}</div>
        <div class="approval-box">APPROVED BY</div>
        {{end}}{{end}}
      </div>
      <div class="signer-name">
        {{range .Approvals}}{{if eq .Stage 3}}{{.ApproverName}}{{end}}{{end}}
      </div>
    </td>

    <!-- Lampiran note -->
    <td class="sp-col-lamp">
      <div class="lamp-note">
        *Isi lampiran diantaranya :<br/>
        1. Penawaran harga supplier<br/>
        2. Catalog sparepart<br/>
        3. Drawing/gambar
      </div>
    </td>
  </tr>
</table>

<!-- ══ FOOTER ══ -->
<p class="footer-note">
  Formulir yang sudah terisi lengkap akan disimpan di Ruang Arsip Teknik selama 1 tahun.
</p>

<div class="doc-footer">
  <div>
    Dokumen ini telah ditandatangani secara elektronik menggunakan aplikasi E-Sparepart
    dengan melampirkan lembar persetujuan elektronik milik PT. Bintang Toedjoe
  </div>
  <div style="text-align:right">
    <div>CR-TK-MT-1005.02 (29 Apr 2024)</div>
    <div>Halaman : 1/1</div>
    {{if eq .Status "approved"}}
    <div class="approved-badge">APPROVED</div>
    {{end}}
  </div>
</div>

</body>
</html>`
