-- Oracle: COMPATIBLE-Parameter + Optimizer-Features-Enable-Level.
-- COMPATIBLE = auf welche Version die DB "abwärtskompatibel" bleibt.

SELECT
    name,
    value,
    description
FROM   v$parameter
WHERE  name IN ('compatible',
                'optimizer_features_enable',
                'db_block_checksum',
                'db_block_checking',
                'log_archive_start');

-- Datenbank-Version, Open Mode, Log Mode
SELECT
    (SELECT banner_full FROM v$version WHERE ROWNUM = 1) AS version,
    d.name         AS db_name,
    d.open_mode,
    d.log_mode,
    d.flashback_on,
    d.database_role,
    d.created,
    d.platform_name
FROM   v$database d;
