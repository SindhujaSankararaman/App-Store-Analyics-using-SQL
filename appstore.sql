-- Create combined table
CREATE TABLE applestore_description_combined AS
    SELECT * FROM appleStore_description1
    UNION ALL
    SELECT * FROM appleStore_description2
    UNION ALL
    SELECT * FROM appleStore_description3
    UNION ALL
    SELECT * FROM appleStore_description4;

-- Check the number of unique apps in both the tables
SELECT COUNT(DISTINCT ID) AS UniqueAppIDs
FROM AppleStore;

SELECT COUNT(DISTINCT ID) AS UniqueAppIDs
FROM applestore_description_combined;

-- Check for missing values in key fields of the table
SELECT COUNT(*) AS MissingValues
FROM AppleStore
WHERE ID IS NULL OR user_rating IS NULL OR track_name IS NULL OR prime_genre IS NULL;

SELECT COUNT(*) AS MissingValues
FROM applestore_description_combined
WHERE ID IS NULL OR track_name IS NULL OR app_desc IS NULL;

-- No data quality issues in both the tables

-- Find out the number of apps per genre
SELECT prime_genre, COUNT(*) AS No_of_apps
FROM AppleStore
GROUP BY prime_genre
ORDER BY No_of_apps DESC;

-- Games and Entertainment genres are clearly leading with a huge number of apps

-- Get an overview of the apps ratings
SELECT MIN(user_rating) AS MinRating,
       MAX(user_rating) AS MaxRating,
       AVG(user_rating) AS AvgRating
FROM AppleStore;

-- Determine whether paid apps have a higher rating than free apps
SELECT 
    CASE 
        WHEN price > 0 THEN 'Paid'
        ELSE 'Free'
    END AS app_type,
    AVG(user_rating) AS Avg_rating
FROM AppleStore
GROUP BY app_type;

-- Rating of paid apps is slightly higher compared to free apps

-- Check if apps with more supported languages have higher ratings
SELECT 
    CASE 
        WHEN lang_num < 10 THEN '<10 languages'
        WHEN lang_num BETWEEN 10 AND 30 THEN '10-30 languages'
        ELSE '>30 languages'
    END AS language_bucket,
    AVG(user_rating) AS Avg_rating
FROM AppleStore
GROUP BY language_bucket
ORDER BY Avg_rating DESC;

-- Check genres with low ratings
SELECT 
    prime_genre,
    AVG(user_rating) AS Avg_rating
FROM AppleStore
GROUP BY prime_genre
ORDER BY Avg_rating ASC
LIMIT 10;

-- Good opportunity to create apps in these categories

-- Check if there is a correlation between the length of app description and user ratings
SELECT 
    CASE
        WHEN LENGTH(B.app_desc) < 300 THEN 'Short'
        WHEN LENGTH(B.app_desc) BETWEEN 500 AND 1000 THEN 'Medium'
        ELSE 'Long'
    END AS description_length_bucket,
    AVG(user_rating) AS Avg_rating
FROM 
    AppleStore AS A
JOIN 
    applestore_description_combined AS B
ON 
    A.id = B.id
GROUP BY description_length_bucket
ORDER BY Avg_rating DESC;

-- Check the top-rated apps for each genre
SELECT 
    prime_genre,
    track_name,
    user_rating
FROM (
    SELECT 
        prime_genre,
        track_name,
        user_rating,
        RANK() OVER(PARTITION BY prime_genre ORDER BY user_rating DESC, rating_count_tot DESC) AS RANK
    FROM
        AppleStore
) AS A
WHERE
    A.RANK = 1;
-- Apps with the highest number of ratings
