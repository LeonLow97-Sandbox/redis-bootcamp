# Introduction to Redis

- Redis is a database.
- Why use Redis? Redis is **fast**!
  - All data is stored in memory. (can be challenging working with a dataset that is larger than the memory provided)
  - Data is organized in simple data structures.
  - Redis has a simple feature set.
- Trade-off: It is more expensive to store data in memory.

# Commands for Adding and Querying Data

- [Documentation for Commands](redis.io/commands)

## `SET`

- `key`: key we are trying to set
- `value`: value we want to store
- `EX | PX | EXAT | PXAT | KEEPTTL`: options for when this value should **expire**
  - `SET color red EX 2`: automatically delete this value after 2 seconds.
  - `PX`: in milliseconds
  - `EXAT | PXAT`: specify date / time
- `NX | XX`:
  - `NX`: Only run the SET if the key does not exist
  - `XX`: Only run the SET if the key already exists
- `GET`: return the previous value stored at this key.

## Strings

- The Redis String type is the simplest type of value you can associate with a Redis key.
- String is not the best term for this type because it it used to hold numeric types as well.
- Internally it is held as a byte array.
- A string is a simpler scalar that can hold a
  - single value
  - XML
  - JSON Document
- A string value can't be bigger than 512 MB.

|   Commands    | Description                                   | Time Complexity |
| :-----------: | --------------------------------------------- | --------------- |
|     `SET`     | Set value                                     | O(1)            |
|    `SETNX`    | Set value if key does not exist               | O(1)            |
|    `MSET`     | Set multiple values                           | O(N)            |
|   `MSETNX`    | Set multiple values if none of the keys exist | O(N)            |
|     `GET`     | Get value                                     | O(1)            |
|    `MGET`     | Get multiple values                           | O(N)            |
|   `GETSET`    | Sets value and returns old value              | O(1)            |
|    `SETEX`    | Set with expiry in seconds                    | O(1)            |
|   `PSETEX`    | Set with expiry in milliseconds               | O(1)            |
|    `INCR`     | Increment integer                             | O(1)            |
|   `INCRBY`    | Add to integer                                | O(1)            |
| `INCRBYFLOAT` | Add to float                                  | O(1)            |
|    `DECR`     | Decrement integer                             | O(1)            |
|   `DECRBY`    | Subtract from integer                         | O(1)            |

## Lists

- A list is a sequence of **ordered** elements.
- What's the downside? Accessing an element _by index_ is very fast in lists implemented with an Array (constant time indexed access) and not so fast in lists implemented by linked list (where the operation requires an amount of work proportional to the index of the accessed element).
- You can think of list as an array.
- Adding new elements at the end of a list or at the beginning is really fast.
  - Redis List supports constant time O(1) insertion and deletion of a single element near the head and tail
- The downside is that indexing into the list can be slow.
  - Accessing middle elements is very slow if it is a very big list, as it is an O(N) operation. It involves traversing the list from either the head or the tail until reaching the desired index.
- When indexing is required, Sorted Sets are a better option.

| Commands  | Description                                         | Time Complexity |
| :-------: | --------------------------------------------------- | --------------- |
|  `LPUSH`  | Add a value at the beginning of the list            | O(1)            |
|  `RPUSH`  | Add a value at the end of the list                  | O(1)            |
| `LPUSHX`  | Add a value at the beginning only if the key exists | O(1)            |
| `RPUSHX`  | Add a value at the end only if the key exists       | O(1)            |
|  `LLEN`   | Get the number of values in the list                | O(1)            |
| `LRANGE`  | Get values from the list within a specified range   | O(N+M)          |
| `LINDEX`  | Get a value from the list by index                  | O(N)            |
|  `LSET`   | Set a value in the list by index                    | O(N)            |
| `LINSERT` | Add a value before or after another in the list     | O(N)            |
|  `LREM`   | Delete elements with a specific value from the list | O(N)            |
|  `LTRIM`  | Trim the list by removing elements outside a range  | O(N)            |
|  `LPOP`   | Delete and get the first element from the list      | O(1)            |
|  `RPOP`   | Delete and get the last element from the list       | O(1)            |

