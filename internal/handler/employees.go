package handler

import (
	"log"
	"net/http"
	"strconv"
	"strings"

	"github.com/gin-gonic/gin"

	"sparepart-mgmt/internal/model"
	"sparepart-mgmt/internal/repository"
	"sparepart-mgmt/internal/service"
)

func ShowEmployees(c *gin.Context) {
	search := strings.TrimSpace(c.Query("search"))
	employees, err := repository.GetAllEmployees(search)
	if err != nil {
		employees = []model.EmployeeIDCard{}
	}
	renderTemplate(c, "employees/index.html", gin.H{
		"Title":     "Kelola Karyawan Pemohon",
		"Employees": employees,
		"Search":    search,
	})
}

func ShowCreateEmployeeForm(c *gin.Context) {
	renderTemplate(c, "employees/form.html", gin.H{
		"Title":  "Tambah Karyawan Pemohon",
		"IsEdit": false,
	})
}

func ShowEditEmployeeForm(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.Redirect(http.StatusFound, "/users?tab=employees")
		return
	}
	emp, err := repository.GetEmployeeByID(id)
	if err != nil {
		c.Redirect(http.StatusFound, "/users?tab=employees")
		return
	}
	renderTemplate(c, "employees/form.html", gin.H{
		"Title":    "Edit Karyawan Pemohon",
		"IsEdit":   true,
		"Employee": emp,
	})
}

func SaveEmployee(c *gin.Context) {
	idStr := strings.TrimSpace(c.PostForm("id"))
	isEdit := idStr != "" && idStr != "0"

	fullName := strings.TrimSpace(c.PostForm("full_name"))
	idCardNumber := strings.TrimSpace(c.PostForm("id_card_number"))
	fingerprintID := strings.TrimSpace(c.PostForm("fingerprint_id"))
	fingerprintTemplate := strings.TrimSpace(c.PostForm("fingerprint_template"))
	notes := strings.TrimSpace(c.PostForm("notes"))
	isActiveStr := c.PostForm("is_active")
	isActive := isActiveStr == "1" || isActiveStr == "true" || isActiveStr == "on"

	formData := gin.H{
		"IsEdit": isEdit,
	}
	if isEdit {
		formData["Title"] = "Edit Karyawan Pemohon"
	} else {
		formData["Title"] = "Tambah Karyawan Pemohon"
	}

	if fullName == "" {
		formData["Error"] = "Nama lengkap wajib diisi"
		renderTemplate(c, "employees/form.html", formData)
		return
	}
	if idCardNumber == "" {
		formData["Error"] = "Nomor ID card wajib diisi"
		renderTemplate(c, "employees/form.html", formData)
		return
	}

	var empID int
	if isEdit {
		var err error
		empID, err = strconv.Atoi(idStr)
		if err != nil {
			c.Redirect(http.StatusFound, "/users?tab=employees")
			return
		}
	}

	taken, err := repository.IsIDCardNumberTaken(idCardNumber, empID)
	if err != nil || taken {
		formData["Error"] = "Nomor ID card sudah terdaftar untuk karyawan lain"
		renderTemplate(c, "employees/form.html", formData)
		return
	}

	if fingerprintID != "" {
		fpTaken, err := repository.IsFingerprintIDTaken(fingerprintID, empID)
		if err != nil || fpTaken {
			formData["Error"] = "Fingerprint ID sudah dipakai karyawan lain"
			renderTemplate(c, "employees/form.html", formData)
			return
		}
	}

	if fingerprintTemplate != "" {
		fpTemplateTaken, err := repository.IsFingerprintTemplateTaken(fingerprintTemplate, empID)
		if err != nil || fpTemplateTaken {
			formData["Error"] = "Sidik jari tersebut sudah terdaftar untuk karyawan lain"
			renderTemplate(c, "employees/form.html", formData)
			return
		}
	}

	createdBy, _, _, _ := GetSessionUser(c)

	emp := &model.EmployeeIDCard{
		ID:                  empID,
		FullName:            fullName,
		IDCardNumber:        idCardNumber,
		FingerprintID:       fingerprintID,
		FingerprintTemplate: fingerprintTemplate,
		IsActive:            isActive,
		Notes:               notes,
	}

	log.Printf("[Employees/Save] Menyimpan karyawan id=%d, name=%s, template_len=%d", empID, fullName, len(fingerprintTemplate))

	if isEdit {
		if err := repository.UpdateEmployee(emp); err != nil {
			formData["Error"] = "Gagal menyimpan perubahan: " + err.Error()
			renderTemplate(c, "employees/form.html", formData)
			return
		}
		service.LogActivity(createdBy, "update_employee", "user", empID,
			"Edit karyawan: "+fullName)
	} else {
		emp.IsActive = true
		if err := repository.CreateEmployee(emp, createdBy); err != nil {
			formData["Error"] = "Gagal menyimpan karyawan: " + err.Error()
			renderTemplate(c, "employees/form.html", formData)
			return
		}
		service.LogActivity(createdBy, "create_employee", "user", 0,
			"Tambah karyawan: "+fullName+" (ID card: "+idCardNumber+")")
	}

	c.Redirect(http.StatusFound, "/users?tab=employees&toast=create_success")
}

func DeleteEmployee(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.Redirect(http.StatusFound, "/users?tab=employees")
		return
	}
	actorID, _, _, _ := GetSessionUser(c)
	target, _ := repository.GetEmployeeByID(id)
	_ = repository.DeleteEmployee(id)
	detail := "Hapus karyawan ID: " + strconv.Itoa(id)
	if target != nil {
		detail = "Hapus karyawan: " + target.FullName + " (ID card: " + target.IDCardNumber + ")"
	}
	service.LogActivity(actorID, "delete_employee", "user", id, detail)
	c.Redirect(http.StatusFound, "/users?tab=employees&toast=delete_success")
}

func ToggleEmployeeActive(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "ID tidak valid"})
		return
	}
	emp, err := repository.GetEmployeeByID(id)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Karyawan tidak ditemukan"})
		return
	}
	newStatus := !emp.IsActive
	emp.IsActive = newStatus
	if err := repository.UpdateEmployee(emp); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengubah status"})
		return
	}
	actorID, _, _, _ := GetSessionUser(c)
	status := "aktif"
	if !newStatus {
		status = "nonaktif"
	}
	service.LogActivity(actorID, "toggle_employee", "user", id,
		"Set karyawan "+emp.FullName+" menjadi "+status)
	if newStatus {
		c.String(http.StatusOK, `<span class="badge badge-success gap-1">Aktif</span>`)
	} else {
		c.String(http.StatusOK, `<span class="badge badge-error gap-1">Nonaktif</span>`)
	}
}
