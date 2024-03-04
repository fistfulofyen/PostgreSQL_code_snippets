SELECT 
  f.film_id, 
  f.title, 
  i.inventory_id 
FROM 
  inventory i
RIGHT JOIN film f USING(film_id)
WHERE i.inventory_id IS NULL
ORDER BY 
  f.title;
