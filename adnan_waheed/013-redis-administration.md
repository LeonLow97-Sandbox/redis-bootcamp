# Redis Administration

- [Object Encoding](https://redis.io/commands/object-encoding/)
- [Redis Keys: Object](https://www.w3resource.com/redis/redis-object-key.php#:~:text=OBJECT%20subcommand%20%5Barguments%20%5Barguments%20.,data%20types%20to%20save%20space.)

## `OBJECT` command

- The Redis `OBJECT` command is used to **inspect the internals of Redis Objects associated with keys**.
- It is useful for debugging or to understand if your keys are using the specially encoded data types to save space.

## `OBJECT` sub commands

- The `OBJECT` command supports multiple sub commands.
- `OBJECT REFCOUNT <key>` returns the number of references of the value associated with the specified key. This command is mainly useful for debugging.
- `OBJECT ENCODING <key>` returns the kind of internal representation used in order to store the value associated with a key.
- `OBJECT IDLETIME <key>` returns the number of seconds since the object stored at the specified key is idle (not requested by read or write operations). While the value is returned in seconds, the actual resolution of this timer is 10 seconds, but may vary in future implementations. See how long the key has been unused

```
127.0.0.1:6379> set hello 1
OK
127.0.0.1:6379> set hello1 "Test"
OK
127.0.0.1:6379> object refcount hello
(integer) 2147483647
127.0.0.1:6379> object refcount hello1
(integer) 1

127.0.0.1:6379> object encoding hello
"int"
127.0.0.1:6379> object encoding hello1
"embstr"

127.0.0.1:6379> object idletime hello
(integer) 1469
127.0.0.1:6379> object idletime hello
(integer) 1472
127.0.0.1:6379> object idletime hello
(integer) 1477

// with a list
127.0.0.1:6379> lpush fruits "banana"
(integer) 1
127.0.0.1:6379> object refcount fruits
(integer) 1
127.0.0.1:6379> object encoding fruits
"listpack"
127.0.0.1:6379> object idletime fruits
(integer) 18
```

## Dump and Restore Keys

- `dump key` shows the data is stored in a **serialized** format in Redis (rdb).
- `restore` command has to be the same Redis version. If you create a dump for Redis version 6.0.0 and you try to restore in Redis version 6.2.4, it will not work! Use `info` to find out Redis version.

```
127.0.0.1:6379> set name "Joe"
OK
127.0.0.1:6379> get name
"Joe"
127.0.0.1:6379> dump name
"\x00\x03Joe\x0b\x00\xb5\x8e\xe4\xd9\xffX\x14\xa1"
127.0.0.1:6379> restore name 0 "\x00\x03Joe\x0b\x00\xb5\x8e\xe4\xd9\xffX\x14\xa1"
(error) BUSYKEY Target key name already exists.
127.0.0.1:6379> del name
(integer) 1
127.0.0.1:6379> get name
(nil)
127.0.0.1:6379> restore name 0 "\x00\x03Joe\x0b\x00\xb5\x8e\xe4\xd9\xffX\x14\xa1"
OK
127.0.0.1:6379> get name
"Joe"

// override existing key
127.0.0.1:6379> get name
"darrel"
127.0.0.1:6379> set name2 leon
OK
127.0.0.1:6379> dump name2
"\x00\x04leon\x0b\x00e\x18\x17\xaaMV-\xf0"
127.0.0.1:6379> restore name 0 "\x00\x04leon\x0b\x00e\x18\x17\xaaMV-\xf0" replace
OK
127.0.0.1:6379> get name
"leon"
```

## Checking Command History

- View command history in Redis server
- Command history is stored in `.rediscli_history` file in Users directory.

```
➜  ~ tail -10 .rediscli_history
flushdb
set name darrel
get name
set name2 leon
dump name2
restore name 0 "\x00\x04leon\x0b\x00e\x18\x17\xaaMV-\xf0" replace
get name
info
flushdb
exit
```

## Using `redis-cli` to scan keys

- Use `redis-cli -h` to get all the commands.
- Can get all keys and also use pattern for the keys.
- Can pipe the output to a file, e.g., `.csv` file.

```
➜  ~ redis-cli --scan
"name3"
"name4"
"friend1"
"name2"
"friend2"
"name1"

➜  ~ redis-cli --scan --pattern "*"
"name3"
"name4"
"friend1"
"name2"
"friend2"
"name1"
➜  ~ redis-cli --scan --pattern "*name*"
"name3"
"name4"
"name2"
"name1"

➜  ~ redis-cli --scan --pattern "*name*" > names.csv
➜  ~ cat names.csv
name3
name4
name2
name1
```

## Using "bash" to get all keys and values

- Performance wise, reading a huge dataset might be slow as it runs `redis-cli get` line by line of the entire file. If small dataset, this method is fine.

```
➜  ~ redis-cli --scan
"name3"
"key3"
"name2"
"key2"
"name1"
"key1"
➜  ~ redis-cli get name1
"1"
➜  ~ redis-cli get name2
"2"
➜  ~ vi readkeys.sh

// enable ownership of the bash file
➜  ~ chmod 755 readkeys.sh
➜  ~ ./readkeys.sh
"name3"
"key3"
"name2"
"key2"
"name1"
"key1"
```

```
➜  ~ cat readkeys.sh
#!/bin/bash
redis-cli --scan > all.keys

while read -r key
do
  value=$(redis-cli get "$key")
  echo $key '|' $value
done < all.keys
➜  ~ ./readkeys.sh
name3 | 3
key3 | 3
name2 | 2
key2 | 2
name1 | 1
key1 | 1
```

## Using URL, echo to list all keys

- redis-cli does not support TLS protocol

```
➜  ~ URL=redis://localhost:6379 
➜  ~ echo "KEYS *" | \         
pipe> redis-cli -u $URL | \
pipe pipe> sed 's/^/GET /' | \
pipe pipe pipe> redis-cli -u $URL 
"3"
"3"
"1"
"1"
"2"
"2"
```