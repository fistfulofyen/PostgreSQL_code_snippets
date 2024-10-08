
# Relational Database Design Lecture Summary

## Introduction
- Database design is an art form focused on creating clean and easily understood databases.
- Goal: Avoid mistakes and design scalable databases for efficient performance tuning later.

## Building a Data Model
- Start by drawing a picture of data objects and determining relationships.
- Basic Rule: Avoid duplicating string data; use relationships instead.

```sql
-- Example: Creating a music database
CREATE TABLE artist (
  id SERIAL,
  name VARCHAR(128) UNIQUE,
  PRIMARY KEY(id)
);

CREATE TABLE album (
  id SERIAL,
  title VARCHAR(128) UNIQUE,
  artist_id INTEGER REFERENCES artist(id) ON DELETE CASCADE,
  PRIMARY KEY(id)
);

-- Additional tables for genre, track, etc.
```

## Key Terminology
- Primary key: Integer autoincrement field.
- Logical key: External lookup key.
- Foreign key: Integer key pointing to another table's primary key.

```sql
-- Example: Creating tables with primary and foreign keys
CREATE TABLE user (
  user_id SERIAL PRIMARY KEY,
  email VARCHAR(128),
  -- Additional columns
);

CREATE TABLE track (
  track_id SERIAL PRIMARY KEY,
  title VARCHAR(128),
  user_id INTEGER REFERENCES user(user_id) ON DELETE CASCADE,
  -- Additional columns
);
```

## Normalization
- Avoid data replication; reference data.
- Use integers for keys and references.
- Add a special "key" column to each table for references.

```sql
-- Example: Database normalization
CREATE TABLE album (
  album_id SERIAL PRIMARY KEY,
  title VARCHAR(128),
  -- Additional columns
);

CREATE TABLE track (
  track_id SERIAL PRIMARY KEY,
  title VARCHAR(128),
  album_id INTEGER REFERENCES album(album_id) ON DELETE CASCADE,
  -- Additional columns
);
```

## Building a Physical Data Schema
- Demonstration of creating a music database with tables for artists, albums, genres, and tracks.

```sql
CREATE TABLE artist (
  id SERIAL,
  name VARCHAR(128) UNIQUE,
  PRIMARY KEY(id)
);

CREATE TABLE album (
  id SERIAL,
  title VARCHAR(128) UNIQUE,
  artist_id INTEGER REFERENCES artist(id) ON DELETE CASCADE,
  PRIMARY KEY(id)
);

CREATE TABLE genre (
  id SERIAL,
  name VARCHAR(128) UNIQUE,
  PRIMARY KEY(id)
);

CREATE TABLE track (
    id SERIAL,
    title VARCHAR(128),
    len INTEGER, rating INTEGER, count INTEGER,
    album_id INTEGER REFERENCES album(id) ON DELETE CASCADE,
    genre_id INTEGER REFERENCES genre(id) ON DELETE CASCADE,
    UNIQUE(title, album_id),
    PRIMARY KEY(id)
);
```
## Insert data

```sql
INSERT INTO artist (name) VALUES ('Led Zeppelin');
INSERT INTO artist (name) VALUES ('AC/DC');

INSERT INTO album (title, artist_id) VALUES ('Who Made Who', 2);
INSERT INTO album (title, artist_id) VALUES ('IV', 1);

INSERT INTO genre (name) VALUES ('Rock');
INSERT INTO genre (name) VALUES ('Metal');

INSERT INTO track (title, rating, len, count, album_id, genre_id) 
    VALUES ('Black Dog', 5, 297, 0, 2, 1) ;
INSERT INTO track (title, rating, len, count, album_id, genre_id) 
    VALUES ('Stairway', 5, 482, 0, 2, 1) ;
INSERT INTO track (title, rating, len, count, album_id, genre_id) 
    VALUES ('About to Rock', 5, 313, 0, 1, 2) ;
INSERT INTO track (title, rating, len, count, album_id, genre_id) 
    VALUES ('Who Made Who', 5, 207, 0, 1, 2) ;
```

