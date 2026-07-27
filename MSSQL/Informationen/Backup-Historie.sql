-- Letzte Backups aller Datenbanken: Full (D), Diff (I) und Log (L).
-- Zeigt Zeitpunkt, Dauer, Größe und Zielpfad des letzten Backups je Typ.
-- Datenbanken ohne Backup tauchen als NULL auf -> sofort verdächtig.

WITH LastBackup AS
(
    SELECT
        bs.database_name,
        bs.type,
        bs.backup_finish_date,
        bs.backup_size / 1024.0 / 1024.0                     AS backup_size_mb,
        DATEDIFF(SECOND, bs.backup_start_date, bs.backup_finish_date) AS duration_sec,
        bmf.physical_device_name,
        ROW_NUMBER() OVER (PARTITION BY bs.database_name, bs.type
                           ORDER BY bs.backup_finish_date DESC) AS rn
    FROM msdb.dbo.backupset bs
    JOIN msdb.dbo.backupmediafamily bmf ON bs.media_set_id = bmf.media_set_id
)
SELECT
    d.name                                            AS database_name,
    d.recovery_model_desc,
    MAX(CASE WHEN lb.type = 'D' THEN lb.backup_finish_date END) AS last_full,
    MAX(CASE WHEN lb.type = 'I' THEN lb.backup_finish_date END) AS last_diff,
    MAX(CASE WHEN lb.type = 'L' THEN lb.backup_finish_date END) AS last_log,
    DATEDIFF(HOUR,
        MAX(CASE WHEN lb.type = 'D' THEN lb.backup_finish_date END),
        GETDATE())                                    AS hours_since_full,
    MAX(CASE WHEN lb.type = 'D' THEN lb.backup_size_mb END)     AS full_size_mb,
    MAX(CASE WHEN lb.type = 'D' THEN lb.physical_device_name END) AS full_path
FROM sys.databases d
LEFT JOIN LastBackup lb ON lb.database_name = d.name AND lb.rn = 1
WHERE d.database_id > 4  -- System-DBs ausblenden
GROUP BY d.name, d.recovery_model_desc
ORDER BY hours_since_full DESC, d.name;
