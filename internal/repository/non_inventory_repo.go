package repository

import (
	"context"
	"fmt"
	"time"

	"sparepart-mgmt/internal/config"
	"sparepart-mgmt/internal/model"
)

// No BPJT generator: MM/YY/DD-SeqHarian  (reset every day)

func GenerateNoBPJT(now time.Time) (string, error) {
	today := now.Format("2006-01-02") // date key
	mm := now.Format("01")
	yy := now.Format("06")
	dd := now.Format("02")

	var seq int
	err := config.DB.QueryRow(context.Background(), `
		INSERT INTO bpjt_daily_counter (counter_date, last_seq)
		VALUES ($1, 1)
		ON CONFLICT (counter_date)
		DO UPDATE SET last_seq = bpjt_daily_counter.last_seq + 1
		RETURNING last_seq
	`, today).Scan(&seq)
	if err != nil {
		return "", fmt.Errorf("generate no_bpjt: %w", err)
	}
	return fmt.Sprintf("%s/%s/%s-%d", mm, yy, dd, seq), nil
}

func PredictNextNoBPJT(now time.Time) (string, error) {
	today := now.Format("2006-01-02")
	mm := now.Format("01")
	yy := now.Format("06")
	dd := now.Format("02")

	var lastSeq int
	err := config.DB.QueryRow(context.Background(), `
		SELECT COALESCE(last_seq, 0) FROM bpjt_daily_counter WHERE counter_date = $1
	`, today).Scan(&lastSeq)
	if err != nil {
		lastSeq = 0
	}

	return fmt.Sprintf("%s/%s/%s-%d", mm, yy, dd, lastSeq+1), nil
}

func CreateNonInventoryRequest(r *model.NonInventoryRequest) (int, error) {
	var id int
	err := config.DB.QueryRow(context.Background(), `
		INSERT INTO non_inventory_requests
			(no_bpjt, pemohon_id, nama_pemohon, seksi_divisi, tanggal_pemakaian, keterangan, lampiran_url, status, current_stage)
		VALUES ($1,$2,$3,$4,$5,$6,$7,'pending',0)
		RETURNING id
	`, r.NoBPJT, r.PemohonID, r.NamaPemohon, r.SeksiDivisi,
		r.TanggalPemakaian, r.Keterangan, r.LampiranURL,
	).Scan(&id)
	return id, err
}

func AddNonInventoryItem(item *model.NonInventoryItem) error {
	_, err := config.DB.Exec(context.Background(), `
		INSERT INTO non_inventory_items (request_id, deskripsi, qty, peruntukan)
		VALUES ($1,$2,$3,$4)
	`, item.RequestID, item.Deskripsi, item.Qty, item.Peruntukan)
	return err
}

func GetNonInventoryByID(id int) (*model.NonInventoryRequest, error) {
	r := &model.NonInventoryRequest{}
	err := config.DB.QueryRow(context.Background(), `
		SELECT id, no_bpjt, pemohon_id, nama_pemohon, seksi_divisi,
		       tanggal_pemakaian, keterangan, COALESCE(lampiran_url,''),
		       status, current_stage, is_done, submitted_at, updated_at
		FROM non_inventory_requests WHERE id = $1
	`, id).Scan(
		&r.ID, &r.NoBPJT, &r.PemohonID, &r.NamaPemohon, &r.SeksiDivisi,
		&r.TanggalPemakaian, &r.Keterangan, &r.LampiranURL,
		&r.Status, &r.CurrentStage, &r.IsDone, &r.SubmittedAt, &r.UpdatedAt,
	)
	if err != nil {
		return nil, err
	}

	items, _ := GetNonInventoryItems(id)
	r.Items = items

	approvals, _ := GetNonInventoryApprovals(id)
	r.Approvals = approvals

	return r, nil
}

