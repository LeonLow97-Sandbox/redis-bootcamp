--[[

EVAL Statement
==============
1. Core features of Lua
2. Knowledge to extend standard sets of Redis Database
3. Input / Output
4. Input Sources:
        - Redis Database
        - Script Arguments
    Output
    - based on Redis Server replies, we generate the output

The EVAL command in Redis is a powerful feature that allows you to execute Lua scripts directly on the Redis server. 
This command provides a way to perform complex operations or multiple commands in a single atomic operation, 
enhancing Redis's capabilities beyond its built-in commands.

Lua and Redis Data Types are still different
============================================

Type            Redis        Lua
-------------   ----------   -------------
integer         -            number
bulk            -            string
multi-bulk      -            table
nil bulk        -            boolean false
status          -            'ok'
error           -            'err'

- We need to follow these RULES or CONVERSIONS as per above

https://redis.io/docs/latest/commands/eval/

]]

-- 1. Let's evaluate the script from the command line

-- 1.1 Simple script to return static string
    -- the first argument in EVAL is Lua Script
    -- the second argument is number of arguments/keys that we will pass to redis
EVAL "return \"Hello Lua!\"" 0

--[[
127.0.0.1:6379> EVAL "return \"Hello Redis!\"" 0
"Hello Redis!"
]]

-- 2. Let's pass a key to the script
    -- The arguments can be accessed in the form of KEYS global variables
    -- KEYS[1] means 1st argument

SET name "Leon"

EVAL "return string.format(\"Hello %s\", KEYS[1])" 1 name

--[[
127.0.0.1:6379> EVAL "return string.format(\"Hello %s\", KEYS[1])" 1 name
"Hello name"
]]

-- Redis commands from a Lua script via redis.call()
-- We need to call redis.call() to get value of KEYS argument

EVAL "return string.format(\"Hi %s\", redis.call('GET', KEYS[1]))" 1 name

--[[
127.0.0.1:6379> EVAL "return string.format(\"Hi %s\", redis.call('GET', KEYS[1]))" 1 name
"Hi Leon"
]]

-- Can pass arguments too, i.e., ARGV[1], ARGV[2]

EVAL "return string.format(\"%s %s\", ARGV[1], redis.call('GET', KEYS[1]))" 1 name "Good Morning"

--[[
127.0.0.1:6379> EVAL "return string.format(\"%s %s\", ARGV[1], redis.call('GET', KEYS[1]))" 1 name "Good Morning"
"Good Morning Leon"
]]

-- 3. Retrieve key-values directly

EVAL "return {KEYS[1], KEYS[2]}" 2 key1 key2

--[[
127.0.0.1:6379> EVAL "return {KEYS[1], KEYS[2]}" 2 key1 key2
1) "key1"
2) "key2"
]]

-- 4. Passing KEYS and ARGV together

EVAL "return {KEYS[1], KEYS[2], ARGV[1], ARGV[2]}" 2 key1 key2 "one" "two"

--[[
127.0.0.1:6379> EVAL "return {KEYS[1], KEYS[2], ARGV[1], ARGV[2]}" 2 key1 key2 "one" "two"
1) "key1"
2) "key2"
3) "one"
4) "two"
]]

-- 5. Let's SET some key-value from a Lua script

-- Not recommended way of setting key-value like this:
EVAL "return redis.call('SET', 'k1', 'v1')" 0

-- Recommended way
EVAL "return redis.call('SET', KEYS[1], 'v2')" 1 k2

--[[
127.0.0.1:6379> EVAL "return redis.call('SET', KEYS[1], 'thunes.com')" 1 app:config:title
OK

127.0.0.1:6379> get app:config:title
"thunes.com"
]]
