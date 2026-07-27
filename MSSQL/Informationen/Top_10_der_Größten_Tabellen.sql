SELECT 
     used AS "# of Pages"
     , rows AS "# of Rows"
     , (used * 8) / 1024 AS "# of MB"
     , CAST(OBJECT_NAME(id) AS CHAR(30)) AS TableName
FROM 
     sysindexes 
WHERE 
     indid IN(1,2,255)
ORDER BY
     used 
DESC