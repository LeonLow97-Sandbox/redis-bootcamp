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

