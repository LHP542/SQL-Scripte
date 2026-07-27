-- Oracle: "Orphaned Users" gibt es so nicht wie in MSSQL - Login und User
-- sind dieselbe Entität. Analoge Auffälligkeiten:
--   - User ohne Default-Tablespace bzw. mit gesperrtem Account
--   - Schema-Owner ohne Objekte (Karteileichen)
--   - User ohne CREATE SESSION Privileg (können nicht mehr anmelden)

-- 1) Gesperrte / expired Accounts
SELECT
    username,
    account_status,
    lock_date,
    expiry_date,
    default_tablespace,
    profile,
    last_login
FROM   dba_users
WHERE  account_status <> 'OPEN'
ORDER BY username;

-- 2) Schema-Owner OHNE Objekte
SELECT
    u.username,
    u.created,
    u.last_login
FROM   dba_users u
LEFT JOIN (SELECT owner FROM dba_objects GROUP BY owner) o ON o.owner = u.username
WHERE  o.owner IS NULL
  AND  u.oracle_maintained = 'N';

-- 3) User ohne CREATE SESSION (indirekt via Rolle wäre trotzdem ok)
-- SELECT username FROM dba_users u
-- WHERE  u.oracle_maintained = 'N'
--   AND  NOT EXISTS (SELECT 1 FROM dba_sys_privs sp
--                    WHERE sp.grantee = u.username AND sp.privilege = 'CREATE SESSION')
--   AND  NOT EXISTS (SELECT 1 FROM dba_role_privs rp
--                    WHERE rp.grantee = u.username);
