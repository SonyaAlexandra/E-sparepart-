INSERT INTO spareparts (kode_oracle, nama_item, deskripsi, jenis_mesin, lokasi, harga, stok, min_stok, max_stok, usage_per_year)
VALUES (
  'SPMERW0103',
  'Limit Switch',
  'Limit Switch AZ 16-12 ZVRK Scamersal',
  'RVS',
  'C42',
  0.0,
  0,
  1,
  2,
  0
)
ON CONFLICT (kode_oracle) DO UPDATE SET
  nama_item      = EXCLUDED.nama_item,
  deskripsi      = EXCLUDED.deskripsi,
  jenis_mesin    = EXCLUDED.jenis_mesin,
  lokasi         = EXCLUDED.lokasi,
  harga          = EXCLUDED.harga,
  stok           = EXCLUDED.stok,
  min_stok       = EXCLUDED.min_stok,
  max_stok       = EXCLUDED.max_stok,
  usage_per_year = EXCLUDED.usage_per_year,
  updated_at     = now();