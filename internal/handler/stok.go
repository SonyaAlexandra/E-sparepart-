package handler

import (
	"github.com/gin-gonic/gin"

	"sparepart-mgmt/internal/model"
	"sparepart-mgmt/internal/repository"
)

func ShowStok(c *gin.Context) {
	_, role, _, _ := GetSessionUser(c)
	jenisMesin := c.Query("jenis_mesin")
	search := c.Query("search")
	statusFilter := c.Query("status")

	all, err := repository.GetAllSpareparts(jenisMesin, search)
	if err != nil {
		all = []model.Sparepart{}
	}

	var filtered []model.Sparepart
	for _, s := range all {
		if statusFilter == "" || s.StokStatus() == statusFilter {
			filtered = append(filtered, s)
		}
	}

	var tersedia, menipis, habis, nonstok int
	for _, s := range all {
		switch s.StokStatus() {
		case "tersedia":
			tersedia++
		case "menipis":
			menipis++
		case "habis":
			habis++
		case "nonstok":
			nonstok++
		}
	}

	jenisMesinList, _ := repository.GetDistinctJenisMesin()

	// Total value stok hanya untuk admin_sp dan spv_sp
	var totalValueStok float64
	isAdminOrSPV := role == "admin_sp" || role == "spv_sp"
	if isAdminOrSPV {
		totalValueStok, _ = repository.GetTotalStockValue()
	}

	renderTemplate(c, "stok/index.html", gin.H{
		"Title":           "Monitoring Stok",
		"Spareparts":      filtered,
		"JenisMesinList":  jenisMesinList,
		"FilterJenis":     jenisMesin,
		"Search":          search,
		"StatusFilter":    statusFilter,
		"CountTersedia":   tersedia,
		"CountMenipis":    menipis,
		"CountHabis":      habis,
		"CountNonstok":    nonstok,
		"TotalValueStok":  totalValueStok,
		"IsAdminOrSPV":    isAdminOrSPV,
		"TotalValueAlert": totalValueStok >= 3_900_000_000,
	})
}
