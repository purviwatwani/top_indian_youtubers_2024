SELECT TOP (1000) [Column_1]
      ,[NAME]
      ,[FOLLOWERS]
      ,[ER]
      ,[COUNTRY]
      ,[TOPIC_OF_INFLUENCE]
      ,[POTENTIAL_REACH]
      ,[yt_channel_id]
      ,[yt_channel_title]
      ,[total_subscribers]
      ,[total_views]
      ,[total_videos]
  FROM [youtube_db].[dbo].[top_india_youtubers_2024]

/*
data cleaning steps 
1. remove unncessary columns by only selecting the required columns
2. EXTRACT THE YT CHANNEL NAMES FROM FIRST COLUMNS
3. RENAME THE COLUMN NAMES

  */

USE youtube_db;
  SELECT yt_channel_title, total_subscribers ,total_views ,total_videos FROM top_india_youtubers_2024;
  

 -- Char index function 
 --so basically char index is used to find the position of a specific character or substring within a string. It returns the starting position of the first occurrence of the specified character or substring. If the character or substring is not found, it returns 0.
-- so lets assume that you have the original data that is the name column for the youtube channel with @ and everything 
-- so for that you would have to use char index to find the position of @ and then use substring to extract the name of the channel from the original data.

--for example
USE youtube_db;
  SELECT name, yt_channel_title, total_subscribers ,total_views ,total_videos FROM top_india_youtubers_2024;


 --SUBSTRING(string, start_position, length) 
select substring(name,1,charindex('@',name)-1 )from youtube_db.dbo.top_india_youtubers_2024;
--this will give you the name of the channel without @ and everything after it

--select charindex('@',name), name from youtube_db.dbo.top_india_youtubers_2024;
--this will give you position of @ in name column


--but currently you have the column that u got through excel so np need to use char index and substring function as you already have the channel names in the yt_channel_title column.

CREATE VIEW view_top_india_youtubers AS
SELECT CAST(yt_channel_title AS VARCHAR(100)) AS yt_channel_title, total_subscribers ,total_views ,total_videos FROM youtube_db.dbo.top_india_youtubers_2024;


use youtube_db;
SELECT * FROM dbo.view_top_india_youtubers;

-- now we check for the data qualities
-- row count check = 100 is passed
select count(*) as no_of_rows
from youtube_db.dbo.view_top_india_youtubers;


--this is data type check - passed

select column_name, DATA_TYPE
 from information_schema.columns
where table_name = 'view_top_india_youtubers';


select * from information_schema.columns
where table_name = 'view_top_india_youtubers';


--column count check -- information schema - bunch of sql views that knows all info about your databases <if you want any info about any object in your database use information schema
--column count = 4 so passed

select count(*) as no_of_columns
from information_schema.columns
where table_name = 'view_top_india_youtubers';

--now we need to check for duplicates and null values

-- this basically means in channel name we are checking which channel name is repeated more than once in the table and we are counting how many times it is repeated. If it is repeated more than once then it is a duplicate.


select yt_channel_title,
count(*) as duplicate_count
from view_top_india_youtubers
group by yt_channel_title
having count(*) >1;



