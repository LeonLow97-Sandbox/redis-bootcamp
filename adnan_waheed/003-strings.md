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