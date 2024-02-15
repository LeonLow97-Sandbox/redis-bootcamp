## Sorted Sets

- A mix between a Set and a Hash
- Implemented via a dual-ported data structure containing both a skip list and a hash table.
- Adding elements and retrieving sorted elements is very fast.
- Like Hashes, Sorted Sets store multiple fields called _members_ and their numerical values called _scores_.
- All the members are always **unique**, non-repeating strings.
- Members are **ordered based on their scores**.
- Sorted sets are used to store data that needs to be **ranked**, such as leadership and more. Like a hash, a single key _stores multiple members_. The score of each member is a number.

### `ZADD`, `ZRANGE`

- `ZADD key [NX|XX] [GT|LT] [CH] [INCR] score member [score member...]` adds all the specified members with the specified scores to the sorted set stored at key
  - Note: The GT, LT and NX options are mutually exclusive.
- `ZRANGE key min max` get all members from a sorted set. returns the specified range of elements in the sorted set.
- `ZRANGE key min max WITHSCORES` returns the members and the score
- Use Case

  - E.g., Tracking followers for a group of users.

    | Users | No. of followers |
    | :---: | :--------------: |
    | Adam  |        10        |
    | Scott |        20        |
    |  Amy  |        30        |

```
127.0.0.1:6379> zadd users:followers 10 adam 20 scott 30 amy
(integer) 3

127.0.0.1:6379> zrange users:followers 0 -1
1) "adam"
2) "scott"
3) "amy"

127.0.0.1:6379> zrange users:followers 0 -1 WITHSCORES
1) "adam"
2) "10"
3) "scott"
4) "20"
5) "amy"
6) "30"
```

### `ZREVRANGE`

- `ZREVRANGE key start stop`

```
127.0.0.1:6379> zadd users:followers 1 John 100 David
(integer) 2

// Ascending order by default
127.0.0.1:6379> zrange users:followers 0 -1 WITHSCORES
 1) "John"
 2) "1"
 3) "adam"
 4) "10"
 5) "scott"
 6) "20"
 7) "amy"
 8) "30"
 9) "David"
10) "100"

// Scores in descending order
127.0.0.1:6379> zrevrange users:followers 0 -1 withscores
 1) "David"
 2) "100"
 3) "amy"
 4) "30"
 5) "scott"
 6) "20"
 7) "adam"
 8) "10"
 9) "John"
10) "1"
```

### Atomic Operations - `ZINCRBY`

- `ZINCRBY key increment member` perform atomic operations on score in sorted sets
- If the member does not exist in the sorted set, `ZINCRBY` adds the member with the `increment` value as score as a new member in the sorted set.

```
127.0.0.1:6379> zrange users:followers 0 -1 withscores
 1) "John"
 2) "1"
 3) "adam"
 4) "10"
 5) "scott"
 6) "20"
 7) "amy"
 8) "30"
 9) "David"
10) "100"

// increment score for adam
127.0.0.1:6379> zincrby users:followers 5 adam
"15"
127.0.0.1:6379> zrange users:followers 0 -1 withscores
 1) "John"
 2) "1"
 3) "adam"
 4) "15"
 5) "scott"
 6) "20"
 7) "amy"
 8) "30"
 9) "David"
10) "100"

// decrement score
127.0.0.1:6379> zincrby usrs:followers -5 scott
"-5"

// member "leon" does not exist
// zincrby adds the member inside
127.0.0.1:6379> zincrby users:followers 5 leon
"5"
127.0.0.1:6379> zrange users:followers 0 -1 withscores
 1) "John"
 2) "1"
 3) "leon"
 4) "5"
```

### Lexicographical Order

- Can add members with the same score
- Cannot add 2 elements into a Sorted Set with the same value but different score

```
// Can add members with the same score
127.0.0.1:6379> zrange num1:ss 0 -1 withscores
1) "a"
2) "1"
3) "b"
4) "2"
5) "c"
6) "3"
7) "d"
8) "3"

// Cannot add 2 elements into a Sorted Set with the same value but different score
127.0.0.1:6379> zadd num2:ss 1 a 2 b 3 c 4 c
(integer) 3
127.0.0.1:6379> zrange num2:ss 0 -1 withscores
1) "a"
2) "1"
3) "b"
4) "2"
5) "c"
6) "4"
```

### Rank Stocks with `ZRANK`

- `ZRANK key member [WITHSCORE]` Returns the rank of member in the sorted set stored at key, with the scores ordered from **low to high**.
- `ZREVRANK key member [WITHSCORE]` Returns the rank of member in the sorted set stored at key, with the scores ordered from **high to low**.
- Rank always starts with 0
- The higher the score, the higher the rank

```
127.0.0.1:6379> zadd stocks:top 1 AAPL 2 MSFT 3 F 4 QQQ 5 C 6 IBM 7 TSLA 8 AMZN 9 NIO 10 SPCE
(integer) 10
127.0.0.1:6379> zrange stocks:top 0 -1 withscores
 1) "AAPL"
 2) "1"
 3) "MSFT"
 4) "2"
 5) "F"
 6) "3"
 7) "QQQ"
 8) "4"
 9) "C"
10) "5"
11) "IBM"
12) "6"
13) "TSLA"
14) "7"
15) "AMZN"
16) "8"
17) "NIO"
18) "9"
19) "SPCE"
20) "10"

127.0.0.1:6379> zrank stocks:top AAPL
(integer) 0
127.0.0.1:6379> zrank stocks:top MSFT
(integer) 1
127.0.0.1:6379> zrank stocks:top AMZN
(integer) 7

127.0.0.1:6379> zrank stocks:top BABA
(nil)

// reverse the rank order
127.0.0.1:6379> zrevrank stocks:top AAPL
(integer) 9
127.0.0.1:6379> zrevrank stocks:top NIO
(integer) 1
```
