package handler

import (
	"fmt"
	"net/http"
	"os"
	"path/filepath"
	"strconv"
	"strings"
	"time"

	"github.com/gin-gonic/gin"

	"sparepart-mgmt/internal/model"
	"sparepart-mgmt/internal/repository"
	"sparepart-mgmt/internal/service"
)

func ShowKatalog(c *gin.Context) {
	jenisMesin := c.Query("jenis_mesin")
	search := c.Query("search")

	spareparts, err := repository.GetAllSpareparts(jenisMesin, search)
	if err != nil {
		spareparts = []model.Sparepart{}
	}

	jenisMesinList, _ := repository.GetDistinctJenisMesin()
	_, role, _, _ := GetSessionUser(c)

	renderTemplate(c, "katalog/index.html", gin.H{
		"Title":          "Katalog Sparepart",
		"Spareparts":     spareparts,
		"JenisMesinList": jenisMesinList,
		"FilterJenis":    jenisMesin,
		"Search":         search,
		"IsAdmin":        role == "admin_sp" || role == "spv_sp",
	})
}

func SearchSpareparts(c *gin.Context) {
	q := strings.TrimSpace(c.Query("q"))
	if q == "" {
		c.JSON(http.StatusOK, []gin.H{})
		return
	}
	sps, err := repository.GetAllSpareparts("", q)
	if err != nil || len(sps) == 0 {
		c.JSON(http.StatusOK, []gin.H{})
		return
	}
	result := make([]gin.H, 0, len(sps))
	for _, sp := range sps {
		result = append(result, gin.H{
			"id":          sp.ID,
			"nama_item":   sp.NamaItem,
			"kode_oracle": sp.KodeOracle,
			"deskripsi":   sp.Deskripsi,
			"harga":       sp.Harga,
			"stok":        sp.Stok,
			"lokasi":      sp.Lokasi,
		})
	}
	c.JSON(http.StatusOK, result)
}

func ShowKatalogDetail(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "ID tidak valid"})
		return
	}

	sp, err := repository.GetSparepartByID(id)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Sparepart tidak ditemukan"})
		return
	}

	_, role, _, _ := GetSessionUser(c)
	canEdit := role == "admin_sp" || role == "spv_sp"

	renderHTMX(c, "katalog/detail_modal.html", gin.H{
		"Sparepart": sp,
		"CanEdit":   canEdit,
	})
}

func ShowKatalogForm(c *gin.Context) {
	idStr := c.Param("id")
	var sp *model.Sparepart

	if idStr != "" && idStr != "form" {
		id, _ := strconv.Atoi(idStr)
		sp, _ = repository.GetSparepartByID(id)
	}

	jenisMesinList, _ := repository.GetDistinctJenisMesin()

	renderTemplate(c, "katalog/form.html", gin.H{
		"Title":          "Form Sparepart",
		"Sparepart":      sp,
		"JenisMesinList": jenisMesinList,
		"IsEdit":         sp != nil,
	})
}

