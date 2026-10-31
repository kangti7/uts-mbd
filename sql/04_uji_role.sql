-- 04_uji_role.sql : bukti hak akses bekerja (jalankan sebagai postgres, setelah 02_users.sql)
-- Prosedur pg_temp.coba() & tabel hasil_uji dibuat di 03_uji_constraint.sql (sesi yang sama).
-- Jika sesi baru, jalankan dulu bagian B di 03_uji_constraint.sql.

-- backend_dev : CRUD
CALL pg_temp.coba('backend_dev','SELECT mahasiswas','BERHASIL','backend_dev',$q$SELECT * FROM salam.mahasiswas$q$);
CALL pg_temp.coba('backend_dev','INSERT mahasiswas','BERHASIL','backend_dev',
  $q$INSERT INTO salam.mahasiswas (nim,nama,email,ipk,semester) VALUES ('1247050991','Uji Backend','uji.be@salam.ac.id',3.1,4)$q$);
CALL pg_temp.coba('backend_dev','UPDATE mahasiswas','BERHASIL','backend_dev',$q$UPDATE salam.mahasiswas SET ipk = 3.2 WHERE nim = '1247050991'$q$);
CALL pg_temp.coba('backend_dev','DELETE mahasiswas','BERHASIL','backend_dev',$q$DELETE FROM salam.mahasiswas WHERE nim = '1247050991'$q$);
CALL pg_temp.coba('backend_dev','CREATE TABLE (tidak boleh)','DITOLAK','backend_dev',$q$CREATE TABLE salam.tes_backend (id INT)$q$);
CALL pg_temp.coba('backend_dev','DROP TABLE (tidak boleh)','DITOLAK','backend_dev',$q$DROP TABLE salam.mahasiswas$q$);

-- bi_dev : hanya SELECT
CALL pg_temp.coba('bi_dev','SELECT tabel mahasiswas','BERHASIL','bi_dev',$q$SELECT * FROM salam.mahasiswas$q$);
CALL pg_temp.coba('bi_dev','SELECT view v_mahasiswa_aktif','BERHASIL','bi_dev',$q$SELECT * FROM salam.v_mahasiswa_aktif$q$);
CALL pg_temp.coba('bi_dev','INSERT (tidak boleh)','DITOLAK','bi_dev',
  $q$INSERT INTO salam.mahasiswas (nim,nama,email,ipk,semester) VALUES ('1247050992','Uji BI','uji.bi@salam.ac.id',3.0,4)$q$);
CALL pg_temp.coba('bi_dev','UPDATE (tidak boleh)','DITOLAK','bi_dev',$q$UPDATE salam.mahasiswas SET ipk = 4.0$q$);
CALL pg_temp.coba('bi_dev','DELETE (tidak boleh)','DITOLAK','bi_dev',$q$DELETE FROM salam.mahasiswas$q$);
CALL pg_temp.coba('bi_dev','CREATE TABLE (tidak boleh)','DITOLAK','bi_dev',$q$CREATE TABLE salam.tes_bi (id INT)$q$);

-- data_engineer : CREATE, MODIFY (ALTER), DROP, CRUD
CALL pg_temp.coba('data_engineer','CREATE TABLE tes_de','BERHASIL','data_engineer',$q$CREATE TABLE salam.tes_de (id INT, ket TEXT)$q$);
CALL pg_temp.coba('data_engineer','INSERT ke tes_de','BERHASIL','data_engineer',$q$INSERT INTO salam.tes_de VALUES (1,'halo')$q$);
CALL pg_temp.coba('data_engineer','ALTER mahasiswas ADD COLUMN angkatan','BERHASIL','data_engineer',$q$ALTER TABLE salam.mahasiswas ADD COLUMN angkatan INT$q$);
CALL pg_temp.coba('data_engineer','UPDATE mahasiswas','BERHASIL','data_engineer',$q$UPDATE salam.mahasiswas SET angkatan = 2024 WHERE nim = '1247050129'$q$);
CALL pg_temp.coba('data_engineer','SELECT mahasiswas','BERHASIL','data_engineer',$q$SELECT * FROM salam.mahasiswas$q$);
CALL pg_temp.coba('data_engineer','ALTER mahasiswas DROP COLUMN angkatan','BERHASIL','data_engineer',$q$ALTER TABLE salam.mahasiswas DROP COLUMN angkatan$q$);
CALL pg_temp.coba('data_engineer','DROP TABLE tes_de','BERHASIL','data_engineer',$q$DROP TABLE salam.tes_de$q$);

SELECT no, kategori, skenario, harapan, status, hasil FROM hasil_uji WHERE kategori <> 'CONSTRAINT' ORDER BY no;
