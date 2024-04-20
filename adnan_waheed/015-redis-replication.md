# Redis Replication

## Introduction to Replication and Scalability

- Copies from one Redis server to other Redis server (Master to Slave).
- Can be used to scale the system horizontally.
- High availability, automatically adjusts to its growing needs.

## Master/Slave Replication

- Functionality of Master Redis server: Read and Write data.
- Functionality of Slave Redis server: Read only operations. (cannot use SET command)
- When Master gets a new data, auto replication propagates the new data to the Slave redis servers.
- Purpose: to remove requests to the Master redis server.

## Setting up Master/Slave Replication

- Setting up 2 Master redis servers

```
redis-server --port 6379 --dbfilename db1.rdb
redis-cli -p 6379

redis-server --port 6380 --dbfilename db2.rdb
redis-cli -p 6380
```

- Using `INFO` to check the type of Redis Server (Master or Slave)

```
INFO

# Replication
role:master
connected_slaves:0
master_failover_state:no-failover
master_replid:f2f4d9db02aab86babe6d9c2bf49faa9186a14af
```

- Converting Redis server running on port 6380 to become a SLAVE Redis server of Redis server 6379

```
127.0.0.1:6380> replicaof localhost 6379

## Logs on Redis Server with port 6380
35311:S 14 Apr 2024 17:53:13.918 * Before turning into a replica, using my own master parameters to synthesize a cached master: I may be able to synchronize with the new master with just a partial transfer.
35311:S 14 Apr 2024 17:53:13.918 * Connecting to MASTER localhost:6379

## Running INFO command on redis server port 6380
## to check that the server is now a SLAVE
127.0.0.1:6380> INFO
# Replication
role:slave
master_host:localhost
master_port:6379
master_replid:d8154a0ac41dbd03e9f35b2e3062b5aa72b00121

## Running INFO command on redis server port 6379
## notice both have the same master_replid now
127.0.0.1:6379> INFO
# Replication
role:master
connected_slaves:1
slave0:ip=::1,port=6380,state=online,offset=196,lag=1
master_failover_state:no-failover
master_replid:d8154a0ac41dbd03e9f35b2e3062b5aa72b00121
```

- Test setting key-value on Master Redis Server and retrieve key from Slave

```
## Setting key 'name' on Master
127.0.0.1:6379> set name 'leon'
OK

## Getting key 'name' on Slave
127.0.0.1:6380> keys *
1) "name"
127.0.0.1:6380> get name
"leon"

## trying to write with Slave redis server, NOT ALLOWED
127.0.0.1:6380> set name 'Darrel'
(error) READONLY You can't write against a read only replica.
```

- Setting another Slave Redis server with port 6381 and connect to Master redis server with port 6379

```
redis-server --port 6381 --dbfilename db3.rdb

redis-cli -p 6381
replicaof localhost 6379

127.0.0.1:6381> INFO
# Replication
role:slave
master_host:localhost
master_port:6379
master_replid:d19cb1b265dc47199fff03eef46680243bd7cf2b

127.0.0.1:6379> INFO
# Replication
role:master
connected_slaves:2
slave0:ip=::1,port=6380,state=online,offset=938,lag=1
slave1:ip=::1,port=6381,state=online,offset=938,lag=1
```

- Remove connection of slave redis server (6381) from master redis server (6379)

```
127.0.0.1:6381> replicaof no one
OK

## Slave redis server converted back to Master redis server
127.0.0.1:6381> INFO
# Replication
role:master
connected_slaves:0

127.0.0.1:6379> INFO
# Replication
role:master
connected_slaves:1
slave0:ip=::1,port=6380,state=online,offset=1050,lag=0
```

## How Replication Works?

- The `master_replid` for both master and slave should be the same, indicating that the replica is correctly connected and synchronized with the master.
- `master_repl_offset` gets bigger as dataset increases. It represents the offset or position in the replication stream from the master that the replica is currently processing. As more data (dataset) is written to the master and replicated to the slave, this offset value increases to reflect the progress of replication.
  - `master_repl_offset`: this value will differ among replicas as they process replication data at different rates and points in time.

```
INFO
# Replication
master_repl_offset:6566

set age 27
set number 12345678

INFO
# Replication
master_repl_offset:8324
```

- Full Synchronization
  - First time slaves connects to master
  - Once `master_replid` are the same in master and slave, replication is completed.

## `INFO` command

- `INFO [section]`
- `INFO cpu` or `INFO replication` only want to view info on a particular section

```
127.0.0.1:6379> info cpu
# CPU
used_cpu_sys:5.890366
used_cpu_user:4.332440
used_cpu_sys_children:0.007360
used_cpu_user_children:0.000943
```

- `INFO all` returns all sections excluding modules
- `INFO everything` returns all sections and modules
- `INFO`

## `INFO server`

- `redis_mode`: standalone. can be cluster or sentinel.
- `gcc_version`: version of gcc compiler that compiles the Redis server.
- `process_id`: where the Redis instance is running, if you need to kill the server, need this process id
- `run_id`: used by sentinel or cluster environment
- `tcp_port` port running
- `uptime_in_seconds`: how many seconds the server has been up for.
- `uptime_in_days`: how many days the server has been up for.
- `executable`: where the executable of redis is found on the machine.

## `INFO clients`

- `connected_clients`: number of client connections currently established with the Redis server.
- `cluster_connections`: number of cluster-mode connections (connections to Redis cluster nodes), which is 0 for a standalone Redis instance.
- `maxclients`: maximum number of clients that can connect to this Redis server instance (configurable in the Redis configuration file).
- `blocked_clients`: number of clients currently blocked, waiting for a blocking Redis command (e.g., BLPOP, BRPOP) to be executed.
- `tracking_clients`: number of clients being tracked for monitoring and debugging purposes.

