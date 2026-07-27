# SQL-Scripte

Sammlung von DBA-Skripten für **Microsoft SQL Server** und **Oracle Database**.
Getrennt in zwei parallele Top-Level-Ordner, in denen sich weitgehend identische
Skripte spiegeln – so ist der Umstieg / Vergleich zwischen den beiden RDBMS einfach.

```
.
├── MSSQL/    T-SQL — getestet gegen SQL Server 2016+
└── ORACLE/   SQL / PL/SQL — Zielumgebung Oracle 19c Standard Edition 2 (SE2)
```

> **Oracle-Kontext:** Die Skripte sind auf **Standard Edition 2** ausgelegt.
> Sie nutzen bewusst **kein AWR** (Diagnostics Pack), **keinen SQL Tuning /
> Access Advisor** (Tuning Pack) und **keine EE-only-Features** wie
> `FLASHBACK DATABASE`, `REBUILD ONLINE` oder `ALTER DATABASE MOVE DATAFILE`.
> An passenden Stellen ist die EE-Alternative als Kommentar mit dokumentiert.

Die Skripte sind bewusst kurz und **kopier-/anpassbar** gehalten. Datenbank-,
Schema-, Tabellen- und Benutzernamen sind Beispiele (`TestDB_zumSpielen`,
`SCOTT`, `SPAR_FIS`, `vis_prod`, …) und müssen vor dem Ausführen an die
eigene Umgebung angepasst werden.

---

## Struktur

Beide Wurzel-Ordner sind parallel aufgebaut:

```
MSSQL/                              ORACLE/
├── Allgemeines/                    ├── Allgemeines/
├── BaseLineDB/         (nur MSSQL) ├── Informationen/
├── Informationen/                  ├── Maintenance/
├── Maintenance/                    ├── Optimierungen/
├── Optimierungen/                  └── Wait Statistiken/
└── Wait Statistiken/
```

### Konvention
- **`Informationen/`** = **read-only**. Nichts hier verändert Daten oder Schema.
- **`Maintenance/`** und **`Optimierungen/`** enthalten **verändernde** Statements –
  vor dem Ausführen prüfen, ob der richtige Kontext (`USE …` bzw. `ALTER SESSION SET CURRENT_SCHEMA`) gesetzt ist.
- Beispielnamen wie `TestDB_zumSpielen`, `SCOTT`, `SPAR_FIS`, `vis_prod` sind
  **Platzhalter** – vor Ausführung ersetzen.

---

## MSSQL

### Allgemeines
| Skript | Zweck |
|---|---|
| `Benutzerrechte auf mehrere Datenbanken.sql` | Legt User an und vergibt `SELECT/INSERT/UPDATE` per Cursor über eine Liste von Datenbanken. |

### BaseLineDB
Reports gegen eine **eigene BaseLine-Datenbank** mit vorhandenen Stored Procedures
(`usp_serverConfigReport`, `usp_SysConfigReport`, `usp_SysStatisticReport`).
Ohne die SPs nicht direkt lauffähig.

