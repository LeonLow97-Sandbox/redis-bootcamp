# Redis Cluster (ChatGPT)

A Redis Cluster is a distributed implementation of Redis that allows you to automatically partition your data across multiple Redis nodes (instances) for scalability, performance and high availability.

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
  - E.g., 3 Masters - M1, M2, M3. M1 will handle hash slots from 0 to 5500, M2 from 5501 to 11000 and M3 from 11001 to 16383. If M4 is added, just shift hash slots from M1, M2, M3 to M4.
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

