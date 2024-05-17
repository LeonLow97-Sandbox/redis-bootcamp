# Introduction to Redis

- Redis ia an open source **in-memory** data structure store
- Used as a database, cache and message broker.
- Redis holds its entire database in memory.
- Disk is used for persistent data storage.
- It is a **NoSQL** database and follows a **key-value** store concepts.
- Redis supports data structures like strings, hashes, lists, sets, sorted sets, bitmap, hyperloglogs.
- Characteristics:
    - In Memory, Open Source, Fast, Key-Value data structure, Simple Access, Persistence, Data Expiration, High Availability, Distributed Cluster, Clients, Modules, Scale Out

## Starting and Shutting down redis server

- `redis-server` starting up redis server
- `redis-cli` client to run redis commands on CLI
    - `shutdown nosave` shutdown redis server and not writing to physical disk
    - `ping` or `ping Hello`
    - `quit`
- `info` getting redis server information
    - `info server`
    - `info memory` NoSQL in memory server
    - `info replication`
    - `info cpu`
    - `info cluster` combine multiple redis server together to build microservices

## Redis Modules

- Redis modules make it possible to extend Redis functionality using external modules, rapidly implementing new Redis commands with features similar to what can be done inside the core itself.
- Redis module are dynamic libraries that can be loaded into Redis at startup
- Redis modules add capabilities to core-Redis and help you use Redis to build powerful applications such as:
    - search
    - real-time inventory monitoring
    - analytics
    - gaming, and more
- Redis 5.0 marks the general availability of the Redis loadable module system. With Redis modules, the developer can now extend Redis functionality in a way suitable to your application's architectural requirements. You can now introduce custom API (Redis commands) that are equally performant to core Redis commands while keeping the simplicity and elegance of using Redis commands intact.
- Exhaustive list of Redis modules at: `https://redis.io/modules`