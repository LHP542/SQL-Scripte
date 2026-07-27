use BaseLineDB

select distinct CaptureDate from ConfigData

exec dbo.usp_SysConfigReport '2023-02-07 10:01:14.370', '2023-02-07 10:01:14.370'