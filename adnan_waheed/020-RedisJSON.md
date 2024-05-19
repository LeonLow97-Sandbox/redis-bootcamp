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

## RedisJSON `STRLEN` and `STRAPPEND`

- `JSON.STRLEN key`: get the string length of a JSON key
- `JSON.STRAPPEND key path 'value'`: append string to a json value

```
127.0.0.1:6379> json.get user:101
{"name":"Leon Low","age":27}
127.0.0.1:6379> json.get user:101 .name
"Leon Low"
127.0.0.1:6379> json.strlen user:101 .name
8

## doesnt work on values that are integer
127.0.0.1:6379> json.strlen user:101 .age
WRONGTYPE wrong type of path value - expected string but found integer
```

```
127.0.0.1:6379> json.set name . '"Leon"'
OK
127.0.0.1:6379> json.get name
"Leon"
127.0.0.1:6379> json.strlen name
4
127.0.0.1:6379> json.strappend name '" Low"'
9
127.0.0.1:6379> json.get name
"Leon Low"
```

## RedisJSON `OBJLEN` and `OBJKEYS`

- `JSON.OBJLEN key`: object length
- `JSON.OBJKEYS key`: object keys

```
127.0.0.1:6379> json.get user:101
{"name":"Leon Low","age":27}
127.0.0.1:6379> json.objlen user:101
2

127.0.0.1:6379> json.objkeys user:101
name
age
```

## RedisJSON `NUMINCRBY` and `NUMMULTBY`

- `JSON.NUMINCRBY key path value`: increment by
- `JSON.NUMMULTBY key path value`: multiply by

```
127.0.0.1:6379> json.get user:101
{"name":"Leon Low","age":27}
127.0.0.1:6379> json.numincrby user:101 .age 50
77
127.0.0.1:6379> json.get user:101
{"name":"Leon Low","age":77}

127.0.0.1:6379> json.nummultby user:101 .age 2
154
127.0.0.1:6379> json.get user:101
{"name":"Leon Low","age":154}

## subtracting
127.0.0.1:6379> json.numincrby user:101 .age -100
54
127.0.0.1:6379> json.get user:101
{"name":"Leon Low","age":54}
```

## Delete a JSON object

- `JSON.DEL key path`: delete a JSON object

```
127.0.0.1:6379> json.set k1 . '"1"'
OK
127.0.0.1:6379> json.get k1
"1"
127.0.0.1:6379> json.del k1
1
127.0.0.1:6379> keys k1

127.0.0.1:6379> json.get k1

```

```
127.0.0.1:6379> json.set user:2 . '[true, {"name":"John"},null]'
OK
127.0.0.1:6379> json.get user:2
[true,{"name":"John"},null]
127.0.0.1:6379> json.type user:2
array
127.0.0.1:6379> json.get user:2 [1]
{"name":"John"}
127.0.0.1:6379> json.get user:2 [1].name
"John"
127.0.0.1:6379> json.get user:2 [0]
true
127.0.0.1:6379> json.get user:2 [2]
null

## delete individual elements in array
127.0.0.1:6379> json.del user:2 [-1]
1
127.0.0.1:6379> json.get user:2
[true,{"name":"John"}]

127.0.0.1:6379> json.del user:2 [0]
1
127.0.0.1:6379> json.get user:2
[{"name":"John"}]

127.0.0.1:6379> json.del user:2
1
127.0.0.1:6379> keys user:2
```

## Memory usage for JSON object

- `JSON.DEBUG MEMORY key`: the RedisJSON data type uses at least 24 bytes (on 64-bit architecture) for every value.

```
127.0.0.1:6379> json.get user:101
{"name":"Leon Low","age":54}

## get number of bytes used for JSON object
127.0.0.1:6379> json.debug memory user:101
151

## empty string
127.0.0.1:6379> json.set emptystr . '""'
OK
127.0.0.1:6379> json.debug memory emptystr
8

## empty array
127.0.0.1:6379> json.set arr . '[]'
OK
127.0.0.1:6379> json.debug memory arr
8

## empty object
127.0.0.1:6379> json.set obj . '{}'
OK
127.0.0.1:6379> json.debug memory obj
8

## an array with a single scary increased memory
127.0.0.1:6379> json.set arr . '[""]'
OK
127.0.0.1:6379> json.debug memory arr
64

127.0.0.1:6379> json.set arr . '["","",""]'
OK
127.0.0.1:6379> json.debug memory arr
80
```

