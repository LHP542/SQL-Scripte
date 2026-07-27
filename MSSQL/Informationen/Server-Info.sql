-- Kompakter Server-Steckbrief: Version, Edition, Host, Cores, Uptime, RAM.

SELECT
    SERVERPROPERTY('ServerName')                AS ServerName,
    SERVERPROPERTY('MachineName')               AS MachineName,
    SERVERPROPERTY('InstanceName')              AS InstanceName,
    SERVERPROPERTY('ProductVersion')            AS ProductVersion,
    SERVERPROPERTY('ProductLevel')              AS ProductLevel,
    SERVERPROPERTY('ProductUpdateLevel')        AS CumulativeUpdate,
    SERVERPROPERTY('Edition')                   AS Edition,
    SERVERPROPERTY('EngineEdition')             AS EngineEdition,
    SERVERPROPERTY('Collation')                 AS DefaultCollation,
    SERVERPROPERTY('IsClustered')               AS IsClustered,
    SERVERPROPERTY('IsHadrEnabled')             AS IsAlwaysOnEnabled,
    SERVERPROPERTY('IsFullTextInstalled')       AS IsFullTextInstalled;

-- @@VERSION im Klartext
SELECT @@VERSION AS FullVersion;

-- CPU / Scheduler
SELECT
    cpu_count               AS LogicalCores,
    hyperthread_ratio       AS Hyperthreads,
    physical_memory_kb/1024 AS PhysicalMemory_MB,
    committed_kb/1024       AS CommittedMemory_MB,
    committed_target_kb/1024 AS CommittedTarget_MB,
    sqlserver_start_time    AS ServiceStart,
    DATEDIFF(HOUR, sqlserver_start_time, GETDATE()) AS Uptime_Hours
FROM sys.dm_os_sys_info;
