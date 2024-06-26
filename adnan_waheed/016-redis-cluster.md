# Redis Cluster (ChatGPT)

> A Redis Cluster is a distributed implementation of Redis that allows you to automatically partition your data across multiple Redis nodes (instances) for scalability, performance and high availability.

1. **Distributed Architecture**: Redis Cluster uses a distributed architecture where data is sharded (partitioned) across multiple Redis nodes. This allows you to horizontally scale Redis beyond the capacity of a single node.
2. **Data Sharding**: Redis Cluster automatically partitions data into slots (ranges of hash space) across multiple nodes. Each node in the cluster is responsible for handling a subset of these slots.
3. **Master-Slave Replication**: Within each Redis Cluster, data replication is employed for fault tolerance. Each data slot is replicated across multiple nodes - typically with one node being the master and other being slaves. This ensures data availability even if some nodes fail.
4. **Automatic Failover**: Redis Cluster supports automatic failover. If a master node fails, a slave node is promoted to master and takes over its slows. Clients are redirected to the new master node seamlessly.
5. **High Availability**: Redis Cluster is designed for high availability. It can tolerate failures of multiple nodes while still ensuring that a majority of nodes are available for writes and reads.
6. **Built-In Redis Commands**: Redis Cluster supports a subset of Redis commands along with additional commands specific to cluster operations. These commands allow you to interact with and manage the cluster seamlessly.
7. **Consistency and Partitioning**: Redis Cluster uses hash-based partitioning to distribute keys across nodes. It maintains consistency and availability by ensuring that each key is mapped to a specific slot and is served by the appropriate node.
8. **Scaling**: Redis Cluster enables horizontal scaling by adding or removing nodes dynamically. This allows you to increase capacity and throughput as your application demands grow.
9. **Configuration and Setup**: Setting up a Redis Cluster involves configuring multiple Redis instances to form a cluster. Redis provides tools and guidelines for setting up and managing cluster effectively.
10. **Use Cases**: Redis Cluster is well-suited for applications requiring high performance, scalability, and fault-tolerance, such as real-time analytics, caching, session management, and message queues.

## Redis Cluster

- Data storage on more than 1 Redis Instance
- Solution: Cluster = Multiple Redis Shards
- Redis Cluster = Hosting multiple master shards. However, not all nodes need to be masters; some will primarily serve as slaves.
- Data is automatically sharded across multiple Redis Nodes. Redis Cluster uses hash-based partitioning to shard data across multiple nodes automatically.
- Automatically splits datasets among multiple nodes.
- Continue operations when a subset of the nodes are experiencing failures. When the master node fails, the slave node becomes the master. Redis Cluster supports high availability by automatically failing over to replicas (slaves) when masters fail.
- Some degree of availability during partitions.
- Redis cluster can have multiple masters availability.
  - Data is group into 16KB buckets on masters
  - Scalability of 1000 nodes
  - Allow multiple masters
- In case of a master failure
  - E.g., M1 - S1, M1 goes down, S1 will be promoted to Master node to M1 automatically.
- What happened if the majority of Master fails?
  - Cluster stops operating

## Redis Cluster Data Sharding

- Goals
  - High performance and linear scalability up to 1000 nodes.
  - Acceptable degree of write safety. Only can write to Master node.
  - Availability
- Data Sharding in Redis Cluster
  - Data sharding is based on key-hash tags.
  - Each master node in a cluster handles a subset of the 16384 hash slots.
  - Every node in a Redis Cluster is responsible for a subset of the hash slots.
  - E.g., 3 Masters - M1, M2, M3. M1 will handle hash slots from 0 to 5460, M2 from 5461 to 10922 and M3 from 10923 to 16383. If M4 is added, just shift hash slots from M1, M2, M3 to M4.
  - When adding or removing nodes from the cluster, Redis dynamically redistributes the hash slots among the available nodes to maintain balanced data distribution. This redistribution ensures that each node continues to handle a proportionate share of the data.