### Informationen (read-only)
| Skript | Zweck |
|---|---|
| `Abfragepläne_im_Planecache.sql`     | Ausführungspläne + Nutzungshäufigkeit aus dem Plan-Cache. |
| `Aktuelle Abfragen.sql`              | Aktuell laufende Requests inkl. Wait-Type, CPU, SQL-Text. |
| `Aktuelle Abfragen kumuliert.sql`    | Aktuelle Requests aggregiert nach Host/Login/DB. |
| `ArbeitsspeicherProDatenbank.sql`    | Buffer-Pool-Größe je Datenbank. |
| `Autogrowth Events.sql`              | File-Autogrowth aus dem Default Trace. |
| `Backup-Historie.sql`                | Letztes Full/Diff/Log je DB inkl. Alter in Stunden. |
| `Backup-Konsistenzcheck.sql`         | Letztes Backup verifizieren. |
| `Blockierungen.sql`                  | Aktuelle Blocking-Session-Kette. |
| `Datenbank_Größe.sql`                | Größe aller Datenbanken (MB). |
| `Deadlock-Historie.sql`              | Deadlock-Graphen aus `system_health` XE-Session. |
| `Doppelte Indexe.sql`                | Indexe mit identischer Key-Column-Reihenfolge. |
| `Failed Logins.sql`                  | Fehlgeschlagene Logins aus dem Error-Log. |
| `File Space Usage.sql`               | Pro Datei: allokiert / belegt / frei + Autogrowth-Config. |
| `IO-Statistik Datenbank.sql`         | Physische IO-Werte + Stalls je Datei einer DB. |
| `Kompatibilitätslevel anzeigen.sql`  | Compat-Level, Recovery-Modell, Page-Verify aller DBs. |
| `Letzten Abfragen anzeigen.sql`      | Zuletzt ausgeführte Statements (letzte Stunde). |
| `Long Running Transactions.sql`      | Offene Transaktionen älter als X Minuten. |
| `OffeneSessions.sql`                 | Alle Sessions inkl. Host/Login/Status. |
| `Offene Verbindungen.sql`            | Verbindungs-Übersicht für `PDV_*`-DBs (DIA-spezifisch). |
| `Orphaned Users.sql`                 | DB-User ohne passenden Server-Login. |
| `QueryStore-Abfragen.sql`            | Query-Store-Status je User-Datenbank. |
| `Server-Info.sql`                    | Version/Edition/Cores/RAM/Uptime. |
| `Server-Konfiguration.sql`           | `sp_configure`-Dump inkl. Advanced Options. |
| `SizeAndFragmentation.sql`           | Größe + Fragmentierung für Tabelle/View. |
| `SQL-Agent Jobs.sql`                 | Letzter Lauf pro Job (Failed zuerst). |
| `SQLOffeneTransaktionenAnzeigen.sql` | Offene Transaktionen + belegter TempDB-Speicher. |
| `TabellenInfos.sql`                  | Struktur (Spalten, PKs, FKs) einer DB. |
| `Teuerste Abfragen.sql`              | Top 10 langsamste Statements (avg elapsed). |
| `Top_10_der_Größten_Tabellen.sql`    | Top 10 nach belegten Pages/MB. |
| `Trigger einer Datenbank.sql`        | Alle DML-Trigger auflisten. |
| `Unbenutzte Indexe.sql`              | Löschkandidaten: Indexe ohne Reads, aber mit Writes. |
| `VLF-Count.sql`                      | VLF-Count pro DB (Log-File-Health). |
| `WertInSpalteSuchen.sql`             | Volltextsuche über alle string-Spalten. |

### Maintenance (verändernd)
| Skript | Zweck |
|---|---|
| `Backup ausführen.sql`                   | Full-/Log-Backup mit `COMPRESSION`, `CHECKSUM`. |
| `CloseAllConnectionToDB.sql`             | Alle Verbindungen einer DB killen. |
| `Datenbank-Snapshot wiederherstellen.sql`| DB aus Snapshot zurücksetzen. |
| `DBCC CHECKDB.sql`                       | Integritätscheck (Physical-Only + Vollvariante). |
| `Index Rebuild und Reorganize.sql`       | Fragmentierungs-basiert: Rebuild ≥ 30 %, Reorganize ≥ 5 %. |
| `LogFileVerschieben.sql`                 | Logfile-Pfad einer DB umziehen. |
| `Restore mit MOVE.sql`                   | Restore-Template inkl. `HEADERONLY`/`FILELISTONLY`. |
| `Session killen.sql`                     | `KILL <spid>` Helper. |
| `Set Database ReadOnly.sql`              | DB auf READ_ONLY setzen. |
| `Set Database ReadWrite.sql`             | DB zurück auf READ_WRITE. |
| `Statistiken aktualisieren.sql`          | `UPDATE STATISTICS … WITH FULLSCAN`. |

### Optimierungen
| Skript | Zweck |
|---|---|
| `Automatisch erstellte Indexe löschen.sql`      | Löscht per DTA erzeugte `_dta_*`-Indexe. |
| `Automatisch erstellte Statistiken löschen.sql` | Löscht per DTA erzeugte `_dta_*`-Statistiken. |
| `Fehlende Indizes.sql`                          | Ranking fehlender Indexe nach Impact. |
| `Kompatibilitätslevel ändern.sql`               | `COMPATIBILITY_LEVEL` setzen. |
| `Page-Verify ändern.sql`                        | `PAGE_VERIFY CHECKSUM` setzen. |
| `Recovery-Model ändern.sql`                     | `FULL` / `SIMPLE` / `BULK_LOGGED`. |

