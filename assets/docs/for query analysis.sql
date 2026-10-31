use youtube_db;

/* we have to do few things 
1. define the variables
2. create a ctes - common table expression // want to round avg views per video column // instead of cte can also create subquery 
3. select column appropriate for analysis
4. filter the results by youtube channels with the highest subscribers bases
5. order by net profit from highest to lowest
*/

---1 step
declare @conversion_rate float = 0.02; -- the conversion rate is 2% 
declare @product_cost money = 5.0; -- product cost at 5 rs
declare @campaign_cost money = 50000.0; --campign cost at 50k rs


--2 step
with channel_data as (
    select 
    yt_channel_title,
    total_subscribers,
    total_views,
    total_videos, 
    round((cast(total_views as float)/total_videos ), -4) as rounded_avg_views_per_video  -- -4 is for rounding to the nearest 10,000 place just like how in decimal we do

    from view_top_india_youtubers
)

-- 3. select columns that we need and calculations

select 
    yt_channel_title, 
    rounded_avg_views_per_video,
    (rounded_avg_views_per_video* @conversion_rate) as potential_untis_sold_per_video,
    (rounded_avg_views_per_video* @conversion_rate * @product_cost) as potential_revenue_per_video,
    (rounded_avg_views_per_video* @conversion_rate * @product_cost) - @campaign_cost as net_profit_per_video
from channel_data
where yt_channel_title in ('T-Series', 'SET India', 'Zee Music Company')
order by net_profit_per_video desc