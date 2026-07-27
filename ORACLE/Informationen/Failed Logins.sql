-- Fehlgeschlagene Logins.
-- Ab 12c: Unified Audit Trail (falls aktiv).
-- Traditionell: dba_audit_session mit RETURNCODE <> 0.
-- Für Traditional Auditing muss AUDIT_TRAIL != NONE gesetzt sein und
-- 'AUDIT SESSION' aktiviert (protokolliert alle Logins mit Erfolgs-Code).

-- Traditional Audit
SELECT
    timestamp,
    username,
    userhost,
    os_username,
    terminal,
    returncode                              AS ora_error
FROM   dba_audit_session
WHERE  returncode <> 0
  AND  timestamp > SYSDATE - 7
ORDER BY timestamp DESC;

-- Unified Audit (12c+)
-- SELECT event_timestamp, dbusername, os_username, userhost, terminal,
--        return_code, action_name
-- FROM   unified_audit_trail
-- WHERE  action_name = 'LOGON'
--   AND  return_code <> 0
--   AND  event_timestamp > SYSTIMESTAMP - INTERVAL '7' DAY
-- ORDER BY event_timestamp DESC;

-- Zusammenfassung nach User
-- SELECT username, COUNT(*) AS failed_attempts, MAX(timestamp) AS last_attempt
-- FROM   dba_audit_session
-- WHERE  returncode <> 0
--   AND  timestamp > SYSDATE - 7
-- GROUP BY username
-- ORDER BY failed_attempts DESC;
