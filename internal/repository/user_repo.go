package repository

import (
	"context"

	"sparepart-mgmt/internal/config"
	"sparepart-mgmt/internal/model"
)

func GetUserByUsername(username string) (*model.User, error) {
	u := &model.User{}
	row := config.DB.QueryRow(context.Background(),
		`SELECT id, username, password_hash, full_name, role,
		        COALESCE(division, ''),
		        COALESCE(id_card_number, ''),
		        telegram_chat_id, created_at
		 FROM users WHERE username = $1`, username)

	err := row.Scan(
		&u.ID, &u.Username, &u.PasswordHash, &u.FullName,
		&u.Role, &u.Division, &u.IDCardNumber,
		&u.TelegramChatID, &u.CreatedAt,
	)
	if err != nil {
		return nil, err
	}
	return u, nil
}

func GetUserByID(id int) (*model.User, error) {
	u := &model.User{}
	row := config.DB.QueryRow(context.Background(),
		`SELECT id, username, password_hash, full_name, role,
		        COALESCE(division, ''),
		        COALESCE(id_card_number, ''),
		        telegram_chat_id, created_at
		 FROM users WHERE id = $1`, id)

	err := row.Scan(
		&u.ID, &u.Username, &u.PasswordHash, &u.FullName,
		&u.Role, &u.Division, &u.IDCardNumber,
		&u.TelegramChatID, &u.CreatedAt,
	)
	if err != nil {
		return nil, err
	}
	return u, nil
}

func GetUserByIDCard(idCardNumber string) (*model.User, error) {
	u := &model.User{}
	row := config.DB.QueryRow(context.Background(),
		`SELECT id, username, full_name, role,
		        COALESCE(division, ''),
		        COALESCE(id_card_number, '')
		 FROM users WHERE id_card_number = $1`, idCardNumber)

	err := row.Scan(
		&u.ID, &u.Username, &u.FullName,
		&u.Role, &u.Division, &u.IDCardNumber,
	)
	if err != nil {
		return nil, err
	}
	return u, nil
}

// GetSPVPemohonByDivision returns the SPV Pemohon responsible for a given division.
// Supports multi-division SPV (e.g. division stored as "MTC1,MTC2").
func GetSPVPemohonByDivision(division string) (*model.User, error) {
	u := &model.User{}
	row := config.DB.QueryRow(context.Background(),
		`SELECT id, username, full_name, role,
		        COALESCE(division, ''),
		        telegram_chat_id
		 FROM users WHERE role = 'spv_pemohon'
		   AND $1 = ANY(string_to_array(COALESCE(division,''), ','))
		 LIMIT 1`, division)

	err := row.Scan(
		&u.ID, &u.Username, &u.FullName,
		&u.Role, &u.Division, &u.TelegramChatID,
	)
	if err != nil {
		return nil, err
	}
	return u, nil
}

func GetAllAdminSP() ([]model.User, error) {
	rows, err := config.DB.Query(context.Background(),
		`SELECT id, username, full_name, telegram_chat_id
		 FROM users WHERE role = 'admin_sp'`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var users []model.User
	for rows.Next() {
		var u model.User
		err := rows.Scan(&u.ID, &u.Username, &u.FullName, &u.TelegramChatID)
		if err != nil {
			return nil, err
		}
		users = append(users, u)
	}
	return users, nil
}

func GetAllSPVSP() ([]model.User, error) {
	rows, err := config.DB.Query(context.Background(),
		`SELECT id, username, full_name, telegram_chat_id
		 FROM users WHERE role = 'spv_sp'`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var users []model.User
	for rows.Next() {
		var u model.User
		err := rows.Scan(&u.ID, &u.Username, &u.FullName, &u.TelegramChatID)
		if err != nil {
			return nil, err
		}
		users = append(users, u)
	}
	return users, nil
}

func GetAllUsers(roleFilter, search string) ([]model.User, error) {
	query := `SELECT id, username, full_name, role,
	                 COALESCE(division, ''),
	                 COALESCE(id_card_number, ''),
	                 telegram_chat_id, created_at
	          FROM users WHERE 1=1`
	args := []interface{}{}
	idx := 1

	if roleFilter != "" {
		query += ` AND role = $` + itoa(idx)
		args = append(args, roleFilter)
		idx++
	}
	if search != "" {
		query += ` AND (full_name ILIKE $` + itoa(idx) + ` OR username ILIKE $` + itoa(idx) + `)`
		args = append(args, "%"+search+"%")
		idx++
	}
	query += ` ORDER BY role, full_name ASC`

	rows, err := config.DB.Query(context.Background(), query, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var users []model.User
	for rows.Next() {
		var u model.User
		err := rows.Scan(&u.ID, &u.Username, &u.FullName, &u.Role,
			&u.Division, &u.IDCardNumber, &u.TelegramChatID, &u.CreatedAt)
		if err != nil {
			return nil, err
		}
		users = append(users, u)
	}
	return users, nil
}

func IsUsernameTaken(username string, excludeID int) (bool, error) {
	var count int
	err := config.DB.QueryRow(context.Background(),
		`SELECT COUNT(*) FROM users WHERE username = $1 AND id != $2`,
		username, excludeID).Scan(&count)
	return count > 0, err
}

func CreateUser(u *model.User) error {
	_, err := config.DB.Exec(context.Background(),
		`INSERT INTO users (username, password_hash, full_name, role, division, id_card_number, telegram_chat_id)
		 VALUES ($1, $2, $3, $4, $5, $6, $7)`,
		u.Username, u.PasswordHash, u.FullName, u.Role,
		nullableStrU(u.Division), nullableStrU(u.IDCardNumber), u.TelegramChatID)
	return err
}

func UpdateUser(u *model.User) error {
	_, err := config.DB.Exec(context.Background(),
		`UPDATE users
		 SET username = $2, full_name = $3, role = $4,
		     division = $5, id_card_number = $6, telegram_chat_id = $7
		 WHERE id = $1`,
		u.ID, u.Username, u.FullName, u.Role,
		nullableStrU(u.Division), nullableStrU(u.IDCardNumber), u.TelegramChatID)
	return err
}

func UpdateUserPassword(userID int, passwordHash string) error {
	_, err := config.DB.Exec(context.Background(),
		`UPDATE users SET password_hash = $2 WHERE id = $1`,
		userID, passwordHash)
	return err
}

func DeleteUser(id int) error {
	ctx := context.Background()
	_, _ = config.DB.Exec(ctx, `UPDATE requests SET pemohon_id = NULL WHERE pemohon_id = $1`, id)
	_, _ = config.DB.Exec(ctx, `UPDATE validations SET validator_id = NULL WHERE validator_id = $1`, id)
	_, _ = config.DB.Exec(ctx, `UPDATE stock_receivings SET received_by = NULL WHERE received_by = $1`, id)
	_, _ = config.DB.Exec(ctx, `UPDATE rfid_sessions SET pemohon_id = NULL WHERE pemohon_id = $1`, id)
	_, _ = config.DB.Exec(ctx, `UPDATE activity_logs SET user_id = NULL WHERE user_id = $1`, id)
	_, _ = config.DB.Exec(ctx, `UPDATE notifications SET user_id = NULL WHERE user_id = $1`, id)
	_, err := config.DB.Exec(ctx, `DELETE FROM users WHERE id = $1`, id)
	return err
}

func nullableStrU(s string) interface{} {
	if s == "" {
		return nil
	}
	return s
}

func itoa(n int) string {
	s := ""
	if n == 0 {
		return "0"
	}
	for n > 0 {
		s = string(rune('0'+n%10)) + s
		n /= 10
	}
	return s
}
