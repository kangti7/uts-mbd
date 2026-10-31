-- 03_uji_constraint.sql : bukti constraint bekerja (jalankan sebagai postgres)

-- A. Data valid
INSERT INTO salam.mahasiswas (nim, nama, email, ipk, semester, status_akademik)
VALUES ('1247050129', 'Muhamad Giast Al-Munawar', 'giast@salam.ac.id', 3.85, 5, 'AKTIF');
SELECT * FROM salam.mahasiswas;

-- B. Pengujian otomatis: tiap skenario dicoba, hasilnya dicatat di tabel sementara
CREATE TEMP TABLE IF NOT EXISTS hasil_uji (
    no SERIAL PRIMARY KEY, kategori TEXT, skenario TEXT, harapan TEXT, status TEXT, hasil TEXT
);

CREATE OR REPLACE PROCEDURE pg_temp.coba(p_kat TEXT, p_skenario TEXT, p_harapan TEXT, p_peran TEXT, p_sql TEXT)
LANGUAGE plpgsql AS $$
DECLARE h TEXT;
BEGIN
    BEGIN
        IF p_peran IS NOT NULL THEN
            EXECUTE format('SET LOCAL ROLE %I', p_peran);
        END IF;
        EXECUTE p_sql;
        h := 'BERHASIL';
    EXCEPTION WHEN OTHERS THEN
        h := 'DITOLAK: ' || SQLERRM;
    END;
    RESET ROLE;
    INSERT INTO hasil_uji (kategori, skenario, harapan, status, hasil)
    VALUES (p_kat, p_skenario, p_harapan,
            CASE WHEN h LIKE p_harapan || '%' THEN 'SESUAI' ELSE 'TIDAK SESUAI' END, h);
END $$;

CALL pg_temp.coba('CONSTRAINT','PRIMARY KEY: NIM duplikat','DITOLAK',NULL,
  $q$INSERT INTO salam.mahasiswas (nim,nama,email,ipk,semester) VALUES ('1247050129','Dobel','dobel@salam.ac.id',3.0,5)$q$);
CALL pg_temp.coba('CONSTRAINT','UNIQUE: email duplikat','DITOLAK',NULL,
  $q$INSERT INTO salam.mahasiswas (nim,nama,email,ipk,semester) VALUES ('1247050130','Email Kembar','giast@salam.ac.id',3.0,5)$q$);
CALL pg_temp.coba('CONSTRAINT','CHECK: IPK 5.00 (di atas 4.00)','DITOLAK',NULL,
  $q$INSERT INTO salam.mahasiswas (nim,nama,email,ipk,semester) VALUES ('1247050131','IPK Besar','a1@salam.ac.id',5.00,5)$q$);
CALL pg_temp.coba('CONSTRAINT','CHECK: IPK -1.00 (di bawah 0)','DITOLAK',NULL,
  $q$INSERT INTO salam.mahasiswas (nim,nama,email,ipk,semester) VALUES ('1247050132','IPK Minus','a2@salam.ac.id',-1.00,5)$q$);
CALL pg_temp.coba('CONSTRAINT','CHECK: semester 20 (maks 14)','DITOLAK',NULL,
  $q$INSERT INTO salam.mahasiswas (nim,nama,email,ipk,semester) VALUES ('1247050133','Semester Besar','a3@salam.ac.id',3.0,20)$q$);
CALL pg_temp.coba('CONSTRAINT','CHECK: status_akademik BOLOS','DITOLAK',NULL,
  $q$INSERT INTO salam.mahasiswas (nim,nama,email,ipk,semester,status_akademik) VALUES ('1247050134','Bolos','a4@salam.ac.id',3.0,5,'BOLOS')$q$);
CALL pg_temp.coba('CONSTRAINT','NOT NULL: nama kosong','DITOLAK',NULL,
  $q$INSERT INTO salam.mahasiswas (nim,nama,email,ipk,semester) VALUES ('1247050135',NULL,'a5@salam.ac.id',3.0,5)$q$);
CALL pg_temp.coba('CONSTRAINT','Data valid kedua (kontrol)','BERHASIL',NULL,
  $q$INSERT INTO salam.mahasiswas (nim,nama,email,ipk,semester,status_akademik) VALUES ('1247050130','Mahasiswa Contoh','contoh@salam.ac.id',3.50,3,'AKTIF')$q$);

SELECT no, skenario, harapan, status, hasil FROM hasil_uji WHERE kategori = 'CONSTRAINT' ORDER BY no;
