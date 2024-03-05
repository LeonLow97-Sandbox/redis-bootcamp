# Redis Protocol

- Redis clients communicate with the Redis server using a protocol called **RESP** (Redis Serialization Protocol). Data stored in Redis is all serialized.
- Simple to implement
- Fast to parse
- Human readable
- RESP can serialize different data types like
  - integers
  - strings
  - arrays
- RESP is binary-safe
- In RESP, the type of some of the data depends on _first byte_
  - For simple strings, the first byte of the reply is "+"
  - For errors, the first byte of the reply is "-"
  - For integers, the first byte of the reply is ":"
  - For bulk strings, the first byte of the reply is "$"
  - For Arrays, the first byte of the reply is "\*"
- Redis generally uses RESP as a request-response protocol in the following way: Clients send commands to a Redis server as an array of bulk strings. The first (and sometimes also the second) bulk string in the array is the command's name. Subsequent elements of the array are the arguments for the command.
- Docs: `https://redis.io/docs/reference/protocol-spec/#:~:text=Redis%20generally%20uses%20RESP%20as,the%20arguments%20for%20the%20command.`

## Use Cases for RESP Redis Protocol

- RESP is used by Redis client libraries for command communication.
- RESP ensures consistent communication between clients and servers.
- RESP enables efficient messaging between distributed systems.
- RESP facilitates Redis integration with diverse technologies.
- RESP ensures data consistency in Redis persistence and replication.

## Request - Response Model

- **Redis Client** sends commands to Redis Server as a RESP Array of Bulk strings
  - `set name Redis`
- **Redis Server** replies with one of the RESP types according to the command implementation
  - `OK`

## Generating Redis Protocol

- Very simple to generate
- To generate Redis Protocol, start with `*<args><cr><lf>`
  - <cr> \r
  - <lf> \n
- length of string, `$<len><cr><lf>`
- argument, `<arg1><cr><lf> ... <argN><cr><lf>`

- `*3` arguments: SET name Redis
- `$3` 3 characters in SET
- `SET`
- `$4` 4 characters in name
- `name`
- `$5` 5 characters in Redis
- `Redis`

```
*3<cr><lf>
$3<cr><lf>
SET<cr><lf>
$4<cr><lf>
name<cr><lf>
$5<cr><lf>
Redis<cr><lf>
```

- Can also define Redis Protocol in **quoted string**

```
// SET name Redis
*3 \r\n $3 \r\n SET \r\n $4 \r\n name \r\n $5 \r\n Redis \r\n
```

## Generating Redis commands using Python

- Code is found in `adnan_waheed/resp-protocol/block_ips.py`

```
// passing output of RESP from python script and pass to redis cli
➜  resp-protocol git:(main) ✗ python3 block_ips.py | redis-cli --pipe
All data transferred. Waiting for the last reply...
Last reply received from server.
errors: 0, replies: 4

127.0.0.1:6379> keys *
1) "10.10.10.4"
2) "10.10.10.3"
3) "10.10.10.2"
4) "10.10.10.1"

127.0.0.1:6379> get 10.10.10.1
"1"
127.0.0.1:6379> get 10.10.10.2
"1"
127.0.0.1:6379> get 10.10.10.3
"1"
127.0.0.1:6379> get 10.10.10.4
"1"
```
