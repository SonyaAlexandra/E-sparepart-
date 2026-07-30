package model

import "time"

type NonInventoryRequest struct {
	ID               int       `db:"id"`
	NoBPJT           string    `db:"no_bpjt"`
	PemohonID        int       `db:"pemohon_id"`
	NamaPemohon      string    `db:"nama_pemohon"`
	SeksiDivisi      string    `db:"seksi_divisi"` // MTC1|MTC2|UTL|BM
	TanggalPemakaian time.Time `db:"tanggal_pemakaian"`
	Keterangan       string    `db:"keterangan"`
	LampiranURL      string    `db:"lampiran_url"`
	Status           string    `db:"status"` // pending|stage1|stage2|stage3|approved|cancelled
	CurrentStage     int       `db:"current_stage"`
	IsDone           bool      `db:"is_done"`
	SubmittedAt      time.Time `db:"submitted_at"`
	UpdatedAt        time.Time `db:"updated_at"`

	Items     []NonInventoryItem     `db:"-"`
	Approvals []NonInventoryApproval `db:"-"`
}

func (r NonInventoryRequest) NIStatusLabel() string {
	switch r.Status {
	case "pending":
		return "Menunggu SPV"
	case "stage1":
		return "Menunggu Admin SP"
	case "stage2":
		return "Menunggu SPV SP"
	case "approved":
		return "Disetujui"
	case "cancelled":
		return "Dibatalkan"
	}
	return r.Status
}

func (r NonInventoryRequest) NIStatusClass() string {
	switch r.Status {
	case "approved":
		return "badge-success"
	case "cancelled":
		return "badge-error"
	case "pending", "stage1", "stage2":
		return "badge-warning"
	}
	return "badge-ghost"
}

func (r NonInventoryRequest) NIStatusStyle() string {
	switch r.Status {
	case "approved":
		return "background:#568C20;color:#fff;border:none"
	case "cancelled":
		return "background:#dc2626;color:#fff;border:none"
	case "pending":
		return "background:#f59e0b;color:#fff;border:none"
	case "stage1":
		return "background:#3b82f6;color:#fff;border:none"
	case "stage2":
		return "background:#8b5cf6;color:#fff;border:none"
	}
	return "background:#6b7280;color:#fff;border:none"
}

type NonInventoryItem struct {
	ID         int    `db:"id"`
	RequestID  int    `db:"request_id"`
	Deskripsi  string `db:"deskripsi"`
	Qty        int    `db:"qty"`
	Peruntukan string `db:"peruntukan"`
	Lampiran   string `db:"lampiran"`
}

type NonInventoryApproval struct {
	ID         int       `db:"id"`
	RequestID  int       `db:"request_id"`
	Stage      int       `db:"stage"`
	ApproverID int       `db:"approver_id"`
	Action     string    `db:"action"` // release|cancel
	ActionedAt time.Time `db:"actioned_at"`

	// Joined
	ApproverName string `db:"-"`
	StageLabel   string `db:"-"`
}
