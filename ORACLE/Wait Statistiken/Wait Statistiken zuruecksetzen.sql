-- Oracle: V$SYSTEM_EVENT lässt sich NICHT ohne Instance-Restart zurücksetzen.
-- Für Delta-Analysen ohne AWR (SE2!) selbst snapshotten.

-- Snapshot-Tabelle einmalig anlegen
CREATE TABLE wait_snap (
    snap_id     NUMBER,
    snap_time   TIMESTAMP DEFAULT SYSTIMESTAMP,
    event       VARCHAR2(64),
    wait_class  VARCHAR2(64),
    total_waits NUMBER,
    time_waited_micro NUMBER
);

CREATE SEQUENCE wait_snap_seq;

-- Snapshot erzeugen (vor und nach der interessanten Phase je einmal)
INSERT INTO wait_snap (snap_id, event, wait_class, total_waits, time_waited_micro)
SELECT wait_snap_seq.NEXTVAL, event, wait_class, total_waits, time_waited_micro
FROM   v$system_event
WHERE  wait_class <> 'Idle';
COMMIT;

-- Delta zwischen zwei Snapshots (start = kleinere snap_id, end = größere)
DEFINE snap_start = 1;
DEFINE snap_end   = 2;

SELECT
    e.event,
    e.wait_class,
    e.total_waits       - s.total_waits       AS delta_waits,
    e.time_waited_micro - s.time_waited_micro AS delta_time_us,
    ROUND((e.time_waited_micro - s.time_waited_micro) / 1000000, 2) AS delta_time_sec
FROM   wait_snap s
JOIN   wait_snap e
       ON  e.event = s.event
       AND s.snap_id = &snap_start
       AND e.snap_id = &snap_end
WHERE  e.time_waited_micro - s.time_waited_micro > 0
ORDER BY delta_time_us DESC
FETCH FIRST 25 ROWS ONLY;

-- Enterprise Edition + Diagnostics Pack: AWR-Snapshots + AWR-Report
-- BEGIN DBMS_WORKLOAD_REPOSITORY.CREATE_SNAPSHOT(); END;
-- @?/rdbms/admin/awrrpt.sql
