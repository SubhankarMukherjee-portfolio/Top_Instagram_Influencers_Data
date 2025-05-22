create database top_insta_influencers_data;
use top_insta_influencers_data;

#check number of empty rows
SELECT * 
FROM top_insta_influencers_data
WHERE Ranks IS NULL 
   OR channel_info IS NULL
   OR influence_score IS NULL
   OR posts_new_in_k IS NULL
   OR followers_new_in_m IS NULL
   OR avg_likes_new_in_m IS NULL
   OR new_60_day_eng_rate IS NULL
   OR new_post_avg_like_in_m IS NULL
   OR new_total_likes_in_b IS NULL 
   OR country IS NULL;

#count number of empty rows
SELECT COUNT(*) AS empty_row_count from top_insta_influencers_data
WHERE Ranks IS NULL 
   OR channel_info IS NULL
   OR influence_score IS NULL
   OR posts_new_in_k IS NULL
   OR followers_new_in_m IS NULL
   OR avg_likes_new_in_m IS NULL
   OR new_60_day_eng_rate IS NULL
   OR new_post_avg_like_in_m IS NULL
   OR new_total_likes_in_b IS NULL 
   OR country IS NULL;

#Delete null rows
SET SQL_SAFE_UPDATES = 0;
DELETE FROM top_insta_influencers_data
WHERE Ranks IS NULL 
   OR channel_info IS NULL
   OR influence_score IS NULL
   OR posts_new_in_k IS NULL
   OR followers_new_in_m IS NULL
   OR avg_likes_new_in_m IS NULL
   OR new_60_day_eng_rate IS NULL
   OR new_post_avg_like_in_m IS NULL
   OR new_total_likes_in_b IS NULL 
   OR country IS NULL;
SET SQL_SAFE_UPDATES = 1;

#check for duplicates
SELECT channel_info, COUNT(*) AS count_order
FROM top_insta_influencers_data
GROUP BY channel_info
HAVING COUNT(*) > 1;

ALTER TABLE top_insta_influencers_data
add COLUMN posts_new_in_k DECIMAL(10,2);

SET SQL_SAFE_UPDATES = 0;

UPDATE top_insta_influencers_data
SET posts_new_in_k = CASE
    WHEN posts IS NULL OR posts = '' THEN 0
    WHEN posts LIKE '%k' THEN CONVERT(REPLACE(REPLACE(posts, 'k', ''), ',', ''), DECIMAL(10,2))
    ELSE NULL
END;


ALTER TABLE top_insta_influencers_data
add COLUMN followers_new_in_m DECIMAL(10,2);

UPDATE top_insta_influencers_data
SET followers_new_in_m = CASE
    WHEN followers IS NULL OR followers = '' THEN 0
    WHEN followers LIKE '%m' THEN CONVERT(REPLACE(REPLACE(followers, 'm', ''), ',', ''), DECIMAL(10,2))
    ELSE NULL
END;



ALTER TABLE top_insta_influencers_data
add COLUMN avg_likes_new_in_m DECIMAL(15,2);

UPDATE top_insta_influencers_data
SET avg_likes_new_in_m = CASE
    WHEN avg_likes LIKE '%m' THEN
        CONVERT(REPLACE(REPLACE(avg_likes, 'm', ''), ',', ''), DECIMAL(15,2))
    WHEN avg_likes LIKE '%k' THEN
        CONVERT(REPLACE(REPLACE(avg_likes, 'k', ''), ',', ''), DECIMAL(15,2)) / 1000
    ELSE NULL
END;



ALTER TABLE top_insta_influencers_data
add COLUMN new_post_avg_like_in_m DECIMAL(10,2);

UPDATE top_insta_influencers_data
SET new_post_avg_like_in_m = CASE
    WHEN new_post_avg_like IS NULL OR new_post_avg_like = '' THEN 0
    WHEN new_post_avg_like LIKE '%m' THEN 
        CONVERT(REPLACE(REPLACE(new_post_avg_like, 'm', ''), ',', ''), DECIMAL(10,2))
    WHEN new_post_avg_like LIKE '%k' THEN 
        CONVERT(REPLACE(REPLACE(new_post_avg_like, 'k', ''), ',', ''), DECIMAL(10,2)) / 1000
    ELSE null
