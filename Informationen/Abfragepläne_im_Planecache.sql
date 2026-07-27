Select ECP.objtype as Type,
		db_name(EST.DBID) as DBName,
		est.text as SQLBefehl,
		OBJECT_NAME(est.objectid, est.dbid) as Objectname,
		ecp.usecounts as Anzahl_genutzt,
		eqp.query_plan as Abfrageplan

from sys.dm_exec_cached_plans as ECP
cross Apply sys.dm_exec_query_plan(ecp.plan_handle) as EQP
cross apply sys.dm_exec_sql_text(ecp.plan_handle) as EST
order by ecp.usecounts desc