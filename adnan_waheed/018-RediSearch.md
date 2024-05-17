# RediSearch

> RediSearch is a full-text search and indexing engine for Redis. It extends Redis with powerful indexing and querying capabilities, allowing you to perform advanced search operations on structured and unstructured data stored in Redis.

- Secondary Index
- Full-text engine (prefix, Fuzzy, Phonetic, Stemming, Synonyms and more)
- Incremental Indexing
- Multi-field queries
- Complex boolean queries like AND, OR, NOT can be applied
- Numeric filters and ranges
- Data Aggregation (SUM, AVERAGE, COUNT)
- Geo Indexing and filtering
- RediSearch provide SQL like capabilities on Redis datasets

## Running RediSearch with Docker

- Using Docker:
  - `docker run -p 6379:6379 redislabs/redisearch:latest`
  - Launching Redis Server with module RediSearch

```
127.0.0.1:6379> info modules
# Modules
module:name=ReJSON,ver=999999,api=1,filters=0,usedby=[search],using=[],options=[handle-io-errors]
module:name=search,ver=20613,api=1,filters=0,usedby=[],using=[ReJSON],options=[handle-io-errors]
```

## Using RediSearch on Movies Database

- Movies Database
  - movie_id
  - movie_name
  - plot
  - category
  - release_date
  - rating
  - poster
  - imdb_id
- Data Structure
  - movies
  - actors
  - theaters
  - users
- Key Names (For nomenclature)
  - Business_object:key
    - E.g., movie:1 means movie with id#1
    - E.g., user:1 means user with id#1
- Movies information can be stored in a **hash**
  - `HSET movie:1 movie_name "The Last Samurai" plot "This is s...." category "Action"`
  - Nice data structure where we can apply a field and a value.

## RediSearch `FT.CREATE`

- Creates an index with the given specification.

```
127.0.0.1:6379> keys *
1) "movie:4"
2) "movie:3"
3) "movie:2"
4) "movie:1"
127.0.0.1:6379> FT.CREATE idx:movie ON hash PREFIX 1 "movie" SCHEMA movie_name TEXT SORTABLE release_year NUMERIC SORTABLE rating NUMERIC SORTABLE category TAG SORTABLE
```

- `FT.CREATE idx:movie ON hash PREFIX 1 "movie" SCHEMA movie_name TEXT SORTABLE release_year NUMERIC SORTABLE rating NUMERIC SORTABLE category TAG SORTABLE`
  - `FT.CREATE`: This is the command to create a RediSearch index.
  - `idx:movie`: This is the name of the index. The idx: prefix is a convention to denote an index.
  - `ON hash`: This specifies the index type as a hash index.
  - `PREFIX 1 "movie"`: This specifies the prefix for the index. In this case, it's set to movie, which means the index will only include keys that start with movie. The number 1 indicates that only keys with this exact prefix will be included.
  - `SCHEMA`: This defines the schema for the index, which includes the fields and their data types.

```
## gives all the info of the index
127.0.0.1:6379> FT.INFO idx:movie
```

## RediSearch `FT.SEARCH`

- Searches the index with a textual query, returning either documents or just ids.

```
## getting all movies with the name "Matrix"
127.0.0.1:6379> FT.SEARCH idx:movie "Matrix"
1) (integer) 2    ## 2 records
2) "movie:1"
3)  1) "category"
    2) "Sci-Fi"
    3) "rating"
    4) "8.7"
    5) "imdb_id"
    6) "tt0133093"
    7) "movie_name"
    8) "The Matrix"
    9) "release_year"
   10) "1999"
   11) "plot"
   12) "Humans are unknowingly trapped within a simulated reality called the Matrix."
4) "movie:5"
5)  1) "category"
    2) "Sci-Fi"
    3) "rating"
    4) "7.5"
    5) "imdb_id"
    6) "tt0234215"
    7) "movie_name"
    8) "The Matrix Reloaded"
    9) "release_year"
   10) "2003"
   11) "plot"
   12) "Neo and the human city of Zion are threatened by the rogue program Smith."

## [with negation] getting all movies with the name "Matrix" but not "Reloaded"
127.0.0.1:6379> FT.SEARCH idx:movie "Matrix - Reloaded"   ## "-" for negation
1) (integer) 1
2) "movie:1"
3)  1) "category"
    2) "Sci-Fi"
    3) "rating"
    4) "8.7"
    5) "imdb_id"
    6) "tt0133093"
    7) "movie_name"
    8) "The Matrix"
    9) "release_year"
   10) "1999"
   11) "plot"
   12) "Humans are unknowingly trapped within a simulated reality called the Matrix."
```

