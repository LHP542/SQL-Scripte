-- Oracle: COMPATIBLE-Parameter ändern.
-- ACHTUNG: irreversibel! Nach Erhöhung kann nur per Restore zurückgestellt werden.
-- Vor dem Ändern: dokumentieren + Backup!

-- Aktueller Wert
SHOW PARAMETER compatible;

-- Ändern (Beispiel auf 19.0.0). Wirksam nach Neustart.
ALTER SYSTEM SET COMPATIBLE = '19.0.0' SCOPE = SPFILE;

-- SHUTDOWN IMMEDIATE;
-- STARTUP;

-- Optimizer-Features unabhängig davon steuern (reversibel):
-- ALTER SYSTEM SET OPTIMIZER_FEATURES_ENABLE = '19.1.0' SCOPE = BOTH;
