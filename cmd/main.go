package main

import (
	"bufio"
	"log"
	"os"
	"strings"

	"github.com/gin-gonic/gin"
	"github.com/gorilla/sessions"

	"sparepart-mgmt/internal/config"
	"sparepart-mgmt/internal/handler"
)

func main() {
	loadEnv(".env")
	config.ConnectDB()
	sessionKey := os.Getenv("SESSION_KEY")
	if sessionKey == "" {
		log.Fatal("SESSION_KEY belum diset di environment")
	}
	handler.Store = sessions.NewCookieStore([]byte(sessionKey))
	handler.Store.Options = &sessions.Options{
		Path:     "/",
		MaxAge:   86400 * 7,
		HttpOnly: true,
	}

	r := gin.Default()

	r.Static("/static", "./web/static")
	r.Static("/uploads", "./uploads")

	r.GET("/login", handler.ShowLogin)
	r.POST("/login", handler.DoLogin)
	r.GET("/logout", handler.DoLogout)
	r.GET("/", func(c *gin.Context) {
		session, _ := handler.Store.Get(c.Request, "sp-session")
		if role, _ := session.Values["user_role"].(string); role == "pemohon" {
			c.Redirect(302, "/stok")
		} else {
			c.Redirect(302, "/dashboard")
		}
	})

	api := r.Group("/api")
	{
		api.POST("/rfid/scan", handler.ScanRFIDFromDevice)
		api.GET("/rfid/stream", handler.StreamRFID)
		api.POST("/rfid/session", handler.RequireAuth, handler.CreateRFIDSession)
		// ── Fingerprint U.are.U 4500 ─────────────────────────────────────────
		api.GET("/fingerprint/templates", handler.FingerprintGetTemplates)
		api.POST("/fingerprint/identify", handler.FingerprintIdentify)
		api.POST("/fingerprint/enroll", handler.HandleFingerprintEnroll)
		api.POST("/fingerprint/register-scan", handler.FingerprintRegisterScan)
		// On-demand scan control (browser → server → listener polling)
		api.POST("/fingerprint/scan-request", handler.FingerprintScanRequest)
		api.POST("/fingerprint/scan-cancel", handler.FingerprintScanCancel)
		api.POST("/fingerprint/capture-done", handler.FingerprintCaptureDone)
		api.GET("/fingerprint/scan-status", handler.FingerprintScanStatus)
	}
	auth := r.Group("/")
	auth.Use(handler.RequireAuth)
	{
		auth.GET("/dashboard",
			handler.RequireRole("admin_sp", "spv_sp", "spv_pemohon"),
			handler.ShowDashboard)
		auth.GET("/notifikasi", handler.ShowNotifications)

		auth.GET("/katalog", handler.ShowKatalog)
		auth.GET("/katalog/search", handler.SearchSpareparts)
		auth.GET("/api/sparepart/oracle", handler.SearchByOracleCode)
		auth.GET("/katalog/:id/detail", handler.ShowKatalogDetail)
		auth.GET("/katalog/:id/pdf", handler.DownloadKatalogPDF)

		adminOnly := auth.Group("/")
		adminOnly.Use(handler.RequireRole("admin_sp", "spv_sp"))
		{
			adminOnly.GET("/katalog/form", handler.ShowKatalogForm)
			adminOnly.GET("/katalog/:id/edit", handler.ShowKatalogForm)
			adminOnly.POST("/katalog/save", handler.SaveKatalog)
			adminOnly.POST("/katalog/:id/delete", handler.DeleteKatalog)

			// Kelola User
			adminOnly.GET("/users", handler.ShowUsers)
			adminOnly.GET("/users/create", handler.ShowCreateUserForm)
			adminOnly.GET("/users/:id/edit", handler.ShowEditUserForm)
			adminOnly.POST("/users/save", handler.SaveUser)
			adminOnly.POST("/users/:id/delete", handler.DeleteUser)

			// Karyawan Pemohon
			adminOnly.GET("/employees", handler.ShowEmployees)
			adminOnly.GET("/employees/create", handler.ShowCreateEmployeeForm)
			adminOnly.GET("/employees/:id/edit", handler.ShowEditEmployeeForm)
			adminOnly.POST("/employees/save", handler.SaveEmployee)
			adminOnly.POST("/employees/:id/delete", handler.DeleteEmployee)
			adminOnly.POST("/employees/:id/toggle", handler.ToggleEmployeeActive)
		}

		auth.GET("/stok",
			handler.RequireRole("admin_sp", "spv_sp", "spv_pemohon", "pemohon"),
			handler.ShowStok)

		auth.GET("/riwayat-pengambilan",
			handler.RequireRole("admin_sp", "spv_sp", "spv_pemohon", "pemohon"),
			handler.ShowAllRequests)
		auth.GET("/riwayat-pengambilan/:id",
			handler.RequireRole("admin_sp", "spv_sp", "spv_pemohon", "pemohon"),
			handler.ShowAllRequestDetail)

		pengambilan := auth.Group("/pengambilan")
		pengambilan.Use(handler.RequireRole("pemohon"))
		{
			pengambilan.GET("/form", handler.ShowPengambilanForm)
			pengambilan.POST("/submit", handler.SubmitRequest)
			pengambilan.GET("/status/:id", handler.ShowRequestStatus)
		}

		auth.POST("/request-order/submit",
			handler.RequireRole("pemohon"),
			handler.SubmitRequestOrder)
		auth.POST("/request-order/:id/done",
			handler.RequireRole("admin_sp", "spv_sp"),
			handler.MarkRequestOrderDone)

		validasi := auth.Group("/validasi")
		validasi.Use(handler.RequireRole("admin_sp", "spv_sp", "spv_pemohon"))
		{
			validasi.GET("", handler.ShowValidasiList)
			validasi.GET("/:id", handler.ShowValidasiDetail)
			validasi.POST("/:id/approve", handler.DoApprove)
			validasi.POST("/:id/reject", handler.DoReject)
			validasi.POST("/item/:id/qty", handler.UpdateItemQty)
			validasi.DELETE("/item/:id", handler.DeleteItem)
		}

		auth.GET("/pengambilan/semua",
			handler.RequireRole("admin_sp", "spv_sp", "spv_pemohon", "pemohon"),
			handler.ShowAllRequests)
		auth.GET("/pengambilan/semua/:id",
			handler.RequireRole("admin_sp", "spv_sp", "spv_pemohon", "pemohon"),
			handler.ShowAllRequestDetail)
		auth.GET("/pengambilan/semua/excel",
			handler.RequireRole("admin_sp", "spv_sp", "spv_pemohon", "pemohon"),
			handler.ExportAllRequestsExcel)

		penerimaan := auth.Group("/penerimaan")
		penerimaan.Use(handler.RequireRole("admin_sp", "spv_sp"))
		{
			penerimaan.GET("", handler.ShowPenerimaan)
			penerimaan.POST("/save", handler.SavePenerimaan)
			penerimaan.GET("/excel", handler.ExportPenerimaanExcel)
		}

		laporan := auth.Group("/laporan")
		laporan.Use(handler.RequireRole("admin_sp", "spv_sp"))
		{
			laporan.GET("", handler.ShowLaporan)
			laporan.GET("/pdf", handler.ExportLaporanPDF)
			laporan.GET("/excel", handler.ExportLaporanExcel)

			sparepartKeluar := auth.Group("/pengambilan/keluar")
			sparepartKeluar.Use(handler.RequireRole("admin_sp", "spv_sp"))
			{
				sparepartKeluar.GET("", handler.ShowSparepartKeluar)
				sparepartKeluar.GET("/excel", handler.ExportSparepartKeluarExcel)
			}
		}
		log := auth.Group("/log")
		log.Use(handler.RequireRole("admin_sp", "spv_sp"))
		{
			log.GET("", handler.ShowLogAktivitas)
		}

		auth.GET("/struk/:id/pdf", handler.DownloadStrukPDF)

		// ── Non-Inventory ─────────────────────────────────
		// Pemohon: buat & lihat permintaan sendiri
		niPemohon := auth.Group("/non-inventory/permintaan")
		niPemohon.Use(handler.RequireRole("pemohon"))
		{
			niPemohon.GET("", handler.ShowNIPermintaan)
			niPemohon.GET("/baru", handler.ShowNIFormBaru)
			niPemohon.POST("/submit", handler.SubmitNIPermintaan)
		}

		niValidasi := auth.Group("/non-inventory/validasi")
		niValidasi.Use(handler.RequireRole("admin_sp", "spv_sp", "spv_pemohon"))
		{
			niValidasi.GET("", handler.ShowNIValidasi)
		}

		auth.GET("/non-inventory/detail/:id",
			handler.RequireRole("pemohon", "admin_sp", "spv_sp", "spv_pemohon"),
			handler.ShowNIDetail)

		auth.POST("/non-inventory/:id/release",
			handler.RequireRole("admin_sp", "spv_sp", "spv_pemohon"),
			handler.NIRelease)
		auth.POST("/non-inventory/:id/cancel",
			handler.RequireRole("admin_sp", "spv_sp", "spv_pemohon"),
			handler.NICancel)

		auth.GET("/non-inventory/:id/pdf",
			handler.RequireRole("pemohon", "admin_sp", "spv_sp", "spv_pemohon"),
			handler.NIDownloadPDF)

		auth.GET("/non-inventory/riwayat",
			handler.RequireRole("pemohon", "admin_sp", "spv_sp", "spv_pemohon"),
			handler.ShowNIRiwayat)
		auth.POST("/non-inventory/:id/toggle-done",
			handler.RequireRole("pemohon", "admin_sp", "spv_sp", "spv_pemohon"),
			handler.ToggleNIDone)
	}

	// ─── 8. Start server ─────────────────────────────────────
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}
	r.Run(":" + port)
}

func loadEnv(filename string) {
	f, err := os.Open(filename)
	if err != nil {
		return
	}
	defer f.Close()

	scanner := bufio.NewScanner(f)
	for scanner.Scan() {
		line := strings.TrimSpace(scanner.Text())
		if line == "" || strings.HasPrefix(line, "#") {
			continue
		}
		parts := strings.SplitN(line, "=", 2)
		if len(parts) != 2 {
			continue
		}
		key := strings.TrimSpace(parts[0])
		val := strings.TrimSpace(parts[1])
		if os.Getenv(key) == "" {
			os.Setenv(key, val)
		}
	}
}
