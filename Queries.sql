--1. How many olympics games have been held?

Select  count(distinct games) as no_of_games
From OLYMPICS_HISTORY;

--2. List down all Olympics games held so far.

Select distinct year, season, city
From OLYMPICS_HISTORY;

--3. Mention the total no of nations who participated in each olympics game?

Select games, count(distinct noc) as no_of_countries
From OLYMPICS_HISTORY
Group by games
Order by games;

--4. Which year saw the highest and lowest no of countries participating in olympics?

with cte as (
Select games, count(distinct noc) as no_of_countries
From OLYMPICS_HISTORY
Group by games
Order by games),

cte2 as (
  Select max(no_of_countries) as max_no, min(no_of_countries)  as min_no
  From cte)

Select 
  case
    When no_of_countries = max_no then concat(games, ' - ', max_no) end as higest_countries,
  case 
    when no_of_countries = min_no then  concat(games, ' - ', min_no) end as lowest_countries
From  cte2
Join cte 
  

--4. Which year saw the highest and lowest no of countries participating in olympics?

  With cte as (
      Select
        games,
        count(distinct noc) as no_of_countries
      From OLYMPICS_HISTORY
      Group by games
)

Select
  case
    when no_of_countries = (Select min(no_of_countries) From cte) then concat(games, ' - ', no_of_countries) end as lowest_countries,
   case
    when no_of_countries = (Select max(no_of_countries) From cte) then concat(games, ' - ', no_of_countries) end as highest_countries
From cte 

  


WITH cte AS (
    SELECT
        games,
        COUNT(DISTINCT noc) AS no_of_countries
    FROM OLYMPICS_HISTORY
    GROUP BY games
)

SELECT
    games,
    no_of_countries,
    CASE
        WHEN no_of_countries = (SELECT MIN(no_of_countries) FROM cte) THEN CONCAT(games, ' - ', no_of_countries) 
    END AS lowest_countries,
    CASE
        WHEN no_of_countries = (SELECT MAX(no_of_countries) FROM cte) THEN CONCAT(games, ' - ', no_of_countries) 
    END AS highest_countries
FROM cte
WHERE no_of_countries = (SELECT MIN(no_of_countries) FROM cte)
   OR no_of_countries = (SELECT MAX(no_of_countries) FROM cte);


--5. Which nation has participated in all of the olympic games?

Select region as country, count(distinct games) as no_of_games
From OLYMPICS_HISTORY oh
Join OLYMPICS_HISTORY_NOC_REGIONS ohr
  On oh.noc = ohr.noc
Group by region
Having count(distinct games) = (Select count(distinct games) as no_games
                                From OLYMPICS_HISTORY)

--6. Identify the sport which was played in all summer olympics.

Select sport, count(distinct games) as no_games
From OLYMPICS_HISTORY
Where season = 'Summer'
Group by sport
Having count(distinct games) = (Select count( distinct games)
                                From OLYMPICS_HISTORY
                                Where season = 'Summer')


--7. Which Sports were just played only once in the olympics?

Select sport, count(distinct games) as cnt_games
From OLYMPICS_HISTORY
Group by sport
Having cnt_games = 1


--8. Fetch the total no of sports played in each olympic games.

Select games, count(distinct sport) as no_of_sport
From OLYMPICS_HISTORY
Group by games
order by no_of_sports desc

--9. Fetch details of the oldest athletes to win a gold medal.

Select *
From OLYMPICS_HISTORY
Where medal = 'Gold' and
      age = (Select max(age) from OLYMPICS_HISTORY)


--10. Find the Ratio of male and female athletes participated in all olympic games.





--11. Fetch the top 5 athletes who have won the most gold medals.

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



--12. Fetch the top 5 athletes who have won the most medals (gold/silver/bronze).

with cte as (
Select name, count(medal) as no_medals,
    dense_rank() over(order by no_medals desc) as rnk
From OLYMPICS_HISTORY
Where medal <> 'NA'
Group by name
)

Select name, no_medals
From cte
Where rnk < 6
order by no_medals desc

--13. Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won.

with cte as (
    Select region as country, count(medal) as no_of_medals,
            dense_rank() over(order by no_of_medals desc) as rnk
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



--14. List down total gold, silver and broze medals won by each country.

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
  On oh.noc = ohr.noc

--15. List down total gold, silver and broze medals won by each country corresponding to each olympic games.


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


--16. Identify which country won the most gold, most silver and most bronze medals in each olympic games.

        by country
games gold silver bronze


--17. Identify which country won the most gold, most silver, most bronze medals and the most medals in each olympic games.








-- 18. Which countries have never won gold medal but have won silver/bronze medals?

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


--19. In which Sport/event, India has won highest medals.

Select sport, count(medal) as no_of_medal
From OLYMPICS_HISTORY
Where team = 'India' and
      medal <> 'NA'
group by sport
Order by no_of_medal desc
Limit 1


--20. Break down all olympic games where india won medal for Hockey and how many medals in each olympic games.

Select team, sport, games, count(medal) as tot_medals
From 
OLYMPICS_HISTORY
Where team = 'India' and
      sport = 'Hockey' and
      medal <> 'NA'
Group by team, sport, games
Order by tot_medals desc












