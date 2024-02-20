
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
