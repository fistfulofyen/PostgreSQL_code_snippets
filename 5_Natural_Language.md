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
