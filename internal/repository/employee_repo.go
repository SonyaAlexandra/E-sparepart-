package repository

import (
	"context"
	"strconv"

	"sparepart-mgmt/internal/config"
	"sparepart-mgmt/internal/model"
)

func GetEmployeeByIDCard(idCardNumber string) (*model.EmployeeIDCard, error) {
	e := &model.EmployeeIDCard{}
	err := config.DB.QueryRow(context.Background(),
		`SELECT id, id_card_number, full_name, is_active, COALESCE(notes, '')
		 FROM employee_id_cards
		 WHERE id_card_number = $1 AND is_active = TRUE`,
		idCardNumber).Scan(&e.ID, &e.IDCardNumber, &e.FullName, &e.IsActive, &e.Notes)
	return e, err
}

func GetEmployeeByFingerprintID(fingerprintID string) (*model.EmployeeIDCard, error) {
	e := &model.EmployeeIDCard{}
	err := config.DB.QueryRow(context.Background(),
		`SELECT id, id_card_number, full_name, is_active, COALESCE(notes, '')
		 FROM employee_id_cards
		 WHERE fingerprint_id = $1 AND is_active = TRUE`,
		fingerprintID).Scan(&e.ID, &e.IDCardNumber, &e.FullName, &e.IsActive, &e.Notes)
	return e, err
}

