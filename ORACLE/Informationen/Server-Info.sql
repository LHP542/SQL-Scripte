-- Server-Steckbrief: Version, Host, DB-Name, Uptime, CPU, RAM.

-- Version
SELECT banner_full FROM v$version WHERE ROWNUM = 1;

-- Instance / Host
SELECT
    i.instance_name,
    i.host_name,
    i.version,
    i.startup_time,
    ROUND((SYSDATE - i.startup_time) * 24, 2) AS uptime_hours,
    i.status,
    i.database_status,
    i.instance_role,
    i.active_state,
    i.blocked
FROM   v$instance i;

-- Datenbank
SELECT
    d.name,
    d.dbid,
    d.created,
    d.open_mode,
    d.log_mode,
    d.flashback_on,
    d.platform_name,
    d.cdb                       AS is_container_db
FROM   v$database d;

-- CPU / RAM / OS
SELECT stat_name, value
FROM   v$osstat
WHERE  stat_name IN ('NUM_CPUS','NUM_CPU_CORES','NUM_CPU_SOCKETS',
                     'PHYSICAL_MEMORY_BYTES','LOAD','IDLE_TIME','BUSY_TIME');

-- SGA / PGA
SELECT name, ROUND(value/1024/1024, 2) AS mb
FROM   v$sga;

SELECT name, ROUND(value/1024/1024, 2) AS mb
FROM   v$pgastat
WHERE  name IN ('total PGA allocated','total PGA inuse','aggregate PGA target parameter');
