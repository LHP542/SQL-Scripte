-- Rechte in allen Datenbanken vergeben und Benutzer ggf. hinzufügen
DECLARE @dbs TABLE (name SYSNAME);
INSERT INTO @dbs (name) VALUES
('vis_prod_sql'), ('vis_prod'), ('vis_test_sql'), ('vis_test_sql2'),
('pdv_spar_kis'), ('pdv_spar_fis'),
('kis_spar_kis'), ('kis_spar_fis'), ('kis_spar_kis2'),
('DIA_SASYSTEM'), ('DIA_SA001'), ('DIA_SA005'),
('DIA_SASYSTEM_TEST'), ('DIA_SA001_TEST'), ('DIA_SA005_TEST');

DECLARE @users TABLE (name SYSNAME);
INSERT INTO @users (name) VALUES ('lhp\ukochm'), ('lhp\uboehmerm'), ('lhp\uhoeschelm');

DECLARE @db SYSNAME, @user SYSNAME, @sql NVARCHAR(MAX);

DECLARE db_cursor CURSOR FOR SELECT name FROM @dbs;
OPEN db_cursor;
FETCH NEXT FROM db_cursor INTO @db;
WHILE @@FETCH_STATUS = 0
BEGIN
    DECLARE user_cursor CURSOR FOR SELECT name FROM @users;
    OPEN user_cursor;
    FETCH NEXT FROM user_cursor INTO @user;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @sql = '
        USE [' + @db + '];
        IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = N''' + @user + ''')
        BEGIN
            CREATE USER [' + @user + '] FOR LOGIN [' + @user + '];
        END
        GRANT SELECT, INSERT, UPDATE TO [' + @user + '];';
        EXEC sp_executesql @sql;

        FETCH NEXT FROM user_cursor INTO @user;
    END
    CLOSE user_cursor;
    DEALLOCATE user_cursor;

    FETCH NEXT FROM db_cursor INTO @db;
END
CLOSE db_cursor;
DEALLOCATE db_cursor;
