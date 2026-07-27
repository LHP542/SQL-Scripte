-- Struktur-Übersicht: Tabellen, Spalten, PKs, FKs für ein Schema.

DEFINE schema_name = 'SCOTT';

SELECT
    tc.owner                                                       AS schema_name,
    tc.table_name,
    tc.column_name,
    tc.data_type ||
      CASE
        WHEN tc.data_type IN ('VARCHAR2','CHAR','NVARCHAR2','NCHAR')
             THEN '(' || tc.data_length || ')'
        WHEN tc.data_type = 'NUMBER' AND tc.data_precision IS NOT NULL
             THEN '(' || tc.data_precision || NVL2(tc.data_scale, ','||tc.data_scale, '') || ')'
        ELSE ''
      END                                                          AS datatype,
    tc.nullable,
    tc.column_id                                                   AS ordinal_position,
    CASE WHEN pk.column_name IS NOT NULL THEN 'PK' END              AS pk_flag,
    fk.constraint_name                                              AS fk_name,
    fk.r_table                                                      AS referenced_table,
    fk.r_column                                                     AS referenced_column
FROM   dba_tab_columns tc
LEFT JOIN (
    SELECT c.owner, c.table_name, cc.column_name
    FROM   dba_constraints c
    JOIN   dba_cons_columns cc ON cc.constraint_name = c.constraint_name AND cc.owner = c.owner
    WHERE  c.constraint_type = 'P'
) pk ON pk.owner = tc.owner AND pk.table_name = tc.table_name AND pk.column_name = tc.column_name
LEFT JOIN (
    SELECT c.owner, c.table_name, cc.column_name, c.constraint_name,
           rc.table_name AS r_table, rcc.column_name AS r_column
    FROM   dba_constraints c
    JOIN   dba_cons_columns cc  ON cc.constraint_name  = c.constraint_name AND cc.owner  = c.owner
    JOIN   dba_constraints rc   ON rc.constraint_name  = c.r_constraint_name AND rc.owner = c.r_owner
    JOIN   dba_cons_columns rcc ON rcc.constraint_name = rc.constraint_name AND rcc.owner = rc.owner AND rcc.position = cc.position
    WHERE  c.constraint_type = 'R'
) fk ON fk.owner = tc.owner AND fk.table_name = tc.table_name AND fk.column_name = tc.column_name
WHERE  tc.owner = '&schema_name'
ORDER BY tc.table_name, tc.column_id;
