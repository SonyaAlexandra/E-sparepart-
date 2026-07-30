package model

import "time"

type User struct {
	ID             int       `db:"id"`
	Username       string    `db:"username"`
	PasswordHash   string    `db:"password_hash"`
	FullName       string    `db:"full_name"`
	Role           string    `db:"role"`     // admin_sp | spv_sp | pemohon | spv_pemohon
	Division       string    `db:"division"` // MTC1 | MTC2 | UTL | BM
	IDCardNumber   string    `db:"id_card_number"`
	TelegramChatID *int64    `db:"telegram_chat_id"` // nullable (not use because internal server restriction, but maybe can be use it in the future)
	CreatedAt      time.Time `db:"created_at"`
}

func (u *User) IsAdmin() bool {
	return u.Role == "admin_sp" || u.Role == "spv_sp"
}

type Sparepart struct {
	ID           int       `db:"id"`
	KodeOracle   string    `db:"kode_oracle"`
	KodeRFID     string    `db:"kode_rfid"`
	NoPart       string    `db:"no_part"`
	NamaItem     string    `db:"nama_item"`
	Deskripsi    string    `db:"deskripsi"`
	JenisMesin   string    `db:"jenis_mesin"`
	Lokasi       string    `db:"lokasi"`
	Harga        float64   `db:"harga"`
	Stok         int       `db:"stok"`
	MinStok      int       `db:"min_stok"`
	MaxStok      int       `db:"max_stok"`
	UsagePerYear int       `db:"usage_per_year"`
	FotoURL      string    `db:"foto_url"`
	PdfURL       string    `db:"pdf_url"`
	CreatedAt    time.Time `db:"created_at"`
	UpdatedAt    time.Time `db:"updated_at"`
}

func (s Sparepart) StokStatus() string {

	if s.MinStok == 0 && s.MaxStok == 0 {
		return "nonstok"
	}
	if s.Stok == 0 {
		return "habis"
	}
	if s.Stok <= s.MinStok {
		return "menipis"
	}
	return "tersedia"
}

type Request struct {
	ID              int       `db:"id"`
	NoWRWO          string    `db:"no_wr_wo"`
	PemohonID       int       `db:"pemohon_id"`
	RequesterName   string    `db:"requester_name"`
	RequesterSource string    `db:"requester_source"` // id_card | manual
	Division        string    `db:"division"`
	MesinArea       string    `db:"mesin_area"`
	Status          string    `db:"status"`        // pending|stage1|stage2|approved|rejected
	CurrentStage    int       `db:"current_stage"` // 0=submitted 1=admin 2=spv_pemohon 3=spv_sp
	RejectionReason string    `db:"rejection_reason"`
	SessionID       string    `db:"session_id"`
	SubmittedAt     time.Time `db:"submitted_at"`
	UpdatedAt       time.Time `db:"updated_at"`

	Items       []RequestItem `db:"-"`
	PemohonName string        `db:"-"`
}

// RequestItem — maps to "request_items" table

type RequestItem struct {
	ID              int    `db:"id"`
	RequestID       int    `db:"request_id"`
	SparepartID     int    `db:"sparepart_id"`
	NoBaki          string `db:"no_baki"`
	Jumlah          int    `db:"jumlah"`
	JumlahDisetujui *int   `db:"jumlah_disetujui"`
	MesinArea       string `db:"mesin_area"`

	NamaItem   string `db:"-"`
	Deskripsi  string `db:"-"`
	KodeOracle string `db:"-"`
	NoPart     string `db:"-"`
}

// Validation — maps to "validations" table
type Validation struct {
	ID          int       `db:"id"`
	RequestID   int       `db:"request_id"`
	Stage       int       `db:"stage"`
	ValidatorID int       `db:"validator_id"`
	Action      string    `db:"action"` // approved | rejected
	Reason      string    `db:"reason"`
	ValidatedAt time.Time `db:"validated_at"`

	ValidatorName string `db:"-"`
}

type StockReceiving struct {
	ID          int       `db:"id"`
	SparepartID int       `db:"sparepart_id"`
	NoPO        string    `db:"no_po"`
	Vendor      string    `db:"vendor"`
	Jumlah      int       `db:"jumlah"`
	Harga       float64   `db:"harga"`
	Tipe        string    `db:"tipe"` // tambah | retur
	Keterangan  string    `db:"keterangan"`
	ReceivedAt  time.Time `db:"received_at"`
	ReceivedBy  int       `db:"received_by"`

	NamaItem   string `db:"-"`
	KodeOracle string `db:"-"`
}

// RFIDSession — maps to "rfid_sessions"

type RFIDSession struct {
	SessionID string    `db:"session_id"`
	RequestID int       `db:"request_id"`
	PemohonID int       `db:"pemohon_id"`
	CreatedAt time.Time `db:"created_at"`
	ExpiresAt time.Time `db:"expires_at"`
	IsActive  bool      `db:"is_active"`
}

// Notification — maps to "notifications"
type Notification struct {
	ID        int       `db:"id"`
	UserID    int       `db:"user_id"`
	Message   string    `db:"message"`
	IsRead    bool      `db:"is_read"`
	CreatedAt time.Time `db:"created_at"`
}

// ActivityLog — maps to "activity_logs"
type ActivityLog struct {
	ID         int       `db:"id"`
	UserID     int       `db:"user_id"`
	Action     string    `db:"action"`
	EntityType string    `db:"entity_type"`
	EntityID   int       `db:"entity_id"`
	Detail     string    `db:"detail"`
	CreatedAt  time.Time `db:"created_at"`

	// Joined
	UserFullName string `db:"-"`
}
