Create Table #DB_SIZE(
	DATABASE_NAME varchar(max),
	DATABASE_SIZE decimal(12,2),
	REMARKS varchar(max)
)

Insert Into #DB_SIZE 
exec sp_databases

Select DATABASE_NAME, (DATABASE_SIZE *8) /1024 as "DATABASE_SIZE in MB" , REMARKS from #DB_SIZE order by DATABASE_SIZE desc

drop table #DB_SIZE

