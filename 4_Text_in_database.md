## Text in Postgress

## Generating Test Data
- We use repeat() to generate long strings
(horizontal)
- We use generate_series() to generate
-- lots of rows (vertical)
- Like Python's range
- We use random() to make rows unique
- Floating point 0 <= random() <= 1.0

```sql
-- Generate Data

SELECT random(), random(), trunc(random()*100);
SELECT repeat('Neon ', 5);
SELECT generate_series(1,5);
SELECT 'Neon' || generate_series(1,5);

-- [ 'Neon' + str(x) for x in range(1,6) ]

```

### TEXT
https://www.postgresql.org/docs/11/functions-string.html

```sql
CREATE TABLE textfun (
  content TEXT
);

INSERT INTO textfun (content) SELECT 'Neon' || generate_series(1,5);

SELECT * FROM textfun;

DELETE FROM textfun;

-- BTree Index is Default
CREATE INDEX textfun_b ON textfun (content);

SELECT pg_relation_size('textfun'), pg_indexes_size('textfun');

SELECT (CASE WHEN (random() < 0.5)
         THEN 'https://www.pg4e.com/neon/'
         ELSE 'https://www.pg4e.com/LEMONS/'
         END) || generate_series(1000,1005);

INSERT INTO textfun (content)
SELECT (CASE WHEN (random() < 0.5)
         THEN 'https://www.pg4e.com/neon/'
         ELSE 'https://www.pg4e.com/LEMONS/'
         END) || generate_series(100000,200000);

SELECT pg_relation_size('textfun'), pg_indexes_size('textfun');

SELECT content FROM textfun WHERE content LIKE '%150000%';
--  https://www.pg4e.com/neon/150000
SELECT upper(content) FROM textfun WHERE content LIKE '%150000%';
--  HTTPS://WWW.PG4E.COM/NEON/150000
SELECT lower(content) FROM textfun WHERE content LIKE '%150000%';
--  https://www.pg4e.com/neon/150000
SELECT right(content, 4) FROM textfun WHERE content LIKE '%150000%';
-- 0000
SELECT left(content, 4) FROM textfun WHERE content LIKE '%150000%';
-- http
SELECT strpos(content, 'ttps://') FROM textfun WHERE content LIKE '%150000%';
-- 2
SELECT substr(content, 2, 4) FROM textfun WHERE content LIKE '%150000%';
-- ttps
SELECT split_part(content, '/', 4) FROM textfun WHERE content LIKE '%150000%';
-- neon
SELECT translate(content, 'th.p/', 'TH!P_') FROM textfun WHERE content LIKE '%150000%';
--  HTTPs:__www!Pg4e!com_neon_150000

-- LIKE-style wild cards
SELECT content FROM textfun WHERE content LIKE '%150000%';
SELECT content FROM textfun WHERE content LIKE '%150_00%';

SELECT content FROM textfun WHERE content IN ('https://www.pg4e.com/neon/150000', 'https://www.pg4e.com/neon/150001');

-- Don't want to fill up the server
DROP TABLE textfun;

```

## Regular Expressions

