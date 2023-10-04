# Redis Lists

- Lists are very flexible data structure in Redis.
- A list acts as a simple collection of elements
    - 1,2,3,4,5,6,...
- List stores sequence of objects
- A list is a sequence of **ordered** elements
- The order of the elements depends on the elements insertion sequence.
- A list can be encoded and memory optimized.
- A list is like an array - from programming perspective.
- Element in a list are **strings**.
- A list can contain > 4 billion elements.

## Redis List - Use Cases

Lists contain strings that are sorted by their insertion order. With Redis Lists, can add items to the head or tail of the lists, which is very useful for queueing jobs. Some of the use cases for the list may be:

- Event Queue
    - Lists are used in many tools like Resque, Celery, Logstash.
- Most recent data
    - Twitter does this by storing the latest tweets of a user in a list.
- Social Networking Sites
    - Social platform like Twitter use Redis Lists to populate their timelines or homepage feeds, and can customize the top of their feeds with trending tweets or stories.
- RSS Feeds:
    - Can create news feeds from custom sources where you can pull the latest updates and allow interested followers to subscribe to their favorite RSS feed.
- Leaderboards: This is more of high use cases where Forums like Reddit and other voting platforms utilize Redis Lists to add articles to the leaderboard and even sort them by most viewed and voted entries.


## `LPUSH`, `RPUSH`, `LRANGE`

- `LPUSH key element...` inserts 1 or multiple values at the beginning of a list in Redis.
- `RPUSH key element...` inserts 1 or multiple values at the end of a list in Redis.
- `LRANGE key start stop` retrieves a range of elements from a list in Redis based on the specified start and stop indices.

```
127.0.0.1:6379> lpush dept "Sales"
(integer) 1
127.0.0.1:6379> lpush dept "Admin" "HR"
(integer) 3
127.0.0.1:6379> lrange dept 0 -1
1) "HR"
2) "Admin"
3) "Sales"

127.0.0.1:6379> rpush dept "Marketing"
(integer) 4
127.0.0.1:6379> lrange dept 0 -1
1) "HR"
2) "Admin"
3) "Sales"
4) "Marketing"
```

## Using `LINDEX` to view latest stock prices

- `LINDEX key index` returns the element at the specified index in the list stored at key.
- Time complexity is O(N) where N is the number of elements to traverse to get to the element at index. This makes asking for the first or the last element of the list O(1).

```
127.0.0.1:6379> lrange dept 0 -1
1) "Admin"
2) "Marketing"
3) "Software Engineering"
4) "Sales"
5) "HR"
127.0.0.1:6379> lindex dept 0
"Admin"
127.0.0.1:6379> lindex dept 1
"Marketing"

127.0.0.1:6379> lindex dept -1
"HR"
127.0.0.1:6379> lindex dept 10
(nil)
```

```
127.0.0.1:6379> lpush MSFT:close_prices 10 10.20 11.00 20.00
(integer) 4

127.0.0.1:6379> lrange MSFT:close_prices 0 -1
1) "20.00"
2) "11.00"
3) "10.20"
4) "10"
127.0.0.1:6379> lindex MSFT:close_prices -1
"10"
```

## Insert an element using `LINSERT`

- `LINSERT key BEFORE|AFTER pivot element` inserts element in the list stored at key either before or after the reference value `pivot`.
- Time Complexity is O(N) where N is the number of elements to traverse before seeing the value pivot.

```
127.0.0.1:6379> lrange dept 0 -1
1) "Marketing"
2) "Sales"
3) "Admin"
4) "HR"
5) "Programming"
127.0.0.1:6379> LINSERT dept BEFORE "Admin" "Finance"
(integer) 6
127.0.0.1:6379> lrange dept 0 -1
1) "Marketing"
2) "Sales"
3) "Finance"
4) "Admin"
5) "HR"
6) "Programming"

127.0.0.1:6379> linsert dept after "Sales" "Analyst"
(integer) 7
127.0.0.1:6379> lrange dept 0 -1
1) "Marketing"
2) "Sales"
3) "Analyst"
4) "Finance"
5) "Admin"
6) "HR"
7) "Programming"
```
## Remove elemnts via `LPOP` and `RPOP`

- `LPOP key count` removes and returns the first elements of the list stored at key.

```
127.0.0.1:6379> lpush num 1 2 3 4 5 6 7 8 9 10
(integer) 10
127.0.0.1:6379> lpop num
"10"
127.0.0.1:6379> rpop num
"1"
127.0.0.1:6379> lrange num 0 -1
1) "9"
2) "8"
3) "7"
4) "6"
5) "5"
6) "4"
7) "3"
8) "2"

127.0.0.1:6379> lpop num 3
1) "9"
2) "8"
3) "7"
127.0.0.1:6379> lrange num 0 -1
1) "6"
2) "5"
3) "4"
4) "3"
5) "2"
127.0.0.1:6379> rpop num 4
1) "2"
2) "3"
3) "4"
4) "5"
127.0.0.1:6379> lrange num 0 -1
1) "6"
```

