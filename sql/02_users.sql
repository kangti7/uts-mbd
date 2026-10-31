-- 02_users.sql : user & hak akses (jalankan setelah 01_schema.sql, sebagai postgres)
DO $$
DECLARE r TEXT;
BEGIN
    FOREACH r IN ARRAY ARRAY['backend_dev','bi_dev','data_engineer'] LOOP
        IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = r) THEN
            EXECUTE format('DROP OWNED BY %I', r);
            EXECUTE format('DROP ROLE %I', r);
        END IF;
    END LOOP;
END $$;

CREATE ROLE backend_dev   LOGIN PASSWORD 'backend123';
CREATE ROLE bi_dev        LOGIN PASSWORD 'bidev123';
CREATE ROLE data_engineer LOGIN PASSWORD 'dataeng123';

-- data_engineer menjadi pemilik schema & objek, karena ALTER/DROP di PostgreSQL
-- hanya bisa dilakukan oleh pemilik objek (GRANT ALL saja tidak cukup).
ALTER SCHEMA   salam                       OWNER TO data_engineer;
ALTER TABLE    salam.mahasiswas            OWNER TO data_engineer;
ALTER TABLE    salam.audit_log             OWNER TO data_engineer;
ALTER VIEW     salam.v_mahasiswa_aktif     OWNER TO data_engineer;
ALTER FUNCTION salam.fn_audit_mahasiswas() OWNER TO data_engineer;
GRANT CREATE ON DATABASE postgres TO data_engineer;

-- backend_dev : CRUD semua tabel
GRANT USAGE ON SCHEMA salam TO backend_dev;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA salam TO backend_dev;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA salam TO backend_dev;

-- bi_dev : hanya SELECT semua tabel/view
GRANT USAGE ON SCHEMA salam TO bi_dev;
GRANT SELECT ON ALL TABLES IN SCHEMA salam TO bi_dev;

-- objek baru yang dibuat data_engineer otomatis dapat hak yang sama
ALTER DEFAULT PRIVILEGES FOR ROLE data_engineer IN SCHEMA salam
    GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO backend_dev;
ALTER DEFAULT PRIVILEGES FOR ROLE data_engineer IN SCHEMA salam
    GRANT USAGE, SELECT ON SEQUENCES TO backend_dev;
ALTER DEFAULT PRIVILEGES FOR ROLE data_engineer IN SCHEMA salam
    GRANT SELECT ON TABLES TO bi_dev;

SELECT rolname, rolcanlogin FROM pg_roles
WHERE rolname IN ('backend_dev','bi_dev','data_engineer') ORDER BY rolname;
