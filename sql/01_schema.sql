-- 01_schema.sql : schema SALAM, tabel mahasiswas, audit log, trigger, view
-- Aman dijalankan ulang (schema lama dihapus dulu).
DROP SCHEMA IF EXISTS salam CASCADE;
CREATE SCHEMA salam;

CREATE TABLE salam.mahasiswas (
    nim             VARCHAR(15)  NOT NULL,
    nama            VARCHAR(100) NOT NULL,
    email           VARCHAR(100),
    ipk             NUMERIC(3,2),
    semester        INT,
    status_akademik VARCHAR(20)  DEFAULT 'AKTIF',
    created_at      TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_mahasiswas       PRIMARY KEY (nim),
    CONSTRAINT uq_mahasiswas_email UNIQUE (email),
    CONSTRAINT ck_mahasiswas_ipk      CHECK (ipk BETWEEN 0.00 AND 4.00),
    CONSTRAINT ck_mahasiswas_semester CHECK (semester BETWEEN 1 AND 14),
    CONSTRAINT ck_mahasiswas_status   CHECK (status_akademik IN ('AKTIF','CUTI','LULUS','DO'))
);

-- FITUR PEMBEDA 1: audit log otomatis (siapa mengubah apa dan kapan)
CREATE TABLE salam.audit_log (
    id     SERIAL PRIMARY KEY,
    tabel  VARCHAR(50),
    aksi   VARCHAR(10),
    nim    VARCHAR(15),
    oleh   VARCHAR(50) DEFAULT current_user,
    waktu  TIMESTAMP   DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION salam.fn_audit_mahasiswas() RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'DELETE' THEN
        INSERT INTO salam.audit_log (tabel, aksi, nim) VALUES (TG_TABLE_NAME, TG_OP, OLD.nim);
        RETURN OLD;
    END IF;
    INSERT INTO salam.audit_log (tabel, aksi, nim) VALUES (TG_TABLE_NAME, TG_OP, NEW.nim);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_audit_mahasiswas
AFTER INSERT OR UPDATE OR DELETE ON salam.mahasiswas
FOR EACH ROW EXECUTE FUNCTION salam.fn_audit_mahasiswas();

-- FITUR PEMBEDA 2: view mahasiswa aktif (dipakai untuk uji hak akses bi_dev)
CREATE VIEW salam.v_mahasiswa_aktif AS
SELECT nim, nama, ipk, semester
FROM salam.mahasiswas
WHERE status_akademik = 'AKTIF';
