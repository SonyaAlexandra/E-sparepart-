package repository

import (
	"context"
	"fmt"
	"strings"

	"sparepart-mgmt/internal/config"
	"sparepart-mgmt/internal/model"
)

const selectSparepart = `
	SELECT id,
	       kode_oracle,
	       COALESCE(kode_rfid, ''),
	       COALESCE(no_part, ''),
	       nama_item,
	       COALESCE(deskripsi, ''),
	       COALESCE(jenis_mesin, ''),
	       COALESCE(lokasi, ''),
	       harga,
	       stok,
	       min_stok,
	       max_stok,
	       usage_per_year,
	       COALESCE(foto_url, ''),
	       COALESCE(pdf_url, ''),
	       created_at,
	       updated_at
	FROM spareparts
	WHERE deleted_at IS NULL`

func scanSparepart(row interface {
	Scan(...interface{}) error
}, s *model.Sparepart) error {
	return row.Scan(
		&s.ID, &s.KodeOracle, &s.KodeRFID, &s.NoPart, &s.NamaItem, &s.Deskripsi,
		&s.JenisMesin, &s.Lokasi, &s.Harga, &s.Stok, &s.MinStok, &s.MaxStok,
		&s.UsagePerYear, &s.FotoURL, &s.PdfURL, &s.CreatedAt, &s.UpdatedAt,
	)
}

