/*
SELECT 
  first_name, 
  last_name 
FROM 
  customer 
WHERE
--   first_name = 'Jamie'
--   OR last_name = 'Rice'
--  first_name IN ('Ann', 'Anne', 'Annie')
  first_name LIKE 'Ann%' -- first names start with the word Ann, % : wild card
  AND LENGTH(first_name) BETWEEN 3 AND 5
  AND last_name != 'Powell'
*/

-- PostgreSQL uses true, 't', 'true', 'y', 'yes', '1' to represent true and false, 'f', 'false', 'n', 'no', and '0' to represent false.

-- AND	 | True	 False	Null
-- ----------------------------
-- True	 | True	 False	Null
-- False | False False	False
-- Null	 | Null	 False	Null

-- To retrieve 4 films starting from the fourth one
SELECT 
  film_id, 
  title, 
  release_year 
FROM 
  film 
ORDER BY 
  film_id 
LIMIT 4 OFFSET 3;