### Wait Statistiken
| Skript | Zweck |
|---|---|
| `SQL_Clear_Wait_Statistic.sql`     | `sys.dm_os_wait_stats` zurücksetzen. |
| `SQL_Wait_Statistic.sql`           | Kurzform – ruft eigene SP `WaitStatistic`. |
| `SQL_Wait_Statistic_full.sql`      | Paul-Randal-Auswertung mit Rausch-Filter. |
| `SQL_What_are_you_waiting_for.sql` | Aktuell wartende Tasks (SPID, Wait-Type, Blocker). |

---

## ORACLE

### Allgemeines
| Skript | Zweck |
|---|---|
| `Benutzerrechte auf mehrere Schemas.sql` | Legt User an und vergibt `SELECT/INSERT/UPDATE` per Loop über mehrere Ziel-Schemas. |

### Informationen (read-only)
| Skript | Zweck | MSSQL-Pendant |
|---|---|---|
| `Abfrageplaene im Plancache.sql`      | Statements aus dem Shared Pool nach Nutzung. | Abfragepläne_im_Planecache |
| `Aktuelle Abfragen.sql`               | Aktive Requests inkl. Wait, CPU, SQL-Text. | Aktuelle Abfragen |
| `Aktuelle Abfragen kumuliert.sql`     | Aktive Sessions aggregiert nach Host/User. | Aktuelle Abfragen kumuliert |
| `Arbeitsspeicher pro Schema.sql`      | Buffer-Cache-Belegung nach Schema-Owner. | ArbeitsspeicherProDatenbank |
| `Autogrowth Events.sql`               | Tablespace-Wachstum aus AWR-Historie. | Autogrowth Events |
| `Backup-Historie.sql`                 | RMAN-Backupsätze der letzten 30 Tage. | Backup-Historie |
| `Backup-Konsistenzcheck.sql`          | Vorlagen für RMAN `VALIDATE`. | Backup-Konsistenzcheck |
| `Blockierungen.sql`                   | Blocking-Session-Kette über `V$LOCK`. | Blockierungen |
| `Datenbank Groesse.sql`               | Größe Data/Temp/Redo + pro Tablespace. | Datenbank_Größe |
| `Deadlock-Historie.sql`               | ORA-00060 aus dem Alert Log. | Deadlock-Historie |
| `Doppelte Indexe.sql`                 | Indexe mit identischer Key-Column-Reihenfolge. | Doppelte Indexe |
| `Failed Logins.sql`                   | Fehlgeschlagene Logins aus dem Audit Trail. | Failed Logins |
| `File Space Usage.sql`                | Datafile-Allokation + Free-Space + Autoextend. | File Space Usage |
| `IO-Statistik Datenbank.sql`          | Reads/Writes/Latenz pro Datafile. | IO-Statistik Datenbank |
| `Kompatibilitaetslevel anzeigen.sql`  | `COMPATIBLE`, Optimizer-Features, Log-Mode. | Kompatibilitätslevel anzeigen |
| `Letzten Abfragen anzeigen.sql`       | Letzte Statements im Shared Pool. | Letzten Abfragen anzeigen |
| `Long Running Transactions.sql`       | Offene TX älter als X Minuten + Undo-Nutzung. | Long Running Transactions |
| `Offene Sessions.sql`                 | Alle User-Sessions inkl. Herkunft. | OffeneSessions |
| `Offene Transaktionen.sql`            | Offene TX mit Undo/Log-IO. | SQLOffeneTransaktionenAnzeigen |
| `Orphaned Users.sql`                  | Gesperrte Accounts, Schemas ohne Objekte. | Orphaned Users |
| `Redo Log Info.sql`                   | Redo-Log-Groups, Log-Switch-Frequenz. | VLF-Count |
| `Scheduler Jobs.sql`                  | Oracle-Scheduler-Jobs, Failed zuerst. | SQL-Agent Jobs |
| `Server-Info.sql`                     | Version, Host, Uptime, CPU, SGA/PGA. | Server-Info |
| `Server-Konfiguration.sql`            | Nicht-Default-Parameter aus `V$PARAMETER`. | Server-Konfiguration |
| `Size and Fragmentation.sql`          | Segment-Größen + Index-Fragmentierung. | SizeAndFragmentation |
| `Tabellen Infos.sql`                  | Spalten, PKs, FKs eines Schemas. | TabellenInfos |
| `Teuerste Abfragen.sql`               | Top 10 nach avg elapsed time. | Teuerste Abfragen |
| `Top 10 der groessten Tabellen.sql`   | Top 10 Segmente nach MB. | Top_10_der_Größten_Tabellen |
| `Trigger eines Schemas.sql`           | Alle Trigger aus `DBA_TRIGGERS`. | Trigger einer Datenbank |
| `Unbenutzte Indexe.sql`               | Indexe ohne Zugriffe (12.2+ `DBA_INDEX_USAGE`). | Unbenutzte Indexe |
| `Wert in Spalte suchen.sql`           | PL/SQL-Volltextsuche über alle String-Spalten. | WertInSpalteSuchen |

