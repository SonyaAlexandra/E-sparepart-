package repository

import (
	"context"
	"fmt"
	"time"

	"sparepart-mgmt/internal/config"
	"sparepart-mgmt/internal/model"
)

func CreateRequest(r *model.Request) (int, error) {
	var newID int
	err := config.DB.QueryRow(context.Background(),
		`INSERT INTO requests
		 (no_wr_wo, pemohon_id, requester_name, requester_source, division, mesin_area, status, current_stage, session_id)
		 VALUES ($1,$2,$3,$4,$5,$6,'pending',0,$7)
		 RETURNING id`,
		r.NoWRWO, r.PemohonID, r.RequesterName, r.RequesterSource, r.Division, r.MesinArea, r.SessionID,
	).Scan(&newID)
	return newID, err
}

func AddRequestItem(item *model.RequestItem) error {
	_, err := config.DB.Exec(context.Background(),
		`INSERT INTO request_items
		 (request_id, sparepart_id, no_baki, jumlah, mesin_area,
		  nama_item_snapshot, kode_oracle_snapshot, no_part_snapshot)
		 VALUES ($1,$2,$3,$4,$5,$6,$7,$8)`,
		item.RequestID, item.SparepartID, item.NoBaki, item.Jumlah, item.MesinArea,
		item.NamaItem, item.KodeOracle, item.NoPart,
	)
	return err
}

func GetRequestByID(id int) (*model.Request, error) {
	r := &model.Request{}
	row := config.DB.QueryRow(context.Background(),
		`SELECT r.id, r.no_wr_wo, r.pemohon_id, r.requester_name, r.requester_source,
		        r.division, COALESCE(r.mesin_area,''), r.status, r.current_stage,
		        COALESCE(r.rejection_reason,''), COALESCE(r.session_id,''),
		        r.submitted_at, r.updated_at, COALESCE(u.full_name,'')
		 FROM requests r
		 LEFT JOIN users u ON u.id = r.pemohon_id
		 WHERE r.id = $1`, id)

	err := row.Scan(
		&r.ID, &r.NoWRWO, &r.PemohonID, &r.RequesterName, &r.RequesterSource,
		&r.Division, &r.MesinArea, &r.Status, &r.CurrentStage, &r.RejectionReason,
		&r.SessionID, &r.SubmittedAt, &r.UpdatedAt, &r.PemohonName,
	)
	if err != nil {
		return nil, err
	}

	items, err := GetRequestItems(id)
	if err != nil {
		return nil, err
	}
	r.Items = items
	return r, nil
}

