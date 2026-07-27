-- Top 10 größte Segmente (Tabellen + Partitionen), ohne System-Schemas.

SELECT * FROM (
    SELECT
        s.owner,
        s.segment_name,
        s.segment_type,
        s.tablespace_name,
        ROUND(s.bytes / 1024 / 1024, 2)   AS size_mb,
        s.blocks,
        s.extents,
        t.num_rows
    FROM   dba_segments s
    LEFT JOIN dba_tables t
           ON t.owner = s.owner AND t.table_name = s.segment_name
    WHERE  s.segment_type IN ('TABLE','TABLE PARTITION','TABLE SUBPARTITION')
      AND  s.owner NOT IN ('SYS','SYSTEM','DBSNMP','OUTLN','APPQOSSYS','GSMADMIN_INTERNAL')
    ORDER BY s.bytes DESC
)
WHERE ROWNUM <= 10;
