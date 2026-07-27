-- Findet Indexe mit identischer Key-Column-Reihenfolge auf derselben Tabelle.
-- Include-Columns hat Oracle nicht (nur ab 19c für Materialized Views o. ä.),
-- daher reicht der Vergleich der COLUMN_POSITION-Reihe.

WITH idx_cols AS (
    SELECT
        ic.index_owner,
        ic.index_name,
        ic.table_owner,
        ic.table_name,
        LISTAGG(ic.column_name || CASE ic.descend WHEN 'DESC' THEN ' DESC' ELSE '' END,
                ',') WITHIN GROUP (ORDER BY ic.column_position) AS key_columns
    FROM   dba_ind_columns ic
    WHERE  ic.table_owner NOT IN ('SYS','SYSTEM','DBSNMP','OUTLN','APPQOSSYS','GSMADMIN_INTERNAL')
    GROUP BY ic.index_owner, ic.index_name, ic.table_owner, ic.table_name
)
SELECT
    table_owner || '.' || table_name       AS table_name,
    key_columns,
    COUNT(*)                               AS duplicate_count,
    LISTAGG(index_owner || '.' || index_name, ', ')
        WITHIN GROUP (ORDER BY index_name) AS duplicate_indexes
FROM   idx_cols
GROUP BY table_owner, table_name, key_columns
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC, table_name;
