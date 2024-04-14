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
