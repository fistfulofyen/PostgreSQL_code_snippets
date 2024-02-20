
# Lecture Notes: SQL Tools

## Table Creation

```sql
-- Create the account table
CREATE TABLE account (
    id SERIAL,
    email VARCHAR(128) UNIQUE,
    created_at DATE NOT NULL DEFAULT NOW(),
    updated_at DATE NOT NULL DEFAULT NOW(),
    PRIMARY KEY(id)
);

-- Create the post table
CREATE TABLE post (
    id SERIAL,
    title VARCHAR(128) UNIQUE NOT NULL,
    content VARCHAR(1024), -- Will extend with ALTER
    account_id INTEGER REFERENCES account(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY(id)
);

-- Create the comment table
CREATE TABLE comment (
    id SERIAL,
    content TEXT NOT NULL,
    account_id INTEGER REFERENCES account(id) ON DELETE CASCADE,
    post_id INTEGER REFERENCES post(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY(id)
);

-- Create the fav table
CREATE TABLE fav (
    id SERIAL,
    oops TEXT, -- Will remove later with ALTER
    post_id INTEGER REFERENCES post(id) ON DELETE CASCADE,
    account_id INTEGER REFERENCES account(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(post_id, account_id),
    PRIMARY KEY(id)
);
```

## Column Operations

### Drop Column

```sql
-- Drop the 'oops' column from the fav table
ALTER TABLE fav DROP COLUMN oops;
```

### Alter Column Type

```sql
-- Change the data type of the 'content' column in the post table to TEXT
ALTER TABLE post ALTER COLUMN content TYPE TEXT;
```

### Add Column

```sql
-- Add a new column 'howmuch' to the fav table
ALTER TABLE fav ADD COLUMN howmuch INTEGER;
```

These SQL statements demonstrate the creation of tables for accounts, posts, comments, and favorites. Additionally, it includes operations such as dropping a column, altering the data type of a column, and adding a new column.

## Date

We can save some code by auto-populating date fields when a row is INSERTed.

```sql
CREATE TABLE fav (
  id SERIAL,
  post_id INTEGER REFERENCES post(id) ON DELETE CASCADE,
  account_id INTEGER REFERENCES account(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(post_id, account_id),
  PRIMARY KEY(id)
);
```

TIMESTAMPTZ – Best Practice
- Store time stamps with timezone
- Prefer UTC for stored time stamps
- Convert to local time zone when retrieving

```sql
SELECT NOW(), NOW() AT TIME ZONE 'UTC', NOW() AT TIME ZONE 'HST';
```

## Casting

```sql
SELECT NOW()::DATE, CAST(NOW() AS DATE), CAST(NOW() AS TIME);

SELECT NOW()::DATE, CAST(NOW() AS DATE), CAST(NOW() AS TIME);
```

Sometimes we want to discard some of the accuracy that is in a TIMESTAMP

## Performance: Table Scans

### Not all equivalent queries have the same perforemance

```sql
-- fast
SELECT id, content, created_at FROM comment
WHERE created_at >= DATE_TRUNC('day',NOW())
AND created_at < DATE_TRUNC('day',NOW() + INTERVAL '1 day');

-- slow
SELECT id, content, created_at FROM comment
WHERE created_at::DATE = NOW()::DATE;
```

## Sub-query

Can use a value or set of values in a query that are computed by another query

```sql
SELECT * FROM account
WHERE email='ed@umich.edu';

SELECT content FROM comment
WHERE account_id = 7;

-- using sub-query
SELECT content FROM comment
WHERE account_id = (SELECT id FROM account WHERE email='ed@umich.edu');
```

## Concurrency

To implement atomicity, PostgreSQL "locks" areas before it starts an SQL command
that might change an area of the database

All other access to that area must wait until the area is unlocked

```sql
UPDATE tracks
SET count=count+1
WHERE id = 42

-- atomicity
LOCK ROW 42 OF tracks
READ count FROM tracks ROW 42
count = count + 1
WRITE count TO tracks ROW 42
UNLOCK ROW 42 OF tracks
```

All the inserts will work and get a unique primary key

Which account gets which key is not predictable

### Compounding statements

There are statements which do more than one thing in one statement for efficiency and concurrency.

```sql
INSERT INTO fav (post_id, account_id, howmuch)
VALUES (1,1,1)
RETURNING *;
UPDATE fav SET howmuch=howmuch+1
WHERE post_id = 1 AND account_id = 1
RETURNING *;
```

### On conflect

```sql
-- This will fail
INSERT INTO fav (post_id, account_id, howmuch)
VALUES (1,1,1)
RETURNING *;
INSERT INTO fav (post_id, account_id, howmuch)
VALUES (1,1,1)
ON CONFLICT (post_id, account_id)
DO UPDATE SET howmuch = fav.howmuch + 1
RETURNING *;
```

## Stored Procedures

A stored procedure is a bit of reusable code that runs inside of the database server
Technically there are multiple language choices but just use "plpgsql"
Generally quite non-portable
Usually the goal is to have fewer SQL statements

You should have a strong reason to use a stored procedure
• Major performance problem
• Harder to test / modify
• No database portability
• Some rule that *must* be enforced

```sql
-- Recal
CREATE TABLE fav (
id SERIAL,
post_id INTEGER REFERENCES post(id) ON DELETE CASCADE,
account_id INTEGER REFERENCES account(id) ON DELETE CASCADE,
created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
UNIQUE(post_id, account_id),
PRIMARY KEY(id)
);

UPDATE fav SET howmuch=howmuch+1
WHERE post_id = 1 AND account_id = 1;

-- everytime you update fav you have to update TIME
UPDATE fav SET howmuch=howmuch+1, updated_at=NOW()
WHERE post_id = 1 AND account_id = 1;

-- Using a trigger for updated_at
CREATE OR REPLACE FUNCTION trigger_set_timestamp()
RETURNS TRIGGER AS $$
BEGIN
NEW.updated_at = NOW();
RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_timestamp
BEFORE UPDATE ON fav
FOR EACH ROW
EXECUTE PROCEDURE trigger_set_timestamp();

UPDATE fav SET howmuch=howmuch+1
WHERE post_id = 1 AND account_id = 1;

```

## Load CSV

