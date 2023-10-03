# Redis data structures

- Unlike RDBMS, there is no table in Redis.
- What data types Redis support natively
    - string, list, hashes, sets, sorted sets
- No way to manipulate data in Redis as compared to SQL with SELECT, ...
- We issue commands directly on the target data type in Redis

## Redis Strings

- String is the basic but more powerful data structure in Redis
- Strings are binary safe, so we can store any data type
- Strings can be used as generic data storage.
    - If our data does not fit in any of other Redis data type, we can store the data into string data type.
- Can serialize ANY TYPE OF DATA to a string.
- String can behave as random access vector too
- Large amount of data can be encoded into small space in string
- Maximum size of string: 512 MB

## Redis Strings - Use Cases

- Plain Strings
    - Serving static contents like static website pages
    - Redis.io websute uses Redis database itself to serve all static pages
- Caching
    - Frequently used data can be cached into string
    - With the help of `EX`, `SET` commands, caching can be possible.

```127.0.0.1:6379> SETEX otp:user_100 120 123456
OK
127.0.0.1:6379> get otp:user_100
"123456"
127.0.0.1:6379> ttl otp:user_100
(integer) 109
127.0.0.1:6379> type otp:user_100
string
```

- Counters
    - Strings can be used to store stats
    - Daily user visis, website stats and more

```
127.0.0.1:6379> set app:stats:daily_visitors 1000
OK
127.0.0.1:6379> get app:stats:daily_visitors
"1000"
```

- Configurations
    - Store application configurations, and master catalogs

```
127.0.0.1:6379> set app:config:title "KlickAnalytics"
OK
127.0.0.1:6379> set app:users:types "Billable, Free"
OK
127.0.0.1:6379> set app:config:usertimeout 100000
OK
```

## Counting Numbers using `INCR` and `DECR`

- `INCR` increases value by 1
- `DECR` decreases value by 1
- `INCRBY` increases value by specified number.
- `DECRBY` decreases value by specified number.

```
127.0.0.1:6379> set student:101:score:math 10
OK

127.0.0.1:6379> incr student:101:score:math
(integer) 11
127.0.0.1:6379> decr student:101:score:math
(integer) 10

127.0.0.1:6379> incrby student:101:score:math 60
(integer) 70
127.0.0.1:6379> decrby student:101:score:math 30
(integer) 40
```

## Counting floating point numbers

- `INCRBYFLOAT` used to increase or decrease floating point values. Specify value as positive or negative.
- Cannot use `INCRBY` to increase a value that is a float, same for `DECRBY`

```
127.0.0.1:6379> get num
"1.5"
127.0.0.1:6379> incrby num 1
(error) ERR value is not an integer or out of range

127.0.0.1:6379> incrbyfloat num 1
"2.5"

127.0.0.1:6379> decrbyfloat num 1
(error) ERR unknown command 'decrbyfloat', with args beginning with: 'num' '1'

127.0.0.1:6379> incrbyfloat num -1
"1.5"

127.0.0.1:6379> set add:fees:creditcard 1.0
OK
127.0.0.1:6379> incrbyfloat add:fees:creditcard 0.2
"1.19999999999999996"
127.0.0.1:6379> incrbyfloat add:fees:creditcard 2.0
"3.20000000000000018"
```

## Using `APPEND` for a time series data

- `APPEND key value` If the key already exists and is a string, this command appends the value at the end of the string.
- `STRLEN key` to get the length of the value

```
127.0.0.1:6379> set title "Hello"
OK
127.0.0.1:6379> append title " Leon"
(integer) 10
127.0.0.1:6379> get title
"Hello Leon"

127.0.0.1:6379> strlen title
(integer) 10
```

- Using `APPEND` for a time series data

```
127.0.0.1:6379> set website:stats:daily_visitors_log "2023-01-01:5000"
OK
127.0.0.1:6379> append website:stats:daily_visitors_log " 2023-01-02:7600"
(integer) 31
127.0.0.1:6379> get website:stats:daily_visitors_log
"2023-01-01:5000 2023-01-02:7600"
```

## Setting and getting multiple keys via `MSET`, `MGET` and `MSETNX`

- `MSET` sets multiple key-value pairs
- `MGET` retrieves the values of multiple keys
- `MSETNX` sets multiple key-value pairs only if none of the specified keys already exists in the database.

```
127.0.0.1:6379> MSET k1 v1 k2 v2 k3 v3
OK
127.0.0.1:6379> keys *
1) "k1"
2) "k2"
3) "k3"
127.0.0.1:6379> MGET k1 k2 k3
1) "v1"
2) "v2"
3) "v3"
127.0.0.1:6379> MGET k1 k2 k3 k4
1) "v1"
2) "v2"
3) "v3"
4) (nil)
127.0.0.1:6379> MSET k1 v10 k2 v2 k3 v3
OK
127.0.0.1:6379> get k1
"v10"
127.0.0.1:6379> MSETNX k1 v20 k2 v2 k3 v3
(integer) 0
127.0.0.1:6379> get k1
"v10"
```

## Using `GETSET` for an atomic reset

- `GETSET key value` sets key to value and returns the old value stored at key. Returns an error when key exists but does not hold a string value.

```
127.0.0.1:6379> set key1 val1
OK
127.0.0.1:6379> getset key1 val1.2
"val1"
127.0.0.1:6379> get key1
"val1.2"

127.0.0.1:6379> getset key2 1
(nil)
```

- Design Pattern
    - `GETSET` can be used together with `INCR` for counting atomic reset.

```
127.0.0.1:6379> set app:daily_tokens 10
OK
127.0.0.1:6379> decr app:daily_tokens
(integer) 9
127.0.0.1:6379> decr app:daily_tokens
(integer) 8
127.0.0.1:6379> getset app:daily_tokens 10
"8"
```

