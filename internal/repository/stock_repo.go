package repository

import (
	"context"
	"time"

	"sparepart-mgmt/internal/config"
	"sparepart-mgmt/internal/model"
)

func CreateStockReceiving(sr *model.StockReceiving) error {
	_, err := config.DB.Exec(context.Background(),
		`INSERT INTO stock_receivings
		 (sparepart_id, no_po, vendor, jumlah, harga, tipe, keterangan, received_by,
		  nama_item_snapshot, kode_oracle_snapshot)
		 VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)`,
		sr.SparepartID, sr.NoPO, sr.Vendor, sr.Jumlah, sr.Harga,
		sr.Tipe, sr.Keterangan, sr.ReceivedBy,
		sr.NamaItem, sr.KodeOracle,
	)
	return err
}

func scanReceiving(row interface{ Scan(...interface{}) error }, sr *model.StockReceiving) error {
	return row.Scan(
		&sr.ID, &sr.SparepartID, &sr.NoPO, &sr.Vendor,
		&sr.Jumlah, &sr.Harga, &sr.Tipe, &sr.Keterangan,
		&sr.ReceivedAt, &sr.ReceivedBy, &sr.NamaItem, &sr.KodeOracle,
	)
}

const receivingSelectSQL = `
	SELECT sr.id,
	       COALESCE(sr.sparepart_id, 0),
	       COALESCE(sr.no_po,''),
	       COALESCE(sr.vendor,''),
	       sr.jumlah,
	       COALESCE(sr.harga, 0),
	       sr.tipe,
	       COALESCE(sr.keterangan,''),
	       sr.received_at,
	       COALESCE(sr.received_by, 0),
	       COALESCE(sp.nama_item, sr.nama_item_snapshot, ''),
	       COALESCE(sp.kode_oracle, sr.kode_oracle_snapshot, '')
	FROM stock_receivings sr
	LEFT JOIN spareparts sp ON sp.id = sr.sparepart_id AND sp.deleted_at IS NULL`

// GetAllStockReceivings returns all stock receiving records, newest first.
func GetAllStockReceivings() ([]model.StockReceiving, error) {
	rows, err := config.DB.Query(context.Background(),
		receivingSelectSQL+" ORDER BY sr.received_at DESC")
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var list []model.StockReceiving
	for rows.Next() {
		var sr model.StockReceiving
		if err := scanReceiving(rows, &sr); err != nil {
			return nil, err
		}
		list = append(list, sr)
	}
	return list, nil
}

func GetStockReceivingsByPeriod(from, to time.Time) ([]model.StockReceiving, error) {
	rows, err := config.DB.Query(context.Background(),
		receivingSelectSQL+`
		 WHERE sr.received_at BETWEEN $1 AND $2
		 ORDER BY sr.received_at DESC`, from, to)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var list []model.StockReceiving
	for rows.Next() {
		var sr model.StockReceiving
		if err := scanReceiving(rows, &sr); err != nil {
			return nil, err
		}
		list = append(list, sr)
	}
	return list, nil
}

func CreateNotification(n *model.Notification) error {
	_, err := config.DB.Exec(context.Background(),
		`INSERT INTO notifications (user_id, message) VALUES ($1, $2)`,
		n.UserID, n.Message)
	return err
}

func GetUnreadNotifications(userID int) ([]model.Notification, error) {
	rows, err := config.DB.Query(context.Background(),
		`SELECT id, user_id, message, is_read, created_at
		 FROM notifications WHERE user_id = $1 AND is_read = FALSE
		 ORDER BY created_at DESC`, userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var list []model.Notification
	for rows.Next() {
		var n model.Notification
		err := rows.Scan(&n.ID, &n.UserID, &n.Message, &n.IsRead, &n.CreatedAt)
		if err != nil {
			return nil, err
		}
		list = append(list, n)
	}
	return list, nil
}

// MarkNotificationsRead marks all notifications as read for a user.
func MarkNotificationsRead(userID int) error {
	_, err := config.DB.Exec(context.Background(),
		`UPDATE notifications SET is_read = TRUE WHERE user_id = $1`, userID)
	return err
}

func CreateActivityLog(log *model.ActivityLog) error {
	_, err := config.DB.Exec(context.Background(),
		`INSERT INTO activity_logs (user_id, action, entity_type, entity_id, detail)
		 VALUES ($1,$2,$3,$4,$5)`,
		log.UserID, log.Action, log.EntityType, log.EntityID, log.Detail)
	return err
}

func GetAllActivityLogs() ([]model.ActivityLog, error) {
	return GetActivityLogsByEntity("")
}

func GetActivityLogsByEntity(entityFilter string) ([]model.ActivityLog, error) {
	const selectPart = `SELECT al.id, COALESCE(al.user_id, 0), al.action, COALESCE(al.entity_type,''),
		        COALESCE(al.entity_id, 0), COALESCE(al.detail,''), al.created_at,
		        COALESCE(u.full_name,'')
		 FROM activity_logs al
		 LEFT JOIN users u ON u.id = al.user_id`

	scanLogs := func(query string, args ...interface{}) ([]model.ActivityLog, error) {
		rows, err := config.DB.Query(context.Background(), query, args...)
		if err != nil {
			return nil, err
		}
		defer rows.Close()
		var list []model.ActivityLog
		for rows.Next() {
			var al model.ActivityLog
			if err := rows.Scan(
				&al.ID, &al.UserID, &al.Action, &al.EntityType,
				&al.EntityID, &al.Detail, &al.CreatedAt, &al.UserFullName,
			); err != nil {
				return nil, err
			}
			list = append(list, al)
		}
		return list, nil
	}

	if entityFilter != "" {
		return scanLogs(
			selectPart+" WHERE al.entity_type = $1 ORDER BY al.created_at DESC LIMIT 500",
			entityFilter,
		)
	}
	return scanLogs(selectPart + " ORDER BY al.created_at DESC LIMIT 500")
}

// CreateRFIDSession saves a new RFID session to the DB.
func CreateRFIDSession(sessionID string, pemohonID int, expiresAt time.Time) (*model.RFIDSession, error) {
	_, err := config.DB.Exec(context.Background(),
		`INSERT INTO rfid_sessions (session_id, pemohon_id, expires_at, is_active)
		 VALUES ($1, $2, $3, TRUE)`,
		sessionID, pemohonID, expiresAt,
	)
	if err != nil {
		return nil, err
	}
	return &model.RFIDSession{
		SessionID: sessionID,
		PemohonID: pemohonID,
		ExpiresAt: expiresAt,
		IsActive:  true,
	}, nil
}

// GetRFIDSession fetches a session by its ID.
func GetRFIDSession(sessionID string) (*model.RFIDSession, error) {
	s := &model.RFIDSession{}
	row := config.DB.QueryRow(context.Background(),
		`SELECT session_id, COALESCE(request_id, 0), pemohon_id,
		        created_at, expires_at, is_active
		 FROM rfid_sessions WHERE session_id = $1`, sessionID)
	err := row.Scan(
		&s.SessionID, &s.RequestID, &s.PemohonID,
		&s.CreatedAt, &s.ExpiresAt, &s.IsActive,
	)
	if err != nil {
		return nil, err
	}
	return s, nil
}

func DeactivateRFIDSession(sessionID string) error {
	_, err := config.DB.Exec(context.Background(),
		`UPDATE rfid_sessions SET is_active = FALSE WHERE session_id = $1`, sessionID)
	return err
}
