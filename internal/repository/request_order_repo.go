package repository

import (
	"context"
	"time"

	"sparepart-mgmt/internal/config"
	"sparepart-mgmt/internal/model"
)

func CreateRequestOrder(ro *model.RequestOrder) (int, error) {
	var newID int
	err := config.DB.QueryRow(context.Background(),
		`INSERT INTO request_orders (pemohon_id, requester_name, status)
		 VALUES ($1, $2, 'pending')
		 RETURNING id`,
		ro.PemohonID, ro.RequesterName,
	).Scan(&newID)
	return newID, err
}

func AddRequestOrderItem(item *model.RequestOrderItem) error {
	_, err := config.DB.Exec(context.Background(),
		`INSERT INTO request_order_items
		 (request_order_id, sparepart_id, nama_item_snapshot, kode_oracle_snapshot, jumlah)
		 VALUES ($1, $2, $3, $4, $5)`,
		item.RequestOrderID, item.SparepartID,
		item.NamaItemSnapshot, item.KodeOracleSnapshot, item.Jumlah,
	)
	return err
}

func GetPendingRequestOrders() ([]model.RequestOrder, error) {
	rows, err := config.DB.Query(context.Background(),
		`SELECT ro.id, ro.pemohon_id, ro.requester_name,
		        ro.status, ro.created_at, ro.completed_at,
		        COALESCE(u.full_name, ro.requester_name)
		 FROM request_orders ro
		 LEFT JOIN users u ON u.id = ro.pemohon_id
		 WHERE ro.status = 'pending'
		 ORDER BY ro.created_at DESC`)
	if err != nil {
		return nil, err
	}
	orders, err := scanRequestOrderRows(rows)
	if err != nil {
		return nil, err
	}

	for i := range orders {
		items, err := GetRequestOrderItems(orders[i].ID)
		if err == nil {
			orders[i].Items = items
		}
	}
	return orders, nil
}

func GetRequestOrderByID(id int) (*model.RequestOrder, error) {
	ro := &model.RequestOrder{}
	row := config.DB.QueryRow(context.Background(),
		`SELECT ro.id, ro.pemohon_id, ro.requester_name,
		        ro.status, ro.created_at, ro.completed_at,
		        COALESCE(u.full_name, ro.requester_name)
		 FROM request_orders ro
		 LEFT JOIN users u ON u.id = ro.pemohon_id
		 WHERE ro.id = $1`, id)
	err := row.Scan(
		&ro.ID, &ro.PemohonID, &ro.RequesterName,
		&ro.Status, &ro.CreatedAt, &ro.CompletedAt,
		&ro.PemohonFullName,
	)
	if err != nil {
		return nil, err
	}
	ro.Items, _ = GetRequestOrderItems(id)
	return ro, nil
}

func GetRequestOrderItems(orderID int) ([]model.RequestOrderItem, error) {
	rows, err := config.DB.Query(context.Background(),
		`SELECT id, request_order_id, COALESCE(sparepart_id,0),
		        nama_item_snapshot, kode_oracle_snapshot, jumlah
		 FROM request_order_items
		 WHERE request_order_id = $1
		 ORDER BY id ASC`, orderID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var list []model.RequestOrderItem
	for rows.Next() {
		var it model.RequestOrderItem
		if err := rows.Scan(&it.ID, &it.RequestOrderID, &it.SparepartID,
			&it.NamaItemSnapshot, &it.KodeOracleSnapshot, &it.Jumlah); err != nil {
			return nil, err
		}
		list = append(list, it)
	}
	return list, nil
}

func CompleteRequestOrder(id int) error {
	_, err := config.DB.Exec(context.Background(),
		`UPDATE request_orders SET status='completed', completed_at=$1 WHERE id=$2`,
		time.Now(), id)
	return err
}

func scanRequestOrderRows(rows interface {
	Next() bool
	Scan(...interface{}) error
	Close()
}) ([]model.RequestOrder, error) {
	defer rows.Close()
	var list []model.RequestOrder
	for rows.Next() {
		var ro model.RequestOrder
		err := rows.Scan(
			&ro.ID, &ro.PemohonID, &ro.RequesterName,
			&ro.Status, &ro.CreatedAt, &ro.CompletedAt,
			&ro.PemohonFullName,
		)
		if err != nil {
			return nil, err
		}
		list = append(list, ro)
	}
	return list, nil
}
