## Redis Hashes

- Hashes are a list of field and value pairs.
- `field1:value1, field2:value2, field3:value3`
- Similar to JSON objects
- Represent mapping relationship between fields and values
- Elements in a hash
  - are strings
  - fields with their values
- Hashes are schemaless (can put anything inside a hash)
- A hash can contain > 4 billion elements.
- Hashes are mutable
- A field will always have a value in a hash

## Redis Hashes - Use Cases

Redis Hashes are maps between string fields and string values. They are the go-to data type if you need to essentially create a container of unique fields and their values to represent objects.

1. User Profiles

Redis Hash data structures can be used to store application objects like "Users" information. Many web applications use Redis Hashes for their user profiles as they can use a single hash for all the user fields such as name, surname, email, password, etc. E.g., `HSET user:101 name "Leon" age 30 country "Singapore"`

2. User Posts

Some of the popular social platforms like Instagram use Redis Hashes for various purposes. E.g., To map all the archived user photos or posts back to a single user. Redis Hashes hashing mechanism allows them to look up and return values very fast, fit the data needed in memory, and leverage data persistence in the event of their servers dies.

3. Storing Multi-Tenant Metrics

Multi-tenant metrics can utilize Redis hashes to store critical information. E.g., they can use Redis hashes to record and store their product and sales metrics in a way that guarantees solid separation between each tenant, as hashes can be encoded efficiently in a very small memory space.

### `HSET`, `HGET`, `HGETALL`

- `HSET key field value`. will return the number of fields that were added to the hash
- `HGET key field`
- `HGETALL key`

```
127.0.0.1:6379> hset user fname "Leon" lname "Low"
(integer) 2

127.0.0.1:6379> hget user fname
"Leon"
127.0.0.1:6379> hget user lname
"Low"

127.0.0.1:6379> hgetall user
1) "fname"
2) "Leon"
3) "lname"
4) "Low"

// updating value in the field `age`
127.0.0.1:6379> hset uer age 27
(integer) 1
127.0.0.1:6379> hset uer age 35
(integer) 0

127.0.0.1:6379> hgetall user
1) "fname"
2) "Leon"
3) "lname"
4) "Low"
5) "age"
6) "35"
```

### `HMGET`

- `HMGET` get multiple fields

```
// rename the key
127.0.0.1:6379> rename user user:101
OK
127.0.0.1:6379> hgetall user:101
1) "fname"
2) "Leon"
3) "lname"
4) "Low"
5) "age"
6) "35"

127.0.0.1:6379> hmget user:101 fname lname
1) "Leon"
2) "Low"
```

### `HLEN`

- `HLEN key` returns the number of fields in the hash stored at key.

```
127.0.0.1:6379> hgetall user:101
1) "fname"
2) "Leon"
3) "lname"
4) "Low"
5) "age"
6) "35"
127.0.0.1:6379> hlen user:101
(integer) 3
```

### `HDEL`

- `HDEL key field` removes the specified fields from the hash stored at key.
- Can delete multiple fields in one command.

```
127.0.0.1:6379> hgetall user:101
 1) "fname"
 2) "Leon"
 3) "lname"
 4) "Low"
 5) "age"
 6) "35"
 7) "gender"
 8) "male"
 9) "school"
10) "nus"

127.0.0.1:6379> hdel user:101 gender school
(integer) 2
127.0.0.1:6379> hgetall user:101
1) "fname"
2) "Leon"
3) "lname"
4) "Low"
5) "age"
6) "35"
```

### `HEXISTS`

- `HEXISTS key field` returns if field exists in hash
- Cannot check multiple fields

```
127.0.0.1:6379> hgetall user:101
1) "fname"
2) "Leon"
3) "lname"
4) "Low"
5) "age"
6) "35"
127.0.0.1:6379> hexists user:101 lname
(integer) 1
```

### `HKEYS`

- `HKEYS key` returns all field names in the hash

