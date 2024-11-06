1. How many olympics games have been held?
```sql
Select  count(distinct games) as no_of_games
From OLYMPICS_HISTORY;
```
2. List down all Olympics games held so far.
```sql
Select distinct year, season, city
From OLYMPICS_HISTORY
order by year;
```
3. Mention the total no of nations who participated in each olympics game?
```sql
Select games, count(distinct noc) as no_of_countries
From OLYMPICS_HISTORY
Group by games
Order by games;
```
4. Which year saw the highest and lowest no of countries participating in olympics?
```sql
with cte as (
Select games, count(distinct noc) as no_of_countries
From OLYMPICS_HISTORY
Group by games
Order by games),

cte2 as (
  Select max(no_of_countries) as max_no, min(no_of_countries)  as min_no
  From cte)

Select 
 concat(t1.games, ' - ', max_no)  as higest_countries,
  concat(t2.games, ' - ', min_no)  as higest_countries

From  cte2
Join cte t1 On t1.no_of_countries = cte2.max_no 
Join cte t2 on t2.no_of_countries = cte2.min_no
```
4. Which year saw the highest and lowest no of countries participating in olympics?
```sql
 With cte as (
      Select
        games,
        count(distinct noc) as no_of_countries
      From OLYMPICS_HISTORY
      Group by games
)

Select
  max(case
    when no_of_countries = (Select min(no_of_countries) From cte) then concat(games, ' - ', no_of_countries) end) as lowest_countries,
 max(  case
    when no_of_countries = (Select max(no_of_countries) From cte) then concat(games, ' - ', no_of_countries) end) as highest_countries
From cte 
```


5. Which nation has participated in all of the olympic games?
```sql
Select region as country, count(distinct games) as no_of_games
From OLYMPICS_HISTORY oh
Join OLYMPICS_HISTORY_NOC_REGIONS ohr
  On oh.noc = ohr.noc
Group by region
Having count(distinct games) = (Select count(distinct games) as no_games
                                From OLYMPICS_HISTORY)
```
6. Identify the sport which was played in all summer olympics.
```sql
Select sport, count(distinct games) as no_games
From OLYMPICS_HISTORY
Where season = 'Summer'
Group by sport
Having count(distinct games) = (Select count( distinct games)
                                From OLYMPICS_HISTORY
                                Where season = 'Summer')
```

7. Which Sports were just played only once in the olympics?
```sql
Select sport, count(distinct games) as cnt_games
From OLYMPICS_HISTORY
Group by sport
Having count(distinct games) = 1
```

8. Fetch the total no of sports played in each olympic games.
```sql
Select games, count(distinct sport) as no_of_sport
From OLYMPICS_HISTORY
Group by games
order by no_of_sport desc
```
9. Fetch details of the oldest athletes to win a gold medal.
```sql
Select *
From
(Select *,
rank() over(order by age desc) as rnk
From OLYMPICS_HISTORY
Where medal = 'Gold' and
       age <> 'NA') a

Where rnk = 1
```

10. Find the Ratio of male and female athletes participated in all olympic games.
```sql
Select round(sum(case when sex = 'M' then 1 else 0 end):: decimal / sum(case when sex = 'F' then 1 else 0 end)::decimal,2) as ratio
From olympics_history
```




11. Fetch the top 5 athletes who have won the most gold medals.
```sql
With cte as (
Select name, count(medal) as tot_gold,
    dense_rank() over(order by count(medal) desc) as rnk
From OLYMPICS_HISTORY
Where medal = 'Gold'
Group by name
)

Select name, tot_gold
From cte
Where rnk < 6
order by tot_gold desc
```


12. Fetch the top 5 athletes who have won the most medals (gold/silver/bronze).
```sql
with cte as (
Select name, count(medal) as no_medals,
    dense_rank() over(order by count(medal) desc) as rnk
From OLYMPICS_HISTORY
Where medal <> 'NA'
Group by name
)

Select name, no_medals
From cte
Where rnk < 6
order by no_medals desc
```
13. Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won.
```sql
with cte as (
    Select region as country, count(medal) as no_of_medals,
            dense_rank() over(order by count(medal) desc) as rnk
    From OLYMPICS_HISTORY oh
    Join OLYMPICS_HISTORY_NOC_REGIONS ohr
      On oh.noc = or.noc
    Where medal <> 'NA'
    Group by region
) 

Select country, no_of_medals
From cte
Where rnk < 6
Order by no_of_medals desc
```


14. List down total gold, silver and broze medals won by each country.
```sql
Select
  region as country,
  Sum(case
    when medal = 'Gold' then 1 else 0 end) as gold,
  Sum(case
    when medal = 'Silver' then 1 else 0 end) as Silver,
  Sum(case
    when medal = 'Bronze' then 1 else 0 end) as Bronze
From OLYMPICS_HISTORY oh
Join OLYMPICS_HISTORY_NOC_REGIONS onr
  On oh.noc = onr.noc
Group by country
order by gold desc
```

