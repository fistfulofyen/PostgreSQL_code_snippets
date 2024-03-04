-- SELECT 
--   film.film_id, 
--   film.title, 
--   inventory.inventory_id 
-- FROM 
--   film 
--   LEFT JOIN inventory ON inventory.film_id = film.film_id 
-- ORDER BY 
--   film.title;

SELECT 
  f.film_id, 
  f.title, 
  i.inventory_id 
FROM 
  film f 
  LEFT JOIN inventory i USING (film_id) 
WHERE 
  i.film_id IS NULL 
ORDER BY 
  f.title;