func SaveKatalog(c *gin.Context) {
	userID, _, _, _ := GetSessionUser(c)

	idStr := c.PostForm("id")
	harga, _ := strconv.ParseFloat(c.PostForm("harga"), 64)
	stok, _ := strconv.Atoi(c.PostForm("stok"))
	minStok, _ := strconv.Atoi(c.PostForm("min_stok"))
	maxStok, _ := strconv.Atoi(c.PostForm("max_stok"))
	usagePerYear, _ := strconv.Atoi(c.PostForm("usage_per_year"))

	uploadsDir := "web/static/uploads"
	os.MkdirAll(uploadsDir, 0755)

	// Photo upload
	fotoURL := c.PostForm("foto_url_existing")
	fotoFile, fotoHeader, err := c.Request.FormFile("foto_file")
	if err == nil {
		defer fotoFile.Close()
		ext := strings.ToLower(filepath.Ext(fotoHeader.Filename))
		allowed := map[string]bool{".jpg": true, ".jpeg": true, ".png": true, ".webp": true}
		if !allowed[ext] {
			jenisMesinList, _ := repository.GetDistinctJenisMesin()
			renderTemplate(c, "katalog/form.html", gin.H{"Title": "Form Sparepart", "Error": "Format foto tidak valid. Gunakan JPG, PNG, atau WebP.", "JenisMesinList": jenisMesinList})
			return
		}
		if fotoHeader.Size > 5<<20 {
			jenisMesinList, _ := repository.GetDistinctJenisMesin()
			renderTemplate(c, "katalog/form.html", gin.H{"Title": "Form Sparepart", "Error": "Ukuran foto maksimal 5 MB.", "JenisMesinList": jenisMesinList})
			return
		}
		filename := fmt.Sprintf("%d%s", time.Now().UnixNano(), ext)
		dest := filepath.Join(uploadsDir, filename)
		if err := c.SaveUploadedFile(fotoHeader, dest); err != nil {
			jenisMesinList, _ := repository.GetDistinctJenisMesin()
			renderTemplate(c, "katalog/form.html", gin.H{"Title": "Form Sparepart", "Error": "Gagal menyimpan foto: " + err.Error(), "JenisMesinList": jenisMesinList})
			return
		}
		fotoURL = "/static/uploads/" + filename
	}

	// PDF upload
	pdfURL := c.PostForm("pdf_url_existing")
	pdfFile, pdfHeader, err := c.Request.FormFile("pdf_file")
	if err == nil {
		defer pdfFile.Close()
		ext := strings.ToLower(filepath.Ext(pdfHeader.Filename))
		if ext != ".pdf" {
			jenisMesinList, _ := repository.GetDistinctJenisMesin()
			renderTemplate(c, "katalog/form.html", gin.H{"Title": "Form Sparepart", "Error": "Format dokumen tidak valid. Hanya file PDF.", "JenisMesinList": jenisMesinList})
			return
		}
		if pdfHeader.Size > 10<<20 {
			jenisMesinList, _ := repository.GetDistinctJenisMesin()
			renderTemplate(c, "katalog/form.html", gin.H{"Title": "Form Sparepart", "Error": "Ukuran PDF maksimal 10 MB.", "JenisMesinList": jenisMesinList})
			return
		}
		filename := fmt.Sprintf("pdf_%d.pdf", time.Now().UnixNano())
		dest := filepath.Join(uploadsDir, filename)
		if err := c.SaveUploadedFile(pdfHeader, dest); err != nil {
			jenisMesinList, _ := repository.GetDistinctJenisMesin()
			renderTemplate(c, "katalog/form.html", gin.H{"Title": "Form Sparepart", "Error": "Gagal menyimpan PDF: " + err.Error(), "JenisMesinList": jenisMesinList})
			return
		}
		pdfURL = "/static/uploads/" + filename
	}

	sp := &model.Sparepart{
		KodeOracle:   c.PostForm("kode_oracle"),
		KodeRFID:     c.PostForm("kode_rfid"),
		NoPart:       c.PostForm("no_part"),
		NamaItem:     c.PostForm("nama_item"),
		Deskripsi:    c.PostForm("deskripsi"),
		JenisMesin:   c.PostForm("jenis_mesin"),
		Lokasi:       c.PostForm("lokasi"),
		Harga:        harga,
		Stok:         stok,
		MinStok:      minStok,
		MaxStok:      maxStok,
		UsagePerYear: usagePerYear,
		FotoURL:      fotoURL,
		PdfURL:       pdfURL,
	}

	var actionLabel string
	if idStr != "" {
		id, _ := strconv.Atoi(idStr)
		sp.ID = id
		oldFotoURL := c.PostForm("foto_url_existing")
		if fotoURL != oldFotoURL && oldFotoURL != "" {
			deletePhotoFile(oldFotoURL, id)
		}
		// Delete old PDF from disk when replaced with a new upload
		oldPdfURL := c.PostForm("pdf_url_existing")
		if pdfURL != oldPdfURL && oldPdfURL != "" {
			deletePDFFile(oldPdfURL)
		}
		repository.UpdateSparepart(sp)
		actionLabel = "update_sparepart"
	} else {
		repository.CreateSparepart(sp)
		actionLabel = "create_sparepart"
	}

	service.LogActivity(userID, actionLabel, "sparepart", sp.ID, "Sparepart: "+sp.NamaItem)

	toastParam := "create_success"
	if idStr != "" {
		toastParam = "edit_success"
	}
	c.Redirect(http.StatusFound, "/katalog?toast="+toastParam)
}