### Maintenance (verändernd)
| Skript | Zweck | MSSQL-Pendant |
|---|---|---|
| `Alle Verbindungen zu Schema killen.sql` | Alle Sessions eines Users killen. | CloseAllConnectionToDB |
| `Backup ausfuehren.sql`                  | RMAN-Vorlagen (Full/Incremental/Archivelog). | Backup ausführen |
| `Datafile verschieben.sql`               | `ALTER DATABASE MOVE DATAFILE` (12c+). | LogFileVerschieben |
| `Point-in-Time Restore.sql`              | RMAN PIT-Recovery bis Ziel-Zeitpunkt (SE2-Ersatz für Flashback DB). | Datenbank-Snapshot wiederherstellen |
| `Index Rebuild.sql`                      | Online-Rebuild aller Schema-Indexe. | Index Rebuild und Reorganize |
| `Restore mit RMAN.sql`                   | RMAN `RESTORE` inkl. `SET NEWNAME`. | Restore mit MOVE |
| `Session killen.sql`                     | `ALTER SYSTEM KILL SESSION`. | Session killen |
| `Statistiken aktualisieren.sql`          | `DBMS_STATS.GATHER_SCHEMA_STATS`. | Statistiken aktualisieren |
| `Tablespace ReadOnly.sql`                | Tablespace / DB auf read-only. | Set Database ReadOnly |
| `Tablespace ReadWrite.sql`               | Tablespace / DB zurück auf read-write. | Set Database ReadWrite |
| `Validate Database.sql`                  | RMAN `VALIDATE` / `DBVERIFY` / `ANALYZE`. | DBCC CHECKDB |

### Optimierungen
| Skript | Zweck | MSSQL-Pendant |
|---|---|---|
| `Archivelog-Mode aendern.sql`                    | `ARCHIVELOG` / `NOARCHIVELOG` umschalten. | Recovery-Model ändern |
| `Automatisch erstellte Indexe loeschen.sql`      | `SYS_AI_*`-Indexe (Auto Index) droppen. | Automatisch erstellte Indexe löschen |
| `Automatisch erstellte Statistiken loeschen.sql` | Extended Stats mit `creator = 'AUTO'` droppen. | Automatisch erstellte Statistiken löschen |
| `Block Checking aendern.sql`                     | `db_block_checksum` / `db_block_checking`. | Page-Verify ändern |
| `Fehlende Indexe.sql`                            | SQL Tuning Advisor / SQL Access Advisor. | Fehlende Indizes |
| `Kompatibilitaetslevel aendern.sql`              | `COMPATIBLE`-Parameter setzen. | Kompatibilitätslevel ändern |

### Wait Statistiken
| Skript | Zweck | MSSQL-Pendant |
|---|---|---|
| `Aktuell wartende Sessions.sql`      | `V$SESSION` mit Wait-Event, P1/P2/P3, Blocker. | SQL_What_are_you_waiting_for |
| `Wait Statistiken.sql`               | Top Wait Events aus `V$SYSTEM_EVENT`. | SQL_Wait_Statistic_full |
| `Wait Statistiken zuruecksetzen.sql` | Hinweis: geht nur per Restart oder AWR-Delta. | SQL_Clear_Wait_Statistic |

---

## Nutzung

- **MSSQL**: SSMS / azdata / sqlcmd. Auf `USE […]` und Zieldatenbank achten.
- **Oracle**: SQL Developer / SQL*Plus / SQLcl. Auf angemeldetes Schema achten
  (`SHOW USER`) – manche Skripte brauchen SYSDBA-Rechte für die `DBA_*`-Views.
- **RMAN**-Vorlagen (Backup/Restore/Validate) werden **im rman-Client** ausgeführt,
  nicht in SQL*Plus.
- Vor `Maintenance/` und `Optimierungen/`: **Erst lesen, dann ausführen** –
  alles hier verändert Daten oder Objekte.

---

## Lizenz

Siehe [`LICENSE.txt`](LICENSE.txt).
