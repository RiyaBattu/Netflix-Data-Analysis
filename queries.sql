--1. number of movies and shows

Select 
	type,
	count (*) as total_content
from [Portfolio_2].[dbo].[netflix]
group by type

--2. Find most common rating for movies and TV shows
SELECT
    type,
    rating
FROM (
    SELECT
        type,
        rating,
        COUNT(*) AS count,
        RANK() OVER (PARTITION BY type ORDER BY COUNT(*) DESC) AS ranking
    FROM [Portfolio_2].[dbo].[netflix]
    GROUP BY type, rating
) AS t1
WHERE ranking = 1;



-- 3. List of movies in a year
Select
	release_year,
	count(release_year) as total_movies_in_year
from [Portfolio_2].[dbo].[netflix]
where type = 'movie'
group by release_year
order by release_year


Select *
from [Portfolio_2].[dbo].[netflix]
where
type = 'movie'
and 
release_year = 2020


--4. Top 5 countreis with the most content on netflix
select 
	top 5
	country,
	count(show_id) as total_content
from [Portfolio_2].[dbo].[netflix]
group by country
order by total_content desc


SELECT
	top 5
    value AS new_country,
    COUNT(show_id) AS total_content
FROM 
    [Portfolio_2].[dbo].[netflix]
CROSS APPLY
    STRING_SPLIT(country, ',')
GROUP BY
    value
ORDER BY
    total_content DESC;



--5. Identify the longest movie
Select *
from [Portfolio_2].[dbo].[netflix]
where 
type= 'movie'
and 
duration = (select max(duration) from [Portfolio_2].[dbo].[netflix])



--6. Find content added in last 5 years
SELECT *
FROM [Portfolio_2].[dbo].[netflix]
WHERE 
    type = 'Movie' -- Filter for movies
    AND TRY_CAST(date_added AS DATE) >= DATEADD(YEAR, -5, GETDATE());




--7. Moive directed by director Rajiv Chilaka'

Select *
from [Portfolio_2].[dbo].[netflix]
where director like '%Rajiv Chilaka%'

-- wihtout using like operator it gives 19 movies
--with liek it is 22

SELECT TOP 1
    director,
    COUNT(show_id) AS most_movies
FROM [Portfolio_2].[dbo].[netflix]
WHERE director IS NOT NULL 
GROUP BY director
ORDER BY most_movies DESC;


SELECT 
    director,
    COUNT(show_id) AS least_movies
FROM [Portfolio_2].[dbo].[netflix]
WHERE director IS NOT NULL 
GROUP BY director
ORDER BY least_movies ASC;


--8. List all the TV shwos with more than 5 seasons


select * from [Portfolio_2].[dbo].[netflix]
SELECT 
    *,
    LEFT(duration, CHARINDEX(' ', duration) - 1) AS sessions
FROM 
    [Portfolio_2].[dbo].[netflix]
WHERE 
    type = 'TV Show'
    AND TRY_CAST(LEFT(duration, CHARINDEX(' ', duration) - 1) AS INT) > 5;

-- >= 164 and with >5 it is 99


--9. Content item in each genre

SELECT 
    value AS genre,
    COUNT(show_id) AS genre_count
FROM 
    [Portfolio_2].[dbo].[netflix]
CROSS APPLY 
    STRING_SPLIT(listed_in, ',')
GROUP BY 
    value
ORDER BY 
    genre_count DESC;




--10. Each yar and average numer of content release
--return top 5 years with highest avg contennt reales
SELECT 
    YEAR(TRY_CAST(date_added AS DATE)) AS year,
    COUNT(*) AS content_count
FROM 
    [Portfolio_2].[dbo].[netflix]
WHERE 
    country = 'India'
GROUP BY 
    YEAR(TRY_CAST(date_added AS DATE))
ORDER BY 
    year;


WITH yearly_content AS (
    SELECT 
        YEAR(TRY_CAST(date_added AS DATE)) AS year,
        COUNT(*) AS content_count
    FROM 
        [Portfolio_2].[dbo].[netflix]
    WHERE 
        country = 'India'
    GROUP BY 
        YEAR(TRY_CAST(date_added AS DATE))
)
SELECT 
    year,
    content_count,
    AVG(content_count * 1.0) OVER (ORDER BY year ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_avg_content_per_year
FROM 
    yearly_content
ORDER BY 
    year;


--11. List all the movies that are documentaries
SELECT 
   *
FROM 
    [Portfolio_2].[dbo].[netflix]
WHERE 
    listed_in LIKE '%documentaries%';



--12. Find all content without director
Select * 
from  [Portfolio_2].[dbo].[netflix]
where director is null

-- 13. In how many movies salman khan appeared in last 10 years
SELECT 
    *
FROM  
    [Portfolio_2].[dbo].[netflix]
WHERE 
    cast LIKE '%Salman Khan%'
    AND release_year > YEAR(GETDATE()) - 10;




--14. Celebrity with most movies
-- Step 1: Split the cast column into individual names
WITH split_cast AS (
    SELECT 
        TRIM(value) AS celebrity,
        show_id
    FROM 
        [Portfolio_2].[dbo].[netflix]
    CROSS APPLY 
        STRING_SPLIT(cast, ',')
    WHERE 
        type = 'Movie'
)

-- Step 2: Count the number of movies for each celebrity
, celebrity_counts AS (
    SELECT 
        celebrity,
        COUNT(DISTINCT show_id) AS movie_count
    FROM 
        split_cast
    GROUP BY 
        celebrity
)

-- Step 3: Get the celebrity with the most movies
SELECT TOP 10
    celebrity,
    movie_count
FROM 
    celebrity_counts
ORDER BY 
    movie_count DESC;


--15. Categroize movies as bad if description contain kill or violence word else good
-- count each of the good and bad 

WITH categorized_content AS (
    SELECT
        CASE
            WHEN LOWER(description) LIKE '%kill%' OR LOWER(description) LIKE '%violence%'
            THEN 'Aggression_inducing'
            ELSE 'Good content'
        END AS category
    FROM [Portfolio_2].[dbo].[netflix]
)
SELECT
    category,
    COUNT(*) AS count
FROM categorized_content
GROUP BY category
ORDER BY category;