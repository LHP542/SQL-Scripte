-- File-Autogrowth-Events aus dem Default Trace (letzte ~5 Rolling-Files).
-- Reihenfolge: neueste zuerst.
-- Häufige Autogrowths = Initial-Size zu klein / Growth-Increment zu klein
-- -> Performance-Einbrüche (Zero-Init) und File-Fragmentierung.

DECLARE @trace_path NVARCHAR(260);

SELECT @trace_path = REVERSE(SUBSTRING(REVERSE(path), CHARINDEX('\', REVERSE(path)), 260)) + N'log.trc'
FROM   sys.traces
WHERE  is_default = 1;

IF @trace_path IS NULL
BEGIN
    RAISERROR('Default Trace ist nicht aktiv.', 16, 1);
    RETURN;
END

SELECT
    t.StartTime,
    t.DatabaseName,
    t.FileName                                    AS logical_file,
    CASE t.EventClass
         WHEN 92 THEN 'Data File Auto Grow'
         WHEN 93 THEN 'Log File Auto Grow'
         WHEN 94 THEN 'Data File Auto Shrink'
         WHEN 95 THEN 'Log File Auto Shrink'
    END                                           AS event_type,
    t.Duration / 1000                             AS duration_ms,
    t.IntegerData * 8 / 1024                      AS change_mb,
    t.LoginName,
    t.HostName,
    t.ApplicationName
FROM sys.fn_trace_gettable(@trace_path, DEFAULT) t
WHERE t.EventClass IN (92, 93, 94, 95)
ORDER BY t.StartTime DESC;