func GetAllEmployees(search string) ([]model.EmployeeIDCard, error) {
	query := `SELECT e.id, e.id_card_number, e.full_name,
	                 e.is_active, COALESCE(e.notes, ''),
	                 COALESCE(u.full_name, '-') as created_by_name,
	                 e.created_at,
	                 COALESCE(e.fingerprint_id, '') as fingerprint_id
	          FROM employee_id_cards e
	          LEFT JOIN users u ON u.id = e.created_by`
	args := []interface{}{}
	if search != "" {
		query += ` WHERE e.full_name ILIKE $1 OR e.id_card_number ILIKE $1`
		args = append(args, "%"+search+"%")
	}
	query += ` ORDER BY e.is_active DESC, e.full_name ASC`

	rows, err := config.DB.Query(context.Background(), query, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var employees []model.EmployeeIDCard
	for rows.Next() {
		var e model.EmployeeIDCard
		if err := rows.Scan(
			&e.ID, &e.IDCardNumber, &e.FullName,
			&e.IsActive, &e.Notes, &e.CreatedByName, &e.CreatedAt,
			&e.FingerprintID,
		); err != nil {
			return nil, err
		}
		employees = append(employees, e)
	}
	return employees, nil
}

func GetEmployeeByID(id int) (*model.EmployeeIDCard, error) {
	e := &model.EmployeeIDCard{}
	err := config.DB.QueryRow(context.Background(),
		`SELECT id, id_card_number, full_name, is_active, COALESCE(notes, ''),
		        COALESCE(fingerprint_id, ''), COALESCE(created_by, 0), created_at, COALESCE(fingerprint_template, '')
		 FROM employee_id_cards WHERE id = $1`, id).
		Scan(&e.ID, &e.IDCardNumber, &e.FullName, &e.IsActive, &e.Notes,
			&e.FingerprintID, &e.CreatedBy, &e.CreatedAt, &e.FingerprintTemplate)
	return e, err
}

func CreateEmployee(e *model.EmployeeIDCard, createdBy int) error {
	_, err := config.DB.Exec(context.Background(),
		`INSERT INTO employee_id_cards
		     (id_card_number, full_name, is_active, notes, fingerprint_id, created_by, fingerprint_template)
		 VALUES ($1, $2, $3, $4, $5, $6, $7)`,
		e.IDCardNumber, e.FullName, e.IsActive,
		nullableStr(e.Notes), nullableStr(e.FingerprintID), createdBy, e.FingerprintTemplate)
	return err
}

func UpdateEmployee(e *model.EmployeeIDCard) error {
	_, err := config.DB.Exec(context.Background(),
		`UPDATE employee_id_cards
		 SET full_name=$2, id_card_number=$3, is_active=$4,
		     notes=$5, fingerprint_id=$6, fingerprint_template=$7, updated_at=NOW()
		 WHERE id=$1`,
		e.ID, e.FullName, e.IDCardNumber, e.IsActive,
		nullableStr(e.Notes), nullableStr(e.FingerprintID), e.FingerprintTemplate)
	return err
}

func DeleteEmployee(id int) error {
	_, err := config.DB.Exec(context.Background(),
		`DELETE FROM employee_id_cards WHERE id=$1`, id)
	return err
}

func IsIDCardNumberTaken(idCardNumber string, excludeID int) (bool, error) {
	var count int
	err := config.DB.QueryRow(context.Background(),
		`SELECT COUNT(*) FROM employee_id_cards WHERE id_card_number=$1 AND id!=$2`,
		idCardNumber, excludeID).Scan(&count)
	return count > 0, err
}

// IsFingerprintIDTaken mengecek apakah fingerprint_id sudah dipakai karyawan lain.
func IsFingerprintIDTaken(fingerprintID string, excludeID int) (bool, error) {
	var count int
	err := config.DB.QueryRow(context.Background(),
		`SELECT COUNT(*) FROM employee_id_cards
		 WHERE fingerprint_id=$1 AND id!=$2`,
		fingerprintID, excludeID).Scan(&count)
	return count > 0, err
}

func nullableStr(s string) interface{} {
	if s == "" {
		return nil
	}
	return s
}

func SaveFingerprintTemplate(idCard string, template string) error {
	_, err := config.DB.Exec(context.Background(),
		"UPDATE employee_id_cards SET fingerprint_template = $1 WHERE id_card_number = $2",
		template, idCard,
	)
	return err
}

// SaveFingerprintTemplateByID menyimpan template sidik jari berdasarkan ID karyawan (integer).
// Dipanggil oleh FingerprintRegisterScan saat mode enroll dari listener.
func SaveFingerprintTemplateByID(employeeID string, template string) error {
	id, err := strconv.Atoi(employeeID)
	if err != nil {
		return err
	}
	_, err = config.DB.Exec(context.Background(),
		"UPDATE employee_id_cards SET fingerprint_template = $1 WHERE id = $2",
		template, id,
	)
	return err
}

func GetAllFingerprintTemplates() ([]model.EmployeeIDCard, error) {
	rows, err := config.DB.Query(context.Background(),
		`SELECT id_card_number, full_name, COALESCE(fingerprint_template, '')
		 FROM employee_id_cards
		 WHERE fingerprint_template IS NOT NULL
		   AND fingerprint_template != ''
		   AND is_active = TRUE`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var employees []model.EmployeeIDCard
	for rows.Next() {
		var e model.EmployeeIDCard
		if err := rows.Scan(&e.IDCardNumber, &e.FullName, &e.FingerprintTemplate); err != nil {
			return nil, err
		}
		employees = append(employees, e)
	}
	return employees, nil
}

type EmployeeWithFingerprint struct {
	ID                  int
	IDCardNumber        string
	FullName            string
	FingerprintTemplate string
}

func GetAllEmployeesWithFingerprint() ([]EmployeeWithFingerprint, error) {
	rows, err := config.DB.Query(context.Background(),
		`SELECT id, id_card_number, full_name, COALESCE(fingerprint_template, '')
		 FROM employee_id_cards
		 WHERE is_active = true
		   AND fingerprint_template IS NOT NULL
		   AND fingerprint_template != ''`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var result []EmployeeWithFingerprint
	for rows.Next() {
		var e EmployeeWithFingerprint
		if err := rows.Scan(&e.ID, &e.IDCardNumber, &e.FullName, &e.FingerprintTemplate); err != nil {
			continue
		}
		result = append(result, e)
	}
	return result, rows.Err()
}

// IsFingerprintTemplateTaken mengecek apakah template sidik jari sudah dimiliki oleh karyawan lain.
func IsFingerprintTemplateTaken(template string, excludeID int) (bool, error) {
	if template == "" {
		return false, nil
	}
	var count int
	err := config.DB.QueryRow(context.Background(),
		`SELECT COUNT(*) FROM employee_id_cards 
		 WHERE fingerprint_template = $1 AND id != $2`,
		template, excludeID).Scan(&count)
	return count > 0, err
}
