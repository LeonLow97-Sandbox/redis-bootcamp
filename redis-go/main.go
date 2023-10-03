package main

import (
	"fmt"
	"log"

	"github.com/go-redis/redis"
)

var redisClient *redis.Client

func main() {
	connectRedis()

	setToRedis("app:url", "http://localhost:3000/v1/")
	setToRedis("app:status", "UP")

	fmt.Println("Application URL:", getFromRedis("app:url"))
	fmt.Println("Application Status:", getFromRedis("app:status"))

	fmt.Println("All keys:\n", getAllKeys("app*"))
}

func connectRedis() {
	// Initialize Redis client
	client := redis.NewClient(&redis.Options{
		Addr:     "localhost:6379", // Redis server address
		Password: "",               // No password
		DB:       0,                // Default DB
	})

	// Check if Redis is reachable
	pong, err := client.Ping().Result()
	if err != nil {
		log.Fatal("Error connecting to Redis:", err)
	}
	fmt.Println("Connected to Redis:", pong)

	redisClient = client
}

func setToRedis(key, val string) {
	err := redisClient.Set(key, val, 0).Err()
	if err != nil {
		log.Println(err)
	}
}

func getFromRedis(key string) string {
	val, err := redisClient.Get(key).Result()
	if err != nil {
		log.Println(err)
		return ""
	}
	return val
}

func getAllKeys(key string) []string {
	keys := []string{}

	iter := redisClient.Scan(0, key, 0).Iterator()
	for iter.Next() {
		keys = append(keys, iter.Val())
	}
	if err := iter.Err(); err != nil {
		panic(err)
	}

	return keys
}
