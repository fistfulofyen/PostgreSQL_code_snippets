-- The WHERE clause filters the rows based on a specified condition whereas 
-- the HAVING clause filter groups of rows according to a specified condition.
SELECT 
  customer_id, 
  SUM (amount) amount 
FROM 
  payment 
GROUP BY 
  customer_id 
HAVING 
  SUM (amount) > 100 
ORDER BY 
  amount DESC;
  
  
SELECT 
  store_id, 
  COUNT (customer_id) 
FROM 
  customer 
GROUP BY 
  store_id 
HAVING 
  COUNT (customer_id) > 300;
