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

## Using `@fieldname` with and without contains

- Simple and complex conditions
- Sorting
- Pagination of data
- Counting Operation

```
## get all movies with word "heat" or related to "heat" (in plot)
127.0.0.1:6379> FT.SEARCH idx:movie "heat" RETURN 3 movie_name release_year plot
1) (integer) 4
2) "movie:818"
3) 1) "movie_name"
   2) "California Heat"
   3) "release_year"
   4) "1995"
   5) "plot"
   6) "A lifeguard bets he can be true to just one woman."
4) "movie:1141"
5) 1) "movie_name"
   2) "Heat"
   3) "release_year"
   4) "1995"
   5) "plot"
   6) "A group of professional bank robbers start to feel the heat from police when they unknowingly leave a clue at their latest heist."
6) "movie:736"
7) 1) "movie_name"
   2) "Chicago Justice"
   3) "release_year"
   4) "2017"
   5) "plot"
   6) "The State's Attorney's dedicated team of prosecutors and investigators navigates heated city politics and controversy head-on,while fearlessly pursuing justice."
8) "movie:1109"
9) 1) "movie_name"
   2) "Love & Hip Hop: Miami"
   3) "release_year"
   4) "2018"
   5) "plot"
   6) "'Love and Hip Hop Miami' turns up the heat and doesn't hold back in making the 305 the place to be. Multi-platinum selling hip-hop legend Trick Daddy is back in the studio collaborating ..."
```

```
## get all movies with title containing the word "heat" or related to "heat"
127.0.0.1:6379> FT.SEARCH idx:movie "@movie_name:heat" RETURN 2 movie_name release_year
1) (integer) 2
2) "movie:818"
3) 1) "movie_name"
   2) "California Heat"
   3) "release_year"
   4) "1995"
4) "movie:1141"
5) 1) "movie_name"
   2) "Heat"
   3) "release_year"
   4) "1995"
```

```
## get all movies with title containing the word "heat" and does NOT contain "california"
127.0.0.1:6379> FT.SEARCH idx:movie "@movie_name:(heat -california)" RETURN 3 movie_name release_year plot
1) (integer) 1
2) "movie:1141"
3) 1) "movie_name"
   2) "Heat"
   3) "release_year"
   4) "1995"
   5) "plot"
   6) "A group of professional bank robbers start to feel the heat from police when they unknowingly leave a clue at their latest heist."
```

## Search with `OR` criteria

- E.g., Find all the 'Drama' or 'Comedy' movies that have 'heat' in the movie_name.
  - `@fieldname:{Drama|Comedy}`

```
## get movie names containing the word 'heat'
127.0.0.1:6379> FT.SEARCH idx:movie "@movie_name:(heat)" RETURN 2 movie_name release_year
1) (integer) 2
2) "movie:818"
3) 1) "movie_name"
   2) "California Heat"
   3) "release_year"
   4) "1995"
4) "movie:1141"
5) 1) "movie_name"
   2) "Heat"
   3) "release_year"
   4) "1995"

## get all the 'Drama' or 'Comedy' movies that have 'heat' in the movie_name
127.0.0.1:6379> FT.SEARCH idx:movie "@movie_name:(heat) @category:{Drama|Comedy}" RETURN 2 movie_name release_year
1) (integer) 2
2) "movie:1141"
3) 1) "movie_name"
   2) "Heat"
   3) "release_year"
   4) "1995"
4) "movie:818"
5) 1) "movie_name"
   2) "California Heat"
   3) "release_year"
   4) "1995"

## get all the 'Drama' or 'Comedy' movies OR movie names with 'heat'
127.0.0.1:6379> FT.SEARCH idx:movie "@movie_name:(heat) | @category:{Drama|Comedy}" RETURN 2 movie_name release_year
```

## Search condition1 AND (condition2 OR condition3)

