package handler

import (
	"net/http"
	"strconv"
	"strings"

	"github.com/gin-gonic/gin"
	"golang.org/x/crypto/bcrypt"

	"sparepart-mgmt/internal/model"
	"sparepart-mgmt/internal/repository"
	"sparepart-mgmt/internal/service"
)

func ShowUsers(c *gin.Context) {
	tab := c.Query("tab")
	showEmployees := tab == "employees"
	roleFilter := c.Query("role")
	search := strings.TrimSpace(c.Query("search"))

	data := gin.H{
		"Title":         "Kelola User",
		"ShowEmployees": showEmployees,
		"Search":        search,
		"Roles": []map[string]string{
			{"value": "admin_sp", "label": "Admin SP"},
			{"value": "spv_sp", "label": "SPV SP"},
			{"value": "spv_pemohon", "label": "SPV Pemohon"},
			{"value": "pemohon", "label": "Pemohon"},
		},
	}

	if showEmployees {
		employees, err := repository.GetAllEmployees(search)
		if err != nil {
			employees = []model.EmployeeIDCard{}
		}
		data["Employees"] = employees
	} else {
		users, err := repository.GetAllUsers(roleFilter, search)
		if err != nil {
			users = []model.User{}
		}
		data["Users"] = users
		data["RoleFilter"] = roleFilter
	}

	renderTemplate(c, "users/index.html", data)
}

func ShowCreateUserForm(c *gin.Context) {
	renderTemplate(c, "users/form.html", gin.H{
		"Title":  "Tambah User",
		"IsEdit": false,
		"Roles": []map[string]string{
			{"value": "admin_sp", "label": "Admin SP"},
			{"value": "spv_sp", "label": "SPV SP"},
			{"value": "spv_pemohon", "label": "SPV Pemohon"},
			{"value": "pemohon", "label": "Pemohon"},
		},
		"Divisions": []string{"MTC1", "MTC2", "UTL", "BM"},
	})
}

func ShowEditUserForm(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.Redirect(http.StatusFound, "/users")
		return
	}

	user, err := repository.GetUserByID(id)
	if err != nil {
		c.Redirect(http.StatusFound, "/users")
		return
	}

	renderTemplate(c, "users/form.html", gin.H{
		"Title":  "Edit User",
		"IsEdit": true,
		"User":   user,
		"Roles": []map[string]string{
			{"value": "admin_sp", "label": "Admin SP"},
			{"value": "spv_sp", "label": "SPV SP"},
			{"value": "spv_pemohon", "label": "SPV Pemohon"},
			{"value": "pemohon", "label": "Pemohon"},
		},
		"Divisions": []string{"MTC1", "MTC2", "UTL", "BM"},
	})
}

