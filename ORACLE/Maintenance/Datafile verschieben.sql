-- Datafile umziehen.
-- SE2-Variante: klassisch offline (ALTER DATABASE MOVE DATAFILE ist EE-only!).

-- Aktueller Pfad
SELECT file_id, file_name, tablespace_name, bytes/1024/1024 AS size_mb
FROM   dba_data_files
WHERE  tablespace_name = 'USERS';

/*
-- ============ Ablauf für SE2 (Tablespace offline nehmen) ============

-- 1) Tablespace offline
ALTER TABLESPACE USERS OFFLINE NORMAL;

-- 2) Datei auf OS-Ebene verschieben (SHELL, nicht SQL)
--    Linux: mv /u01/oradata/PROD/users01.dbf /u02/oradata/PROD/users01.dbf
--    Win  : move D:\oradata\PROD\users01.dbf E:\oradata\PROD\users01.dbf

-- 3) Oracle über neuen Pfad informieren
ALTER TABLESPACE USERS RENAME DATAFILE '/u01/oradata/PROD/users01.dbf'
                             TO       '/u02/oradata/PROD/users01.dbf';

-- 4) Tablespace wieder online
ALTER TABLESPACE USERS ONLINE;

-- SYSTEM / SYSAUX gehen nur bei DB im Mount:
-- SHUTDOWN IMMEDIATE;
-- STARTUP MOUNT;
-- Host: mv <alt> <neu>
-- ALTER DATABASE RENAME FILE '<alt>' TO '<neu>';
-- ALTER DATABASE OPEN;
*/

-- Enterprise Edition könnte dasselbe online in einem Befehl:
--   ALTER DATABASE MOVE DATAFILE '<alt>' TO '<neu>';