- Redis cluster does not support 'multiple databases'
  - Redis Cluster does not support multiple databases like traditional standalone Redis instances.
  - It only supports Database 0 (the default database). Attempting to switch databases (e.g., using `SELECT 1`) will not work in Redis Cluster.

## Setup and Configuration of 6 nodes Redis Cluster

- `ps -ef | grep redis` to check what Redis server instances are running
- Create a configuration file for creating a Node in a Redis cluster, need 6 `.conf` files.
  - 6 Ports to be created: 7001, 7002, 7003, 7004, 7005, 7006

```conf
port 7001
cluster-enabled yes
cluster-config-file nodes.conf
cluster-node-timeout 5000
appendonly yes
```

```
(base) ➜  cluster git:(main) ✗ mkdir 7001 7002 7003 7004 7005 7006
(base) ➜  cluster git:(main) ✗ ls
7001          7003          7005          n1_redis.conf n3_redis.conf n5_redis.conf
7002          7004          7006          n2_redis.conf n4_redis.conf n6_redis.conf
(base) ➜  cluster git:(main) ✗ mv n1_redis.conf 7001
(base) ➜  cluster git:(main) ✗ mv n2_redis.conf 7002
(base) ➜  cluster git:(main) ✗ mv n3_redis.conf 7003
(base) ➜  cluster git:(main) ✗ mv n4_redis.conf 7004
(base) ➜  cluster git:(main) ✗ mv n5_redis.conf 7005
(base) ➜  cluster git:(main) ✗ mv n6_redis.conf 7006
(base) ➜  cluster git:(main) ✗ ls
7001 7002 7003 7004 7005 7006
```

- Run the following command to launch Redis server with port 7001
  - `(base) ➜  7001 git:(main) ✗ redis-server n1_redis.conf &` added `&` so you can hit enter and exit the CLI to run this Redis server in the background
  - Observer below that Redis server is running in cluster mode

