# Install Redis

1. Create an instance on Redis Cloud with [redis.com](redis.com)
2. To run Redis commands manually, use `rbook.cloud` or use Redis CLI
   - To run RBook locally, run `npx rbook` and navigate to `http://localhost:3050`
   - Any notebook you create will be saved into the same folder that you ran `npx rbook` in.

# Install Redis Locally

- [Install on MacOS](https://redis.io/docs/stack/get-started/install/mac-os/)

1. If you do not already have HomeBrew installed, navigate to https://brew.sh/ and run the command at the top in your terminal to install HomeBrew
2. At your terminal, run `brew tap redis-stack/redis-stack`
3. At your terminal, run `brew install redis-stack`
4. To start Redis, run `redis-stack-server`
5. To connect to your local Redis server and execute commands, run `redis-cli`

---

- [Install on Windows](https://redis.io/docs/stack/get-started/install/docker/)

1. Install Docker Desktop for Windows from this page - https://docs.docker.com/desktop/windows/install/
2. At your terminal, run `docker run -d --name redis-stack-server -p 6379:6379 redis/redis-stack-server:latest`
3. To connect to your local Redis server and execute commands, run `docker exec -it redis-stack-server redis-cli`

---

- If you want to connect the RBay e-commerce app to your local copy of Redis, update the .env file in the root project directory to the following:

```
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PW=
```

- If you want to connect RBook to your local copy of Redis, you will need to run RBook locally.

1. To run RBook locally, run npx rbook at your terminal.
2. Navigate to localhost:3050
3. Open the connection settings window
4. Enter a host of 'localhost'
5. Enter a port of 6379
6. Leave the password blank

- When running RBook locally, any notebooks you create will be added to the folder you ran `npx rbook` in.

---