- Returns particular fields only
  - `RETURN <number_of_fields> <field1> <field2>`
  - E.g., Get movie_name and release_year only

```
127.0.0.1:6379> FT.SEARCH idx:movie "Matrix" RETURN 2 movie_name release_year
1) (integer) 2
2) "movie:1"
3) 1) "movie_name"
   2) "The Matrix"
   3) "release_year"
   4) "1999"
4) "movie:5"
5) 1) "movie_name"
   2) "The Matrix Reloaded"
   3) "release_year"
   4) "2003"
```

- Search on particular fields only
  - `@field:<value>`
  - E.g., Get all movies that contain the string "Matrix" in the movie_name

```
127.0.0.1:6379> FT.SEARCH idx:movie "@movie_name:Matrix" RETURN 2 movie_name release_year
1) (integer) 2
2) "movie:1"
3) 1) "movie_name"
   2) "The Matrix"
   3) "release_year"
   4) "1999"
4) "movie:5"
5) 1) "movie_name"
   2) "The Matrix Reloaded"
   3) "release_year"
   4) "2003"
```

## Fuzzy logic and Search by value (`%%`)

- Get all movies using fuzzy search 'Matrix'

```
127.0.0.1:6379> FT.SEARCH idx:movie "%Matrix%" RETURN 2 movie_name release_year
1) (integer) 2
2) "movie:1"
3) 1) "movie_name"
   2) "The Matrix"
   3) "release_year"
   4) "1999"
4) "movie:5"
5) 1) "movie_name"
   2) "The Matrix Reloaded"
   3) "release_year"
   4) "2003"
```

- Search based on a value of the field
  - `@fieldname:{value}`

```
## Fuzzy search on fields with "-" (dash)
FT.SEARCH idx:movie "@category:{Sci\\-Fi}"

## Fuzzy search on fields with no special characters
127.0.0.1:6379> FT.SEARCH idx:movie "@category:{Drama}" RETURN 2 movie_name category
1) (integer) 1
2) "movie:2"
3) 1) "movie_name"
   2) "The Shawshank Redemption"
   3) "category"
   4) "Drama"
```

- Getting multiple values from a single field
  - `@fieldname:{value1|value2}`
  - E.g., Get all Action and Drama movies

```
127.0.0.1:6379> FT.SEARCH idx:movie "@category:{Drama|Action}" RETURN 2 movie_name category

1) (integer) 2
2) "movie:3"
3) 1) "movie_name"
   2) "The Dark Knight"
   3) "category"
   4) "Action"
4) "movie:2"
5) 1) "movie_name"
   2) "The Shawshank Redemption"
   3) "category"
   4) "Drama"
```

- Applying multiple filters
  - `@fieldname1:{value} @fieldname2:{value}`
  - E.g., Get all Drama and Sci-Fi movies that does not have 'Matrix' in the movie_name

```
127.0.0.1:6379> FT.SEARCH idx:movie "@category:{Drama|Sci\\-Fi} @movie_name:-Matrix" RETURN 2 movie_name category
1) (integer) 2
2) "movie:2"
3) 1) "movie_name"
   2) "The Shawshank Redemption"
   3) "category"
   4) "Drama"
4) "movie:4"
5) 1) "movie_name"
   2) "Inception"
   3) "category"
   4) "Sci-Fi"
```

## Value range searches

- Search based on a value range of the field (2 Methods)
  - 1st Method: `@fieldnme:[value1 value2]`
  - 2nd Method: `FILTER fieldname value1 value2` (using filter parameter)
  - E.g., Get all movies release_year between 2000 and 2010

```
127.0.0.1:6379> FT.SEARCH idx:movie "@release_year:[2000 2010]" RETURN 2 movie_name release_year
1) (integer) 3
2) "movie:3"
3) 1) "movie_name"
   2) "The Dark Knight"
   3) "release_year"
   4) "2008"
4) "movie:4"
5) 1) "movie_name"
   2) "Inception"
   3) "release_year"
   4) "2010"
6) "movie:5"
7) 1) "movie_name"
   2) "The Matrix Reloaded"
   3) "release_year"
   4) "2003"
```

