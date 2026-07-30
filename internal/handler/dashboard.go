package handler

import (
	"github.com/gin-gonic/gin"

	"sparepart-mgmt/internal/model"
	"sparepart-mgmt/internal/repository"
)

func ShowDashboard(c *gin.Context) {
	_, role, _, division := GetSessionUser(c)

	switch role {
	case "admin_sp", "spv_sp":
		showAdminDashboard(c)
	case "spv_pemohon":
		showSPVPemohonDashboard(c, division)
	default:
		showPemohonDashboard(c)
	}
}

func showAdminDashboard(c *gin.Context) {
	_, role, _, _ := GetSessionUser(c)

	lowStock, _ := repository.GetLowStockSpareparts()

	zeroStockCount := 0
	for _, s := range lowStock {
		if s.Stok == 0 {
			zeroStockCount++
		}
	}
	lowNotZeroCount := len(lowStock) - zeroStockCount

	var stage, niStage int
	if role == "admin_sp" {
		stage = 1
		niStage = 2 // NI status "stage1" = waiting admin_sp
	} else {
		stage = 3
		niStage = 3 // NI status "stage2" = waiting spv_sp
	}
	pendingRequests, _ := repository.GetRequestsByStage(stage)

	// Ambil NI pending sesuai role
	var pendingNI []model.NonInventoryRequest
	if role == "admin_sp" {
		pendingNI, _ = repository.GetNonInventoryByStage(niStage)
	} else {
		spvUserID, _, _, spvDivision := GetSessionUser(c)
		liveDivision := getLiveDivision(c, spvUserID)
		if liveDivision == "" {
			liveDivision = spvDivision
		}
		stage3, _ := repository.GetNonInventoryByStage(niStage)
		pendingNI = append(pendingNI, stage3...)
		if liveDivision != "" {
			pendingDiv, _ := repository.GetNonInventoryByStageAndDivision(liveDivision)
			pendingNI = append(pendingNI, pendingDiv...)
		}
	}
	pendingOrders, _ := repository.GetPendingRequestOrders()

	renderTemplate(c, "dashboard/admin.html", gin.H{
		"Title":              "Dashboard",
		"LowStockItems":      lowStock,
		"PendingRequests":    pendingRequests,
		"PendingCount":       len(pendingRequests),
		"PendingNI":          pendingNI,
		"PendingNICount":     len(pendingNI),
		"LowStockCount":      lowNotZeroCount,
		"ZeroStockCount":     zeroStockCount,
		"PendingOrders":      pendingOrders,
		"PendingOrdersCount": len(pendingOrders),
		"ShowRequestOrder":   true,
	})
}

func showSPVPemohonDashboard(c *gin.Context, division string) {
	userID, _, _, _ := GetSessionUser(c)
	lowStock, _ := repository.GetLowStockSpareparts()

	zeroStockCount := 0
	for _, s := range lowStock {
		if s.Stok == 0 {
			zeroStockCount++
		}
	}
	lowNotZeroCount := len(lowStock) - zeroStockCount

	liveDivision := getLiveDivision(c, userID)
	pendingRequests, _ := repository.GetRequestsByStageAndDivision(2, liveDivision)
	pendingNI, _ := repository.GetNonInventoryByStageAndDivision(liveDivision)

	renderTemplate(c, "dashboard/admin.html", gin.H{
		"Title":           "Dashboard",
		"LowStockItems":   lowStock,
		"PendingRequests": pendingRequests,
		"PendingCount":    len(pendingRequests),
		"PendingNI":       pendingNI,
		"PendingNICount":  len(pendingNI),
		"LowStockCount":   lowNotZeroCount,
		"ZeroStockCount":  zeroStockCount,
	})
}

func showPemohonDashboard(c *gin.Context) {
	userID, _, _, _ := GetSessionUser(c)

	waiting, approved, thisMonth, _ := repository.GetPemohonStats(userID)
	recentRequests, _ := repository.GetRecentRequestsByPemohon(userID, 5)

	renderTemplate(c, "dashboard/pemohon.html", gin.H{
		"Title":          "Dashboard Saya",
		"RecentRequests": recentRequests,
		"WaitingCount":   waiting,
		"ApprovedCount":  approved,
		"ThisMonthCount": thisMonth,
	})
}
