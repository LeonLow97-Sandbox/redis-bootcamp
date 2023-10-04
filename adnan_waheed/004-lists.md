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

- Event Queue
    - Lists are used in many tools like Resque, Celery, Logstash.
- Most recent data
    - Twitter does this by storing the latest tweets of a user in a list.

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
## Remove elemnts via `LOPOP` and `RPOP`

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