- E.g., Find all 'Mystery' OR 'Thriller' movies, released in 2014 OR 2018
  - `@field`
  - `[2014 2014] | [2018 2018]`

```
127.0.0.1:6379> FT.SEARCH idx:movie "@category:{Mystery|Thriller} (@release_year:[2014 2014] | @release_year:[2018 2018])" RETURN 3 movie_name release_year category
1) (integer) 3
2) "movie:65"
3) 1) "movie_name"
   2) "The Loft"
   3) "release_year"
   4) "2014"
   5) "category"
   6) "Mystery"
4) "movie:461"
5) 1) "movie_name"
   2) "The Boat ()"
   3) "release_year"
   4) "2018"
   5) "category"
   6) "Mystery"
6) "movie:989"
7) 1) "movie_name"
   2) "Los Angeles Overnight"
   3) "release_year"
   4) "2018"
   5) "category"
   6) "Thriller"
```

## Numeric Conditions

- E.g., We want WHERE num BETWEEN 1 AND 2 like in Postgres
  - `@num:[1 2]`: syntax for RediSearch with numeric conditions

```
127.0.0.1:6379> FT.SEARCH idx:movie "@release_year:[2000 2001]" RETURN 2 movie_name release_year
```

- E.g., WHERE num >= 10
  - `@num:[10 +inf]`

```
## get all movies with release year that are above year 2000
127.0.0.1:6379> FT.SEARCH idx:movie "@release_year:[2000 +inf]" RETURN 2 movie_name release_year
```

- E.g., WHERE num > 10
  - `@num:[(10 +inf]`

```
## get all movies above year 2014 and NOT including year 2014
127.0.0.1:6379> FT.SEARCH idx:movie "@release_year:[(2014 +inf]" RETURN 2 movie_name release_year
```

- E.g., WHERE num < 10
  - `@num:[-inf (10]`

```
## get all movies with release year that are below year 2014 and not including 2014
127.0.0.1:6379> FT.SEARCH idx:movie "@release_year:[-inf (2014]" RETURN 2 movie_name release_year
```

- E.g., WHERE num <= 10
  - `@num:[-inf 10]`

```
## get all movies with release year that are below year 2014 (inclusive)
127.0.0.1:6379> FT.SEARCH idx:movie "@release_year:[-inf 2014]" RETURN 2 movie_name release_year
```

## Sort data with `SORTBY`

- E.g., Get all the "Action" movies, sorted by release_year from most recent to the oldest.

```
## sort in ascending order
FT.SEARCH idx:movie "@category:{Action}" SORTBY release_year RETURN 2 movie_name release_year

## sort in descending order (Add "DESC")
FT.SEARCH idx:movie "@category:{Action}" SORTBY release_year DESC RETURN 2 movie_name release_year
```

```
## sort in alphabetical order did not work because "plot" field does not have SORTABLE
FT.SEARCH idx:movie "@category:{Action}" SORTBY plot RETURN 3 movie_name release_year plot
```

- Checking what elements are SORTABLE

```
## we can clearly see that "plot" element is not SORTABLE but "release_year" is SORTABLE
FT.INFO idx:movie
    2) 1) identifier
       2) release_year
       3) attribute
       4) release_year
       5) type
       6) NUMERIC
       7) SORTABLE
    5) 1) identifier
       2) plot
       3) attribute
       4) plot
       5) type
       6) TEXT
       7) WEIGHT
       8) "1"
```

## Limiting results using `LIMIT`

- Pagination Queries
  - `LIMIT <from> <numOfRecords>` **from** is the offset
- E.g., Get all the 'Action' movies, sorted by release_year from the oldest to the most recent, returning the record by batch of 100 movies.
  Then, find the next batch of 100 movies.

