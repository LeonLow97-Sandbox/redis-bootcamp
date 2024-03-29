# Redis Data Management

## Keys and Values

- A key is a way to store and retrieve values
- All data in Redis is built on keys.
- `SET key value` set key with value
- `GET key` get key
- `DEL key` delete key
  - `DEL key1 key2 key3 ...` delete multiple keys
- `EXISTS key` check if the key exists
  - `EXISTS key1 key2 key3 ...` check multiple keys

## Define Keys with Expiration

- `SETEX key 100 value` setting key and value for 100 seconds
  - `ttl key` check the time to live for the key, if negative means key expired
  - `expire key time` setting the expiry time of the key
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

## Key Naming Conventions

- `Object-id:id`
- Max allowed key size is 512 MB.
- Redis keys are binary safe - can use binary sequence as key
- Empty string is also a valid key (not recommended)
- For example, a user can have an id, belong to a group, have friends.
  - user:100:group

```
127.0.0.1:6379> set user:100 Leon
OK
127.0.0.1:6379> set user:101 Amy
OK
127.0.0.1:6379> set user:102 Darrel
OK

127.0.0.1:6379>  set user:100:group "Software Engineer"
OK
127.0.0.1:6379> set user:101:group HR
OK
127.0.0.1:6379> set user:100:friends Darrel
OK
127.0.0.1:6379> keys *
1) "user:101"
2) "user:102"
3) "user:100"
4) "user:100:group"
5) "user:100:friends"
```

## Keys Regular Expression

- `KEYS pattern`
  - `h?llo` matches hello, hallo and hxllo
  - `h*llo` matches hllo and heeeeello
  - `h[ae]llo` matches hello and hallo, but not hillo
  - `h[^e]llo` matches hallo, hbllo, ... but not hello
  - `h[a-b]llo` matches hallo and hbllo
- Redis running on an entry level laptop can scan a 1 million key database in 40 milliseconds
- Consider `KEYS` as a command should only be used in production environments with extreme care. It may ruin performance when it is executed against large databases.
  - Consider using `SCAN` in production environments.

```
127.0.0.1:6379> SET hello 1
OK
127.0.0.1:6379> SET hallo 2
OK
127.0.0.1:6379> SET hrllo 3
OK
127.0.0.1:6379> SET heello 4
OK
127.0.0.1:6379> SET hijllo 5
OK

127.0.0.1:6379> KEYS *ll*
1) "hello"
2) "hallo"
3) "hrllo"
4) "hijllo"
5) "heello"
127.0.0.1:6379> KEYS h[a-e]llo
1) "hello"
2) "hallo"
127.0.0.1:6379> keys *e*
1) "hello"
2) "heello"
127.0.0.1:6379> keys h?llo
1) "hello"
2) "hallo"
3) "hrllo"
```

```
127.0.0.1:6379> keys *
1) "user:102:friends"
2) "user:100:group"
3) "user:100:friends"
4) "user:101"
5) "user:102"
6) "user:101:group"
7) "user:100"
127.0.0.1:6379> KEYS user:???
1) "user:101"
2) "user:102"
3) "user:100"
127.0.0.1:6379> KEYS user:*:group
1) "user:100:group"
2) "user:101:group"
127.0.0.1:6379> keys user:???
1) "user:101"
2) "user:102"
3) "user:100"
```

# Saving keys information on server

- `SHUTDOWN SAVE` to save keys to the disk
- `SHUTDOWN NOSAVE` won't save the keys

```
127.0.0.1:6379> set 1 hello1
OK
127.0.0.1:6379> set 2 hello2
OK

127.0.0.1:6379> SHUTDOWN SAVE
not connected> ping
PONG
127.0.0.1:6379> GET 1
"hello1"
127.0.0.1:6379> GET 2
"hello2"

127.0.0.1:6379> SET 3 hello3
OK
127.0.0.1:6379> SHUTDOWN NOSAVE
not connected> PING
PONG
127.0.0.1:6379> GET 3
(nil)
127.0.0.1:6379> GET 2
"hello2"
```

## `RENAME` a key

- `RENAME <key> <newkey>`, recommended to use `RENAMENX` instead
- `RENAME` is used to rename a key, and it replaces the existing key if the new key name already exists.
- `RENAMENX` renames the key only if the new key name does not already exist. It avoids accidentally overriding an existing key with the new key name.

```
127.0.0.1:6379> SET name1 Leon
OK
127.0.0.1:6379> SET name2 Darrel
OK
127.0.0.1:6379> RENAME name1 myname
OK
127.0.0.1:6379> RENAME name2 myfriend
OK
127.0.0.1:6379> keys *
1) "myfriend"
2) "myname"
```

- If newkey already exists, it is overwritten.
- When this happens `RENAME` executes an implicit `DEL` operation, so if the deleted key contains a very big value, it may cause high latency even if `RENAME` itself is usually a constant-time operation.

```
127.0.0.1:6379> RENAME myfriend myname
OK
127.0.0.1:6379> KEYS *
1) "myname"
```

## `RENAMENX`

- Use this instead of `RENAME`.
- `RENAMENX` renames key to newkey if newkey does not yet exist.
- Return value:
    - 1 if key was renamed to newkey.
    - 0 if newkey already exists.

```
127.0.0.1:6379> set k1 v1
OK
127.0.0.1:6379> set k2 v2
OK
127.0.0.1:6379> renamenx k1 k2
(integer) 0
127.0.0.1:6379> renamenx k1 k3
(integer) 1
127.0.0.1:6379> keys *
1) "k2"
2) "k3"
```

## Deleting Keys Asynchronously via `UNLINK`

- `DEL key1 key2` deletes synchronously
- `UNLINK key1 key2` deletes asynchronously (non-blocking operation)

## Finding data type of key

- `TYPE key` get the type of the key

```
127.0.0.1:6379> set name "Leon"
OK
127.0.0.1:6379> type name
string

127.0.0.1:6379> lpush k1 "value"
(integer) 1
127.0.0.1:6379> type k1
list

127.0.0.1:6379> sadd k2 "value"
(integer) 1
127.0.0.1:6379> type k2
set
```