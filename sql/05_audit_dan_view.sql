-- 05_audit_dan_view.sql : bukti fitur pembeda (audit log otomatis & view)
SELECT id, tabel, aksi, nim, oleh, waktu FROM salam.audit_log ORDER BY id;
SELECT * FROM salam.v_mahasiswa_aktif;