```
## displaying the first 10 records (by default)
127.0.0.1:6379> FT.SEARCH idx:actor "*"

## displaying the first 5 records
127.0.0.1:6379> FT.SEARCH idx:actor "*" LIMIT 0 5

## displaying the first record
127.0.0.1:6379> FT.SEARCH idx:actor "*" LIMIT 0 1

## skipping one record
127.0.0.1:6379> FT.SEARCH idx:actor "*" LIMIT 1 1

## provides the total number of records for idx:movie
FT.SEARCH idx:movie "*" LIMIT 0 0
```

```
## displaying the first 100 records
127.0.0.1:6379> FT.SEARCH idx:movie "@category:{Action}" LIMIT 0 100 SORTBY release_year DESC
127.0.0.1:6379> FT.SEARCH idx:movie "@category:{Action}" SORTBY release_year DESC LIMIT 0 100

## next batch of 100 records
127.0.0.1:6379> FT.SEARCH idx:movie "@category:{Action}" LIMIT 100 100 SORTBY release_year DESC

## this time it returned an integer because there are only 186 records in total
127.0.0.1:6379> FT.SEARCH idx:movie "@category:{Action}" LIMIT 200 100 SORTBY release_year DESC
1) (integer) 186
```

## Aggregation with `FT.AGGREGATE`

- Aggregation queries
  - Grouping, Reducing, Sorting, Transforming
- **Flow**: Filter --> Group [Reduce] --> Apply --> Sort --> Apply

```
## get all movies
FT.SEARCH idx:movie "*" LIMIT 0 0

## group all movies by each year (60 release years)
127.0.0.1:6379> FT.AGGREGATE idx:movie "*" GROUPBY 1 @release_year
 1) (integer) 60
 2) 1) "release_year"
    2) "1964"
 3) 1) "release_year"
    2) "1977"
 4) 1) "release_year"
    2) "1991"
 5) 1) "release_year"
    2) "2004"
 6) 1) "release_year"
    2) "2017"
    ...

## group all movies by category (25 categories)
127.0.0.1:6379> FT.AGGREGATE idx:movie "*" GROUPBY 1 @category
 1) (integer) 25
 2) 1) "category"
    2) "thriller"
 3) 1) "category"
    2) "action"
 4) 1) "category"
    2) "reality-tv"
    ...

## group all movies by each year and category (based on the query below, release_year gets grouped first then category)
FT.AGGREGATE idx:movie "*" GROUPBY 2 @release_year @category

## get total number of movies
FT.SEARCH idx:movie "*" LIMIT 0 0

## get total number of movies by each release_year
127.0.0.1:6379> FT.AGGREGATE idx:movie "*" GROUPBY 1 @release_year REDUCE COUNT 0
 1) (integer) 60
 2) 1) "release_year"
    2) "1964"
    3) "__generated_aliascount"
    4) "9"
 3) 1) "release_year"
    2) "1977"
    3) "__generated_aliascount"
    4) "11"
 4) 1) "release_year"
    2) "1991"
    3) "__generated_aliascount"
    4) "12"

## set alias for __generated_aliascount
127.0.0.1:6379> FT.AGGREGATE idx:movie "*" GROUPBY 1 @release_year REDUCE COUNT 0 as total_num_of_movies
 1) (integer) 60
 2) 1) "release_year"
    2) "1964"
    3) "total_num_of_movies"
    4) "9"
 3) 1) "release_year"
    2) "1977"
    3) "total_num_of_movies"
    4) "11"
 4) 1) "release_year"
    2) "1991"
    3) "total_num_of_movies"
    4) "12"

## group all movies by each release_year where movie contains "heat"
127.0.0.1:6379> FT.AGGREGATE idx:movie "heat" GROUPBY 1 @release_year REDUCE COUNT 0 as total_num_of_movies
1) (integer) 3
2) 1) "release_year"
   2) "2018"
   3) "total_num_of_movies"
   4) "1"
3) 1) "release_year"
   2) "2017"
   3) "total_num_of_movies"
   4) "1"
4) 1) "release_year"
   2) "1995"
   3) "total_num_of_movies"
   4) "2"

## (ASCENDING) get total number of movies by each release year from most recent to oldest
127.0.0.1:6379> FT.AGGREGATE idx:movie "*" GROUPBY 1 @release_year REDUCE COUNT 0 as total_num_of_movies SORTBY 1 @release_year
 1) (integer) 60
 2) 1) "release_year"
    2) "1960"
    3) "total_num_of_movies"
    4) "5"
 3) 1) "release_year"
    2) "1961"
    3) "total_num_of_movies"
    4) "7"
 4) 1) "release_year"
    2) "1962"
    3) "total_num_of_movies"
    4) "6"
 5) 1) "release_year"
    2) "1963"
    3) "total_num_of_movies"
    4) "7"

## (DESCENDING) get total number of movies by each release year from most recent to oldest
127.0.0.1:6379> FT.AGGREGATE idx:movie "*" GROUPBY 1 @release_year REDUCE COUNT 0 as total_num_of_movies SORTBY 2 @release_year DESC
 1) (integer) 60
 2) 1) "release_year"
    2) "2019"
    3) "total_num_of_movies"
    4) "14"
 3) 1) "release_year"
    2) "2018"
    3) "total_num_of_movies"
    4) "15"
 4) 1) "release_year"
    2) "2017"
    3) "total_num_of_movies"
    4) "15"
```