````
                _._
           _.-``__ ''-._
      _.-``    `.  `_.  ''-._           Redis 7.2.2 (00000000/0) 64 bit
  .-`` .-```.  ```\/    _.,_ ''-._
 (    '      ,       .-`  | `,    )     Running in cluster mode
 |`-._`-...-` __...-.``-._|'` _.-'|     Port: 7001
 |    `-._   `._    /     _.-'    |     PID: 84880
  `-._    `-._  `-./  _.-'    _.-'
 |`-._`-._    `-.__.-'    _.-'_.-'|
 |    `-._`-._        _.-'_.-'    |           https://redis.io
  `-._    `-._`-.__.-'_.-'    _.-'
 |`-._`-._    `-.__.-'    _.-'_.-'|
 |    `-._`-._        _.-'_.-'    |
  `-._    `-._`-.__.-'_.-'    _.-'
      `-._    `-.__.-'    _.-'
          `-._        _.-'
              `-.__.-'
````

```
(base) ➜  7001 git:(main) ✗ ps -ef | grep redis
  501 84880 86024   0  6:00PM ttys017    0:00.10 redis-server *:7001 [cluster]
```

- Repeat for other nodes in the cluster running on ports 7002, 7003, 7004, 7005, 7006

```
(base) ➜  7006 git:(main) ✗ ps -ef | grep redis
  501 84880 86024   0  6:00PM ttys017    0:00.36 redis-server *:7001 [cluster]
  501 86346 86024   0  6:02PM ttys017    0:00.16 redis-server *:7002 [cluster]
  501 87133 86024   0  6:03PM ttys017    0:00.06 redis-server *:7003 [cluster]
  501 87291 86024   0  6:03PM ttys017    0:00.05 redis-server *:7004 [cluster]
  501 87471 86024   0  6:03PM ttys017    0:00.03 redis-server *:7005 [cluster]
  501 87625 86024   0  6:04PM ttys017    0:00.02 redis-server *:7006 [cluster]
```

## Launch a Redis Cluster with Nodes

- Creating a Redis Cluster with the 6 nodes
  - `redis-cli --cluster create 127.0.0.1:7001 127.0.0.1:7002 127.0.0.1:7003 127.0.0.1:7004 127.0.0.1:7005 127.0.0.1:7006 --cluster-replicas 1`

```
>>> Performing hash slots allocation on 6 nodes...
Master[0] -> Slots 0 - 5460
Master[1] -> Slots 5461 - 10922
Master[2] -> Slots 10923 - 16383
Adding replica 127.0.0.1:7005 to 127.0.0.1:7001
Adding replica 127.0.0.1:7006 to 127.0.0.1:7002
Adding replica 127.0.0.1:7004 to 127.0.0.1:7003
>>> Trying to optimize slaves allocation for anti-affinity
[WARNING] Some slaves are in the same host as their master
M: e4a6c6746bb0a6c915c92c9929d23dab2d32e795 127.0.0.1:7001
   slots:[0-5460] (5461 slots) master
M: f5e5114ce8f0395f3e6e099ceea13ffc1302785a 127.0.0.1:7002
   slots:[5461-10922] (5462 slots) master
M: dc0757f4f08f9e5d40c6288a81979b1939b2275d 127.0.0.1:7003
   slots:[10923-16383] (5461 slots) master
S: 2f5d26afeac4300f0986930c54ce261b8a572acf 127.0.0.1:7004
   replicates e4a6c6746bb0a6c915c92c9929d23dab2d32e795
S: 30fd0eca4f5d2117b40ad28309826c5552aefdff 127.0.0.1:7005
   replicates f5e5114ce8f0395f3e6e099ceea13ffc1302785a
S: 6c57151ea9e9054f0a2f0c400aa8046f8fef0c2e 127.0.0.1:7006
   replicates dc0757f4f08f9e5d40c6288a81979b1939b2275d
Can I set the above configuration? (type 'yes' to accept):
```

- Master nodes: 7001, 7002, 703
- Connecting to Master Node with port 7001 in the Redis Cluster
  - `redis-cli -c -p 7001`, the `-c` flag is to operate in Redis Cluster mode.

```
(base) ➜  cluster git:(main) ✗ redis-cli -c -p 7001
127.0.0.1:7001> info cluster
# Cluster
cluster_enabled:1

127.0.0.1:7001> info replication
# Replication
role:master
connected_slaves:1
slave0:ip=127.0.0.1,port=7004,state=online,offset=252,lag=0
master_failover_state:no-failover
master_replid:313c9bae9c371900421653c15fe31541ce16f999
master_replid2:0000000000000000000000000000000000000000
master_repl_offset:252
second_repl_offset:-1
repl_backlog_active:1
repl_backlog_size:1048576
repl_backlog_first_byte_offset:1
repl_backlog_histlen:252
```

- Connecting to Slave node

```
(base) ➜  cluster git:(main) ✗ redis-cli -c -p 7004

127.0.0.1:7004> info cluster
# Cluster
cluster_enabled:1

127.0.0.1:7004> info replication
# Replication
role:slave
master_host:127.0.0.1
master_port:7001
master_link_status:up
master_last_io_seconds_ago:5
master_sync_in_progress:0
slave_read_repl_offset:420
slave_repl_offset:420
slave_priority:100
slave_read_only:1
replica_announced:1
connected_slaves:0
master_failover_state:no-failover
master_replid:313c9bae9c371900421653c15fe31541ce16f999
master_replid2:0000000000000000000000000000000000000000
master_repl_offset:420
second_repl_offset:-1
repl_backlog_active:1
repl_backlog_size:1048576
repl_backlog_first_byte_offset:1
repl_backlog_histlen:420

## Running ROLE command
127.0.0.1:7004> role
1) "slave"
2) "127.0.0.1"
3) (integer) 7001
4) "connected"
5) (integer) 462
```

- Setting a key-value in Master Node 7001
- Notice that the data is redirected to Master Node 7003, Redis uses the CRC16 to calculate the hash for determining hash slots and decide where to store the key-value pair based on the key provided.
- Master Node (`127.0.0.1:7003`) owns the hash slot (`12706`) where the key (`k1`) is supposed to be stored according to the hash calculation.

```
(base) ➜  cluster git:(main) ✗ redis-cli -c -p 7001
127.0.0.1:7001> set k1 v1
-> Redirected to slot [12706] located at 127.0.0.1:7003
OK
127.0.0.1:7003> set name Redis
-> Redirected to slot [5798] located at 127.0.0.1:7002
OK
127.0.0.1:7002> keys *
1) "name"
```

- Key `name` is stored on Master Node 7002, if you try to `get name` in Master Node 7001, it will automatically redirect to 7002

```
127.0.0.1:7001> keys *
(empty array)
127.0.0.1:7001> get name
-> Redirected to slot [5798] located at 127.0.0.1:7002
"Redis"
127.0.0.1:7002>
```

- Checking if Master Node 7002 keys are stored in Slave Node 7005

```
127.0.0.1:7002> keys *
1) "name"
2) "1"
127.0.0.1:7002> ROLE
1) "master"
2) (integer) 1238
3) 1) 1) "127.0.0.1"
      2) "7005"
      3) "1238"
