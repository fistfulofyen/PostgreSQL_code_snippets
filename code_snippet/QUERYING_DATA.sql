-- SELECT 
--    first_name || ' ' || last_name AS full_name, -- or "full name"
--    email
-- FROM 
--    customer;


SELECT 
  DISTINCT first_name, 
  last_name 
FROM 
  customer 
ORDER BY 
  first_name DESC,
  last_name ASC,
  LENGTH(last_name) DESC,
  first_name NULLS FIRST;
  
