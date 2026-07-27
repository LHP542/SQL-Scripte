-- Instanz-Parameter (Analog zu MSSQL sp_configure).
-- Interessant sind meist die von Default abweichenden.

SELECT
    name,
    value,
    default_value,
    isdefault,
    ismodified,
    description
FROM   v$parameter
WHERE  isdefault = 'FALSE'
ORDER BY name;

-- Alle Parameter (Filter nach Bedarf)
-- SELECT name, value, description
-- FROM   v$parameter
-- WHERE  name LIKE '%memory%'
--    OR  name LIKE '%sga%'
--    OR  name LIKE '%pga%'
--    OR  name LIKE '%cpu%';

-- SPFILE vs. Runtime-Wert (falls Änderungen bereits im SPFILE, aber noch nicht aktiv)
-- SELECT p.name, p.value AS runtime_value, sp.value AS spfile_value
-- FROM   v$parameter p
-- JOIN   v$spparameter sp ON sp.name = p.name
-- WHERE  p.value <> sp.value;