127.0.0.1:7002> quit

(base) ➜  cluster git:(main) ✗ redis-cli -c -p 7005
127.0.0.1:7005> keys *
1) "1"
2) "name"
```

- If you try to create a key-value in a Slave node, it automatically redirects to a slot in the master node. Very intelligent Redis Cluster.

```
127.0.0.1:7005> set k2 v2
-> Redirected to slot [449] located at 127.0.0.1:7001
OK
127.0.0.1:7001>
```

## Cluster Commands - Check Nodes, Slaves, Slots

- `redis-cli --cluster check 127.0.0.1:7001`: used to check the health and configuration of a Redis Cluster node
- `redis-cli -p 7001 cluster nodes`: used to list information about all nodes in a Redis Cluster running on a specific port (7001 in this case), including their roles and hash slot assignments. It also returns the **Node ID**.

## High Availability in Redis Cluster

- If one of our Master nodes has issues, then there will be a failover, a Slave node will be promoted to a Master node.

```
## shutdown one of our Master Slaves running on port 7001
127.0.0.1:7001> info replication
# Replication
role:master
connected_slaves:1
slave0:ip=127.0.0.1,port=7004,state=online,offset=10384,lag=1
master_failover_state:no-failover
master_replid:313c9bae9c371900421653c15fe31541ce16f999
master_replid2:0000000000000000000000000000000000000000
master_repl_offset:10384
second_repl_offset:-1
repl_backlog_active:1
repl_backlog_size:1048576
repl_backlog_first_byte_offset:1
repl_backlog_histlen:10384

127.0.0.1:7001> shutdown

## 7001 is gone
(base) ➜  cluster git:(main) ✗ ps -ef | grep redis
  501 72168 86024   0  8:57PM ttys017    0:00.00 grep --color=auto --exclude-dir=.bzr --exclude-dir=CVS --exclude-dir=.git --exclude-dir=.hg --exclude-dir=.svn --exclude-dir=.idea --exclude-dir=.tox redis
  501 86346 86024   0  6:02PM ttys017    0:11.82 redis-server *:7002 [cluster]
  501 87133 86024   0  6:03PM ttys017    0:12.27 redis-server *:7003 [cluster]
  501 87291 86024   0  6:03PM ttys017    0:11.64 redis-server *:7004 [cluster]
  501 87471 86024   0  6:03PM ttys017    0:11.84 redis-server *:7005 [cluster]
  501 87625 86024   0  6:04PM ttys017    0:11.62 redis-server *:7006 [cluster]

## 7004 which was a slave was promoted to a Master node
(base) ➜  cluster git:(main) ✗ redis-cli -c -p 7004