func GetNonInventoryItems(requestID int) ([]model.NonInventoryItem, error) {
	rows, err := config.DB.Query(context.Background(), `
		SELECT id, request_id, deskripsi, qty, peruntukan
		FROM non_inventory_items WHERE request_id = $1 ORDER BY id
	`, requestID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var items []model.NonInventoryItem
	for rows.Next() {
		var it model.NonInventoryItem
		if err := rows.Scan(&it.ID, &it.RequestID, &it.Deskripsi, &it.Qty, &it.Peruntukan); err != nil {
			continue
		}
		items = append(items, it)
	}
	return items, nil
}

func GetNonInventoryApprovals(requestID int) ([]model.NonInventoryApproval, error) {
	rows, err := config.DB.Query(context.Background(), `
		SELECT a.id, a.request_id, a.stage, a.approver_id, a.action, a.actioned_at,
		       COALESCE(u.full_name,'')
		FROM non_inventory_approvals a
		LEFT JOIN users u ON u.id = a.approver_id
		WHERE a.request_id = $1 ORDER BY a.stage
	`, requestID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var list []model.NonInventoryApproval
	for rows.Next() {
		var a model.NonInventoryApproval
		if err := rows.Scan(&a.ID, &a.RequestID, &a.Stage, &a.ApproverID, &a.Action, &a.ActionedAt, &a.ApproverName); err != nil {
			continue
		}
		switch a.Stage {
		case 1:
			a.StageLabel = "SPV Pemohon"
		case 2:
			a.StageLabel = "Admin SP"
		case 3:
			a.StageLabel = "SPV SP"
		}
		list = append(list, a)
	}
	return list, nil
}

// Read: lists by role

func GetNonInventoryByPemohon(pemohonID int) ([]model.NonInventoryRequest, error) {
	return queryNIList(`
		SELECT id, no_bpjt, pemohon_id, nama_pemohon, seksi_divisi,
		       tanggal_pemakaian, keterangan, COALESCE(lampiran_url,''),
		       status, current_stage, is_done, submitted_at, updated_at
		FROM non_inventory_requests
		WHERE pemohon_id = $1
		ORDER BY submitted_at DESC
	`, pemohonID)
}

func GetNonInventoryByPemohonFiltered(pemohonID int, dateFrom, dateTo string) ([]model.NonInventoryRequest, error) {
	query := `
		SELECT id, no_bpjt, pemohon_id, nama_pemohon, seksi_divisi,
		       tanggal_pemakaian, keterangan, COALESCE(lampiran_url,''),
		       status, current_stage, is_done, submitted_at, updated_at
		FROM non_inventory_requests
		WHERE pemohon_id = $1
	`
	args := []interface{}{pemohonID}
	i := 2

	if dateFrom != "" {
		query += fmt.Sprintf(" AND submitted_at::date >= $%d", i)
		args = append(args, dateFrom)
		i++
	}
	if dateTo != "" {
		query += fmt.Sprintf(" AND submitted_at::date <= $%d", i)
		args = append(args, dateTo)
	}

	query += " ORDER BY submitted_at DESC"
	return queryNIList(query, args...)
}

func GetNonInventoryByStage(stage int) ([]model.NonInventoryRequest, error) {
	statusMap := map[int]string{
		1: "pending",
		2: "stage1",
		3: "stage2",
	}
	status, ok := statusMap[stage]
	if !ok {
		return nil, nil
	}
	return queryNIList(`
		SELECT id, no_bpjt, pemohon_id, nama_pemohon, seksi_divisi,
		       tanggal_pemakaian, keterangan, COALESCE(lampiran_url,''),
		       status, current_stage, is_done, submitted_at, updated_at
		FROM non_inventory_requests
		WHERE status = $1
		ORDER BY submitted_at ASC
	`, status)
}

// GetNonInventoryByStageAndDivision fetches pending NI requests for the given division(s).
// division may be a comma-separated list (e.g. "MTC1,MTC2") — all matching are included.
func GetNonInventoryByStageAndDivision(division string) ([]model.NonInventoryRequest, error) {
	return queryNIList(`
		SELECT id, no_bpjt, pemohon_id, nama_pemohon, seksi_divisi,
		       tanggal_pemakaian, keterangan, COALESCE(lampiran_url,''),
		       status, current_stage, is_done, submitted_at, updated_at
		FROM non_inventory_requests
		WHERE status = 'pending'
		  AND seksi_divisi = ANY(string_to_array($1, ','))
		ORDER BY submitted_at ASC
	`, division)
}

type NIFilter struct {
	DateFrom string
	DateTo   string
	Divisi   string
}

func GetNonInventoryRiwayat(f NIFilter) ([]model.NonInventoryRequest, error) {
	query := `
		SELECT id, no_bpjt, pemohon_id, nama_pemohon, seksi_divisi,
		       tanggal_pemakaian, keterangan, COALESCE(lampiran_url,''),
		       status, current_stage, is_done, submitted_at, updated_at
		FROM non_inventory_requests
		WHERE status IN ('approved','cancelled')
	`
	args := []interface{}{}
	i := 1

	if f.DateFrom != "" {
		query += fmt.Sprintf(" AND submitted_at::date >= $%d", i)
		args = append(args, f.DateFrom)
		i++
	}
	if f.DateTo != "" {
		query += fmt.Sprintf(" AND submitted_at::date <= $%d", i)
		args = append(args, f.DateTo)
		i++
	}
	if f.Divisi != "" && f.Divisi != "Semua" {
		query += fmt.Sprintf(" AND seksi_divisi = $%d", i)
		args = append(args, f.Divisi)
		i++
	}

	query += " ORDER BY submitted_at DESC"
	return queryNIList(query, args...)
}

func queryNIList(query string, args ...interface{}) ([]model.NonInventoryRequest, error) {
	rows, err := config.DB.Query(context.Background(), query, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var list []model.NonInventoryRequest
	for rows.Next() {
		var r model.NonInventoryRequest
		if err := rows.Scan(
			&r.ID, &r.NoBPJT, &r.PemohonID, &r.NamaPemohon, &r.SeksiDivisi,
			&r.TanggalPemakaian, &r.Keterangan, &r.LampiranURL,
			&r.Status, &r.CurrentStage, &r.IsDone, &r.SubmittedAt, &r.UpdatedAt,
		); err != nil {
			continue
		}
		list = append(list, r)
	}
	return list, nil
}

func ReleaseNonInventory(requestID, approverID, approverStage int) error {
	req, err := GetNonInventoryByID(requestID)
	if err != nil {
		return err
	}

	nextStatus := ""
	switch approverStage {
	case 1: // spv_pemohon releases → send to admin_sp
		if req.Status != "pending" {
			return fmt.Errorf("status tidak valid untuk release oleh SPV Pemohon")
		}
		nextStatus = "stage1"
	case 2: // admin_sp releases → send to spv_sp
		if req.Status != "stage1" {
			return fmt.Errorf("status tidak valid untuk release oleh Admin SP")
		}
		nextStatus = "stage2"
	case 3: // spv_sp releases → approved
		if req.Status != "stage2" {
			return fmt.Errorf("status tidak valid untuk release oleh SPV SP")
		}
		nextStatus = "approved"
	default:
		return fmt.Errorf("stage tidak dikenal: %d", approverStage)
	}

	tx, err := config.DB.Begin(context.Background())
	if err != nil {
		return err
	}
	defer tx.Rollback(context.Background())

	_, err = tx.Exec(context.Background(), `
		UPDATE non_inventory_requests
		SET status = $1, current_stage = $2, updated_at = NOW()
		WHERE id = $3
	`, nextStatus, approverStage, requestID)
	if err != nil {
		return err
	}

	_, err = tx.Exec(context.Background(), `
		INSERT INTO non_inventory_approvals (request_id, stage, approver_id, action)
		VALUES ($1,$2,$3,'release')
	`, requestID, approverStage, approverID)
	if err != nil {
		return err
	}

	return tx.Commit(context.Background())
}

func CancelNonInventory(requestID, approverID, approverStage int) error {
	tx, err := config.DB.Begin(context.Background())
	if err != nil {
		return err
	}
	defer tx.Rollback(context.Background())

	_, err = tx.Exec(context.Background(), `
		UPDATE non_inventory_requests
		SET status = 'cancelled', updated_at = NOW()
		WHERE id = $1
	`, requestID)
	if err != nil {
		return err
	}

	_, err = tx.Exec(context.Background(), `
		INSERT INTO non_inventory_approvals (request_id, stage, approver_id, action)
		VALUES ($1,$2,$3,'cancel')
	`, requestID, approverStage, approverID)
	if err != nil {
		return err
	}

	return tx.Commit(context.Background())
}

func ToggleNonInventoryDone(requestID int, isDone bool) error {
	_, err := config.DB.Exec(context.Background(), `
		UPDATE non_inventory_requests
		SET is_done = $1, updated_at = NOW()
		WHERE id = $2
	`, isDone, requestID)
	return err
}
