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

---
#### `SET`

- `key`: key we are trying to set
- `value`: value we want to store
- `EX | PX | EXAT | PXAT | KEEPTTL`: options for when this value should expire
- `NX | XX`:
    - `NX`: Only run the SET if the key does not exist
    - `XX`: Only run the SET if the key already exists
- `GET`: return the previous value stored at this key.
---