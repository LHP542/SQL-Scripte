-- Rechte in mehreren Schemas vergeben und User anlegen, falls nicht vorhanden.
-- "Datenbank" in MSSQL entspricht in Oracle typischerweise dem Schema.

DECLARE
    TYPE t_list IS TABLE OF VARCHAR2(128);
    v_schemas t_list := t_list('SCOTT','HR','APP_OWNER');
    v_users   t_list := t_list('DEV_USER','TEST_USER');
    v_sql     VARCHAR2(4000);
    v_exists  NUMBER;
BEGIN
    FOR u IN 1 .. v_users.COUNT LOOP

        -- User anlegen, wenn er noch nicht existiert
        SELECT COUNT(*) INTO v_exists FROM dba_users WHERE username = UPPER(v_users(u));
        IF v_exists = 0 THEN
            v_sql := 'CREATE USER ' || v_users(u)
                  || ' IDENTIFIED BY "Change_Me_Once!"'
                  || ' DEFAULT TABLESPACE USERS'
                  || ' TEMPORARY TABLESPACE TEMP';
            DBMS_OUTPUT.PUT_LINE(v_sql);
            EXECUTE IMMEDIATE v_sql;
            EXECUTE IMMEDIATE 'GRANT CREATE SESSION TO ' || v_users(u);
        END IF;

        -- Rechte auf jedes Ziel-Schema
        FOR s IN 1 .. v_schemas.COUNT LOOP
            FOR t IN (SELECT table_name FROM dba_tables WHERE owner = UPPER(v_schemas(s))) LOOP
                v_sql := 'GRANT SELECT, INSERT, UPDATE ON '
                      || v_schemas(s) || '.' || t.table_name
                      || ' TO ' || v_users(u);
                DBMS_OUTPUT.PUT_LINE(v_sql);
                BEGIN
                    EXECUTE IMMEDIATE v_sql;
                EXCEPTION
                    WHEN OTHERS THEN
                        DBMS_OUTPUT.PUT_LINE('  Fehler: ' || SQLERRM);
                END;
            END LOOP;
        END LOOP;

    END LOOP;
END;
/
