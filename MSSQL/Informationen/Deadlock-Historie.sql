-- Deadlock-Graphen aus der system_health Extended-Event-Session.
-- Standardmäßig hält system_health nur die letzten ~5 MB Events vor
-- -> daher meist die letzten Stunden bis wenige Tage sichtbar.
-- Die deadlock_graph-XML lässt sich in SSMS als .xdl speichern und grafisch öffnen.

WITH SystemHealth AS
(
    SELECT CAST(target_data AS XML) AS TargetData
    FROM   sys.dm_xe_session_targets st
    JOIN   sys.dm_xe_sessions s ON s.address = st.event_session_address
    WHERE  s.name = 'system_health'
      AND  st.target_name = 'ring_buffer'
),
Events AS
(
    SELECT node.query('.')                                     AS EventXml,
           node.value('(@timestamp)[1]', 'datetime2')          AS EventTime
    FROM   SystemHealth
    CROSS APPLY TargetData.nodes('/RingBufferTarget/event[@name="xml_deadlock_report"]') AS T(node)
)
SELECT TOP 50
    EventTime                                                                   AS deadlock_time,
    EventXml.value('(event/data[@name="xml_report"]/value/deadlock/victim-list/victimProcess/@id)[1]',
                   'nvarchar(50)')                                              AS victim_process,
    EventXml.query('event/data[@name="xml_report"]/value/deadlock')             AS deadlock_graph
FROM Events
ORDER BY EventTime DESC;
