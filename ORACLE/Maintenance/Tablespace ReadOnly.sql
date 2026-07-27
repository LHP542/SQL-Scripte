-- Oracle: "READ ONLY" auf DB-Ebene geht nur bei einem STANDBY oder ganzer DB im Mount.
-- Für den praktischen Fall (Daten einfrieren) wird ein Tablespace read-only gesetzt.

ALTER TABLESPACE USERS READ ONLY;

-- Ganze DB read-only (nur bei STANDBY oder physical standby "read only" sinnvoll):
-- ALTER DATABASE OPEN READ ONLY;    -- setzt STARTUP MOUNT voraus
