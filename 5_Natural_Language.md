## Natural language

Rows can vary quite a bit in terms of length.

```sql
CREATE TABLE messages
 (id SERIAL,              -- 4 bytes
  email TEXT,             -- 10-20 bytes
  sent_at TIMESTAMPTZ,    -- 8 bytes
  subject TEXT,           -- 10-100 bytes
  headers TEXT,           -- 500-1000 bytes
  body TEXT               -- 50-2000 bytes
                          -- 600-2500 bytes
);
```

Since modifying data is so important to databases, we don't pack store one row after another in a file. We arrange the file into blocks (default 8K) and pack the rows into blocks leaving some free space to make inserts updates, or deletes possible without needing to rewrite a large file to move things up or down.

The beginning of the block is a set of  short pointers that indicate the starting poing (offset) of each of the rows in the block. Rows are inserted from the end of the block and the middle space between the rows and offsets is free space. The link simply opens a larger version of the image in a new window. 

PostgreSQL Organizes Rows into Blocks

- We read an entire block into memory (i.e. not just one row)
- Easy to compute the start of a block within a file for random access
- There are the unit of caching in memory They are (often) the unit of locking when we think we are locking a row

What is the Best Block Size?

- Blocks that are small waste free space / fragmentation
- Large blocks take more memory in cache be cached for a given memory size Large blocks longer to read and write to/from SSD

![Disk block](https://www.pg4e.com/lectures/05-FullText-images/postgres-disk-blocks.png)

If we have a table that contains 1GB (125,000 blocks) of data, a sequential scan from a fast SSD takes about 2 seconds while with careful optimization, reading a random block can be fast as 1/50000th of a second. Some SSD drives can read as many as 32 different random blocks in a single read request. If the block is already cached in memory it is even faster. Sequential scans are very bad.

## Index


### PostgreSQL Index Types

Assume each row in the users table is about 1K, we could save a lot of time if somehow we had a hint about which row was in which block.

| email               | block |
|---------------------|-------|
| anthony@umich.edu    | 20175 |
| csev@umich.edu       | 14242 |
| colleen@umich.edu    | 21456 |

```sql
SELECT name FROM users WHERE email='csev@umich.edu';
SELECT name FROM users WHERE email='colleen@umich.edu';
SELECT name FROM users WHERE email='anthony@umich.edu';
```

Our index would be about 30 bytes per row, which is much smaller than the actual row data. We store index data in 8K blocks as well - as indexes grow in size, we need to find ways to avoid reading the entire index to look up one key. We need an index to the index.

For string logical keys, a B-Tree index is a good, general solution. B-Trees keep the keys in sorted order by reorganizing the tree as keys are inserted.

## Index Types

- **B-Tree** - The default for many applications - automatically balanced as it grows
- **BRIN** - Block Range Index - Smaller and faster if data is mostly sorted
- **Hash** - Quick lookup of long key strings
- **GIN** - Generalized Inverted Indexes - Multiple values in a column
- **GiST** - Generalized Search Tree
- **SP-GiST** - Space Partitioned Generalized Search Tree

## Inverted Indexes
Here's how the content can be formatted in a Markdown file:


# PostgreSQL String Manipulation and Inverted Index

We can split long text columns into space-delimited words using PostgreSQL's `string_to_array()` function. Then, we can use the PostgreSQL `unnest()` function to turn the resulting array into separate rows.

```sql
pg4e=> string_to_array('Hello world', ' ');
 string_to_array
-----------------
 {Hello,world}
```

```sql
pg4e=> unnest(string_to_array('Hello world', ' '));
 unnest
--------
 Hello
 world
```

After that, it is just a few `SELECT DISTINCT` statements, and we can create and use an inverted index.

## Creating an Inverted Index Example

```sql
CREATE TABLE docs (id SERIAL, doc TEXT, PRIMARY KEY(id));

INSERT INTO docs (doc) VALUES
('This is SQL and Python and other fun teaching stuff'),
('More people should learn SQL from UMSI'),
('UMSI also teaches Python and also SQL');
```

### Creating a GIN Table

```sql
CREATE TABLE docs_gin (
  keyword TEXT,
  doc_id INTEGER REFERENCES docs(id) ON DELETE CASCADE
);
```

### Sample Data in `docs_gin`

```sql
pg4e=> select * from docs_gin;
 keyword  | doc_id
----------+--------
 Python   |      1
 SQL      |      1
 This     |      1
 stuff    |      1
 teaching |      1
 More     |      2
 SQL      |      2
 UMSI     |      2
 from     |      2
 learn    |      2
 people   |      2
 should   |      2
 Python   |      3
 SQL      |      3
 UMSI     |      3
 also     |      3
 and      |      3
 teaches  |      3
(22 rows)
```

This process allows us to efficiently search for documents containing specific keywords by utilizing an inverted index.
