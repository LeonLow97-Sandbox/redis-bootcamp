# Redis Data Management

## Keys and Values

- A key is a way to store and retrieve values
- All data in Redis is built on keys.
- `SET key value` set key with valeu
- `GET key` get key
- `DEL key` delete key
    - `DEL key1 key2 key3 ...` delete multiple keys
- `EXISTS key` check if the key exists
    - `EXISTS key1 key2 key3 ...` check multiple keys

## Define Keys with Expiration

- `SETEX key 100 value` setting key and value for 100 seconds
    - `ttl key` check the time to live for the key, if negative means key expired
    - `expire time` setting the expiry time of the key
- `SET key value px 1000` expires in 1000 milliseconds
    - `pttl key` check time to live in milliseconds
    - `pexpire key time` 
- `PERSIST key` remove the expiration on the key.

## How Redis handles keys expiration

- Normal keys are created without any expirations:
    - `SET key value` the keys live forever, persistent if saved in disk.
- For expired keys, key expiration information is stored in Unix timestamp (in milliseconds).
- Keys are expired in 2 ways:
    1. Passive way: A key is passively expired simply when some client tries to access it, and the key is found to be timed out.
    2. Active way:
        - Redis does 10 times per second:
            - Test 20 random keys from the set of keys with an associated expire.
            - Delete all the keys found expired.
            - If more than 25% of keys were expired, start again from step 1.

## Key Spaces

- Key Spaces is similar to database namespaces schemas.
- Allows you to have **same key name in multiple key spaces**.
- Key values are override in same key space location.
- Can manage keys per each key spaces.
- Cannot link keys from one key space to another key space!
- Key space index always starts at 0
- `SELECT index` to connect to a key space.
- `keys *` to see all the keys in the key space.
- `flushall` or `flushdb` remove all keys in the key space. (not ideal to use in redis server, use `del` instead)

```
127.0.0.1:6379> SELECT 1
OK
127.0.0.1:6379[1]> SET key1 value1
OK
127.0.0.1:6379[1]> GET key1
"value1"

127.0.0.1:6379[1]> SELECT 0
OK
127.0.0.1:6379> GET key1
"value2"
```

