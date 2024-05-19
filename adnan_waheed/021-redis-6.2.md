# Redis 6.2

## New Options for the SET command

- Can SET the key-value and GET the old value at the same time

```
127.0.0.1:6379> set name leon
OK
127.0.0.1:6379> set name darrel get
"leon"

## if not set previously, will get nil instead
127.0.0.1:6379> set age 27 get
(nil)
```

- Use SET with `exat` to set a particular time for the key to expire with a Unix timestamp so the key will expire at a **particular date and time**.

```
127.0.0.1:6379> set discountCoupon tomorrow exat 9999999999999
```

## Alternative to the GET command

- `GETDEL`: get the value and delete the key at the same time

```
127.0.0.1:6379> set app:config:welcomeScreen 1
OK
127.0.0.1:6379> getdel app:config:welcomeScreen
"1"
127.0.0.1:6379> get app:config:welcomeScreen
(nil)
```

- Set expiry on the key only when the key is accessed for the first time.

```
127.0.0.1:6379> set limitedoffer 1
OK
127.0.0.1:6379> getex limitedoffer ex 7200
"1"
127.0.0.1:6379> ttl limitedoffer
(integer) 7196
```

## `HRANDFIELD` command

- Returns a random key from the hash

```
127.0.0.1:6379> hkeys user:1
1) "name"
2) "age"
3) "gender"
4) "school"
127.0.0.1:6379> hrandfield user:1
"name"
127.0.0.1:6379> hrandfield user:1
"age"
127.0.0.1:6379> hrandfield user:1
"name"
127.0.0.1:6379> hrandfield user:1
"gender"

## add a count at the back to state the number of random keys to be returned
127.0.0.1:6379> hrandfield user:1 3
1) "name"
2) "gender"
3) "school"
127.0.0.1:6379> hrandfield user:1 2
1) "age"
2) "school"

## add a `withvalues` to also get back the values
127.0.0.1:6379> hrandfield user:1 2 withvalues
1) "age"
2) "27"
3) "gender"
4) "male"
127.0.0.1:6379> hrandfield user:1 2 withvalues
1) "age"
2) "27"
3) "school"
4) "nus"
```

## `SMISMEMBER` command

- Check if multiple values exists in Set

```
127.0.0.1:6379> smembers winninglot
(empty array)
127.0.0.1:6379> sadd winninglot 20 34 57 2 8 9
(integer) 6

## sismember can only check 1
127.0.0.1:6379> sismember winninglot 20
(integer) 1

## smismember can check multiple values
127.0.0.1:6379> smismember winninglot 20 50 67 2
1) (integer) 1
2) (integer) 0
3) (integer) 0
4) (integer) 1
```

```
127.0.0.1:6379> smembers topstocks
(empty array)
127.0.0.1:6379> sadd topstocks AAPL MSFT TSLA
(integer) 3
127.0.0.1:6379> sismember topstocks AAPL
(integer) 1
127.0.0.1:6379> smismember topstocks BABA NIO TSLA
1) (integer) 0
2) (integer) 0
3) (integer) 1
```