```
127.0.0.1:6379> hgetall user:101
1) "fname"
2) "Leon"
3) "lname"
4) "Low"
5) "age"
6) "35"
127.0.0.1:6379> hkeys user:101
1) "fname"
2) "lname"
3) "age"
```

### `HVALS`

- `HVALS key` returns all values in the hash

```
127.0.0.1:6379> hgetall user:101
1) "fname"
2) "Leon"
3) "lname"
4) "Low"
5) "age"
6) "35"
127.0.0.1:6379> hvals user:101
1) "Leon"
2) "Low"
3) "35"
```

### `HINCRBY`, `HINCRBYFLOAT`

- `HINCRBY key field increment` increments the number stored at field in the hash
- `HINCRBYFLOAT` to increment float

```
// increment integers
127.0.0.1:6379> hgetall user:101
1) "fname"
2) "Leon"
3) "lname"
4) "Low"
5) "age"
6) "35"
127.0.0.1:6379> hincrby user:101 age 10
(integer) 45
127.0.0.1:6379> hincrby user:101 age -17
(integer) 28

// increment floats
127.0.0.1:6379> hset user:101 amount 10.15
(integer) 1
127.0.0.1:6379> hincrbyfloat user:101 amount 2.45
"12.60000000000000142"
```

### `HSETNX`

- `HSETNX key field value` can only set field if it does not exist

```
127.0.0.1:6379> hgetall user:101
1) "fname"
2) "Leon"
3) "lname"
4) "Low"
5) "age"
6) "28"
7) "amount"
8) "12.60000000000000142"

127.0.0.1:6379> hsetnx user:101 fname Daniel
(integer) 0
127.0.0.1:6379> hsetnx user:101 f1 v1
(integer) 1

127.0.0.1:6379> hgetall user:101
 1) "fname"
 2) "Leon"
 3) "lname"
 4) "Low"
 5) "age"
 6) "28"
 7) "amount"
 8) "12.60000000000000142"
 9) "f1"
10) "v1"
```

### `HRANDFIELD`

- `HRANDFIELD key [count]` returns random values from a hash
  - `count` is optional.
  - If count > 0, it returns the number of fields specified in count that are **unique**.
  - If count < 0, e.g., -2. It returns the number of fields specified in count that **could contain duplicates**.
- `HRANDFIELD key [count] withvalues`
    - `withvalues` returns the fields with its associated values

```
127.0.0.1:6379> hgetall user:101
 1) "fname"
 2) "Leon"
 3) "lname"
 4) "Low"
 5) "age"
 6) "28"
 7) "amount"
 8) "12.60000000000000142"
 9) "f1"
10) "v1"

127.0.0.1:6379> hrandfield user:101
"fname"
127.0.0.1:6379> hrandfield user:101
"f1"
127.0.0.1:6379> hrandfield user:101
"fname"
127.0.0.1:6379> hrandfield user:101
"age"
127.0.0.1:6379> hrandfield user:101
"amount"

// positive returns unique field names
127.0.0.1:6379> hrandfield user:101 3
1) "age"
2) "amount"
3) "f1"
127.0.0.1:6379> hrandfield user:101 2
1) "age"
2) "amount"
127.0.0.1:6379> hrandfield user:101 4
1) "lname"
2) "age"
3) "amount"
4) "f1"

// negative could return duplicate field names
127.0.0.1:6379> hrandfield user:101 -2
1) "age"
2) "age"

// return with values
127.0.0.1:6379> hrandfield user:101 2 withvalues
1) "fname"
2) "Leon"
3) "amount"
4) "12.60000000000000142"

// can specify a large count and it will return everything
127.0.0.1:6379> hrandfield user:101 50 withvalues
 1) "fname"
 2) "Leon"
 3) "lname"
 4) "Low"
 5) "age"
 6) "28"
 7) "amount"
 8) "12.60000000000000142"
 9) "f1"
10) "v1"
```