## Design a Food Truck System via RedisJSON

```
## setup a food moving truck called "truck:1" with name "Amazing Delights"
127.0.0.1:6379> json.set truck:1 . '{"name":"Amazing Delights"}'
OK
127.0.0.1:6379> json.get truck:1
{"name":"Amazing Delights"}

## lets add an indicator that our truck is open for orders
127.0.0.1:6379> json.set truck:1 .is_open 'true'
OK
127.0.0.1:6379> json.get truck:1
{"name":"Amazing Delights","is_open":true}

## lets setup a wait time for 10 minutes
127.0.0.1:6379> json.set truck:1 .wait_time 10
OK
127.0.0.1:6379> json.get truck:1
{"name":"Amazing Delights","is_open":true,"wait_time":10}

## lets add current location
127.0.0.1:6379> json.set truck:1 .location '"123 Choa Chu Kang"'
OK
127.0.0.1:6379> json.get truck:1
{"name":"Amazing Delights","is_open":true,"wait_time":10,"location":"123 Choa Chu Kang"}

## lets add menu with item and price, using an array
127.0.0.1:6379> json.set truck:1 .menu '[{"item":"taco","price":6},{"item":"burrito","price":8},{"item":"chicken burger","price":10}]'
OK
127.0.0.1:6379> json.get truck:1
{"name":"Amazing Delights","is_open":true,"wait_time":10,"location":"123 Choa Chu Kang","menu":[{"item":"taco","price":6},{"item":"burrito","price":8},{"item":"chicken burger","price":10}]}

## lets display all menu items
127.0.0.1:6379> json.get truck:1 .menu
[{"item":"taco","price":6},{"item":"burrito","price":8},{"item":"chicken burger","price":10}]

## get the first and last item in the menu
127.0.0.1:6379> json.get truck:1 .menu[0]
{"item":"taco","price":6}
127.0.0.1:6379> json.get truck:1 .menu[-1]
{"item":"chicken burger","price":10}
127.0.0.1:6379> json.get truck:1 .menu[2]
{"item":"chicken burger","price":10}

## total number of items in the menu, use json.arrlen instead of json.objlen
127.0.0.1:6379> json.type truck:1 .menu
array
127.0.0.1:6379> json.arrlen truck:1 .menu
3

## add a new item in a menu
127.0.0.1:6379> json.arrappend truck:1 .menu '{"item":"Lamp Chop","price":12}'
4
127.0.0.1:6379> json.get truck:1 .menu[-1]
{"item":"Lamp Chop","price":12}

## increase wait time to 20
127.0.0.1:6379> json.numincrby truck:1 .wait_time 10
20
127.0.0.1:6379> json.get truck:1 .wait_time
20

## add special_menu to true
127.0.0.1:6379> json.set truck:1 .special_menu true
OK
127.0.0.1:6379> json.get truck:1
{"name":"Amazing Delights","is_open":true,"wait_time":20,"location":"123 Choa Chu Kang","menu":[{"item":"taco","price":6},{"item":"burrito","price":8},{"item":"chicken burger","price":10},{"item":"Lamp Chop","price":12}],"special_menu":true}

## delete the special_menu
127.0.0.1:6379> json.set truck:1 .special_menu false
OK
127.0.0.1:6379> json.get truck:1 .special_menu
false

## remove burrito item from the menu
127.0.0.1:6379> json.arrpop truck:1 .menu 1
{"item":"burrito","price":8}
127.0.0.1:6379> json.get truck:1 .menu
[{"item":"taco","price":6},{"item":"chicken burger","price":10},{"item":"Lamp Chop","price":12}]

## add a new dish called 'sushi after 2nd menu item'
127.0.0.1:6379> json.arrinsert truck:1 .menu 1 '{"item":"sushi","price":10}'
4
```
