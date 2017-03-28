# queries to analyze Dognition database to determine factors that may contribute to increased test completions

# Assessing whether Dognition personality dimensions are related to the number of tests completed
SELECT num_tests.dimension, COUNT(DISTINCT num_tests.dog_id) AS num_dogs, AVG(num_tests.count_tests) AS avg_completes
FROM (SELECT d.dog_guid AS dog_id, d.dimension AS dimension, COUNT(c.test_name) AS count_tests
    FROM dogs d JOIN complete_tests c
    ON d.dog_guid = c.dog_guid
    WHERE (d.dimension != '' AND d.dimension IS NOT NULL) AND (d.exclude IS NULL OR d.exclude = '0')
    GROUP BY d.dog_guid) AS num_tests
GROUP BY num_tests.dimension
ORDER BY num_dogs DESC;

# Assessing whether dog breeds are related to the number of tests completed
SELECT num_tests.breed_type, COUNT(DISTINCT num_tests.dog_id) AS total_tests
FROM (SELECT d.dog_guid AS dog_id, d.breed_type AS breed_type
    FROM dogs d JOIN complete_tests c
    ON d.dog_guid = c.dog_guid
    WHERE d.exclude IS NULL OR d.exclude = '0'
    GROUP BY d.dog_guid) AS num_tests
GROUP BY num_tests.breed_type
ORDER BY total_tests DESC;

# Assessing whether dog breeds and neutering are related to the number of tests completed
SELECT num_tests.pure_breed AS pure, num_tests.fixed AS fixed, AVG(num_tests.count_tests) AS avg_tests, COUNT(num_tests.test_name)
FROM (SELECT d.dog_guid AS dog_id, d.breed_type AS breed_type, d.dog_fixed AS fixed, c.test_name AS test_name, COUNT(c.test_name) AS count_tests,
      CASE
        WHEN d.breed_type = 'Pure Breed' THEN 'Pure_Breed'
        ELSE 'Not_Pure_Breed'
        END AS pure_breed
    FROM dogs d JOIN complete_tests c
    ON d.dog_guid = c.dog_guid
    WHERE d.exclude IS NULL OR d.exclude = '0'
    GROUP BY d.dog_guid) AS num_tests
GROUP BY pure, fixed
ORDER BY avg_tests DESC;

# Weekdays that Dognition users complete the most tests
SELECT COUNT(DATE_SUB(c.created_at, INTERVAL 6 HOUR)) AS test_count, 
    YEAR(DATE_SUB(c.created_at, INTERVAL 6 HOUR)) AS year,
    (CASE
        WHEN DAYOFWEEK(c.created_at) = 1 THEN 'Sun'
        WHEN DAYOFWEEK(c.created_at) = 2 THEN 'Mon'
        WHEN DAYOFWEEK(c.created_at) = 3 THEN 'Tue'
        WHEN DAYOFWEEK(c.created_at) = 4 THEN 'Wed'
        WHEN DAYOFWEEK(c.created_at) = 5 THEN 'Thu'
        WHEN DAYOFWEEK(c.created_at) = 6 THEN 'Fri'
        WHEN DAYOFWEEK(c.created_at) = 7 THEN 'Sat'
        ELSE 'N/A'
        END) AS day_name
FROM complete_tests c JOIN 
    (SELECT DISTINCT d.dog_guid AS dog_guid
        FROM dogs d JOIN users u
        ON d.user_guid = u.user_guid
        WHERE (d.exclude IS NULL OR d.exclude = '0') AND (u.exclude IS NULL OR u.exclude = '0') 
            AND (u.country = 'US' AND u.state NOT IN ('HI', 'AK'))) AS dogs_users
    ON c.dog_guid = dogs_users.dog_guid
GROUP BY year, day_name
ORDER BY year ASC, FIELD(day_name, 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun');

# States that have the most Dognition users
SELECT u.state, COUNT(DISTINCT u.user_guid) AS num_users
FROM dogs d JOIN users u
ON d.user_guid = u.user_guid
WHERE (d.exclude IS NULL OR d.exclude = '0') AND (u.exclude IS NULL OR u.exclude = '0') 
        AND (u.country = 'US')
GROUP BY u.state
ORDER BY num_users DESC
LIMIT 5;

# Countries that have the most Dognition users
SELECT u.country, COUNT(DISTINCT u.user_guid) AS num_users
FROM dogs d JOIN users u
ON d.user_guid = u.user_guid
WHERE (d.exclude IS NULL OR d.exclude = '0') AND (u.exclude IS NULL OR u.exclude = '0')
GROUP BY u.country
ORDER BY num_users DESC
LIMIT 10;