## Grouping, reducing and sorting data

```
127.0.0.1:6379> FT.AGGREGATE idx:movie "*" GROUPBY 1 @category REDUCE COUNT 0 as total_num_of_movies SORTBY 2 @category DESC
 1) (integer) 25
 2) 1) "category"
    2) "western"
    3) "total_num_of_movies"
    4) "7"
 3) 1) "category"
    2) "thriller"
    3) "total_num_of_movies"
    4) "5"
 4) 1) "category"
    2) "talk-show"
    3) "total_num_of_movies"
    4) "1"
 5) 1) "category"
    2) "sport"
    3) "total_num_of_movies"
    4) "3"
```

## Grouping with multiple reduce functions `SUM`, `AVG`

```
## get total number of movies by each category, with total number of votes and average rating

## getting this error because votes was not indexed, can check via `FT.INFO idx:movie` and see that attributes has no `votes`
127.0.0.1:6379> FT.AGGREGATE idx:movie "*" GROUPBY 1 @category REDUCE COUNT 0 as count_of_movies REDUCE SUM 1 votes
(error) Property `votes` not present in document or pipeline

127.0.0.1:6379> FT.ALTER idx:movie SCHEMA ADD votes numeric sortable
OK

127.0.0.1:6379> FT.AGGREGATE idx:movie "*" GROUPBY 1 @category REDUCE COUNT 0 as count_of_movies REDUCE SUM 1 votes as total_votes reduce avg 1 rating as average_rating
 1) (integer) 25
 2) 1) "category"
    2) "thriller"
    3) "count_of_movies"
    4) "5"
    5) "total_votes"
    6) "29457"
    7) "average_rating"
    8) "6"
 3) 1) "category"
    2) "action"
    3) "count_of_movies"
    4) "186"
    5) "total_votes"
    6) "34844552"
    7) "average_rating"
    8) "6.51290322581"
 4) 1) "category"
    2) "reality-tv"
    3) "count_of_movies"
    4) "15"
    5) "total_votes"
    6) "7739"
    7) "average_rating"
    8) "5.3"

## sort by average rating, use `average_rating` instead of `rating`
127.0.0.1:6379> FT.AGGREGATE idx:movie "*" GROUPBY 1 @category REDUCE COUNT 0 as count_of_movies REDUCE SUM 1 votes as total_votes reduce avg 1 rating as average_rating sortby 1 @average_rating
 1) (integer) 25
 2) 1) "category"
    2) "game-show"
    3) "count_of_movies"
    4) "2"
    5) "total_votes"
    6) "163"
    7) "average_rating"
    8) "4.3"
 3) 1) "category"
    2) "reality-tv"
    3) "count_of_movies"
    4) "15"
    5) "total_votes"
    6) "7739"
    7) "average_rating"
    8) "5.3"
 4) 1) "category"
    2) "western"
    3) "count_of_movies"
    4) "7"
    5) "total_votes"
    6) "4532"
    7) "average_rating"
    8) "5.38571428571"

## sort by average rating in descending order
127.0.0.1:6379> FT.AGGREGATE idx:movie "*" GROUPBY 1 @category REDUCE COUNT 0 as count_of_movies REDUCE SUM 1 votes as total_votes reduce avg 1 rating as average_rating sortby 2 @average_rating desc

## sort by average rating in descending order, followed by sorting by total_votes in descending order
127.0.0.1:6379> FT.AGGREGATE idx:movie "*" GROUPBY 1 @category REDUCE COUNT 0 as count_of_movies REDUCE SUM 1 votes as total_votes reduce avg 1 rating as average_rating sortby 4 @average_rating desc @total_votes desc
```

