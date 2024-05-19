# RedisInsight

- Visualize and Interact with Redis databases
- Built-in support for Redis modules
- Memory analysis for Redis
- Trace Redis commands
- Intuitive CLI
- Administer Redis

## Setup Redis Insight with Docker

```
## running redis server (port 6379) and redis insight (port 8001)
docker run -d --name redis-stack -p 6379:6379 -p 8001:8001 redis/redis-stack:latest

## to access redis cli
(base) ➜  redis-bootcamp git:(main) ✗ docker exec -it redis-stack redis-cli
127.0.0.1:6379>
```

## Import sample movie data sets

```
(base) ➜  redisearch git:(main) ✗ pwd
/Users/leonlow/Desktop/udemy/redis-bootcamp/adnan_waheed/redisearch

redis-cli -h localhost -p 6379 < ./import_actors.redis
redis-cli -h localhost -p 6379 < ./import_movies.redis
redis-cli -h localhost -p 6379 < ./import_theaters.redis
redis-cli -h localhost -p 6379 < ./import_users.redis
```

## Start Redis Insight

- Load up `http://localhost:8001`