## `LTRIM` 

- `LTRIM key start stop` trim an existing list so that it will contain only the specified range of elements specified.

```
127.0.0.1:6379> lrange num 0 -1
 1) "10"
 2) "9"
 3) "8"
 4) "7"
 5) "6"
 6) "5"
 7) "4"
 8) "3"
 9) "2"
10) "1"
127.0.0.1:6379> LTRIM num 3 -1
OK
127.0.0.1:6379> lrange num 0 -1
1) "7"
2) "6"
3) "5"
4) "4"
5) "3"
6) "2"
7) "1"
```

## `LSET`

- `LSET key index element` sets the list element at index with element. it's like updating an element in the list

```
127.0.0.1:6379> rpush num 1 2 3 4 5
(integer) 5
127.0.0.1:6379> lrange num 0 -1
1) "1"
2) "2"
3) "3"
4) "4"
5) "5"
127.0.0.1:6379> lset num 2 100
OK
127.0.0.1:6379> lrange num 0 -1
1) "1"
2) "2"
3) "100"
4) "4"
5) "5"
```

## Find the length of a list using `LLEN`

- `LLEN key` to get the length of a list

```
127.0.0.1:6379> rpush app:config:lst_supported_lang "English" Japanese Korean Chinese Spanish
(integer) 5
127.0.0.1:6379> LLEN app:config:lst_supported_lang
(integer) 5
```

## Find matching elements with `LPOS`

- `LPOS key element` returns the index of matching elements inside a Redis list.
- Options:
    - `RANK` specifies the rank to start searching from (default is 0).
    - `COUNT` limits the number of matching elements to return (`0` returns all indexes of the matched element).
    - `MAXLEN` sets a maximum distance for a range search, e.g., `MAXLEN 2` means with a maximum distance of 2 elements. it only returns 1 index.

```
127.0.0.1:6379> rpush mylist d a a b c e a a f g
(integer) 10
127.0.0.1:6379> lpos mylist a rank 1
(integer) 1
127.0.0.1:6379> lpos mylist a count 0
1) (integer) 1
2) (integer) 2
3) (integer) 6
4) (integer) 7
127.0.0.1:6379> lpos mylist a count 2
1) (integer) 1
2) (integer) 2
127.0.0.1:6379> lpos mylist a maxlen 2
(integer) 1
127.0.0.1:6379> lpos mylist a maxlen 100
(integer) 1
127.0.0.1:6379> lpos mylist a maxlen 5
(integer) 1
127.0.0.1:6379> lpos mylist a count 0 maxlen 3
1) (integer) 1
2) (integer) 2
```

## Remove element via `LREM`

- `LREM key count element` removes the first count occurrences of elements equal to `element` from the list stored at `key`.
    - `count > 0`: remove elements equal to `element` moving from head to tail. (left to right)
    - `count < 0`: remove elements equal to `element` moving from tail to head. (right to left)
    - `count = 0`: remove elements equal to `element`

```
127.0.0.1:6379> rpush mylist one one two three one
(integer) 5
127.0.0.1:6379> lrem mylist 0 "two"
(integer) 1
127.0.0.1:6379> lrange mylist 0 -1
1) "one"
2) "one"
3) "three"
4) "one"

127.0.0.1:6379> lrem mylist 2 "one"
(integer) 2
127.0.0.1:6379> lrange mylist 0 -1
1) "three"
2) "one"

127.0.0.1:6379> lrem mylist -1 "one"
(integer) 1
127.0.0.1:6379> lrange mylist 0 -1
1) "three"
```

## Move elements between lists via `LMOVE`

- `LMOVE source destination LEFT|RIGHT LEFT|RIGHT` atomically returns and removes the first/last element of the list stored at `source` and pushes the element at the first/last element of the list stored at `destination`.
- If `LEFT RIGHT`, takes the leftmost position from source and add to rightmost position in destination.
- Use case: to arrange cron jobs. Can put this in a loop and once its done, we move it from source to destination.

```
127.0.0.1:6379> rpush jobs:pending job1 job2 job3
(integer) 3
127.0.0.1:6379> lmove jobs:pending jobs:completed LEFT RIGHT
"job1"
127.0.0.1:6379> lrange jobs:pending 0 -1
1) "job2"
2) "job3"
127.0.0.1:6379> lrange jobs:completed 0 -1
1) "job1"
127.0.0.1:6379> lmove jobs:pending jobs:completed LEFT RIGHT
"job2"
127.0.0.1:6379> lrange jobs:pending 0 -1
1) "job3"
127.0.0.1:6379> lrange jobs:completed 0 -1
1) "job1"
2) "job2"
127.0.0.1:6379> lmove jobs:pending jobs:completed LEFT LEFT
"job3"
127.0.0.1:6379> lrange jobs:pending 0 -1
(empty array)
127.0.0.1:6379> lrange jobs:completed 0 -1
1) "job3"
2) "job1"
3) "job2"
```