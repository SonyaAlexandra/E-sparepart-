package handler

import (
	"html/template"
	"net/http"
	"path/filepath"
	"strings"
	"time"

	"github.com/gin-gonic/gin"

	"sparepart-mgmt/internal/model"
	"sparepart-mgmt/internal/repository"
)

func renderTemplate(c *gin.Context, page string, data gin.H) {
	userID, role, name, division := GetSessionUser(c)

	notifCount := 0
	if userID > 0 {
		notifs, _ := repository.GetUnreadNotifications(userID)
		notifCount = len(notifs)
	}

	if data == nil {
		data = gin.H{}
	}
	data["UserID"] = userID
	data["UserRole"] = role
	data["UserName"] = name
	data["UserDivision"] = division
	data["NotifCount"] = notifCount
	data["CurrentPath"] = c.Request.URL.Path

	tmplFiles := []string{
		"web/templates/layout/base.html",
		"web/templates/layout/sidebar.html",
		"web/templates/" + page,
	}

	tmpl, err := template.New(filepath.Base(page)).Funcs(templateFuncs()).ParseFiles(tmplFiles...)
	if err != nil {
		c.String(http.StatusInternalServerError, "Template error: %v", err)
		return
	}

	if err := tmpl.ExecuteTemplate(c.Writer, "base", data); err != nil {
		c.String(http.StatusInternalServerError, "Render error: %v", err)
	}
}

func renderStandalone(c *gin.Context, page string, data gin.H) {
	tmpl, err := template.New(filepath.Base(page)).Funcs(templateFuncs()).
		ParseFiles("web/templates/" + page)
	if err != nil {
		c.String(http.StatusInternalServerError, "Template error: %v", err)
		return
	}
	if err := tmpl.Execute(c.Writer, data); err != nil {
		c.String(http.StatusInternalServerError, "Render error: %v", err)
	}
}

func renderHTMX(c *gin.Context, partial string, data gin.H) {
	tmpl, err := template.New(filepath.Base(partial)).Funcs(templateFuncs()).
		ParseFiles("web/templates/" + partial)
	if err != nil {
		c.String(http.StatusInternalServerError, "Template error: %v", err)
		return
	}
	if err := tmpl.Execute(c.Writer, data); err != nil {
		c.String(http.StatusInternalServerError, "Render error: %v", err)
	}
}

func templateFuncs() template.FuncMap {
	return template.FuncMap{
		"formatDate": func(t time.Time) string {
			return t.Format("02 Jan 2006")
		},
		"formatDateTime": func(t time.Time) string {
			return t.Format("02 Jan 2006 15:04")
		},
		"formatRupiah": func(f float64) string {
			return formatRupiah(f)
		},
		"statusClass": func(status string) string {
			switch status {
			case "approved":
				return "badge-success"
			case "rejected":
				return "badge-error"
			case "pending", "stage1", "stage2", "stage3":
				return "badge-warning"
			default:
				return "badge-ghost"
			}
		},
		"statusLabel": func(status string) string {
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
		},
		"stokClass": func(s model.Sparepart) string {
			switch s.StokStatus() {
			case "tersedia":
				return "badge-success"
			case "menipis":
				return "badge-warning"
			case "habis":
				return "badge-error"
			}
			return "badge-ghost"
		},
		"seq": func(n int) []int {
			s := make([]int, n)
			for i := range s {
				s[i] = i + 1
			}
			return s
		},
		"add": func(a, b int) int { return a + b },
		"isActive": func(currentPath, target string) bool {
			return currentPath == target
		},
		"isActivePrefix": func(currentPath, prefix string) bool {
			return len(currentPath) >= len(prefix) && currentPath[:len(prefix)] == prefix
		},
		"mul":  func(qty int, price float64) float64 { return float64(qty) * price },
		"even": func(i int) bool { return i%2 == 0 },

		"hasDivision": func(divisionField, div string) bool {
			for _, d := range strings.Split(divisionField, ",") {
				if strings.TrimSpace(d) == strings.TrimSpace(div) {
					return true
				}
			}
			return false
		},

		"niStatusLabel": func(status string) string {
			switch status {
			case "pending":
				return "Menunggu SPV"
			case "stage1":
				return "Menunggu Admin SP"
			case "stage2":
				return "Menunggu SPV SP"
			case "approved":
				return "Disetujui"
			case "cancelled":
				return "Dibatalkan"
			}
			return status
		},
		"niStatusClass": func(status string) string {
			switch status {
			case "approved":
				return "badge-success"
			case "cancelled":
				return "badge-error"
			case "pending", "stage1", "stage2":
				return "badge-warning"
			}
			return "badge-ghost"
		},

		"slice": func(s string, n int) string {
			if len(s) == 0 {
				return "?"
			}
			if n > len(s) {
				n = len(s)
			}
			return s[:n]
		},
	}
}

func formatRupiah(f float64) string {
	n := int64(f)
	result := ""
	neg := n < 0
	if neg {
		n = -n
	}
	s := formatInt(n)
	for i, c := range s {
		if i > 0 && (len(s)-i)%3 == 0 {
			result += "."
		}
		result += string(c)
	}
	if neg {
		result = "-" + result
	}
	return "Rp " + result
}

func formatInt(n int64) string {
	if n == 0 {
		return "0"
	}
	s := ""
	for n > 0 {
		s = string(rune('0'+n%10)) + s
		n /= 10
	}
	return s
}