END;


ALTER TABLE top_insta_influencers_data
add COLUMN new_total_likes_in_b DECIMAL(10,2);

UPDATE top_insta_influencers_data
SET new_total_likes_in_b = CASE
    WHEN total_likes IS NULL OR total_likes = '' THEN 0
    WHEN total_likes LIKE '%m' THEN 
        CONVERT(REPLACE(REPLACE(total_likes, 'm', ''), ',', ''), DECIMAL(10,2))/1000
    WHEN total_likes LIKE '%b' THEN 
        CONVERT(REPLACE(REPLACE(total_likes, 'b', ''), ',', ''), DECIMAL(10,2)) 
    ELSE null
END;


ALTER TABLE top_insta_influencers_data
add COLUMN new_60_day_eng_rate DECIMAL(10,2);

UPDATE top_insta_influencers_data
SET new_60_day_eng_rate = CASE
    WHEN `60_day_eng_rate` IS NULL OR `60_day_eng_rate` = '' THEN 0
    WHEN REPLACE(`60_day_eng_rate`, '%', '') REGEXP '^[0-9]+(\.[0-9]+)?$'
    THEN CAST(REPLACE(`60_day_eng_rate`, '%', '') AS DECIMAL(10,2))
    ELSE NULL
END;

ALTER TABLE top_insta_influencers_data
DROP COLUMN 60_day_eng_rate,
DROP COLUMN posts,
DROP COLUMN followers,
DROP COLUMN avg_likes,
DROP COLUMN new_post_avg_like,
DROP COLUMN total_likes;

select * from top_insta_influencers_data;

#1)	Top Influencers by Followers
SELECT RANK() OVER (ORDER BY followers_new_in_m DESC) AS ranks,channel_info,followers_new_in_m FROM top_insta_influencers_data
ORDER BY ranks ASC;

#2)	Average Influence Score by Country
select RANK() OVER (ORDER BY avg(influence_score) DESC) AS ranks, country,avg(influence_score)  as Average_Influence_Score FROM top_insta_influencers_data
where country  <> ''
group by country
order by ranks ASC;
   
#3)	Most Active Influencers by Number of Posts
SELECT RANK() OVER (ORDER BY posts_new_in_k DESC) AS ranks,channel_info,posts_new_in_k FROM top_insta_influencers_data
ORDER BY ranks ASC;

#4)	Influencers with Engagement Rate Above 2%
SELECT COUNT(*) AS influencer_count
FROM top_insta_influencers_data
WHERE new_60_day_eng_rate > 2;


#5) Top Countries by Total Likes Across Influencers
select RANK() OVER (ORDER BY sum(new_total_likes_in_b) DESC) AS ranks,country,sum(new_total_likes_in_b) as total_likes_in_billion FROM top_insta_influencers_data
where country  <> ''
group by country
ORDER BY ranks ASC;

#6) Influencers with More Than 100 Million Followers and Influence Score Over 90
select rank() OVER (ORDER BY followers_new_in_m  DESC, influence_score desc ) AS ranks ,channel_info, followers_new_in_m, influence_score from top_insta_influencers_data
where followers_new_in_m>100 and influence_score>90
order by ranks asc;

#7) Influencer with Highest Engagement Rate
select channel_info, new_60_day_eng_rate from top_insta_influencers_data
ORDER BY new_60_day_eng_rate DESC;

#8) Total Likes per Post Ratio for Top 5 Influencers
SELECT  channel_info,  posts_new_in_k,  new_total_likes_in_b,  ROUND((new_total_likes_in_b * 1000000000.0 / (posts_new_in_k * 1000)) / 1000000, 2) AS likes_per_post_in_million FROM  top_insta_influencers_data
WHERE posts_new_in_k > 0
ORDER BY  likes_per_post_in_million DESC
LIMIT 5;

#9) Find influencers ranked between 11 and 20 with followers over 50 million
SELECT * 
FROM (SELECT RANK() OVER (ORDER BY followers_new_in_m DESC) AS ranks,channel_info,followers_new_in_m FROM top_insta_influencers_data
    WHERE followers_new_in_m > 50) AS ranked_data
