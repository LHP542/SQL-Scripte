-- Top Wait Events der Instanz (kumulativ seit Startup).
-- Idle-Events werden ausgefiltert (die drücken sonst alles nach unten).

SELECT
    e.wait_class,
    e.event,
    e.total_waits,
    ROUND(e.time_waited     / 100, 2)                          AS time_waited_sec,
    ROUND(e.time_waited_micro / 1000000, 2)                    AS time_waited_sec_micro,
    ROUND(e.average_wait,   4)                                 AS avg_wait_cs,
    ROUND(100 * e.time_waited / SUM(e.time_waited) OVER (), 2) AS pct
FROM   v$system_event e
WHERE  e.wait_class <> 'Idle'
ORDER BY e.time_waited DESC
FETCH FIRST 25 ROWS ONLY;