```
## get total number of female users by each country, sorted by descending order
ft.aggregate idx:user "@gender:{female}" groupby 1 @country reduce count 0 as num_of_users sortby 2 @num_of_users desc
```

## Transforming aggregated data using `APPLY` function

- `APPLY {expr} AS {name}`
- Apply 1 to 1 transformation on one or more properties/fields in an index
- `expr` can be used to
  - perform arithmetic operations on numeric fields, e.g., `apply "monthofyear(@last_login) + 1" as month`
  - or functions that can be applied on fields e.g., `SQRT`, `LOG`, etc
- `APPLY` will evaluate this expression dynamically for each record and store the results into alias `name`
- Multiple APPLY statements can also be used.

```
## number of logins per year and per month, sort by year in descending order and by month in ascending order
127.0.0.1:6379> ft.aggregate idx:user "*" apply year(@last_login) as year apply "monthofyear(@last_login) + 1" as month groupby 2 @year @month reduce count 0 as number_of_logins sortby 4 @year desc @month asc
 1) (integer) 13
 2) 1) "year"
    2) "2020"
    3) "month"
    4) "1"
    5) "number_of_logins"
    6) "520"
 3) 1) "year"
    2) "2020"
    3) "month"
    4) "2"
    5) "number_of_logins"
    6) "449"
 4) 1) "year"
    2) "2020"
    3) "month"
    4) "3"
    5) "number_of_logins"
    6) "497"
```

```
## View APPLY function visually

FT.AGGREGATE idx:user
  "*"
  APPLY year(@last_login) as year
  APPLY "monthofyear(@last_login) + 1" as month

  GROUPBY 2 @year @month
    REDUCE count 0 as count_user_logins
  SORTBY 4 @year DESC @month ASC
```

```
## number of logins per weekday
127.0.0.1:6379> ft.aggregate idx:user "*" apply "dayofweek(@last_login) + 1" as day_of_week groupby 1 @day_of_week reduce count 0 as count_week_user_logins sortby 2 @day_of_week desc
1) (integer) 7
2) 1) "day_of_week"
   2) "7"
   3) "count_week_user_logins"
   4) "906"
3) 1) "day_of_week"
   2) "6"
   3) "count_week_user_logins"
   4) "832"
4) 1) "day_of_week"
   2) "5"
   3) "count_week_user_logins"
   4) "834"
5) 1) "day_of_week"
   2) "4"
   3) "count_week_user_logins"
   4) "878"
6) 1) "day_of_week"
   2) "3"
   3) "count_week_user_logins"
   4) "868"
7) 1) "day_of_week"
   2) "2"
   3) "count_week_user_logins"
   4) "863"
8) 1) "day_of_week"
   2) "1"
   3) "count_week_user_logins"
   4) "815"
```
