## Sets

- A set is a list of strings which are **unordered and unique**.
- Provides standard mathematical operations
  - Intersection
  - Difference
  - Union
- Can be used to check the existence of members
- Maximum number of elements in a set is around 4 billion.
- Used to track unique items. E.g., Capture only UNIQUE IP addresses of a website
  - `SADD unique_ips 1.1.1.0 1.1.2.0

### `SADD`, `SMEMBERS`

- `SMEMBERS key` to view all members in the set
- `SADD key member` adds the specified members to the set stored at key.
- Specified members that are already a member of this set are ignored.
- If key does not exist, a new set is created before adding the specified members.
- Can add multiple elements to a set in one command

```
127.0.0.1:6379> sadd cars toyota tesla ford xpeng
(integer) 4
127.0.0.1:6379> sadd cars mercedes mazda
(integer) 2

127.0.0.1:6379> smembers cars
1) "toyota"
2) "tesla"
3) "ford"
4) "xpeng"
5) "mercedes"
6) "mazda"

// tesla already exists in the set
127.0.0.1:6379> sadd cars tesla
(integer) 0
127.0.0.1:6379> smembers cars
1) "toyota"
2) "tesla"
3) "ford"
4) "xpeng"
5) "mercedes"
6) "mazda"
```

### `SCARD`

- `SCARD key` to check the total number of elements in set (Cardinality).

```
127.0.0.1:6379> smembers cars
1) "toyota"
2) "tesla"
3) "ford"
4) "xpeng"
5) "mercedes"
6) "mazda"

127.0.0.1:6379> scard cars
(integer) 6
```

### `SREM`, `SPOP`

- `SREM` remove element, can remove multiple elements (Time complexity: O(n))
- `SPOP` remove a random element, can also define count (optional).

```
127.0.0.1:6379> sadd subjects math english science chinese literature
(integer) 5
127.0.0.1:6379> srem subjects english
(integer) 1
127.0.0.1:6379> smembers subjects
1) "math"
2) "science"
3) "chinese"
4) "literature"

127.0.0.1:6379> spop subjects
"chinese"
127.0.0.1:6379> smembers subjects
1) "math"
2) "science"
3) "literature"

// defining count in spop
127.0.0.1:6379> spop subjects 2
1) "science"
2) "literature"
127.0.0.1:6379> smembers subjects
1) "math"
```

### `SISMEMBER`, `SMEMBERS`, `SMISMEMBER`

- `SISMEMBER key member` returns 0 or 1 on whether member exists in key. Search for member is case sensitive.
- `SMISMEMBER key member1 member2 ...` check for multiple members
- `SMEMBERS key` displays all members in a set

```
127.0.0.1:6379> smembers cars
1) "mercedes"
2) "mazda"
3) "toyota"
127.0.0.1:6379> sismember cars mercedes
(integer) 1
127.0.0.1:6379> sismember cars lamboghini
(integer) 0

127.0.0.1:6379> smembers player:online
1) "alpha"
2) "beta"
3) "gamma"
127.0.0.1:6379> smismember player:online alpha gamma
1) (integer) 1
2) (integer) 1
127.0.0.1:6379> smismember player:online alpha delta
1) (integer) 1
2) (integer) 0
```

### `SRANDMEMBER`

- `SRANDMEMBER key [count]` returns a random element from the set
- Use Cases
  - Create a unique lottery number
  - Get 2 random numbers

```
127.0.0.1:6379> sadd unique_lottery_num 1 20 30 40 50
(integer) 5
127.0.0.1:6379> smembers unique_lottery_num
1) "1"
2) "20"
3) "30"
4) "40"
5) "50"

127.0.0.1:6379> srandmember unique_lottery_num
"50"
127.0.0.1:6379> srandmember unique_lottery_num
"1"
127.0.0.1:6379> srandmember unique_lottery_num
"40"

