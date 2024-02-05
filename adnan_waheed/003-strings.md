# Redis data structures

- Unlike RDBMS, there is no table in Redis.
- What data types Redis support natively
    - string, list, hashes, sets, sorted sets
- No way to manipulate data in Redis as compared to SQL with SELECT, ...
- We issue commands directly on the target data type in Redis

## Strings - Use Cases

- The Redis string data structure is the most versatile data structures that can be used across multiple use cases.
    - **For serving static websites pages**: Redis.io site uses strings to serve all static page contents.
    - **Caching**: To store most common, frequently used data within an application or a website.
    - **Counters**: e.g., Daily website visitors and more.
    - **Master Catalog and configuration**. E.g., Can store all the application default or user based configuration settings in respective key strings, e.g., SET app:config:website www.KlickAnalytics.com

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
    - Redis.io website uses Redis database itself to serve all static pages
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

## Extract string value via `GETRANGE`

- `GETRANGE key start end` returns the substring of the string value stored at key, determined by offsets `start` and `end` (both are inclusive).
- Time Complexity is O(N) where N is the length of the returned string. Can be considered O(1) for small strings.

```
127.0.0.1:6379> set website "jiewei.com"
OK

127.0.0.1:6379> getrange website 2 4
"ewe"
127.0.0.1:6379> getrange website 0 -1
"jiewei.com"
127.0.0.1:6379> getrange website 0 0
"j"
```

## Replace string value using `SETRANGE`

- `SETRANGE key offset value` overwrites part of the string stored at `key`, starting at the specified offset, for the entire length of value.
- Time Complexity is O(1).
- If use `SETRANGE` on a key that does not exist, it creates the key along with paddings of `\x00` depending on what offset you put.

```
127.0.0.1:6379> set name "Hello World"
OK
127.0.0.1:6379> SETRANGE name 6 "Leon"
(integer) 11
127.0.0.1:6379> get name
"Hello Leond"

127.0.0.1:6379> SETRANGE name2 6 " Jie Wei"
(integer) 14
127.0.0.1:6379> get name2
"\x00\x00\x00\x00\x00\x00 Jie Wei"
```

## Set Key and Expiration using `SETEX` and `PSETEX`

- `SETEX key seconds value` set `key` to hold the string `value` and set `key` to timeout after a given number of seconds.
- This command is equivalent to `SET key value` + `EXPIRE key seconds`
- `PSETEX` for setting in milliseconds

```
127.0.0.1:6379> setex app:config:timeout 100 1
OK
127.0.0.1:6379> ttl app:config:timeout
(integer) 89

127.0.0.1:6379> psetex app:config:timeout_ms 100000 1
OK
127.0.0.1:6379> ttl app:config:timeout_ms
(integer) 94
```

## Set Key if not exists using `SETNX`

- `SETNX key value` set key to hold string value if key does not exist.
- `SETNX` is short for "SET if Not Exists".
- Return Values
    - `1` if the key was set
    - `0` if the key was not set

```
127.0.0.1:6379> set num1 100
OK
127.0.0.1:6379> get num1
"100"
127.0.0.1:6379> setnx num1 200
(integer) 0
127.0.0.1:6379> get num1
"100"

127.0.0.1:6379> setnx num2 200
(integer) 1

127.0.0.1:6379> setnx user:101:login_attempt 1
(integer) 1
127.0.0.1:6379> get user:101:login_attempt
"1"
```

## String Encoding Types

- Redis decides the encoding automatically based on the string value.
    - `int` for strings representing 64-bit signed integers
    - `embstr` for strings whose length is less or equal to 44 bytes; this type of encoding is more efficient in memory usage and performance.
    - `raw` for strings whose length is greater than 44 bytes.

```
127.0.0.1:6379> set mykey 123456
OK
127.0.0.1:6379> object encoding mykey
"int"

127.0.0.1:6379> set mykey "test string"
OK
127.0.0.1:6379> object encoding mykey
"embstr"

127.0.0.1:6379> set mykey "This is a long string defined for redis database structure"
OK
127.0.0.1:6379> object encoding mykey
"raw"
```

## Using Serialized JSON

- In the context of JSON, serialization refers to converting an object or data structure into a string representation.
- In the example below, the data is being serialized into JSON format before being stored.
- The value retrieved is a string that represents a JSON object.

```
127.0.0.1:6379> SET json '{"first_name":"Leon","last_name":"Low"}'
OK
127.0.0.1:6379> GET json
"{\"first_name\":\"Leon\",\"last_name\":\"Low\"}"
```

## Scanning Keys with `SCAN`

- `SCAN cursor` returns data in a paginated format. use the cursor returned from redis-cli after running the `SCAN` command.
- Time Complexity is O(1)
- Use `SCAN` instead of `KEYS *` because it is an expensive operation.
- `SCAN 0` defaults to return 10 keys, default `COUNT` is 10.

- Inserted 50 dummy keys

---
#### `SCAN` with `COUNT`

```
127.0.0.1:6379> scan 0 count 15
1) "52"
2)  1) "key:39"
    2) "key:2"
    3) "key:28"
    4) "key:32"
    5) "key:8"
    6) "key:34"
    7) "key:37"
    8) "key:15"
    9) "key:6"
   10) "key:13"
   11) "key:26"
   12) "key:22"
   13) "key:49"
   14) "key:18"
   15) "key:33"
127.0.0.1:6379> scan 52 count 15
1) "9"
2)  1) "key:46"
    2) "key:29"
    3) "key:19"
    4) "key:12"
    5) "key:44"
    6) "key:14"
    7) "key:3"
    8) "key:7"
    9) "key:20"
   10) "key:9"
   11) "key:27"
   12) "key:25"
   13) "key:36"
   14) "key:21"
   15) "key:17"
127.0.0.1:6379> scan 9 count 15
1) "15"
2)  1) "key:5"
    2) "key:23"
    3) "key:42"
    4) "key:43"
    5) "key:16"
    6) "key:30"
    7) "key:31"
    8) "key:41"
    9) "key:1"
   10) "key:40"
   11) "key:24"
   12) "key:45"
   13) "key:35"
   14) "key:50"
   15) "key:11"
   16) "key:10"
127.0.0.1:6379> scan 15 count 15
1) "0"
2) 1) "key:4"
   2) "key:47"
   3) "key:38"
   4) "key:48"
```
----
#### `SCAN` with `MATCH`

- `MATCH` to input regular expression for keys

```
127.0.0.1:6379> scan 0 match *key:?
1) "56"
2) 1) "key:2"
   2) "key:8"
   3) "key:6"
127.0.0.1:6379> scan 56 match *key:?
1) "10"
2) 1) "key:3"
127.0.0.1:6379> scan 10 match *key:?
1) "57"
2) 1) "key:7"
   2) "key:9"
   3) "key:5"
```
----

#### `SCAN` with `TYPE`

- `TYPE` searches for keys that match the data type.

```
127.0.0.1:6379> scan 0 match *h* type string count 30
1) "33"
2) 1) "hello"

127.0.0.1:6379> sadd hobbies basketball
(integer) 1
127.0.0.1:6379> sadd hobbies swimming
(integer) 1
127.0.0.1:6379> type hobbies
set
127.0.0.1:6379> scan 0 type set count 50
1) "31"
2) 1) "hobbies"
```