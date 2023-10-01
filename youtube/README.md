# Redis

- NoSQL database. Data is stored in key-value pairs.
- Unlike normal database that stores data in disk, redis works in RAM with in memory. If the system crashes, the data is lost and not persistent.
- Redis is used more for caching, data that is consistently being used, faster than the traditional database.
- Redis is typically built on top of traditional databases like MongoDB, PostgreSQL, ...
- Access Redis to check if data is available, otherwise search database for the data, this improves performance by a lot.

# Installing Redis

-----
#### macOS

- `brew install redis`
- `redis-server`: starting up redis server, default port for redis is `6379`
- Once `redis-server` is running, run alongside it with `redis-cli` to set key-value pairs.
-----

# `SET`, `GET`, `DEL`, `EXISTS`

- `GET` will all return string type.

```redis
127.0.0.1:6379> SET name leon
OK
127.0.0.1:6379> GET name
"leon"

127.0.0.1:6379> SET age 26
OK
127.0.0.1:6379> GET age
"26"

127.0.0.1:6379> DEL age
(integer) 1
127.0.0.1:6379> GET age
(nil)
127.0.0.1:6379> EXISTS name
(integer) 1

127.0.0.1:6379> keys *
1) "name"
127.0.0.1:6379> flushall
OK
127.0.0.1:6379> keys *
(empty array)
```

# Expiration with TTL

- If TTL is negative, means there is no expiration.
- `expire <key> 10` 

```redis
127.0.0.1:6379> ttl name
(integer) -1

127.0.0.1:6379> expire name 10
(integer) 1

127.0.0.1:6379> setex name 10 leon
OK
```

# Lists

- Useful for queue or stack. If you have a messenger app and want to cache the 5 most recent messages for a user, can `lpush` to the top of the array and `rpop` the end of the array.
This way you always get the 5 more recent messages.

```redis
127.0.0.1:6379> lpush friends darrel
(integer) 1

127.0.0.1:6379> get friends
(error) WRONGTYPE Operation against a key holding the wrong kind of value

127.0.0.1:6379> lrange friends 0 -1
1) "darrel"

127.0.0.1:6379> lpush friends alfred
(integer) 2
127.0.0.1:6379> lrange friends 0 -1
1) "alfred"
2) "darrel"

127.0.0.1:6379> rpush friends amos
(integer) 3
127.0.0.1:6379> lrange friends 0 -1
1) "alfred"
2) "darrel"
3) "amos"

127.0.0.1:6379> lpop friends
"alfred"
127.0.0.1:6379> rpop friends
"amos"
127.0.0.1:6379> lrange friends 0 -1
1) "darrel"
```

# Sets

- Stores unique keys.
- `SADD`: add
- `SREM`: remove

```redis
127.0.0.1:6379> SADD hobbies "weight lifting"
(integer) 1
127.0.0.1:6379> SMEMBERS hobbies
1) "weight lifting"
127.0.0.1:6379> SADD hobbies "weight lifting"
(integer) 0
127.0.0.1:6379> SMEMBERS hobbies
1) "weight lifting"

127.0.0.1:6379> SREM hobbies "weight lifting"
(integer) 1
127.0.0.1:6379> SMEMBERS hobbies
(empty array)
```

# Hashes

- Useful for storing key-value pairs inside of an individual key.

```redis
127.0.0.1:6379> HSET person name leon
(integer) 1
127.0.0.1:6379> HGET person name
"leon"
127.0.0.1:6379> HGETALL person
1) "name"
2) "leon"

127.0.0.1:6379> HSET person age 26
(integer) 1
127.0.0.1:6379> HGETALL person
1) "name"
2) "leon"
3) "age"
4) "26"

127.0.0.1:6379> HGET person name
"leon"
127.0.0.1:6379> HGET person age
"26"

127.0.0.1:6379> HDEL person age
(integer) 1
127.0.0.1:6379> HGETALL person
1) "name"
2) "leon"

127.0.0.1:6379> HEXISTS person name
(integer) 1
127.0.0.1:6379> HEXISTS person age
(integer) 0
```