127.0.0.1:6379> srandmember unique_lottery_num 2
1) "50"
2) "40"
127.0.0.1:6379> srandmember unique_lottery_num 2
1) "20"
2) "1"
127.0.0.1:6379> srandmember unique_lottery_num 2
1) "30"
2) "50"
```

### `SMOVE`

- `SMOVE source destination member` moves elements from one set to another (Time Complexity: O(1))
  - returns
    - 1 if the element is moved.
    - 0 if the element is not a member of source and no operation was performed.
- Use Cases
  - Create 2 sets: pending orders and completed orders
  - Move pending order elements to completed order
  - Server Jobs (Started, In-progress, Completed)
  - To-Do List

```
127.0.0.1:6379> smembers num_odd
1) "1"
2) "3"
3) "5"
4) "7"
5) "9"
127.0.0.1:6379> smembers num_even
1) "2"
2) "4"
3) "6"
4) "8"
5) "10"

127.0.0.1:6379> smove num_odd num_even 1
(integer) 1
127.0.0.1:6379> smembers num_odd
1) "3"
2) "5"
3) "7"
4) "9"
127.0.0.1:6379> smembers num_even
1) "1"
2) "2"
3) "4"
4) "6"
5) "8"
6) "10"

127.0.0.1:6379> smove num_odd num_even 1
(integer) 0

// unable to move multiple members at once
127.0.0.1:6379> smove num_odd num_even 5 7
(error) ERR wrong number of arguments for 'smove' command
```

### Set Operation - `UNION`

- `SUNION key1 key2` create 2 sets of numbers then combine them using SUNION
  - Union = key1 + key2
- Use Case
  - Create 2 sets - pending tickets and completed tickets on a helpdesk system.

```
127.0.0.1:6379> sadd num1 1 2 3 4 5
(integer) 5
127.0.0.1:6379> sadd num2 2 4 6 8 10
(integer) 5

127.0.0.1:6379> sunion num1 num2
1) "1"
2) "2"
3) "3"
4) "4"
5) "5"
6) "6"
7) "8"
8) "10"
```

### Set Operations - `SUNIONSTORE`

- `SUNIONSTORE destination key1 key2` creating a set out of the result set of union

```
127.0.0.1:6379> sadd num1 1 2 3 4 5
(integer) 5
127.0.0.1:6379> sadd num2 2 4 6 8 10
(integer) 5
127.0.0.1:6379> sadd num3 3 6 9 12 15
(integer) 5
127.0.0.1:6379> SUNIONSTORE nums num1 num2 num3
(integer) 11
127.0.0.1:6379> smembers nums
 1) "1"
 2) "2"
 3) "3"
 4) "4"
 5) "5"
 6) "6"
 7) "8"
 8) "9"
 9) "10"
10) "12"
11) "15"
```

### Set Operation - Intersection

- `SINTER key1 key2` take all common elements from the keys
- Uses cases
  - Find the best stocks within the lists - Top price gainers, Top volume gainers, Top analyst recommends.

```
127.0.0.1:6379> sadd key1 a b c d
(integer) 4
127.0.0.1:6379> sadd key2 c
(integer) 1
127.0.0.1:6379> sadd key3 a c d
(integer) 3

127.0.0.1:6379> SINTER key1 key2 key3
1) "c"

// example use case
127.0.0.1:6379> sadd stocks:gainers AAPL MSFT IBM TSLA
(integer) 4
127.0.0.1:6379> sadd stocks:vol_gainers AAPL MSFT QQQ
(integer) 3
127.0.0.1:6379> sadd stocks:analyst AAPL C
(integer) 2
127.0.0.1:6379> sinter stocks:gainers stocks:vol_gainers stocks:analyst
1) "AAPL"
```

- `SINTERSTORE destination key1 key2` combines the result set

```
127.0.0.1:6379> sinterstore stocks:best stocks:gainers stocks:vol_gainers stocks:analyst
(integer) 1
127.0.0.1:6379> smembers stocks:best
1) "AAPL"
```

### Set Operation - Difference

- `SDIFF key1 key2` returns the members of the set resulting from the **difference** between the first set and all the successive sets.
- Basically, looking UNCOMMON elements between key1 and key2 + key3

```
127.0.0.1:6379> sadd k1 a b c d
(integer) 4
127.0.0.1:6379> sadd k2 c
(integer) 1
127.0.0.1:6379> sadd k3 a c e
(integer) 3
127.0.0.1:6379> sdiff k1 k2 k3
1) "b"
2) "d"
```