## Hashes

- Hashes are useful for representing **objects**.
- Hashes contain one or more fields

|    Commands    | Description                             | Time Complexity |
| :------------: | --------------------------------------- | --------------- |
|     `HSET`     | Set field value                         | O(1)            |
|    `HSETNX`    | Set field value if field does not exist | O(1)            |
|    `HMSET`     | Set multiple field values               | O(N)            |
|     `HGET`     | Get field value                         | O(1)            |
|    `HMGET`     | Get multiple field values               | O(N)            |
|     `HLEN`     | Get Number of fields                    | O(1)            |
|    `HKEYS`     | Get all field keys                      | O(N)            |
|    `HVALS`     | Get all field values                    | O(N)            |
|   `HGETALL`    | Get all fields and values               | O(N)            |
|   `HEXISTS`    | Check if field exists                   | O(1)            |
|     `HDEL`     | Delete field                            | O(1)            |
|   `HINCRBY`    | Increment field integer value           | O(1)            |
| `HINCRBYFLOAT` | Increment field float value             | O(1)            |

## Sets

Redis Sets can be used in a lot of scenarios like:

- Unique user tracking visiting a website
- Holding unique list of items like user groups, user avatar names, product names, country codes, etc.
- Sharded data of unique values for an application
- **IP Tracking**: storing unique IP addresses to track visitors
- Implementing a product recommendation based on a user action, similar to Amazon feature where they display 'People also buy these items'.
- Analyzing Ecommerce Sites - Many online e-commerce websites use Redis Sets to analyze customer behavior such as searches, or purchases for a specific product category or subcategory. For example, an online bookstore owner can find out how many customers purchased technology books in Technology section.
- Inappropriate Content Filtering - For any app that collects user input, it's a good idea to implement some kind of content filtering for any inappropriate words, and we can do this with Redis Sets by adding you would like to filter to a SET key and the SADD command. E.g., `SADD bad_words "word1" "word2"`

---

- Redis Sets are unordered collection of strings.
- They cannot have duplicate values.
- Sets are good for expressing relations between objects.

| Commands      | Description                                                                               | Time Complexity |
| ------------- | ----------------------------------------------------------------------------------------- | --------------- |
| `SADD`        | Add one or more members to a set                                                          | O(1)            |
| `SMOVE`       | Move a member from one set to another                                                     | O(1)            |
| `SREM`        | Remove one or more members from a set                                                     | O(1)            |
| `SPOP`        | Remove and return one or multiple random members from a set                               | O(1)            |
| `SCARD`       | Get the number of members in a set                                                        | O(1)            |
| `SMEMBERS`    | Get all the members of a set                                                              | O(N)            |
| `SISMEMBER`   | Test if a member exists in a set                                                          | O(1)            |
| `SRANDMEMBER` | Get one or more random members from a set                                                 | O(1) or O(N)    |
| `SUNION`      | Get all unique members from all specified sets                                            | O(N)            |
| `SUNIONSTORE` | Get all unique members from all specified sets and store in a new set                     | O(N)            |
| `SINTER`      | Get members that exist in all specified sets                                              | O(N)            |
| `SINTERSTORE` | Get members that exist in all specified sets and store in a new set                       | O(N)            |
| `SDIFF`       | Get members from the first set that are not in the subsequent sets                        | O(N)            |
| `SDIFFSTORE`  | Get members from the first set that are not in the subsequent sets and store in a new set | O(N)            |

---

### Sorted Sets

Sorted sets are an advanced data structure in Redis that combine the features of sets with the added functionality of associating each member with a numeric score. This allows for efficient retrieval of members based on their score, making sorted sets suitable for various applications where ordering and ranking are important.