## Using JOIN Across Tables
- The JOIN operation links tables in a SELECT operation.
- Demonstration of JOIN operations with examples.

```sql
-- Example: Using JOIN operations
SELECT album.title, artist.name FROM album JOIN artist 
    ON album.artist_id = artist.id;

SELECT album.title, album.artist_id, artist.id, artist.name 
    FROM album INNER JOIN artist ON album.artist_id = artist.id;

SELECT track.title, track.genre_id, genre.id, genre.name 
    FROM track CROSS JOIN genre;

SELECT track.title, genre.name FROM track JOIN genre 
    ON track.genre_id = genre.id;

-- Join all table
SELECT track.title, artist.name, album.title, genre.name 
FROM track 
    JOIN genre ON track.genre_id = genre.id 
    JOIN album ON track.album_id = album.id 
    JOIN artist ON album.artist_id = artist.id;

DELETE FROM genre WHERE name='Metal';
```

## ON DELETE CASCADE
- Use CASCADE to clean up broken references automatically.

```sql
-- Example: Using ON DELETE CASCADE
CREATE TABLE track (
  track_id SERIAL PRIMARY KEY,
  title VARCHAR(128),
  album_id INTEGER REFERENCES album(album_id) ON DELETE CASCADE,
  -- Additional columns
);
```

## Many-to-Many Relationships
- Introduction to modeling many-to-many relationships with a connection table.
- Example of student-course memberships with tables for students, courses, and a membership connection table.

```sql
CREATE TABLE student (
  id SERIAL,
  name VARCHAR(128),
  email VARCHAR(128) UNIQUE,
  PRIMARY KEY(id)
) ;

CREATE TABLE course (
  id SERIAL,
  title VARCHAR(128) UNIQUE,
  PRIMARY KEY(id)
) ;

-- We could put 'id SERIAL' in this table, but it is not essential
CREATE TABLE member (
    student_id INTEGER REFERENCES student(id) ON DELETE CASCADE,
    course_id INTEGER REFERENCES course(id) ON DELETE CASCADE,
	role        INTEGER,
    PRIMARY KEY (student_id, course_id)
) ;

INSERT INTO student (name, email) VALUES ('Jane', 'jane@tsugi.org');
INSERT INTO student (name, email) VALUES ('Ed', 'ed@tsugi.org');
INSERT INTO student (name, email) VALUES ('Sue', 'sue@tsugi.org');

INSERT INTO course (title) VALUES ('Python');
INSERT INTO course (title) VALUES ('SQL');
INSERT INTO course (title) VALUES ('PHP');

INSERT INTO member (student_id, course_id, role) VALUES (1, 1, 1);
INSERT INTO member (student_id, course_id, role) VALUES (2, 1, 0);
INSERT INTO member (student_id, course_id, role) VALUES (3, 1, 0);

INSERT INTO member (student_id, course_id, role) VALUES (1, 2, 0);
INSERT INTO member (student_id, course_id, role) VALUES (2, 2, 1);

INSERT INTO member (student_id, course_id, role) VALUES (2, 3, 1);
INSERT INTO member (student_id, course_id, role) VALUES (3, 3, 0);

SELECT student.name, member.role, course.title
  FROM student 
  JOIN member ON member.student_id = student.id 
  JOIN course ON member.course_id = course.id
  ORDER BY course.title, member.role DESC, student.name;

```

## Complexity Enables Speed
- Complexity in database design allows for speed and scalability.
- Normalization and linking with integer keys reduce data scanning.

## Summary
- Relational databases scale well with one copy of each data element and efficient use of relations and joins.
- Database and SQL design is an art form.

## Acknowledgements
- Slides Copyright 2010- Charles R. Severance, available under a Creative Commons Attribution 4.0 License.

```