```
127.0.0.1:6379> FT.SEARCH idx:movie * FILTER release_year 2000 2010 RETURN 2 movie_name release_year
1) (integer) 3
2) "movie:3"
3) 1) "movie_name"
   2) "The Dark Knight"
   3) "release_year"
   4) "2008"
4) "movie:4"
5) 1) "movie_name"
   2) "Inception"
   3) "release_year"
   4) "2010"
6) "movie:5"
7) 1) "movie_name"
   2) "The Matrix Reloaded"
   3) "release_year"
   4) "2003"
```

- Excluding a value, use a single left bracket
  - E.g., exclude movies from 2008 onwards, like `(2008`

```
127.0.0.1:6379> FT.SEARCH idx:movie "@release_year:[2000 (2008]" RETURN 2 movie_name release_year
1) (integer) 1
2) "movie:5"
3) 1) "movie_name"
   2) "The Matrix Reloaded"
   3) "release_year"
   4) "2003"
```

## Counting total records/documents

- `LIMIT from to`
  - E.g., Counting the number of movies

```
127.0.0.1:6379> FT.SEARCH idx:movie "*" LIMIT 0 0
1) (integer) 5  ## total 5 movies
```

## Insert, Update, Delete and Expire Documents

- Effect on index on CRUD operation (Add/Edit/Delete)
  - Add a new movie
  - Update a movie info like movie_title
  - Expire a movie info like movie_title

## Manage Index

- Listing Indexes: `FT._LIST`
- Get information on a particular index: `FT.INFO "indexName"`
- Updating an Index: `FT.ALTER "indexName"`
- Deleting an Index: `FT.DROPINDEX "indexName"`

```
127.0.0.1:6379> FT._LIST
1) "idx:movie"

127.0.0.1:6379> FT.INFO "idx:movie"

## The WEIGHT parameter in this command specifies the importance of the plot field in search queries, with 0.5 indicating moderate influence on search results. A higher weight value would make the plot field more important, while a lower value would make it less important, in determining the relevance of search results.

127.0.0.1:6379> FT.ALTER idx:movie SCHEMA ADD plot TEXT WEIGHT 0.5
OK

127.0.0.1:6379> ft.search idx:movie "Joker" return 2 movie_name release_year
1) (integer) 1
2) "movie:3"
3) 1) "movie_name"
   2) "The Dark Knight"
   3) "release_year"
   4) "2008"
```

## Import sample movie data sets

```
(base) ➜  redisearch git:(main) ✗ pwd
/Users/leonlow/Desktop/udemy/redis-bootcamp/adnan_waheed/redisearch

redis-cli -h localhost -p 6379 < ./import_actors.redis\n
redis-cli -h localhost -p 6379 < ./import_movies.redis\n
redis-cli -h localhost -p 6379 < ./import_theaters.redis\n
redis-cli -h localhost -p 6379 < ./import_users.redis\n
```

## Creating Indexes on Movies database

- Create a idx:movie index
- Create a idx:actor index
- Create a idx:theater index
- Create a idx:user index
- Pick the correct indexes because creating multiple indexes will take up disk space and memory space.

```
127.0.0.1:6379> FT.CREATE idx:movie ON hash PREFIX 1 "movie:" SCHEMA movie_name TEXT SORTABLE release_year NUMERIC SORTABLE category TAG SORTABLE rating NUMERIC SORTABLE plot TEXT

127.0.0.1:6379> FT.CREATE idx:actor ON hash PREFIX 1 "actor:" SCHEMA first_name TEXT SORTABLE last_name TEXT SORTABLE date_of_birth NUMERIC SORTABLE

127.0.0.1:6379> FT.CREATE idx:theater ON hash PREFIX 1 "theater:" SCHEMA name TEXT SORTABLE location GEO

127.0.0.1:6379> FT.CREATE idx:user ON hash PREFIX 1 "user:" SCHEMA gender TAG country TAG SORTABLE last_login NUMERIC SORTABLE location GEO

127.0.0.1:6379> FT._LIST
1) "idx:actor"
2) "idx:movie"
3) "idx:user"
4) "idx:theater"
```

