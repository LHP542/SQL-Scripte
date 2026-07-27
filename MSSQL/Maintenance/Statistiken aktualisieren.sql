-- Aktualisiert die Statistiken aller User-Tabellen mit FULLSCAN.
-- FULLSCAN liefert die genauesten Histogramme, dauert aber länger.
-- Für sehr große Datenbanken sp_updatestats (Sample-basiert) verwenden.

USE [TestDB_zumSpielen];
GO

EXEC sp_MSforeachtable
    @command1 = 'UPDATE STATISTICS ? WITH FULLSCAN;';
GO

-- Alternative (schneller, weniger präzise):
-- EXEC sp_updatestats;
-- GO
