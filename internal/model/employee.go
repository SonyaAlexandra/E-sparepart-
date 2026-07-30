package model

import "time"

type EmployeeIDCard struct {
	ID           int       `db:"id"`
	IDCardNumber string    `db:"id_card_number"`
	FullName     string    `db:"full_name"`
	IsActive     bool      `db:"is_active"`
	Notes        string    `db:"notes"`
	CreatedBy    int       `db:"created_by"`
	CreatedAt    time.Time `db:"created_at"`
	UpdatedAt    time.Time `db:"updated_at"`

	FingerprintID string `db:"fingerprint_id"`
	FingerprintTemplate string `db:"fingerprint_template"`

	CreatedByName string `db:"-"`
}