```sql
--- Regex

CREATE TABLE em (id serial, primary key(id), email text);

INSERT INTO em (email) VALUES ('csev@umich.edu');
INSERT INTO em (email) VALUES ('coleen@umich.edu');
INSERT INTO em (email) VALUES ('sally@uiuc.edu');
INSERT INTO em (email) VALUES ('ted79@umuc.edu');
INSERT INTO em (email) VALUES ('glenn1@apple.com');
INSERT INTO em (email) VALUES ('nbody@apple.com');

SELECT email FROM em WHERE email ~ 'umich';
SELECT email FROM em WHERE email ~ '^c';
SELECT email FROM em WHERE email ~ 'edu$';
SELECT email FROM em WHERE email ~ '^[gnt]';
SELECT email FROM em WHERE email ~ '[0-9]';
SELECT email FROM em WHERE email ~ '[0-9][0-9]';

SELECT substring(email FROM '[0-9]+') FROM em WHERE email ~ '[0-9]';

SELECT substring(email FROM '.+@(.*)$') FROM em;

SELECT DISTINCT substring(email FROM '.+@(.*)$') FROM em;

SELECT substring(email FROM '.+@(.*)$'), 
    count(substring(email FROM '.+@(.*)$')) 
FROM em GROUP BY substring(email FROM '.+@(.*)$');

SELECT * FROM em WHERE substring(email FROM '.+@(.*)$') = 'umich.edu';

CREATE TABLE tw (id serial, primary key(id), tweet text);

INSERT INTO tw (tweet) VALUES ('This is #SQL and #FUN stuff');
INSERT INTO tw (tweet) VALUES ('More people should learn #SQL FROM #UMSI');
INSERT INTO tw (tweet) VALUES ('#UMSI also teaches #PYTHON');

SELECT tweet FROM tw;

SELECT id, tweet FROM tw WHERE tweet ~ '#SQL';

SELECT regexp_matches(tweet,'#([A-Za-z0-9_]+)', 'g') FROM tw;

SELECT DISTINCT regexp_matches(tweet,'#([A-Za-z0-9_]+)', 'g') FROM tw;

SELECT id, regexp_matches(tweet,'#([A-Za-z0-9_]+)', 'g') FROM tw;

-- wget https://www.pg4e.com/lectures/mbox-short.txt

CREATE TABLE mbox (line TEXT);

-- E'\007' is the BEL character and not in the data so each row is one column
\copy mbox FROM 'mbox-short.txt' with delimiter E'\007';

\copy mbox FROM PROGRAM 'wget -q -O - "$@" https://www.pg4e.com/lectures/mbox-short.txt' with delimiter E'\007';

SELECT line FROM mbox WHERE line ~ '^From ';
SELECT substring(line, ' (.+@[^ ]+) ') FROM mbox WHERE line ~ '^From ';

SELECT substring(line, ' (.+@[^ ]+) '), count(substring(line, ' (.+@[^ ]+) ')) FROM mbox WHERE line ~ '^From ' GROUP BY substring(line, ' (.+@[^ ]+) ') ORDER BY count(substring(line, ' (.+@[^ ]+) ')) DESC;

SELECT email, count(email) FROM
( SELECT substring(line, ' (.+@[^ ]+) ') AS email FROM mbox WHERE line ~ '^From '
) AS badsub
GROUP BY email ORDER BY count(email) DESC;


--- Advanced Indexes
--- Note these might overrun a class-provided server with a small disk quota

SELECT 'https://www.pg4e.com/neon/' || trunc(random()*1000000) || repeat('Lemon', 5) || generate_series(1,5);

CREATE TABLE cr1 (
  id SERIAL,
  url VARCHAR(128) UNIQUE,
  content TEXT
);

INSERT INTO cr1(url)
SELECT repeat('Neon', 1000) || generate_series(1,5000);

CREATE TABLE cr2 (
  id SERIAL,
  url TEXT,
  content TEXT
);

INSERT INTO cr2 (url)
SELECT repeat('Neon', 1000) || generate_series(1,5000);

SELECT pg_relation_size('cr2'), pg_indexes_size('cr2');

CREATE unique index cr2_unique on cr2 (url);

SELECT pg_relation_size('cr2'), pg_indexes_size('cr2');

DROP index cr2_unique;

SELECT pg_relation_size('cr2'), pg_indexes_size('cr2');

CREATE unique index cr2_md5 on cr2 (md5(url));

SELECT pg_relation_size('cr2'), pg_indexes_size('cr2');

explain SELECT * FROM cr2 WHERE url='lemons';

explain SELECT * FROM cr2 WHERE md5(url)=md5('lemons');

DROP index cr2_md5;

CREATE unique index cr2_sha256 on cr2 (sha256(url::bytea));

explain SELECT * FROM cr2 WHERE sha256(url::bytea)=sha256('bob'::bytea);

CREATE TABLE cr3 (
  id SERIAL,
  url TEXT,
  url_md5 uuid unique,
  content TEXT
);

INSERT INTO cr3 (url)
SELECT repeat('Neon', 1000) || generate_series(1,5000);

SELECT pg_relation_size('cr3'), pg_indexes_size('cr3');

update cr3 set url_md5 = md5(url)::uuid;

SELECT pg_relation_size('cr3'), pg_indexes_size('cr3');

EXPLAIN ANALYZE SELECT * FROM cr3 WHERE url_md5=md5('lemons')::uuid;

CREATE TABLE cr4 (
  id SERIAL,
  url TEXT,
  content TEXT
);

INSERT INTO cr4 (url)
SELECT repeat('Neon', 1000) || generate_series(1,5000);

CREATE index cr4_hash on cr4 using hash (url);

SELECT pg_relation_size('cr4'), pg_indexes_size('cr4');

EXPLAIN ANALYZE SELECT * FROM cr5 WHERE url='lemons';

-- Drop these tables to make sure not to overrun your server
DROP table cr1;
DROP table cr2;
DROP table cr3;
DROP table cr4;
DROP table cr5;

```

### 1. **Table Creation and Insertion (`em` Table)**:
- A table `em` (email) is created with two fields: `id` (serial, primary key) and `email` (text).
- Several email records are inserted into this table.

### 2. **Regex-based Queries (`em` Table)**:
- Queries use the `~` operator to apply regex pattern matching:
  - **`SELECT email FROM em WHERE email ~ 'umich';`**  
    Matches emails containing "umich."
  - **`SELECT email FROM em WHERE email ~ '^c';`**  
    Matches emails starting with "c."
  - **`SELECT email FROM em WHERE email ~ 'edu$';`**  
    Matches emails ending with "edu."
  - **`SELECT email FROM em WHERE email ~ '^[gnt]';`**  
    Matches emails starting with "g," "n," or "t."
  - **`SELECT email FROM em WHERE email ~ '[0-9]';`**  
    Matches emails containing a number.
  - **`SELECT email FROM em WHERE email ~ '[0-9][0-9]';`**  
    Matches emails containing two consecutive digits.

