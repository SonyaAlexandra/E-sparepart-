package service

import (
	"fmt"

	"sparepart-mgmt/internal/model"
	"sparepart-mgmt/internal/repository"
)

func NotifyAdminSP(requestID int, noWRWO, requesterName string) {
	msg := fmt.Sprintf("Ada request baru menunggu validasi Admin SP: %s", noWRWO)
	admins, _ := repository.GetAllAdminSP()
	for _, u := range admins {
		repository.CreateNotification(&model.Notification{UserID: u.ID, Message: msg})
	}
}

func NotifySPVPemohon(division, noWRWO string) {
	spv, err := repository.GetSPVPemohonByDivision(division)
	if err != nil {
		return
	}
	msg := fmt.Sprintf("Ada request menunggu validasi Anda (SPV Pemohon %s): %s", division, noWRWO)
	repository.CreateNotification(&model.Notification{UserID: spv.ID, Message: msg})
}

func NotifySPVSP(requestID int, noWRWO string) {
	msg := fmt.Sprintf("Ada request menunggu validasi akhir SPV SP (Tahap 3): %s", noWRWO)
	spvs, _ := repository.GetAllSPVSP()
	for _, u := range spvs {
		repository.CreateNotification(&model.Notification{UserID: u.ID, Message: msg})
	}
}

func NotifySPVSPStage2BM(requestID int, noWRWO, requesterName string) {
	msg := fmt.Sprintf("Ada request dari divisi BM menunggu validasi Anda (Tahap 2 - SPV Pemohon BM): %s", noWRWO)
	spvs, _ := repository.GetAllSPVSP()
	for _, u := range spvs {
		repository.CreateNotification(&model.Notification{UserID: u.ID, Message: msg})
	}
}

func NotifyPemohon(pemohonID int, noWRWO, status string) {
	var msg string
	switch status {
	case "stage1":
		msg = fmt.Sprintf("Request %s sedang diproses Admin SP (Tahap 1)", noWRWO)
	case "stage2":
		msg = fmt.Sprintf("Request %s sedang diproses SPV Pemohon (Tahap 2)", noWRWO)
	case "stage3":
		msg = fmt.Sprintf("Request %s sedang diproses SPV SP (Tahap 3)", noWRWO)
	case "approved":
		msg = fmt.Sprintf("Request %s telah DISETUJUI. Silakan ambil sparepart.", noWRWO)
	case "rejected":
		msg = fmt.Sprintf("Request %s telah DITOLAK. Cek detail untuk alasan.", noWRWO)
	default:
		msg = fmt.Sprintf("Status request %s diperbarui: %s", noWRWO, status)
	}
	repository.CreateNotification(&model.Notification{UserID: pemohonID, Message: msg})
}

func NotifyPemohonRejected(pemohonID int, noWRWO string, stage int, validatorName, reason string) {
	msg := fmt.Sprintf("Request %s DITOLAK pada tahap %d oleh %s. Alasan: %s",
		noWRWO, stage, validatorName, reason)
	repository.CreateNotification(&model.Notification{UserID: pemohonID, Message: msg})
}

func NotifyLowStock(sp model.Sparepart) {}

func LogActivity(userID int, action, entityType string, entityID int, detail string) {
	repository.CreateActivityLog(&model.ActivityLog{
		UserID:     userID,
		Action:     action,
		EntityType: entityType,
		EntityID:   entityID,
		Detail:     detail,
	})
}
