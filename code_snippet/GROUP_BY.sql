-- Group by name
SELECT 
  c.first_name || ' ' || c.last_name full_name, 
  SUM (p.amount) amount 
FROM 
  payment AS p
  INNER JOIN customer AS c USING (customer_id) 
GROUP BY 
  full_name 
ORDER BY 
  amount DESC;

-- Group by id
SELECT 
  customer_id, 
  staff_id, 
  SUM(amount) 
FROM 
  payment 
GROUP BY 
  staff_id, 
  customer_id 
ORDER BY 
  customer_id;

-- Group by date
SELECT 
  payment_date::date payment_date, 
  SUM(amount) sum 
FROM 
  payment 
GROUP BY 
  payment_date
ORDER BY 
  payment_date DESC;