15. List down total gold, silver and broze medals won by each country corresponding to each olympic games.
```sql

Select   
  games,
  region as country,
  Sum(
    case
      when medal = 'Gold' then 1 else 0 end) as gold,
    Sum(
    case
      when medal = 'Silver' then 1 else 0 end) as silver ,
    Sum(
    case
      when medal = 'Bronze' then 1 else 0 end) as Bronze
From OLYMPICS_HISTORY oh
Join OLYMPICS_HISTORY_NOC_REGIONS onr
  On oh.noc = onr.noc 
Group by games, region
```

16. Identify which country won the most gold, most silver and most bronze medals in each olympic games.

```sql

WITH cte_gold AS (
    SELECT 
        games,
        region AS country,
        COUNT(medal) AS gold,
        ROW_NUMBER() OVER(PARTITION BY games ORDER BY COUNT(medal) DESC) AS rw
    FROM OLYMPICS_HISTORY oh
    JOIN OLYMPICS_HISTORY_NOC_REGIONS onr ON oh.noc = onr.noc
    WHERE medal = 'Gold'
    GROUP BY games, region
),
cte_silver AS (
    SELECT 
        games,
        region AS country,
        COUNT(medal) AS silver,
        ROW_NUMBER() OVER(PARTITION BY games ORDER BY COUNT(medal) DESC) AS rw
    FROM OLYMPICS_HISTORY oh
    JOIN OLYMPICS_HISTORY_NOC_REGIONS onr ON oh.noc = onr.noc
    WHERE medal = 'Silver'
    GROUP BY games, region
),
cte_bronze AS (
    SELECT 
        games,
        region AS country,
        COUNT(medal) AS bronze,
        ROW_NUMBER() OVER(PARTITION BY games ORDER BY COUNT(medal) DESC) AS rw
    FROM OLYMPICS_HISTORY oh
    JOIN OLYMPICS_HISTORY_NOC_REGIONS onr ON oh.noc = onr.noc
    WHERE medal = 'Bronze'
    GROUP BY games, region
)

SELECT 
    g.games,
    CONCAT(g.country, ' - ', g.gold) AS gold,
    CONCAT(s.country, ' - ', s.silver) AS silver,
    CONCAT(b.country, ' - ', b.bronze) AS bronze
FROM cte_gold g
JOIN cte_silver s ON g.games = s.games AND g.rw = s.rw
JOIN cte_bronze b ON s.games = b.games AND s.rw = b.rw
WHERE g.rw = 1  -- Ensures only the top country per games and medal type
order by g.games 
```



  

17. Identify which country won the most gold, most silver, most bronze medals and the most medals in each olympic games.

```sql


with gold as
(Select games,region, count(medal) as gold, row_number() over(partition by games order by count(medal) desc) as rw
From olympics_history oh
Join olympics_history_noc_regions hr
Using(noc)
Where medal = 'Gold'
Group by games,region
),
silver as
(Select games,region, count(medal) as silver, row_number() over(partition by games order by count(medal) desc) as rw
From olympics_history oh
Join olympics_history_noc_regions hr
Using(noc)
Where medal = 'Silver'
Group by games,region),

bronze as
(Select games,region, count(medal) as bronze, row_number() over(partition by games order by count(medal) desc) as rw
From olympics_history oh
Join olympics_history_noc_regions hr
Using(noc)
Where medal = 'Bronze'
Group by games,region),

medals as
(Select games,region, count(medal) as medals, row_number() over(partition by games order by count(medal) desc) as rw
From olympics_history oh
Join olympics_history_noc_regions hr
Using(noc)
Where medal <> 'NA'
Group by games,region
)

SELECT games, concat(g.region,' - ',gold) as max_gold,  
      concat(s.region,' - ',silver) as max_silver,  
      concat(b.region,' - ',bronze) as max_bronze,  
      concat(m.region,' - ',medals) as max_medals
From gold g
Join silver s
using(games)
Join bronze b
using(games)
Join medals m
using(games)
Where g.rw = 1 and s.rw = 1 and b.rw = 1 and m.rw = 1  
```






18. Which countries have never won gold medal but have won silver/bronze medals?
```sql

Select 
  region as country,
  sum(
    case 
      when medal = 'gold' then 1 else 0 end) as gold, 
  sum(
    case 
      when medal = 'silver' then 1 else 0 end) as silver,
 sum(
    case 
      when medal = 'bronze' then 1 else 0 end) as bronze

From OLYMPICS_HISTORY oh
Join OLYMPICS_HISTORY_NOC_REGIONS ohr
  On oh.noc = ohr.noc
Where medal <> 'gold'
```
19. In which Sport/event, India has won highest medals.
```sql

Select sport, count(medal) as no_of_medal
From OLYMPICS_HISTORY
Where team = 'India' and
      medal <> 'NA'
group by sport
Order by no_of_medal desc
Limit 1
```

20. Break down all olympic games where india won medal for Hockey and how many medals in each olympic games.
```sql
Select team, sport, games, count(medal) as tot_medals
From 
OLYMPICS_HISTORY
Where team = 'India' and
      sport = 'Hockey' and
      medal <> 'NA'
Group by team, sport, games
Order by tot_medals desc# Olympics_SQL
```