### 3. **Substring Extraction (`em` Table)**:
- **`SELECT substring(email FROM '[0-9]+') FROM em WHERE email ~ '[0-9]';`**  
  Extracts sequences of digits from emails.
- **`SELECT substring(email FROM '.+@(.*)$') FROM em;`**  
  Extracts the domain part of the email (everything after `@`).
- **`SELECT DISTINCT substring(email FROM '.+@(.*)$') FROM em;`**  
  Extracts unique domain parts of emails.
- **`SELECT substring(email FROM '.+@(.*)$'), count(substring(email FROM '.+@(.*)$')) FROM em GROUP BY substring(email FROM '.+@(.*)$');`**  
  Counts the occurrence of each domain.
- **`SELECT * FROM em WHERE substring(email FROM '.+@(.*)$') = 'umich.edu';`**  
  Finds all emails with the domain "umich.edu."

### 4. **Tweet Table and Hashtag Matching (`tw` Table)**:
- **Creating the `tw` Table**:  
  This table is for storing tweets (`tweet` is of type text).
- **Inserting Tweets**:  
  A few sample tweets with hashtags are inserted.
- **Hashtag Extraction and Matching**:
  - **`SELECT tweet FROM tw;`**  
    Retrieves all tweets.
  - **`SELECT id, tweet FROM tw WHERE tweet ~ '#SQL';`**  
    Finds tweets containing the hashtag `#SQL`.
  - **`SELECT regexp_matches(tweet,'#([A-Za-z0-9_]+)', 'g') FROM tw;`**  
    Extracts all hashtags from tweets.
  - **`SELECT DISTINCT regexp_matches(tweet,'#([A-Za-z0-9_]+)', 'g') FROM tw;`**  
    Finds distinct hashtags in tweets.
  - **`SELECT id, regexp_matches(tweet,'#([A-Za-z0-9_]+)', 'g') FROM tw;`**  
    Extracts hashtags along with the tweet ID.

### 5. **Handling Mbox Files (Mailbox Data) (`mbox` Table)**:
- **Creating the `mbox` Table**:  
  A table is created to hold lines of text from an mbox file (email data).
- **Loading Data**:
  - **`\copy mbox FROM 'mbox-short.txt' with delimiter E'\007';`**  
    Loads data from the mbox-short.txt file, with `E'\007'` as the delimiter.
  - **`SELECT line FROM mbox WHERE line ~ '^From ';`**  
    Selects lines starting with "From " (likely email sender information).
  - **`SELECT substring(line, ' (.+@[^ ]+) ') FROM mbox WHERE line ~ '^From ';`**  
    Extracts email addresses from these lines.
  - **Email Address Counting**:
    - **`SELECT substring(line, ' (.+@[^ ]+) '), count(substring(line, ' (.+@[^ ]+) ')) FROM mbox WHERE line ~ '^From ' GROUP BY substring(line, ' (.+@[^ ]+) ');`**  
      Counts occurrences of each email.
    - **`SELECT email, count(email) FROM (SELECT substring(line, ' (.+@[^ ]+) ') AS email FROM mbox WHERE line ~ '^From ') AS badsub GROUP BY email ORDER BY count(email) DESC;`**  
      Another method to count email occurrences.

### 6. **Advanced Indexes (Performance Optimization)**:
- **URL-based Table (`cr1`, `cr2`, `cr3`, `cr4`)**:
  - **Table `cr1`**: Created with a `url` field that is unique and has a content field.
  - **Table `cr2`**: Created similarly but without uniqueness on the `url` field initially.
  - **Indexing on `cr2`**:
    - **Creating and Dropping Indexes**: Demonstrates various indexing techniques such as creating a unique index on `url`, using MD5 hashes, SHA-256 hashes, and analyzing the effects on storage size.
    - **Performance Comparison**: Explains how queries perform differently based on whether the index is on `url` or `md5(url)`.

### 7. **Additional Indexing (`cr3`, `cr4`)**:
- **MD5 Hash Indexing (`cr3`)**:
  - Demonstrates creating a table with an additional `url_md5` field, then updates this field with MD5 hash values, and compares query performance.
- **Hash Indexing (`cr4`)**:
  - Uses hash indexing on the `url` field and compares storage size and performance of queries using hash indexes.

### 8. **Cleanup**:
- **`DROP` Tables**:  
  Drops the tables (`cr1`, `cr2`, `cr3`, `cr4`, `cr5`) to prevent running out of disk space.