func GetRequestItems(requestID int) ([]model.RequestItem, error) {
	rows, err := config.DB.Query(context.Background(),
		`SELECT ri.id, ri.request_id, COALESCE(ri.sparepart_id, 0), COALESCE(ri.no_baki,''),
		        ri.jumlah, ri.jumlah_disetujui, COALESCE(ri.mesin_area,''),
		        COALESCE(sp.nama_item,   ri.nama_item_snapshot,   ''),
		        COALESCE(sp.deskripsi,   ''),
		        COALESCE(sp.kode_oracle, ri.kode_oracle_snapshot, ''),
		        COALESCE(sp.no_part,     ri.no_part_snapshot,     '')
		 FROM request_items ri
		 LEFT JOIN spareparts sp ON sp.id = ri.sparepart_id AND sp.deleted_at IS NULL
		 WHERE ri.request_id = $1
		 ORDER BY ri.id ASC`, requestID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var items []model.RequestItem
	for rows.Next() {
		var item model.RequestItem
		err := rows.Scan(
			&item.ID, &item.RequestID, &item.SparepartID, &item.NoBaki,
			&item.Jumlah, &item.JumlahDisetujui, &item.MesinArea,
			&item.NamaItem, &item.Deskripsi, &item.KodeOracle, &item.NoPart,
		)
		if err != nil {
			return nil, err
		}
		items = append(items, item)
	}
	return items, nil
}

func GetRequestsByStage(stage int) ([]model.Request, error) {
	rows, err := config.DB.Query(context.Background(),
		`SELECT r.id, r.no_wr_wo, r.requester_name, r.division, r.status,
		        r.current_stage, r.submitted_at, COALESCE(u.full_name,'')
		 FROM requests r
		 LEFT JOIN users u ON u.id = r.pemohon_id
		 WHERE r.current_stage = $1 AND r.status NOT IN ('approved','rejected')
		 ORDER BY r.submitted_at DESC`, stage)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	return scanRequestRows(rows)
}

func GetRequestsByStageAndDivision(stage int, division string) ([]model.Request, error) {
	rows, err := config.DB.Query(context.Background(),
		`SELECT r.id, r.no_wr_wo, r.requester_name, r.division, r.status,
		        r.current_stage, r.submitted_at, COALESCE(u.full_name,'')
		 FROM requests r
		 LEFT JOIN users u ON u.id = r.pemohon_id
		 WHERE r.current_stage = $1
		   AND r.division = ANY(string_to_array($2, ','))
		   AND r.status NOT IN ('approved','rejected')
		 ORDER BY r.submitted_at DESC`, stage, division)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	return scanRequestRows(rows)
}

func GetRequestsByStageForSPVSP(division string) ([]model.Request, error) {
	var rows interface {
		Next() bool
		Scan(...interface{}) error
		Close()
	}
	var err error

	if division == "" {
		// No division: only show stage 3 (final approval)
		rows, err = config.DB.Query(context.Background(),
			`SELECT r.id, r.no_wr_wo, r.requester_name, r.division, r.status,
			        r.current_stage, r.submitted_at, COALESCE(u.full_name,'')
			 FROM requests r
			 LEFT JOIN users u ON u.id = r.pemohon_id
			 WHERE r.status NOT IN ('approved','rejected')
			   AND r.current_stage = 3
			 ORDER BY r.submitted_at DESC`)
	} else {
		// Has division: stage 3 (all) + stage 2 for their division(s)
		// division may be comma-separated e.g. "MTC1,MTC2"
		rows, err = config.DB.Query(context.Background(),
			`SELECT r.id, r.no_wr_wo, r.requester_name, r.division, r.status,
			        r.current_stage, r.submitted_at, COALESCE(u.full_name,'')
			 FROM requests r
			 LEFT JOIN users u ON u.id = r.pemohon_id
			 WHERE r.status NOT IN ('approved','rejected')
			   AND (
			     (r.current_stage = 2 AND r.division = ANY(string_to_array($1, ',')))
			     OR (r.current_stage = 3)
			   )
			 ORDER BY r.current_stage ASC, r.submitted_at DESC`, division)
	}
	if err != nil {
		return nil, err
	}
	return scanRequestRows(rows)
}

func GetAllRequests() ([]model.Request, error) {
	rows, err := config.DB.Query(context.Background(),
		`SELECT r.id, r.no_wr_wo, r.requester_name, r.division, r.status,
		        r.current_stage, r.submitted_at, COALESCE(u.full_name,'')
		 FROM requests r
		 LEFT JOIN users u ON u.id = r.pemohon_id
		 ORDER BY r.submitted_at DESC`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	return scanRequestRows(rows)
}

func GetRequestsByPemohon(pemohonID int) ([]model.Request, error) {
	rows, err := config.DB.Query(context.Background(),
		`SELECT r.id, r.no_wr_wo, r.requester_name, r.division, r.status,
		        r.current_stage, r.submitted_at, COALESCE(u.full_name,'')
		 FROM requests r
		 LEFT JOIN users u ON u.id = r.pemohon_id
		 WHERE r.pemohon_id = $1
		 ORDER BY r.submitted_at DESC`, pemohonID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	return scanRequestRows(rows)
}

func GetRequestsByPemohonByPeriod(pemohonID int, from, to time.Time) ([]model.Request, error) {
	rows, err := config.DB.Query(context.Background(),
		`SELECT r.id, r.no_wr_wo, r.requester_name, r.division, r.status,
		        r.current_stage, r.submitted_at, COALESCE(u.full_name,'')
		 FROM requests r
		 LEFT JOIN users u ON u.id = r.pemohon_id
		 WHERE r.pemohon_id = $1
		   AND r.submitted_at BETWEEN $2 AND $3
		 ORDER BY r.submitted_at DESC`, pemohonID, from, to)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	return scanRequestRows(rows)
}

func UpdateRequestStage(requestID, newStage int, newStatus string) error {
	_, err := config.DB.Exec(context.Background(),
		`UPDATE requests SET current_stage=$1, status=$2, updated_at=NOW()
		 WHERE id=$3`, newStage, newStatus, requestID)
	return err
}

func RejectRequest(requestID int, reason string) error {
	_, err := config.DB.Exec(context.Background(),
		`UPDATE requests SET status='rejected', rejection_reason=$1, updated_at=NOW()
		 WHERE id=$2`, reason, requestID)
	return err
}

func GetRequestItemByID(itemID int) (*model.RequestItem, error) {
	item := &model.RequestItem{}
	row := config.DB.QueryRow(context.Background(),
		`SELECT ri.id, ri.request_id, COALESCE(ri.sparepart_id, 0), COALESCE(ri.no_baki,''),
		        ri.jumlah, ri.jumlah_disetujui, COALESCE(ri.mesin_area,''),
		        COALESCE(sp.nama_item,   ri.nama_item_snapshot,   ''),
		        COALESCE(sp.deskripsi,   ''),
		        COALESCE(sp.kode_oracle, ri.kode_oracle_snapshot, ''),
		        COALESCE(sp.no_part,     ri.no_part_snapshot,     '')
		 FROM request_items ri
		 LEFT JOIN spareparts sp ON sp.id = ri.sparepart_id AND sp.deleted_at IS NULL
		 WHERE ri.id = $1`, itemID)
	err := row.Scan(
		&item.ID, &item.RequestID, &item.SparepartID, &item.NoBaki,
		&item.Jumlah, &item.JumlahDisetujui, &item.MesinArea,
		&item.NamaItem, &item.Deskripsi, &item.KodeOracle, &item.NoPart,
	)
	return item, err
}

func UpdateRequestItemQty(itemID, jumlahDisetujui int) error {
	_, err := config.DB.Exec(context.Background(),
		`UPDATE request_items SET jumlah_disetujui=$1 WHERE id=$2`,
		jumlahDisetujui, itemID)
	return err
}

func DeleteRequestItem(itemID int) error {
	_, err := config.DB.Exec(context.Background(),
		`DELETE FROM request_items WHERE id=$1`, itemID)
	return err
}

func CreateValidation(v *model.Validation) error {
	_, err := config.DB.Exec(context.Background(),
		`INSERT INTO validations (request_id, stage, validator_id, action, reason)
		 VALUES ($1,$2,$3,$4,$5)`,
		v.RequestID, v.Stage, v.ValidatorID, v.Action, v.Reason,
	)
	return err
}

func GetValidationsByRequest(requestID int) ([]model.Validation, error) {
	rows, err := config.DB.Query(context.Background(),
		`SELECT v.id, v.request_id, v.stage, v.validator_id,
		        v.action, COALESCE(v.reason,''), v.validated_at,
		        COALESCE(u.full_name,'')
		 FROM validations v
		 LEFT JOIN users u ON u.id = v.validator_id
		 WHERE v.request_id = $1
		 ORDER BY v.stage ASC`, requestID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var list []model.Validation
	for rows.Next() {
		var v model.Validation
		err := rows.Scan(
			&v.ID, &v.RequestID, &v.Stage, &v.ValidatorID,
			&v.Action, &v.Reason, &v.ValidatedAt, &v.ValidatorName,
		)
		if err != nil {
			return nil, err
		}
		list = append(list, v)
	}
	return list, nil
}

func scanRequestRows(rows interface {
	Next() bool
	Scan(...interface{}) error
	Close()
}) ([]model.Request, error) {
	defer rows.Close()
	var list []model.Request
	for rows.Next() {
		var r model.Request
		err := rows.Scan(
			&r.ID, &r.NoWRWO, &r.RequesterName, &r.Division,
			&r.Status, &r.CurrentStage, &r.SubmittedAt, &r.PemohonName,
		)
		if err != nil {
			return nil, err
		}
		list = append(list, r)
	}
	return list, nil
}

func GetAllRequestsByPeriod(from, to time.Time) ([]model.Request, error) {
	var query string
	var args []interface{}

	if from.IsZero() || to.IsZero() {
		query = `SELECT r.id, r.no_wr_wo, r.requester_name, r.division, r.status,
		                r.current_stage, r.submitted_at, COALESCE(u.full_name,'')
		         FROM requests r
		         LEFT JOIN users u ON u.id = r.pemohon_id
		         ORDER BY r.submitted_at DESC`
	} else {
		query = `SELECT r.id, r.no_wr_wo, r.requester_name, r.division, r.status,
		                r.current_stage, r.submitted_at, COALESCE(u.full_name,'')
		         FROM requests r
		         LEFT JOIN users u ON u.id = r.pemohon_id
		         WHERE r.submitted_at BETWEEN $1 AND $2
		         ORDER BY r.submitted_at DESC`
		args = []interface{}{from, to}
	}

	rows, err := config.DB.Query(context.Background(), query, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	return scanRequestRows(rows)
}

func GetRecentRequestsByPemohon(pemohonID, limit int) ([]model.Request, error) {
	rows, err := config.DB.Query(context.Background(),
		`SELECT r.id, r.no_wr_wo, r.requester_name, r.division, r.status,
		        r.current_stage, r.submitted_at, COALESCE(u.full_name,'')
		 FROM requests r
		 LEFT JOIN users u ON u.id = r.pemohon_id
		 WHERE r.pemohon_id = $1
		 ORDER BY r.submitted_at DESC
		 LIMIT $2`, pemohonID, limit)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	return scanRequestRows(rows)
}

func GetPemohonStats(pemohonID int) (waiting, approved, thisMonth int, err error) {
	err = config.DB.QueryRow(context.Background(),
		`SELECT
		   COUNT(*) FILTER (WHERE status = 'pending') AS waiting,
		   COUNT(*) FILTER (WHERE status = 'approved') AS approved,
		   COUNT(*) FILTER (WHERE DATE_TRUNC('month', submitted_at) = DATE_TRUNC('month', NOW())) AS this_month
		 FROM requests
		 WHERE pemohon_id = $1`, pemohonID,
	).Scan(&waiting, &approved, &thisMonth)
	return
}

type SparepartKeluarItem struct {
	NoWRWO           string
	KodeOracle       string
	NamaItem         string
	Jumlah           int
	Harga            float64
	TransactionValue float64
	Division         string
	TransactionDate  string
	SubmittedAt      interface{}
}

func GetApprovedRequestItems(division string, from, to time.Time) ([]SparepartKeluarItem, error) {
	query := `
		SELECT r.no_wr_wo,
		       COALESCE(sp.kode_oracle, ri.kode_oracle_snapshot, ''),
		       COALESCE(sp.nama_item,   ri.nama_item_snapshot,   ''),
		       COALESCE(ri.jumlah_disetujui, ri.jumlah),
		       COALESCE(sp.harga, 0),
		       COALESCE(ri.jumlah_disetujui, ri.jumlah) * COALESCE(sp.harga, 0),
		       r.division,
		       r.submitted_at
		FROM requests r
		JOIN request_items ri ON ri.request_id = r.id
		LEFT JOIN spareparts sp ON sp.id = ri.sparepart_id AND sp.deleted_at IS NULL
		WHERE r.status = 'approved'`
	args := []interface{}{}
	idx := 1

	if division != "" {
		query += fmt.Sprintf(" AND r.division = $%d", idx)
		args = append(args, division)
		idx++
	}
	if !from.IsZero() {
		query += fmt.Sprintf(" AND r.submitted_at >= $%d", idx)
		args = append(args, from)
		idx++
	}
	if !to.IsZero() {
		query += fmt.Sprintf(" AND r.submitted_at < $%d", idx)
		args = append(args, to.AddDate(0, 0, 1))
		idx++
	}
	query += " ORDER BY r.submitted_at DESC"

	rows, err := config.DB.Query(context.Background(), query, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var list []SparepartKeluarItem
	for rows.Next() {
		var it SparepartKeluarItem
		var submittedAt interface{}
		if err := rows.Scan(
			&it.NoWRWO, &it.KodeOracle, &it.NamaItem,
			&it.Jumlah, &it.Harga, &it.TransactionValue,
			&it.Division, &submittedAt,
		); err != nil {
			return nil, err
		}
		it.SubmittedAt = submittedAt
		list = append(list, it)
	}
	return list, nil
}
