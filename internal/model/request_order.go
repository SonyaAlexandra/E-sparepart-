package model

import "time"

type RequestOrderItem struct {
	ID                 int    `db:"id"`
	RequestOrderID     int    `db:"request_order_id"`
	SparepartID        int    `db:"sparepart_id"`
	NamaItemSnapshot   string `db:"nama_item_snapshot"`
	KodeOracleSnapshot string `db:"kode_oracle_snapshot"`
	Jumlah             int    `db:"jumlah"`
}

type RequestOrder struct {
	ID            int        `db:"id"`
	PemohonID     int        `db:"pemohon_id"`
	RequesterName string     `db:"requester_name"`
	Status        string     `db:"status"` // pending | completed
	CreatedAt     time.Time  `db:"created_at"`
	CompletedAt   *time.Time `db:"completed_at"` // nullable

	PemohonFullName string             `db:"-"`
	Items           []RequestOrderItem `db:"-"`
}
