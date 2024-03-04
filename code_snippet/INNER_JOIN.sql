/*
SELECT
	customer.customer_id,
	customer.first_name,
	customer.last_name,
	payment.amount,
	DATE(payment.payment_date)
FROM
	customer INNER JOIN payment
-- ON
-- 	payment.customer_id = customer.customer_id
	USING(customer_id)
ORDER BY
	payment.payment_date;
*/

SELECT 
  c.customer_id, 
  c.first_name || ' ' || c.last_name customer_name, 
  s.first_name || ' ' || s.last_name staff_name, 
  p.amount, 
  p.payment_date 
FROM 
  customer c 
  INNER JOIN payment p USING (customer_id) 
  INNER JOIN staff s using(staff_id) 
ORDER BY 
  payment_date;
