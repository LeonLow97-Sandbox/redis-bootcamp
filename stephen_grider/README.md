# Introduction to Redis

- Redis is a database.
- Why use Redis? Redis is **fast**!
    - All data is stored in memory. (can be challenging is working with a dataset that is larger than the memory provided)
    - Data is organized in simple data structures.
    - Redis has a simple feature set.
- Trade-off: It is more expensive to store data in memory.

<img src="./pics/redis_vs_traditional_database.png" width="60%" />

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

## Basic Commands with Strings

|Commands|Description|
|---|---|
|`SETEX`|Same thing as SET with the EX option. `SET color red EX 2` is similar to `SETEX color 2 red`|
|`SETNX`|`SETNX` does the same thing as SET with the NX option. `SET color red NX` is similar to `SETNX color red`|
|`MSET`|Set multiple key-value pairs at the same time. E.g., `MSET color red car toyota`.|
|`MGET`|Get multiple keys at the same time.|
|`DEL`|Deletes a key. Works with any data type, not just strings.|
|`GETRANGE`|Return a sequence of characters from an existing string. `GETRANGE color 0 3` returns all the characters between the first and the 4th.|
|`SETRANGE`|Update a portion of an existing string. `SETRANGE color 2 blue` start replacing characters at index 2 with the specified value.|

## Storing numbers in Redis

- When we store numbers in Redis, `SET age 20`, Redis stores 20 as a string "20".
- When we retrieve it in our App Server, have to parse "20" to become an integer 20.

|Commands|Description|
|---|---|
|`INCR`|`INCR age` adds 1 to the number stored at key|
|`DECR`|`DECR age` subtracts 1 from the number stored at key|
|`INCRBY`|`INCRBY age 10` adds an integer to the number stored at key. can specify how much to increase by.|
|`DECRBY`|`DECRBY age 12` subtracts an integer from the number stored at key. can specify how much to decrease by.|

## Project 1: E-Commerce App Setup (`rbay`)

- Add redis connection to `.env` file
- Start up application `npm run dev`
