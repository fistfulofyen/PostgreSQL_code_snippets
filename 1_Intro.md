Certainly! Here's a summary of the provided content in a Markdown (.md) format, including some code snippets:


# Relational Databases and PostgreSQL

## Introduction
Charles Severance explores the fundamentals of relational databases, focusing on PostgreSQL.

## Basics of Relational Databases
- Relational databases store data in tables with rows and columns.
- Structured Query Language (SQL) is used to interact with databases.

## Terminology
- Database: Contains one or more tables.
- Relation (Table): Contains tuples (rows) and attributes (columns).
- Tuple: Represents an object, and attributes are its elements.

## Common Database Systems
- PostgreSQL: 100% open source and feature-rich.
- Oracle: Large, commercial, enterprise-scale.
- MySQL: Fast and scalable, commercial open source.
- SqlServer: Microsoft's database management system.

## SQL Architecture
- Components include Database Server, User, DBA, pgAdmin, and psql.

## Getting Started with PostgreSQL
- Connect using the command line: `$ psql -U postgres`.
- Create a user, database, and connect to it.

## Creating a Table
```sql
CREATE TABLE users (
    name VARCHAR(128),
    email VARCHAR(128)
);
```

## SQL Operations
- Insert, delete, update, and select data.
- Examples of SQL commands:
  - `INSERT INTO users (name, email) VALUES ('Chuck', 'csev@umich.edu');`
  - `DELETE FROM users WHERE email='ted@umich.edu';`
  - `UPDATE users SET name='Charles' WHERE email='csev@umich.edu';`
  - `SELECT * FROM users ORDER BY email;`

## Data Types in PostgreSQL
- Text, binary, numeric, integer, floating-point, and date types.

## Database Keys and Indexes
- AUTO_INCREMENT for primary keys.
- PostgreSQL functions like NOW().
- Use of indexes, such as B-trees and hashes.

## Generate 1000 Rows with Mockaroo
https://www.mockaroo.com/
- Use command \i <file_name> to insert from external sql file

## Dealing with blank space
```sql
SELECT COALESCE(email, 'Email not provided') FROM person;
```

## Date
```sql
SELECT NOW()::DATE - INTERVAL '10 years' AS "10 years ago";
```

```sql
SELECT EXTRACT(YEAR FROM NOW())
```
