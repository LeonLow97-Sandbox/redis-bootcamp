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

|   Commands    | Description                                   |
| :-----------: | --------------------------------------------- |
|     `SET`     | Set value                                     |
|    `SETNX`    | Set value if key does not exist               |
|    `MSET`     | Set multiple values                           |
|   `MSETNX`    | Set multiple values if none of the keys exist |
|     `GET`     | Get value                                     |
|    `MGET`     | Get multiple values                           |
|   `GETSET`    | Sets value and returns old value              |
|    `SETEX`    | Set with expiry in seconds                    |
|   `PSETEX`    | Set with expiry in milliseconds               |
|    `INCR`     | Increment integer                             |
|   `INCRBY`    | Add to integer                                |
| `INCRBYFLOAT` | Add to float                                  |
|    `DECR`     | Decrement integer                             |
|   `DECRBY`    | Subtract from integer                         |

## Lists

- A list is a sequence of **ordered** elements.
- What's the downside? Accessing an element _by index_ is very fast in lists implemented with an Array (constant time indexed access) and not so fast in lists implemented by linked list (where the operation requires an amount of work proportional to the index of the accessed element).
- You can think of list as an array.
- Adding new elements at the end of a list or at the beginning is really fast.
  - Redis List supports constant time O(1) insertion and deletion of a single element near the head and tail
- The downside is that indexing into the list can be slow.
  - Accessing middle elements is very slow if it is a very big list, as it is an O(N) operation. It involves traversing the list from either the head or the tail until reaching the desired index.
- When indexing is required, Sorted Sets are a better option.

| Commands  | Description                                         |
| :-------: | --------------------------------------------------- |
|  `LPUSH`  | Add a value at the beginning of the list            |
|  `RPUSH`  | Add a value at the end of the list                  |
| `LPUSHX`  | Add a value at the beginning only if the key exists |
| `RPUSHX`  | Add a value at the end only if the key exists       |
|  `LLEN`   | Get the number of values in the list                |
| `LRANGE`  | Get values from the list within a specified range   |
| `LINDEX`  | Get a value from the list by index                  |
|  `LSET`   | Set a value in the list by index                    |
| `LINSERT` | Add a value before or after another in the list     |
|  `LREM`   | Delete elements with a specific value from the list |
|  `LTRIM`  | Trim the list by removing elements outside a range  |
|  `LPOP`   | Delete and get the first element from the list      |
|  `RPOP`   | Delete and get the last element from the list       |

## Hashes

- Hashes are useful for representing **objects**.
- Hashes contain one or more fields

|    Commands    | Description                             |
| :------------: | --------------------------------------- |
|     `HSET`     | Set field value                         |
|    `HSETNX`    | Set field value if field does not exist |
|    `HMSET`     | Set multiple field values               |
|     `HGET`     | Get field value                         |
|    `HMGET`     | Get multiple field values               |
|     `HLEN`     | Get Number of fields                    |
|    `HKEYS`     | Get all field keys                      |
|    `HVALS`     | Get all field values                    |
|   `HGETALL`    | Get all fields and values               |
|   `HEXISTS`    | Check if field exists                   |
|     `HDEL`     | Delete field                            |
|   `HINCRBY`    | Increment field integer value           |
| `HINCRBYFLOAT` | Increment field float value             |

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

| Commands      | Description                                                                               |
| ------------- | ----------------------------------------------------------------------------------------- |
| `SADD`        | Add one or more members to a set                                                          |
| `SMOVE`       | Move a member from one set to another                                                     |
| `SREM`        | Remove one or more members from a set                                                     |
| `SPOP`        | Remove and return one or multiple random members from a set                               |
| `SCARD`       | Get the number of members in a set                                                        |
| `SMEMBERS`    | Get all the members of a set                                                              |
| `SISMEMBER`   | Test if a member exists in a set                                                          |
| `SRANDMEMBER` | Get one or more random members from a set                                                 |
| `SUNION`      | Get all unique members from all specified sets                                            |
| `SUNIONSTORE` | Get all unique members from all specified sets and store in a new set                     |
| `SINTER`      | Get members that exist in all specified sets                                              |
| `SINTERSTORE` | Get members that exist in all specified sets and store in a new set                       |
| `SDIFF`       | Get members from the first set that are not in the subsequent sets                        |
| `SDIFFSTORE`  | Get members from the first set that are not in the subsequent sets and store in a new set |

---
