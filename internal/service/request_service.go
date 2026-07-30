package service

import (
	"fmt"

	"sparepart-mgmt/internal/model"
	"sparepart-mgmt/internal/repository"
)

func SubmitRequest(r *model.Request, items []model.RequestItem) (int, error) {
	requestID, err := repository.CreateRequest(r)
	if err != nil {
		return 0, fmt.Errorf("gagal membuat request: %w", err)
	}
	for _, item := range items {
		item.RequestID = requestID

		if item.SparepartID > 0 && item.NamaItem == "" {
			if sp, spErr := repository.GetSparepartByID(item.SparepartID); spErr == nil {
				item.NamaItem = sp.NamaItem
				item.KodeOracle = sp.KodeOracle
				item.NoPart = sp.NoPart
			}
		}
		if err := repository.AddRequestItem(&item); err != nil {
			return 0, fmt.Errorf("gagal menambah item: %w", err)
		}
	}
	if err := repository.UpdateRequestStage(requestID, 1, "stage1"); err != nil {
		return 0, err
	}

	NotifyAdminSP(requestID, r.NoWRWO, r.RequesterName)
	NotifyPemohon(r.PemohonID, r.NoWRWO, "stage1")
	LogActivity(r.PemohonID, "submit_request", "request", requestID,
		fmt.Sprintf("Request %s dikirim oleh %s", r.NoWRWO, r.RequesterName))

	return requestID, nil
}

func ApproveStage1(requestID, validatorID int, noWRWO, division string) error {

	validator, _ := repository.GetUserByID(validatorID)
	validatorName := ""
	if validator != nil {
		validatorName = validator.FullName
	}

	if err := repository.CreateValidation(&model.Validation{
		RequestID: requestID, Stage: 1, ValidatorID: validatorID, Action: "approved",
	}); err != nil {
		return err
	}
	if err := repository.UpdateRequestStage(requestID, 2, "stage2"); err != nil {
		return err
	}

	req, _ := repository.GetRequestByID(requestID)
	go func() {
		if division == "BM" {
			NotifySPVSPStage2BM(requestID, noWRWO, req.RequesterName)
		} else {
			NotifySPVPemohon(division, noWRWO)
		}
		if req != nil {
			NotifyPemohon(req.PemohonID, noWRWO, "stage2")
		}
	}()

	LogActivity(validatorID, "approve_stage1", "validation", requestID,
		fmt.Sprintf("%s menyetujui request %s (stage 1)", validatorName, noWRWO))
	return nil
}

func ApproveStage2(requestID, validatorID int, noWRWO string) error {
	validator, _ := repository.GetUserByID(validatorID)
	validatorName := ""
	if validator != nil {
		validatorName = validator.FullName
	}

	if err := repository.CreateValidation(&model.Validation{
		RequestID: requestID, Stage: 2, ValidatorID: validatorID, Action: "approved",
	}); err != nil {
		return err
	}
	if err := repository.UpdateRequestStage(requestID, 3, "stage3"); err != nil {
		return err
	}

	go func() {
		NotifySPVSP(requestID, noWRWO)
		req, _ := repository.GetRequestByID(requestID)
		if req != nil {
			NotifyPemohon(req.PemohonID, noWRWO, "stage3")
		}
	}()

	LogActivity(validatorID, "approve_stage2", "validation", requestID,
		fmt.Sprintf("%s menyetujui request %s (stage 2)", validatorName, noWRWO))
	return nil
}

func ApproveStage3(requestID, validatorID int, noWRWO string) error {
	validator, _ := repository.GetUserByID(validatorID)
	validatorName := ""
	if validator != nil {
		validatorName = validator.FullName
	}

	if err := repository.CreateValidation(&model.Validation{
		RequestID: requestID, Stage: 3, ValidatorID: validatorID, Action: "approved",
	}); err != nil {
		return err
	}
	if err := repository.UpdateRequestStage(requestID, 0, "approved"); err != nil {
		return err
	}

	items, err := repository.GetRequestItems(requestID)
	if err != nil {
		return err
	}
	for _, item := range items {
		qty := item.Jumlah
		if item.JumlahDisetujui != nil {
			qty = *item.JumlahDisetujui
		}
		if err := repository.DeductStock(item.SparepartID, qty); err != nil {
			return fmt.Errorf("gagal kurangi stok item %d: %w", item.SparepartID, err)
		}
		sp, err := repository.GetSparepartByID(item.SparepartID)
		if err == nil && sp.Stok <= sp.MinStok {
			NotifyLowStock(*sp)
		}
	}

	go func() {
		req, _ := repository.GetRequestByID(requestID)
		if req != nil {
			NotifyPemohon(req.PemohonID, noWRWO, "approved")
		}
	}()

	LogActivity(validatorID, "approve_final", "validation", requestID,
		fmt.Sprintf("%s menyetujui final request %s, stok dikurangi", validatorName, noWRWO))
	return nil
}

func RejectRequest(requestID, validatorID, stage int, noWRWO, reason string) error {

	validator, _ := repository.GetUserByID(validatorID)
	validatorName := "Validator"
	if validator != nil {
		validatorName = validator.FullName
	}

	if err := repository.CreateValidation(&model.Validation{
		RequestID:   requestID,
		Stage:       stage,
		ValidatorID: validatorID,
		Action:      "rejected",
		Reason:      reason,
	}); err != nil {
		return err
	}
	if err := repository.RejectRequest(requestID, reason); err != nil {
		return err
	}

	go func() {
		req, _ := repository.GetRequestByID(requestID)
		if req != nil {
			NotifyPemohonRejected(req.PemohonID, noWRWO, stage, validatorName, reason)
		}
	}()

	LogActivity(validatorID, "reject_request", "validation", requestID,
		fmt.Sprintf("Request %s ditolak pada stage %d oleh %s: %s", noWRWO, stage, validatorName, reason))
	return nil
}