2 common use cases for sorted sets:

1. Multiplayer Gaming

- In online gaming application, sorted sets are used to maintain leaderboards and update game scores in real-time. This enables the application to efficiently track and display top performers based on their scores.

2. Questions and Answers / Community Forums:

- Sorted sets are utilized in platforms like Redis.io and Stack Overflow to rank answers based on votes for each question. This allows users to easily identify and access the highest-rated answers, promoting quality content and community engagement.

- Sorted sets are a data type in Redis that combine features of sets and hashes.
- Adding elements to sorted sets and retrieving sorted elements is extremely fast due to the efficient data structure.
- Similar to hashes, sorted sets store multiple fields known as members, along with their corresponding numerical values known as scores.
- Members within sorted sets are always unique.
- The order of members within sorted sets is determined based on their scores, allowing for easy retrieval of members in sorted order.

| Commands         | Description                                                                              | Time Complexity |
| ---------------- | ---------------------------------------------------------------------------------------- | --------------- |
| ZADD             | Add one or more members or update score                                                  | O(log(N))       |
| ZINCRBY          | Increment the score of a member                                                          | O(log(N))       |
| ZREM             | Remove one or more members                                                               | O(log(N)+M)     |
| ZCARD            | Get number of members                                                                    | O(1)            |
| ZCOUNT           | Count members within sort key (score) range                                              | O(log(N)+M)     |
| ZSCORE           | Get the score associated with the given member                                           | O(1)            |
| ZRANK            | Determine the index of a member                                                          | O(log(N))       |
| ZRANGE           | Get members sorted by sort key (score)                                                   | O(log(N)+M)     |
| ZRANGEBYLEX      | Return a range of members by lexicographical range                                       | O(log(N)+M)     |
| ZRANGEBYSCORE    | Return a range of members by score                                                       | O(log(N)+M)     |
| ZLEXCOUNT        | Count the number of members between a given lexicographical range                        | O(log(N)+M)     |
| ZREMRANGEBYLEX   | Remove all members between the given lexicographical range                               | O(log(N)+M)     |
| ZREMRANGEBYRANK  | Remove all members within the given indexes                                              | O(log(N)+M)     |
| ZREMRANGEBYSCORE | Remove all members within the given scores                                               | O(log(N)+M)     |
| ZREVRANGE        | Return a range of members by index with scores ordered from high to low                  | O(log(N)+M)     |
| ZREVRANGEBYSCORE | Return a range of members by score, with scores ordered from high to low                 | O(log(N)+M)     |
| ZREVRANK         | Determine the index of a member with scores ordered from high to low                     | O(log(N))       |
| ZREVRANGEBYLEX   | Return a range of members by lexicographical range, ordered from higher to lower strings | O(log(N)+M)     |
| ZINTERSTORE      | Get keys that exist in all sets only and store the resulting sorted set in a new key     | O(N+M)          |
| ZUNIONSTORE      | Add multiple sorted sets and store the resulting sorted set in a new key                 | O(N+M)          |

### HyperLogLog

Use cases for HyperLogLog (HLL):

- Counting unique visitors to a website or platform.
- Generating unique identifiers for items in a book or inventory.
- Maintaining a record of the best-performing stocks.
- Generating unique names for products, services, or categories.
- Tracking unique student names in a class or dataset.
- Situations prioritizing dataset counts over individual elements.

HyperLogLog is efficient for counting unique data with minimal memory usage. HLL offers high performance at low computational cost. Ideal for scenarios where large datasets need to be analyzed for unique elements.

| Command | Description                       | Time Complexity                                                           |
| ------- | --------------------------------- | ------------------------------------------------------------------------- |
| PFADD   | Append one or more elements       | O(1) per element                                                          |
| PFCOUNT | Count number of elements          | O(1)                                                                      |
| PFMERGE | Merge elements from multiple keys | O(N) where N is the total number of elements across all keys being merged |
