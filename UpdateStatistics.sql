--Check last update date
SELECT name AS StatsName, last_updated, rows, modification_counter   
FROM sys.stats AS stat   
CROSS APPLY sys.dm_db_stats_properties(stat.object_id, stat.stats_id) AS sp  
ORDER BY modification_counter desc 

--Update all statistics
DECLARE @cmd NVARCHAR(2000)
DECLARE stats_cursor CURSOR FOR 
SELECT 'UPDATE STATISTICS ' + OBJECT_SCHEMA_NAME(stat.object_id) + '.' + OBJECT_NAME(stat.object_id) + ' ' + name + ';' AS command
FROM sys.stats AS stat    
CROSS APPLY sys.dm_db_stats_properties(stat.object_id, stat.stats_id) AS sp   
WHERE last_updated < GetDate()-7 OR modification_counter > rows*.10
 
OPEN stats_cursor  
FETCH NEXT FROM stats_cursor INTO @cmd
 
WHILE @@FETCH_STATUS = 0  
BEGIN  
  EXEC sp_executesql @cmd
  FETCH NEXT FROM stats_cursor INTO @cmd 
END  
CLOSE stats_cursor  
DEALLOCATE stats_cursor
