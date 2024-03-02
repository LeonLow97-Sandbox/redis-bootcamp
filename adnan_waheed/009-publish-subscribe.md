## Publish/Subscribe Model

- Allows you to create simple message buses - publish and consume
- Allows you to
  - PUBLISH messages to channels
  - SUBSCRIBE to messages from channels
- It is like "fire and forget" messages
- Redis acts as a 'central broker' or **Channel** for multiple clients providing
  - Simple method to post messages
  - and consume messages
- One client publishes to Redis channel and another client subscribes to the same Redis channel.

### Setup Publish/Subscribe Communication

- Start 2 Redis CLI
- Can have multiple subscribers and multiple publishers on the same Redis channel.

```
// Subscriber
127.0.0.1:6379> subscribe ch1
1) "subscribe"
2) "ch1"
3) (integer) 1
1) "message"
2) "ch1"
3) "Hello Leon"
1) "message"
2) "ch1"
3) "How are you today?"

// Publisher
127.0.0.1:6379> publish ch1 "Hello Leon"
(integer) 1
127.0.0.1:6379> publish ch1 "How are you today?"
(integer) 1
```

```
// brew install telnet
// Using telnet
➜  redis-bootcamp git:(main) ✗ telnet
telnet> o localhost 6379
Trying ::1...
Connected to localhost.
Escape character is '^]'.
subscribe ch1
*3
$9
subscribe
$3
ch1
:1
*3
$7
message
$3
ch1
$9
message 2
unsubscribe ch1
*3
$11
unsubscribe
$3
ch1
:0
quit
+OK
Connection closed by foreign host.
```

### Patterned Subscription

- `psubscribe pattern` to subscribe to multiple channels

```
127.0.0.1:6379> publish news:tech "tech1"
(integer) 0
127.0.0.1:6379> publish news:bix "biz1"
(integer) 0
127.0.0.1:6379> publish news:tech "tech2"
(integer) 1
127.0.0.1:6379> publish news:bix "biz2"
(integer) 1
127.0.0.1:6379> publish news:politics "pol1"
(integer) 0
127.0.0.1:6379> publish news:tech "Apple"
(integer) 1
127.0.0.1:6379> publish topnews "top1"
(integer) 0
127.0.0.1:6379> publish topnews "top1"
(integer) 1

127.0.0.1:6379> psubscribe news:*
1) "psubscribe"
2) "news:*"
3) (integer) 1
1) "pmessage"
2) "news:*"
3) "news:tech"
4) "Apple"
127.0.0.1:6379> psubscribe news:* top*
1) "psubscribe"
2) "news:*"
3) (integer) 1
1) "psubscribe"
2) "top*"
3) (integer) 2
1) "pmessage"
2) "top*"
3) "topnews"
4) "top1"
```

### `PUBSUB`

- `PUBSUB CHANNELS [pattern]` to view the **active channels** (must have both subscriber and publisher).

```
127.0.0.1:6379> publish news1 "news1"
(integer) 0
127.0.0.1:6379> publish news2 "news2"
(integer) 0

127.0.0.1:6379> subscribe news1
1) "subscribe"
2) "news1"
3) (integer) 1
127.0.0.1:6379> subscribe news2
1) "subscribe"
2) "news2"
3) (integer) 1

127.0.0.1:6379> pubsub channels *
1) "news2"
2) "news1"
```

- `PUBSUB NUMSUB channel` to view how many subscribers are there in a channel.

```
// 1 active subscription in news1 channel
127.0.0.1:6379> pubsub numsub news1
1) "news1"
2) (integer) 1

// 2 active subscription in news1 channel
127.0.0.1:6379> pubsub numsub news1
1) "news1"
2) (integer) 2
```

### Redis Pub/Sub Unsubscribe Commands

- `UNSUBSCRIBE <Channel Name>` unsubscribe from specific channel
  - E.g., `UNSUBSCRIBE news1`
- `UNSUBSCRIBE` unsubscribes the client from all channels
  - Note: This command can be run without specifying any channel name.
- `PUNSUBSCRIBE <pattern>` unsubscribed based on pattern
  - E.g., `PUNSUBSCRIBE news*`
  - Effect: Unsubscribes the client from channels matching the specified pattern.
  - When no patterns are specified, the client is unsubscribed from all previously subscribed patterns.
  - A message for every unsubscribed pattern will be sent to the client.

### Redis Database Design

- Chat Application
  - What data structure to use? What nomenclature to use?

```
127.0.0.1:6379> smembers users
(empty array)
127.0.0.1:6379> sismember users user1
(integer) 0
127.0.0.1:6379> sadd users user1
(integer) 1
127.0.0.1:6379> sismember users user1
(integer) 1
127.0.0.1:6379> srem users user1
(integer) 1
127.0.0.1:6379> sismember users user1
(integer) 0

// chat room messages
127.0.0.1:6379> rpush msg:room:lobby "user1:testmessage"
(integer) 1
127.0.0.1:6379> rpush msg:room:lobby "user2:testmessage"
(integer) 2
127.0.0.1:6379> lrange msg:room:lobby 0 -1
1) "user1:testmessage"
2) "user2:testmessage"

// direct message
127.0.0.1:6379> rpush msg:direct:user1:user2 "user1: test message"
(integer) 1
127.0.0.1:6379> rpush msg:direct:user2:user1 "user2: test message"
(integer) 1
127.0.0.1:6379> lrange msg:direct:user1:user2 0 -1
1) "user1: test message"
```

```
// creating chat rooms
127.0.0.1:6379> smembers room:lobby
(empty array)
127.0.0.1:6379> smembers room:admin
(empty array)
127.0.0.1:6379> smembers room:special
(empty array)

// what users are there in a particular room?
127.0.0.1:6379> sadd room:lobby user1 user2
(integer) 2
127.0.0.1:6379> smembers room:lobby
1) "user1"
2) "user2"

// when a user enters a chat room
127.0.0.1:6379> subscribe room:lobby
1) "subscribe"
2) "room:lobby"
3) (integer) 1
127.0.0.1:6379> sadd room:lobby user1
(integer) 0

// when a user leaves a chat room
127.0.0.1:6379> unsubscribe room:lobby
1) "unsubscribe"
2) "room:lobby"
3) (integer) 0
127.0.0.1:6379> srem room:lobby user1
(integer) 1
```
