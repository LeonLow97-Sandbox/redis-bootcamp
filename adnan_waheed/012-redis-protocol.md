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

## Request - Response Model

- **Redis Client** sends commands to Redis Server as a RESP Array of Bulk strings
  - `set name Redis`
- **Redis Server** replies with one of the RESP types according to the command implementation
  - `OK`
