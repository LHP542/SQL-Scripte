-- Kompletter sp_configure-Dump inkl. Advanced Options.
-- Zeigt alle Instanz-Einstellungen: max server memory, MAXDOP,
-- cost threshold for parallelism, remote query timeout, etc.

EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;

EXEC sp_configure;

-- Optional: nur Abweichungen von Default anzeigen
SELECT
    name,
    value,
    value_in_use,
    minimum,
    maximum,
    description
FROM sys.configurations
WHERE value <> value_in_use
   OR (name IN ('max server memory (MB)',
                'min server memory (MB)',
                'max degree of parallelism',
                'cost threshold for parallelism',
                'optimize for ad hoc workloads',
                'backup compression default'))
ORDER BY name;