127.0.0.1:7004> info replication
# Replication
role:master
connected_slaves:0
master_failover_state:no-failover
master_replid:523e9f6d59226a3384eb9a38a65204642634c3ab
master_replid2:313c9bae9c371900421653c15fe31541ce16f999
master_repl_offset:10384
second_repl_offset:10385
repl_backlog_active:1
repl_backlog_size:1048576
repl_backlog_first_byte_offset:1
repl_backlog_histlen:10384
```

- Thus, if a Master node goes down, a slave node will be promoted to become a master node. This is a failover scenario which means that Redis Cluster provides high availability.

## Adding a Node to a Redis Cluster

- Adding back our node with port 7001 to the Redis Cluster. Although it was introduced as a Master Node, our Redis Cluster automatically changes it to a Slave Node and connect it with Master Node 7004
  - `redis-server n1_redis.conf &`
  - Automatically, Redis Cluster has assigned the Master Node (port 7004) to connect to Slave Node (port 7001)
  ```
  73693:S 20 Apr 2024 20:59:55.046 * Connecting to MASTER 127.0.0.1:7004
  73693:S 20 Apr 2024 20:59:55.046 * MASTER <-> REPLICA sync started
  ```

```
127.0.0.1:7001> info replication
# Replication
role:slave
master_host:127.0.0.1
master_port:7004

127.0.0.1:7004> info replication
# Replication
role:master
connected_slaves:1
```

## What happens when a slave is shutdown?

- Nothing will happen in the Redis Cluster, Master slaves and Redis Cluster will still stay the same.
- Shutdown Slave Node (port 7006)

```
(base) ➜  cluster git:(main) ✗ redis-cli -c -p 7006
127.0.0.1:7006> role
1) "slave"
2) "127.0.0.1"
3) (integer) 7003
4) "connected"
5) (integer) 11228
127.0.0.1:7006> shutdown

## Slave Node (port 7006) is indeed shutdown
(base) ➜  cluster git:(main) ✗ ps -ef | grep redis
  501 73693 86024   0  8:59PM ttys017    0:00.64 redis-server *:7001 [cluster]
  501 77909 86024   0  9:06PM ttys017    0:00.00 grep --color=auto --exclude-dir=.bzr --exclude-dir=CVS --exclude-dir=.git --exclude-dir=.hg --exclude-dir=.svn --exclude-dir=.idea --exclude-dir=.tox redis
  501 86346 86024   0  6:02PM ttys017    0:12.86 redis-server *:7002 [cluster]
  501 87133 86024   0  6:03PM ttys017    0:13.31 redis-server *:7003 [cluster]
  501 87291 86024   0  6:03PM ttys017    0:12.70 redis-server *:7004 [cluster]
  501 87471 86024   0  6:03PM ttys017    0:12.89 redis-server *:7005 [cluster]
```

## Using CLUSTER NODES, CLUSTER SLOTS commands

- `cluster slots` also returns the node ID in each hash slot.

```
127.0.0.1:7002> cluster slots
1) 1) (integer) 0
   2) (integer) 5460
   3) 1) "127.0.0.1"
      2) (integer) 7004
      3) "2f5d26afeac4300f0986930c54ce261b8a572acf"
      4) (empty array)
   4) 1) "127.0.0.1"
      2) (integer) 7001
      3) "e4a6c6746bb0a6c915c92c9929d23dab2d32e795"
      4) (empty array)
2) 1) (integer) 5461
   2) (integer) 10922
   3) 1) "127.0.0.1"
      2) (integer) 7002
      3) "f5e5114ce8f0395f3e6e099ceea13ffc1302785a"
      4) (empty array)
   4) 1) "127.0.0.1"
      2) (integer) 7005
      3) "30fd0eca4f5d2117b40ad28309826c5552aefdff"
      4) (empty array)
3) 1) (integer) 10923
   2) (integer) 16383
   3) 1) "127.0.0.1"
      2) (integer) 7003
      3) "dc0757f4f08f9e5d40c6288a81979b1939b2275d"
      4) (empty array)