func DownloadKatalogPDF(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.String(http.StatusBadRequest, "ID tidak valid")
		return
	}
	sp, err := repository.GetSparepartByID(id)
	if err != nil {
		c.String(http.StatusNotFound, "Sparepart tidak ditemukan")
		return
	}

	if sp.PdfURL == "" {
		c.String(http.StatusNotFound, "PDF belum di-upload untuk sparepart ini")
		return
	}

	filePath := filepath.Join("web", strings.TrimPrefix(sp.PdfURL, "/"))

	if _, statErr := os.Stat(filePath); os.IsNotExist(statErr) {
		c.String(http.StatusNotFound, "File PDF tidak ditemukan di server")
		return
	}

	safeName := strings.Map(func(r rune) rune {
		switch {
		case r >= 'a' && r <= 'z', r >= 'A' && r <= 'Z', r >= '0' && r <= '9',
			r == '-', r == '_':
			return r
		case r == ' ':
			return '_'
		default:
			return -1
		}
	}, sp.NamaItem)
	if safeName == "" {
		safeName = sp.KodeOracle
	}
	downloadName := safeName + "_Drawing.pdf"

	c.Header("Content-Disposition", "attachment; filename=\""+downloadName+"\"")
	c.Header("Content-Type", "application/pdf")
	c.File(filePath)
}

func deletePhotoFile(fotoURL string, excludeID int) {
	if fotoURL == "" || !strings.HasPrefix(fotoURL, "/static/uploads/") {
		return
	}
	count, err := repository.CountSparepartsByFoto(fotoURL, excludeID)
	if err != nil || count > 0 {
		return
	}
	filePath := filepath.Join("web", strings.TrimPrefix(fotoURL, "/"))
	os.Remove(filePath)
}

func deletePDFFile(pdfURL string) {
	if pdfURL == "" || !strings.HasPrefix(pdfURL, "/static/uploads/") {
		return
	}
	filePath := filepath.Join("web", strings.TrimPrefix(pdfURL, "/"))
	os.Remove(filePath)
}

func DeleteKatalog(c *gin.Context) {
	userID, _, _, _ := GetSessionUser(c)
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.Redirect(http.StatusFound, "/katalog")
		return
	}

	sp, _ := repository.GetSparepartByID(id)

	// Soft-delete: mark as deleted without removing the row.
	// Historical records (request_items, stock_receivings) still JOIN
	// the sparepart row and display its real name instead of [Sparepart Dihapus].
	if err := repository.SoftDeleteSparepart(id); err != nil {
		c.Redirect(http.StatusFound, "/katalog?toast=delete_error")
		return
	}

	if sp != nil {
		deletePhotoFile(sp.FotoURL, sp.ID)
		deletePDFFile(sp.PdfURL)
		service.LogActivity(userID, "delete_sparepart", "sparepart", id, "Hapus sparepart: "+sp.NamaItem)
	}

	c.Redirect(http.StatusFound, "/katalog?toast=delete_success")
}

func SearchByOracleCode(c *gin.Context) {
	kode := strings.TrimSpace(c.Query("kode"))
	if kode == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Kode oracle tidak boleh kosong"})
		return
	}

	sp, err := repository.GetSparepartByKodeOracle(kode)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Sparepart dengan kode oracle '" + kode + "' tidak ditemukan"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"sparepart_id": sp.ID,
		"nama_item":    sp.NamaItem,
		"kode_oracle":  sp.KodeOracle,
		"no_part":      sp.NoPart,
		"deskripsi":    sp.Deskripsi,
		"stok":         sp.Stok,
		"lokasi":       sp.Lokasi,
	})
}