func GetAllSpareparts(jenisMesin, search string) ([]model.Sparepart, error) {
	conditions := []string{}
	args := []interface{}{}
	argIdx := 1

	if jenisMesin != "" {
		conditions = append(conditions, fmt.Sprintf("jenis_mesin = $%d", argIdx))
		args = append(args, jenisMesin)
		argIdx++
	}
	if search != "" {
		conditions = append(conditions,
			fmt.Sprintf("(nama_item ILIKE $%d OR kode_oracle ILIKE $%d)", argIdx, argIdx))
		args = append(args, "%"+search+"%")
		argIdx++
	}

	query := selectSparepart
	if len(conditions) > 0 {
		query += " AND " + strings.Join(conditions, " AND ")
	}
	query += " ORDER BY nama_item ASC"

	rows, err := config.DB.Query(context.Background(), query, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var list []model.Sparepart
	for rows.Next() {
		var s model.Sparepart
		if err := scanSparepart(rows, &s); err != nil {
			return nil, err
		}
		list = append(list, s)
	}
	return list, nil
}

func GetSparepartByID(id int) (*model.Sparepart, error) {
	s := &model.Sparepart{}
	row := config.DB.QueryRow(context.Background(),
		selectSparepart+" AND id = $1", id)
	if err := scanSparepart(row, s); err != nil {
		return nil, err
	}
	return s, nil
}

func GetSparepartByKodeOracle(kodeOracle string) (*model.Sparepart, error) {
	s := &model.Sparepart{}
	row := config.DB.QueryRow(context.Background(),
		selectSparepart+" AND kode_oracle = $1", kodeOracle)
	if err := scanSparepart(row, s); err != nil {
		return nil, err
	}
	return s, nil
}

func GetSparepartByRFID(rfid string) (*model.Sparepart, error) {
	s := &model.Sparepart{}
	row := config.DB.QueryRow(context.Background(),
		selectSparepart+" AND kode_rfid = $1", rfid)
	if err := scanSparepart(row, s); err != nil {
		return nil, err
	}
	return s, nil
}

func GetDistinctJenisMesin() ([]string, error) {
	rows, err := config.DB.Query(context.Background(),
		`SELECT DISTINCT jenis_mesin FROM spareparts
		 WHERE jenis_mesin IS NOT NULL AND jenis_mesin != ''
		   AND deleted_at IS NULL
		 ORDER BY jenis_mesin ASC`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var result []string
	for rows.Next() {
		var jm string
		if err := rows.Scan(&jm); err != nil {
			return nil, err
		}
		result = append(result, jm)
	}
	return result, nil
}

// GetLowStockSpareparts returns items where stok <= min_stok,
// KECUALI yang stok=0 AND min_stok=0 AND max_stok=0 (tidak dimonitor).
func GetLowStockSpareparts() ([]model.Sparepart, error) {
	rows, err := config.DB.Query(context.Background(),
		`SELECT id, kode_oracle, COALESCE(kode_rfid,''), COALESCE(no_part,''),
		        nama_item, COALESCE(deskripsi,''), COALESCE(jenis_mesin,''),
		        COALESCE(lokasi,''), harga, stok, min_stok, max_stok,
		        usage_per_year, COALESCE(foto_url,''), COALESCE(pdf_url,''), created_at, updated_at
		 FROM spareparts
		 WHERE stok <= min_stok
		   AND NOT (stok = 0 AND min_stok = 0 AND max_stok = 0)
		   AND deleted_at IS NULL
		 ORDER BY stok ASC`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var list []model.Sparepart
	for rows.Next() {
		var s model.Sparepart
		if err := scanSparepart(rows, &s); err != nil {
			return nil, err
		}
		list = append(list, s)
	}
	return list, nil
}

// GetZeroStockSpareparts returns items with stok = 0,
// KECUALI yang min_stok=0 AND max_stok=0 (tidak dimonitor).
func GetZeroStockSpareparts() ([]model.Sparepart, error) {
	rows, err := config.DB.Query(context.Background(),
		`SELECT id, kode_oracle, COALESCE(kode_rfid,''), COALESCE(no_part,''),
		        nama_item, COALESCE(deskripsi,''), COALESCE(jenis_mesin,''),
		        COALESCE(lokasi,''), harga, stok, min_stok, max_stok,
		        usage_per_year, COALESCE(foto_url,''), COALESCE(pdf_url,''), created_at, updated_at
		 FROM spareparts
		 WHERE stok = 0
		   AND NOT (min_stok = 0 AND max_stok = 0)
		   AND deleted_at IS NULL
		 ORDER BY nama_item ASC`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var list []model.Sparepart
	for rows.Next() {
		var s model.Sparepart
		if err := scanSparepart(rows, &s); err != nil {
			return nil, err
		}
		list = append(list, s)
	}
	return list, nil
}

func GetTotalStockValue() (float64, error) {
	var total float64
	err := config.DB.QueryRow(context.Background(),
		`SELECT COALESCE(SUM(stok * harga), 0) FROM spareparts WHERE deleted_at IS NULL`).Scan(&total)
	return total, err
}

func CreateSparepart(s *model.Sparepart) error {
	_, err := config.DB.Exec(context.Background(),
		`INSERT INTO spareparts
		 (kode_oracle, kode_rfid, no_part, nama_item, deskripsi, jenis_mesin,
		  lokasi, harga, stok, min_stok, max_stok, usage_per_year, foto_url, pdf_url)
		 VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14)`,
		s.KodeOracle, s.KodeRFID, s.NoPart, s.NamaItem, s.Deskripsi, s.JenisMesin,
		s.Lokasi, s.Harga, s.Stok, s.MinStok, s.MaxStok, s.UsagePerYear, s.FotoURL, s.PdfURL,
	)
	return err
}

func CreateSparepartReturningID(s *model.Sparepart) (int, error) {
	var newID int
	err := config.DB.QueryRow(context.Background(),
		`INSERT INTO spareparts
		 (kode_oracle, kode_rfid, no_part, nama_item, deskripsi, jenis_mesin,
		  lokasi, harga, stok, min_stok, max_stok, usage_per_year, foto_url, pdf_url)
		 VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14)
		 RETURNING id`,
		s.KodeOracle, s.KodeRFID, s.NoPart, s.NamaItem, s.Deskripsi, s.JenisMesin,
		s.Lokasi, s.Harga, s.Stok, s.MinStok, s.MaxStok, s.UsagePerYear, s.FotoURL, s.PdfURL,
	).Scan(&newID)
	return newID, err
}

func UpdateSparepart(s *model.Sparepart) error {
	_, err := config.DB.Exec(context.Background(),
		`UPDATE spareparts SET
		 kode_rfid=$1, no_part=$2, nama_item=$3, deskripsi=$4, jenis_mesin=$5,
		 lokasi=$6, harga=$7, stok=$8, min_stok=$9, max_stok=$10,
		 usage_per_year=$11, foto_url=$12, pdf_url=$13, updated_at=NOW()
		 WHERE id=$14`,
		s.KodeRFID, s.NoPart, s.NamaItem, s.Deskripsi, s.JenisMesin,
		s.Lokasi, s.Harga, s.Stok, s.MinStok, s.MaxStok,
		s.UsagePerYear, s.FotoURL, s.PdfURL, s.ID,
	)
	return err
}

func NullifySparepartReferences(sparepartID int) error {
	ctx := context.Background()
	_, err := config.DB.Exec(ctx,
		`UPDATE request_items SET sparepart_id = NULL WHERE sparepart_id = $1`, sparepartID)
	if err != nil {
		return err
	}
	_, err = config.DB.Exec(ctx,
		`UPDATE stock_receivings SET sparepart_id = NULL WHERE sparepart_id = $1`, sparepartID)
	return err
}

func DeleteSparepart(id int) error {
	_, err := config.DB.Exec(context.Background(),
		`DELETE FROM spareparts WHERE id = $1`, id)
	return err
}

func SoftDeleteSparepart(id int) error {
	_, err := config.DB.Exec(context.Background(),
		`UPDATE spareparts SET deleted_at = NOW(), updated_at = NOW() WHERE id = $1`, id)
	return err
}

func DeductStock(sparepartID, qty int) error {
	_, err := config.DB.Exec(context.Background(),
		`UPDATE spareparts SET stok = stok - $1, updated_at = NOW() WHERE id = $2`,
		qty, sparepartID)
	return err
}

func CountSparepartsByFoto(fotoURL string, excludeID int) (int, error) {
	var count int
	err := config.DB.QueryRow(context.Background(),
		`SELECT COUNT(*) FROM spareparts WHERE foto_url = $1 AND id != $2`,
		fotoURL, excludeID).Scan(&count)
	return count, err
}

func AddStock(sparepartID, qty int) error {
	_, err := config.DB.Exec(context.Background(),
		`UPDATE spareparts SET stok = stok + $1, updated_at = NOW() WHERE id = $2`,
		qty, sparepartID)
	return err
}
