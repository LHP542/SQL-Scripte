-- Alle Trigger eines Schemas (oder aller User-Schemas).

SELECT
    owner,
    trigger_name,
    trigger_type,
    triggering_event,
    table_owner,
    table_name,
    status,
    action_type,
    when_clause
FROM   dba_triggers
WHERE  owner NOT IN ('SYS','SYSTEM','DBSNMP','OUTLN','MDSYS','XDB','APPQOSSYS')
ORDER BY owner, table_name, trigger_name;