WHERE ranks BETWEEN 11 AND 20;

#10) Compare influencers with more than 1 thousand posts
SELECT 
  CASE 
        WHEN posts_new_in_k >= 1 THEN 'Above 1k Posts'
        ELSE 'Below 1k Posts'
    END AS post_group,
    COUNT(*) AS total_influencers,
    ROUND(AVG(followers_new_in_m), 2) AS avg_followers_million,
    ROUND(AVG(influence_score), 2) AS avg_influence_score
FROM top_insta_influencers_data
WHERE posts_new_in_k > 10 OR posts_new_in_k < 8
GROUP BY post_group;


#11) Top 5 countries with the highest average followers per influencer
select country, round((sum(followers_new_in_m)  /count(channel_info)),2) as average_followers FROM top_insta_influencers_data
group by country
order by average_followers desc limit 5;

#12) Find influencers whose average likes dropped in recent posts
SELECT channel_info, avg_likes_new_in_m AS average_likes_in_million, new_post_avg_like_in_m AS new_post_average_likes_in_million FROM top_insta_influencers_data
WHERE avg_likes_new_in_m > new_post_avg_like_in_m
ORDER BY (avg_likes_new_in_m - new_post_avg_like_in_m) DESC;

#13) Influencers with high influence_score but low average likes (score > 90, likes < 1 million)
select channel_info, influence_score, new_post_avg_like_in_m as new_post_avg_like_in_million, avg_likes_new_in_m as average_likes_in_million from top_insta_influencers_data
where new_post_avg_like_in_m<1 and influence_score>90 and avg_likes_new_in_m<1
order by influence_score desc, new_post_avg_like_in_million asc;

#14) Find influencers whose average likes are more than 15% of their followers
SELECT channel_info,followers_new_in_m AS followers_in_million, avg_likes_new_in_m AS average_likes_in_million FROM top_insta_influencers_data
WHERE avg_likes_new_in_m > 0.15 * followers_new_in_m
ORDER BY followers_new_in_m DESC;

#15) Rank influencers within each country by total likes and show only the top 3 per country.
SELECT * 
FROM (select RANK() OVER (partition by country ORDER BY new_total_likes_in_b DESC) AS ranks, country, channel_info, new_total_likes_in_b as new_total_likes_in_bilion from top_insta_influencers_data
	  where country <> ''
      order by new_total_likes_in_bilion desc) ranked_data
WHERE ranks <= 3
ORDER BY country desc;

#16) Which influencers have consistently high performance (above mean in all of: followers, avg_likes, and engagement rate)?
SELECT channel_info, influence_score, followers_new_in_m, new_total_likes_in_b, new_60_day_eng_rate FROM top_insta_influencers_data
WHERE influence_score > (SELECT AVG(influence_score) FROM top_insta_influencers_data)
    AND followers_new_in_m > (SELECT AVG(followers_new_in_m) FROM top_insta_influencers_data)
    AND new_total_likes_in_b > (SELECT AVG(new_total_likes_in_b) FROM top_insta_influencers_data)
    AND new_60_day_eng_rate > (SELECT AVG(new_60_day_eng_rate) FROM top_insta_influencers_data)
ORDER BY influence_score DESC, followers_new_in_m DESC, new_total_likes_in_b DESC, new_60_day_eng_rate DESC;

#17) Identify influencers who are in the top 10% by followers but bottom 10% by total likes.
WITH ranked_data AS (
  SELECT channel_info,followers_new_in_m AS followers_in_million,new_total_likes_in_b AS total_likes_in_billion,
    PERCENT_RANK() OVER (ORDER BY followers_new_in_m) AS follower_rank,
    PERCENT_RANK() OVER (ORDER BY new_total_likes_in_b) AS likes_rank
  FROM top_insta_influencers_data)
SELECT channel_info,followers_in_million,total_likes_in_billion FROM ranked_data
WHERE follower_rank >= 0.90  
  AND likes_rank <= 0.10 
ORDER BY followers_in_million DESC;