```

- `cluster nodes`

## Using CLUSTER INFO, MYID and REPLICAS commands

- `cluster help` to get all the commands
- `cluster info` give a short summary of the Redis Cluster.
- `cluster myid` getting the Node ID of the node
- `cluster replicas [node_id]`

```
127.0.0.1:7002> cluster myid
"f5e5114ce8f0395f3e6e099ceea13ffc1302785a"
127.0.0.1:7002> cluster replicas f5e5114ce8f0395f3e6e099ceea13ffc1302785a
1) "30fd0eca4f5d2117b40ad28309826c5552aefdff 127.0.0.1:7005@17005 slave f5e5114ce8f0395f3e6e099ceea13ffc1302785a 0 1713619164056 2 connected"
```

## Find a hash slot number of keys and keys in slots

- `cluster slots`
- `cluster keyslot [key]` returns the hash slot where the key-value is stored.

```
127.0.0.1:7004> cluster keyslot k2
(integer) 449
127.0.0.1:7004> cluster keyslot name
(integer) 5798
```

- Getting the hash slot for a key that does not exist in Redis Cluster

```
## key `name1` does not exist in Redis Cluster
127.0.0.1:7004> cluster keyslot name1
(integer) 12933

127.0.0.1:7004> set name1 Darrel
-> Redirected to slot [12933] located at 127.0.0.1:7003
OK

## 12933 means it will be set to Node with port 7003
127.0.0.1:7003> keys *
1) "name1"
2) "foo"
3) "k1"
127.0.0.1:7003> get name1
"Darrel"
```

- `getkeysinslot` returns the key when provided the key hash

```
127.0.0.1:7003> keys *
1) "name1"
2) "foo"
3) "k1"
127.0.0.1:7003> cluster keyslot name1
(integer) 12933
127.0.0.1:7003> cluster getkeysinslot 12933 1
1) "name1"
```

## Shutdown a Cluster

> Shutdown Slave Node, followed by Master Node.

- Find the Slaves Nodes with `cluster nodes` command

```
127.0.0.1:7001> cluster nodes
30fd0eca4f5d2117b40ad28309826c5552aefdff 127.0.0.1:7005@17005 slave f5e5114ce8f0395f3e6e099ceea13ffc1302785a 0 1713619710517 2 connected
e4a6c6746bb0a6c915c92c9929d23dab2d32e795 127.0.0.1:7001@17001 myself,slave 2f5d26afeac4300f0986930c54ce261b8a572acf 0 1713619709000 7 connected
f5e5114ce8f0395f3e6e099ceea13ffc1302785a 127.0.0.1:7002@17002 master - 0 1713619709000 2 connected 5461-10922
dc0757f4f08f9e5d40c6288a81979b1939b2275d 127.0.0.1:7003@17003 master - 0 1713619709000 3 connected 10923-16383
6c57151ea9e9054f0a2f0c400aa8046f8fef0c2e 127.0.0.1:7006@17006 slave,fail dc0757f4f08f9e5d40c6288a81979b1939b2275d 1713618337097 1713618334558 3 disconnected
2f5d26afeac4300f0986930c54ce261b8a572acf 127.0.0.1:7004@17004 master - 0 1713619709504 7 connected 0-5460
```

- Nodes with ports 7005, 7001 and 7006 are Slave Nodes.
    - `redis-cli -p 7001 shutdown`

```
(base) ➜  cluster git:(main) ✗ ps -ef | grep redis
  501 87291 86024   0  6:03PM ttys017    0:17.37 redis-server *:7004 [cluster]
  501 87471 86024   0  6:03PM ttys017    0:17.46 redis-server *:7005 [cluster]
  501 93904 86024   0  9:30PM ttys017    0:00.00 grep --color=auto --exclude-dir=.bzr --exclude-dir=CVS --exclude-dir=.git --exclude-dir=.hg --exclude-dir=.svn --exclude-dir=.idea --exclude-dir=.tox redis
```