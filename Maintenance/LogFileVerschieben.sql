use [master]


SELECT db.NAME,
       fs.physical_name,
       fs.NAME AS LogFileName
FROM   sys.databases db
       JOIN sys.master_files fs
         ON db.database_id = fs.database_id
WHERE  type_desc = 'LOG'
       AND db.NAME = 'TestDB_zumSpielen'


--Alter Database [TestDB_zumSpielen] set offline WITH ROLLBACK IMMEDIATE
--Alter DATABASE [TestDB_zumSpielen] MODIFY FILE (NAME = 'TestDB_zumSpielen_log', FILENAME = 'E:\MSSQL13.MSSQLSERVER\MSSQL\DATA\TestDB_zumSpielen_log.ldf')
--Alter Database [TestDB_zumSpielen] set online