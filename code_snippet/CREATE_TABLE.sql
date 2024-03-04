CREATE TABLE IF NOT EXISTS accounts (
  user_id SERIAL PRIMARY KEY, 
  username VARCHAR (50) UNIQUE NOT NULL, 
  password VARCHAR (50) NOT NULL, 
  email VARCHAR (255) UNIQUE NOT NULL, 
  created_at TIMESTAMP NOT NULL, 
  last_login TIMESTAMP
);

-- Constraints
-- PostgreSQL includes the following column constraints:

-- NOT NULL – ensures that the values in a column cannot be NULL.
-- UNIQUE – ensures the values in a column are unique across the rows within the same table.
-- PRIMARY KEY – a primary key column uniquely identifies rows in a table. A table can have one and only one primary key. The primary key constraint allows you to define the primary key of a table.
-- CHECK – ensures the data must satisfy a boolean expression. For example, the value in the price column must be zero or positive.
-- FOREIGN KEY – ensures that the values in a column or a group of columns from a table exist in a column or group of columns in another table. Unlike the primary key, a table can have many foreign keys.
-- Table constraints are similar to column constraints except that you can include more than one column in the table constraint.
