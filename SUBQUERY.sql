SELECT 
  country_id 
from 
  country 
where 
  country = 'United States';

SELECT 
  city 
FROM 
  city 
WHERE 
  country_id = 103 
ORDER BY 
  city;

SELECT 
  city 
FROM 
  city 
WHERE 
  country_id = (
    SELECT 
      country_id 
    FROM 
      country 
    WHERE 
      country = 'United States'
  ) 
ORDER BY 
  city;
