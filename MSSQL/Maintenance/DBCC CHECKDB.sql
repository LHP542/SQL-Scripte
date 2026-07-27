-- Integritätscheck einer Datenbank.
-- PHYSICAL_ONLY läuft deutlich schneller und reicht für den regelmäßigen Check.
-- Für den vollen (logischen + physischen) Check die zweite Variante nutzen.

USE [TestDB_zumSpielen];
GO

-- Schnell: nur physische Konsistenz
DBCC CHECKDB WITH PHYSICAL_ONLY, NO_INFOMSGS;
GO

-- Vollständig: physisch + logisch, inkl. Indizes und Constraints
-- DBCC CHECKDB WITH DATA_PURITY, NO_INFOMSGS, ALL_ERRORMSGS;
-- GO