## `INFO memory`

- `used_memory`: total number of bytes allocated by Redis
- `used_memory_human`: human readable bytes (will be a large number for production server)
- `used_memory_startup`: initial amount of memory
- `total_system_memory`: total amount of memory that the redis host has
- `total_system_memory`: human readable
- `lazyfree_pending_objects`: number of memory objects (such as keys or data structures) that are pending for deallocation or memory release.

## `INFO persistence`

- `loading`: Indicates whether Redis is currently loading data from disk (1 if loading, 0 otherwise).
- `rdb_changes_since_last_save`: Number of changes to the dataset since the last RDB (Redis Database) save operation.
- `rdb_bgsave_in_progress`: Indicates if a background save operation (RDB snapshot) is currently in progress (1 if in progress, 0 otherwise).
- `rdb_last_save_time`: Unix timestamp (seconds since epoch) of the last successful RDB save operation.
- `rdb_last_bgsave_status`: Status of the last RDB save operation (success or failure).
- `rdb_last_bgsave_time_sec`: Duration (in seconds) of the last RDB save operation.
- `rdb_current_bgsave_time_sec`: Duration (in seconds) of the ongoing background RDB save operation (if in progress).
- `aof_enabled`: Indicates whether Append-Only File (AOF) persistence mode is enabled (1 if enabled, 0 otherwise).
- `aof_rewrite_in_progress`: Indicates if an AOF rewrite operation is currently in progress (1 if in progress, 0 otherwise).
- `aof_rewrite_scheduled`: Indicates whether an AOF rewrite has been scheduled (1 if scheduled, 0 otherwise).
- `aof_last_rewrite_time_sec`: Duration (in seconds) of the last AOF rewrite operation.
- `aof_last_bgrewrite_status`: Status of the last AOF rewrite operation (success or failure).

## `INFO stats`

- `total_connections_received`: Total number of connections accepted by the Redis server since startup.
- `total_commands_processed`: Total number of commands processed by the Redis server since startup.
- `instantaneous_ops_per_sec`: Number of commands processed per second in the latest second.
- `total_net_input_bytes`: Total number of bytes received by the Redis server from clients.
- `total_net_output_bytes`: Total number of bytes sent by the Redis server to clients.
- `rejected_connections`: Number of connections rejected due to hitting the maxclients limit.
- `expired_keys`: Total number of keys that have expired and been removed from the database.
- `evicted_keys`: Total number of keys evicted due to reaching max memory capacity and using eviction policies like LRU.
- `keyspace_hits`: Number of successful key lookups (hits) in the main dictionary.
- `keyspace_misses`: Number of unsuccessful key lookups (misses) in the main dictionary.
- `used_memory`: Total number of bytes allocated by Redis for storing data.
- `used_memory_peak`: Peak memory consumption (in bytes) since Redis server startup.
- `used_memory_lua`: Memory used by the Lua engine for executing scripts.
- `used_memory_rss`: Resident Set Size (RSS) representing the total memory consumed by the Redis server process.
- `mem_fragmentation_ratio`: Ratio of memory allocated by the OS (used_memory_rss) to the memory used by Redis (used_memory).
- `loading`: Flag indicating if the Redis server is currently loading data from disk.
- `rdb_changes_since_last_save`: Number of changes to the dataset since the last RDB (Redis Database) save operation.
- `aof_last_bgrewrite_status`: Status of the last background append-only file (AOF) rewrite operation (success or failure).
- `aof_last_write_status`: Status of the last AOF write operation (success or failure).
- `total_reads_processed`: total number of read operations
- `total_writes_processed`: total number of write operations

## `INFO replication`

- `role`: master or slave replication
- `connected_slaves`: how many slaves are connected to master
- `master-failover_state`

## `INFO CPU`

- `used_cpu_sys`: Total time in seconds the CPU has spent handling system-level operations.
- `used_cpu_user`: Total time in seconds the CPU has spent handling user-level operations.
- `used_cpu_sys_children`: Total time in seconds the CPU has spent handling system-level operations for background processes.
- `used_cpu_user_children`: Total time in seconds the CPU has spent handling user-level operations for background processes.

## `INFO Errorstats`

- `errorstat_ERR:count` refers to the count of errors that have occurred with the specific error code or category identified by ERR.

## `INFO keyspace`

```
127.0.0.1:6379> info keyspace
# Keyspace
db0:keys=3,expires=0,avg_ttl=0

127.0.0.1:6379> select 1
OK
127.0.0.1:6379[1]> set k1 v1
OK
127.0.0.1:6379[1]> info keyspace
# Keyspace
db0:keys=3,expires=0,avg_ttl=0
db1:keys=1,expires=0,avg_ttl=0
```

## `ROLE` command

- Output of `ROLE` command depends on whether redis server is running master, slave or sentinel.

- Master

```
127.0.0.1:6379> role
1) "master"
2) (integer) 12366          ## current master `master_repl_offset`
3) 1) 1) "::1"              ## 1 slave connected
      2) "6380"             ## port 6380
      3) "12366"            ## last acknowledged replication offset
```

- Slave

```
127.0.0.1:6380> role
1) "slave"
2) "localhost"              ## IP address
3) (integer) 6379           ## port number of the master
4) "connected"              ## state of replication, "connected" to master
5) (integer) 12366          ## master replication offset
```

