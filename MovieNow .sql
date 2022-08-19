Use MovieNow ;

-- Conduct an analysis to see when the first customer accounts were created for each country.

SELECT 
    country, MIN(date_account_start) AS first_account
FROM
    customers
GROUP BY country
ORDER BY first_account;

-- For each movie the average rating, the number of ratings and the number of views has to be reported. 

SELECT 
    movie_id,
    AVG(rating) AS avg_rating,
    COUNT(rating) AS number_ratings,
    COUNT(*) AS number_renting
FROM
    renting
GROUP BY movie_id
ORDER BY avg_rating DESC; -- Order by average rating in decreasing order


SELECT 
    customer_id, 
    AVG(rating) AS avg_rating, 
    COUNT(rating) AS number_ratings, 
    COUNT(movie_id) AS number_views
FROM
    renting
GROUP BY customer_id
HAVING COUNT(renting_id) > 7
ORDER BY AVG(rating); -- Order by the average rating in ascending order

-- Identify favorite movies for a speicfic group of customers born in 90s.

SELECT 
    m.title, COUNT(*), AVG(r.rating)
FROM
    renting AS r
        LEFT JOIN
    customers AS c ON c.customer_id = r.customer_id
        LEFT JOIN
    movies AS m ON m.movie_id = r.movie_id
WHERE
    c.date_of_birth BETWEEN '1990-01-01' AND '1999-12-31'
GROUP BY m.title
HAVING COUNT(*) > 1
ORDER BY AVG(r.rating) DESC; -- Order with highest rating first

-- Report a list of movies with average rating above average. The advertising team only wants a list of movie titles

SELECT 
    title
FROM
    movies
WHERE
    movie_id IN (SELECT 
            movie_id
        FROM
            renting
        GROUP BY movie_id
        HAVING AVG(rating) > (SELECT 
                AVG(rating)
            FROM
                renting));
                
-- Report a list of movies that received the most attention on the movie platform

SELECT 
    *
FROM
    movies AS m
WHERE
    8 < (SELECT 
            AVG(rating)
        FROM
            renting AS r
        WHERE
            r.movie_id = m.movie_id);
            
-- Are there particular genres which are more popular in specific countries?

SELECT 
	c.country, 
	m.genre, 
	AVG(r.rating) AS avg_rating, 
	COUNT(*) AS num_rating
FROM renting AS r
LEFT JOIN movies AS m
ON m.movie_id = r.movie_id
LEFT JOIN customers AS c
ON r.customer_id = c.customer_id
GROUP BY c.country, m.genre WITH ROLLUP
ORDER BY c.country, m.genre;

 -- The management considers investing money in movies of the best rated genres.
 
SELECT 
    genre,
    AVG(rating) AS avg_rating,
    COUNT(rating) AS n_rating,
    COUNT(*) AS n_rentals,
    COUNT(DISTINCT m.movie_id) AS n_movies
FROM
    renting AS r
        LEFT JOIN
    movies AS m ON m.movie_id = r.movie_id
WHERE
    r.movie_id IN (SELECT 
            movie_id
        FROM
            renting
        GROUP BY movie_id
        HAVING COUNT(rating) >= 3)
        AND r.date_renting >= '2018-01-01'
GROUP BY genre
ORDER BY avg_rating DESC; 

 
-- Calculate the revenue coming from movie rentals, the number of movie rentals and the number of customers who rented a movie.

SELECT 
    SUM(m.renting_price),
    COUNT(*), -- the number of movie rentals
    COUNT(DISTINCT r.customer_id)
FROM
    renting AS r
        LEFT JOIN
    movies AS m ON r.movie_id = m.movie_id;
  
-- Report the same values for the year 2019(last year for renting)

SELECT 
    SUM(m.renting_price),
    COUNT(*),
    COUNT(DISTINCT r.customer_id)
FROM
    renting AS r
        LEFT JOIN
    movies AS m ON r.movie_id = m.movie_id
WHERE
    date_renting BETWEEN '2019-01-01' AND '2019-12-31';
    
-- Report the same values except customer numbers for each country 

   SELECT 
    c.country,
    COUNT(*) AS number_renting,
    AVG(r.rating) AS average_rating,
    SUM(m.renting_price) AS revenue
FROM
    renting AS r
        LEFT JOIN
    customers AS c ON c.customer_id = r.customer_id
        LEFT JOIN
    movies AS m ON m.movie_id = r.movie_id
GROUP BY country;
    
-- Report the income from movie rentals for each movie 

SELECT 
    rm.title, SUM(rm.renting_price) AS income_movie
FROM
    (SELECT 
        m.title, m.renting_price
    FROM
        renting AS r
    LEFT JOIN movies AS m ON r.movie_id = m.movie_id) AS rm
GROUP BY rm.title
ORDER BY income_movie DESC; -- Order the result by decreasing income

-- Create a list of movie titles and actor names

SELECT 
    m.title, a.name
FROM
    actsin AS ai
        LEFT JOIN
    movies AS m ON m.movie_id = ai.movie_id
        LEFT JOIN
    actors AS a ON a.actor_id = ai.actor_id;

--  Explore the age of American actors and actresses

SELECT a.gender, 
      Min(a.year_of_birth), -- The year of birth of the oldest actor
      Max(a.year_of_birth) -- The year of birth of the youngest actor
FROM
   (Select * 
   From actors
   Where nationality = 'USA')
  As a 
GROUP BY a.gender;

--  Analyze customer preferences for certain actors.

SELECT 
    a.nationality,
    a.gender,
    AVG(r.rating) AS avg_rating,
    COUNT(r.rating) AS n_rating,
    COUNT(*) AS n_rentals,
    COUNT(DISTINCT a.actor_id) AS n_actors
FROM
    renting AS r
        LEFT JOIN
    actsin AS ai ON ai.movie_id = r.movie_id
        LEFT JOIN
    actors AS a ON ai.actor_id = a.actor_id
WHERE
    r.movie_id IN (SELECT 
            movie_id
        FROM
            renting
        GROUP BY movie_id
        HAVING COUNT(rating) >= 4)
        AND r.date_renting >= '2018-04-01'
GROUP BY a.nationality , a.gender WITH ROLLUP;


