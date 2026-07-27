-- Oracle-Äquivalent zu MSSQL PAGE_VERIFY CHECKSUM.
-- db_block_checksum  -> Checksumme bei Read/Write prüfen (kaum Performance-Kosten)
-- db_block_checking  -> logische Konsistenzprüfung pro Block-Änderung (spürbare Kosten)
-- Best Practice: db_block_checksum = TYPICAL (Default), db_block_checking = MEDIUM.

-- Aktuelle Werte
SELECT name, value FROM v$parameter
WHERE  name IN ('db_block_checksum','db_block_checking');

-- Setzen (BOTH = laufend + im SPFILE)
ALTER SYSTEM SET db_block_checksum = 'TYPICAL' SCOPE = BOTH;
ALTER SYSTEM SET db_block_checking = 'MEDIUM'  SCOPE = BOTH;

-- Alternativen:
--   db_block_checksum: OFF | TYPICAL | FULL
--   db_block_checking: OFF | LOW | MEDIUM | FULL