func SaveUser(c *gin.Context) {
	actorID, _, _, _ := GetSessionUser(c)
	idStr := strings.TrimSpace(c.PostForm("id"))
	isEdit := idStr != "" && idStr != "0"

	fullName := strings.TrimSpace(c.PostForm("full_name"))
	username := strings.TrimSpace(c.PostForm("username"))
	password := strings.TrimSpace(c.PostForm("password"))
	role := strings.TrimSpace(c.PostForm("role"))
	divisionArr := c.PostFormArray("division")
	division := strings.Join(divisionArr, ",")
	idCardNumber := strings.TrimSpace(c.PostForm("id_card_number"))

	formData := gin.H{
		"Roles": []map[string]string{
			{"value": "admin_sp", "label": "Admin SP"},
			{"value": "spv_sp", "label": "SPV SP"},
			{"value": "spv_pemohon", "label": "SPV Pemohon"},
			{"value": "pemohon", "label": "Pemohon"},
		},
		"Divisions": []string{"MTC1", "MTC2", "UTL", "BM"},
	}

	if fullName == "" || username == "" || role == "" {
		formData["Error"] = "Nama lengkap, username, dan role wajib diisi"
		formData["IsEdit"] = isEdit
		if isEdit {
			formData["Title"] = "Edit User"
		} else {
			formData["Title"] = "Tambah User"
			if password == "" {
				formData["Error"] = "Password wajib diisi untuk user baru"
			}
		}
		renderTemplate(c, "users/form.html", formData)
		return
	}

	if !isEdit && password == "" {
		formData["Error"] = "Password wajib diisi untuk user baru"
		formData["IsEdit"] = false
		formData["Title"] = "Tambah User"
		renderTemplate(c, "users/form.html", formData)
		return
	}

	validRoles := map[string]bool{"admin_sp": true, "spv_sp": true, "spv_pemohon": true, "pemohon": true}
	if !validRoles[role] {
		formData["Error"] = "Role tidak valid"
		formData["IsEdit"] = isEdit
		renderTemplate(c, "users/form.html", formData)
		return
	}

	if role == "spv_pemohon" && division == "" {
		formData["Error"] = "Divisi wajib diisi untuk SPV Pemohon"
		formData["IsEdit"] = isEdit
		formData["Title"] = "Tambah/Edit User"
		renderTemplate(c, "users/form.html", formData)
		return
	}
	if role != "spv_pemohon" && role != "spv_sp" {
		division = ""
	}

	var userID int
	if isEdit {
		var err error
		userID, err = strconv.Atoi(idStr)
		if err != nil {
			c.Redirect(http.StatusFound, "/users")
			return
		}
	}
	_ = actorID

	taken, err := repository.IsUsernameTaken(username, userID)
	if err != nil || taken {
		formData["Error"] = "Username sudah digunakan, pilih username lain"
		formData["IsEdit"] = isEdit
		renderTemplate(c, "users/form.html", formData)
		return
	}

	u := &model.User{
		ID:           userID,
		Username:     username,
		FullName:     fullName,
		Role:         role,
		Division:     division,
		IDCardNumber: idCardNumber,
	}

	if isEdit {
		if err := repository.UpdateUser(u); err != nil {
			formData["Error"] = "Gagal menyimpan perubahan: " + err.Error()
			formData["IsEdit"] = true
			formData["Title"] = "Edit User"
			renderTemplate(c, "users/form.html", formData)
			return
		}
		if password != "" {
			hash, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
			if err == nil {
				_ = repository.UpdateUserPassword(userID, string(hash))
			}
		}
		service.LogActivity(actorID, "update_user", "user", userID,
			"Edit user: "+username+" ("+role+")")
	} else {
		hash, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
		if err != nil {
			formData["Error"] = "Gagal memproses password"
			formData["IsEdit"] = false
			formData["Title"] = "Tambah User"
			renderTemplate(c, "users/form.html", formData)
			return
		}
		u.PasswordHash = string(hash)
		if err := repository.CreateUser(u); err != nil {
			formData["Error"] = "Gagal menyimpan user: " + err.Error()
			formData["IsEdit"] = false
			formData["Title"] = "Tambah User"
			renderTemplate(c, "users/form.html", formData)
			return
		}
		service.LogActivity(actorID, "create_user", "user", 0,
			"Tambah user baru: "+username+" ("+role+")")
	}

	toastParam := "create_success"
	if isEdit {
		toastParam = "edit_success"
	}
	c.Redirect(http.StatusFound, "/users?toast="+toastParam)
}

func DeleteUser(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.Redirect(http.StatusFound, "/users?toast=delete_error")
		return
	}

	sessionUserID, _, _, _ := GetSessionUser(c)
	if id == sessionUserID {
		c.Redirect(http.StatusFound, "/users?toast=self_delete_error")
		return
	}

	target, _ := repository.GetUserByID(id)

	if err := repository.DeleteUser(id); err != nil {
		c.Redirect(http.StatusFound, "/users?toast=delete_error")
		return
	}

	detail := "Hapus user ID: " + strconv.Itoa(id)
	if target != nil {
		detail = "Hapus user: " + target.Username + " (" + target.Role + ")"
	}
	service.LogActivity(sessionUserID, "delete_user", "user", id, detail)

	c.Redirect(http.StatusFound, "/users?toast=delete_success")
}
