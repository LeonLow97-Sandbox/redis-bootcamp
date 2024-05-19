# RedisJSON

- [RedisJSON Official Documentation](https://redis.io/docs/latest/develop/data-types/json/)
- JSON data type in Redis
- RedisJSON is a Redis module that implements a JSON data type for Redis
- Allows
  - storing
  - updating
  - fetching JSON values from Redis keys
- Allows us to store and manipulate JSON objects
- Full support of the JSON standard
- Documents are stored as binary data in a tree structure, allowing fast access to sub-elements.
- Atomic operations for all JSON value types
- Fast selection of elements inside documents
- Native JSON data structure in Redis
- Schema free - Each document can contain different elements and structure
- Having our JSON in Redis, we can SET and GET single or multiple properties of JSON objects.

## Why do we need RedisJSON?

- Can already store a JSON object as a serialized object in a String data type.
- To modify a single property in a STRING, need to
  - Pull the entire string
  - Deserialize the string
  - Change the desired property
  - Re-serialize it and store again
  - This is NOT an efficient way...
- RedisJSON allows us to store a JSON object
  - In a single key
  - Regardless of depth or child data types
  - No additional keys or data structure mappings are required
  - Can view or modify JSON object properties/attributes without retrieving the entire object.
  - Fast access
  - Less network bandwidth used

## Setup RedisJSON via Docker

```
## Launch RedisJSON with Docker
docker run -p 6379:6379 --name redis-redisjson redislabs/rejson:latest
```

## SET and GET a JSON object

- `JSON.SET key path 'value'`: to set a JSON value
- `JSON.GET`: to get a JSON value
- `JSON.TYPE key`: to get the TYPE of a JSON key

```
127.0.0.1:6379> json.set foo . '{"foo":"bar"}'
OK

127.0.0.1:6379> json.get foo
"{\"foo\":\"bar\"}"

## to make json.get more readable, access redis-cli with `--raw`
(base) ➜  ~ redis-cli --raw
127.0.0.1:6379> json.get foo
{"foo":"bar"}

## considered as a document object because it is in curly brackets {}
127.0.0.1:6379> json.type foo
object

## get the type of the property in the json, `.` is the path
127.0.0.1:6379> json.type foo .foo
string

## adding new JSON properties into an existing JSON
127.0.0.1:6379> json.set foo .test 1
OK

127.0.0.1:6379> json.get foo
{"foo":"bar","test":1}

127.0.0.1:6379> json.type foo .test
integer
```

```
## Example adding a user
127.0.0.1:6379> json.set user:101 . '{"name":"Leon Low"}'
OK
127.0.0.1:6379> json.get user:101
{"name":"Leon Low"}
127.0.0.1:6379> json.set user:101 .age 27
OK
127.0.0.1:6379> json.get user:101
{"name":"Leon Low","age":27}

127.0.0.1:6379> json.type user:101 .age
integer
```