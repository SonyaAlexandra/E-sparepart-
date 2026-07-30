package handler

import (
	"fmt"
	"net/http"
	"strconv"
	"strings"

	"github.com/gin-gonic/gin"

	"sparepart-mgmt/internal/model"
	"sparepart-mgmt/internal/repository"
	"sparepart-mgmt/internal/service"
)

func SubmitRequestOrder(c *gin.Context) {
	userID, _, fullName, _ := GetSessionUser(c)

	sparepartIDs := c.PostFormArray("sparepart_id[]")
	namaItems := c.PostFormArray("nama_item[]")
	kodeOracles := c.PostFormArray("kode_oracle[]")
	jumlahStrs := c.PostFormArray("jumlah[]")

	if len(sparepartIDs) == 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Tambahkan minimal 1 sparepart ke request order."})
		return
	}

	ro := &model.RequestOrder{
		PemohonID:     userID,
		RequesterName: fullName,
	}
	orderID, err := repository.CreateRequestOrder(ro)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menyimpan request order."})
		return
	}

	var itemNames []string
	for i, idStr := range sparepartIDs {
		spID, err := strconv.Atoi(idStr)
		if err != nil || spID == 0 {
			continue
		}
		jumlah := 1
		if i < len(jumlahStrs) {
			if j, e := strconv.Atoi(jumlahStrs[i]); e == nil && j > 0 {
				jumlah = j
			}
		}
		nama := ""
		if i < len(namaItems) {
			nama = namaItems[i]
		}
		kode := ""
		if i < len(kodeOracles) {
			kode = kodeOracles[i]
		}
		item := &model.RequestOrderItem{
			RequestOrderID:     orderID,
			SparepartID:        spID,
			NamaItemSnapshot:   nama,
			KodeOracleSnapshot: kode,
			Jumlah:             jumlah,
		}
		_ = repository.AddRequestOrderItem(item)
		itemNames = append(itemNames, fmt.Sprintf("%s x%d", nama, jumlah))
	}

	go service.LogActivity(userID, "create_request_order", "request_order", orderID,
		fmt.Sprintf("Request Order #%d: %s", orderID, strings.Join(itemNames, ", ")))

	// Notifikasi: beritahu Admin SP ada Request Order baru
	go service.NotifyAdminSP(orderID, fmt.Sprintf("Request Order #%d", orderID), fullName)

	c.JSON(http.StatusOK, gin.H{"message": "Request Order berhasil dikirim. Admin akan segera menambahkan stok."})
}

func MarkRequestOrderDone(c *gin.Context) {
	idStr := c.Param("id")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "ID tidak valid."})
		return
	}

	ro, err := repository.GetRequestOrderByID(id)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Request Order tidak ditemukan."})
		return
	}
	if ro.Status == "completed" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Request Order sudah selesai."})
		return
	}

	if err := repository.CompleteRequestOrder(id); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal memperbarui status."})
		return
	}

	if ro.PemohonID > 0 {
		itemCount := len(ro.Items)
		var detail string
		if itemCount == 1 {
			detail = ro.Items[0].NamaItemSnapshot
		} else {
			detail = fmt.Sprintf("%d sparepart", itemCount)
		}
		msg := fmt.Sprintf(" Request Order Anda (%s) sudah diproses. Silakan cek katalog.", detail)
		go repository.CreateNotification(&model.Notification{
			UserID:  ro.PemohonID,
			Message: msg,
		})
	}

	adminID, _, _, _ := GetSessionUser(c)
	go service.LogActivity(adminID, "complete_request_order", "request_order", id,
		fmt.Sprintf("Completed Request Order #%d (%d items)", id, len(ro.Items)))

	c.JSON(http.StatusOK, gin.H{"message": "Request Order ditandai selesai."})
}
