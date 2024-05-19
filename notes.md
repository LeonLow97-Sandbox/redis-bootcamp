# Redis Notes

## Using `KEYS *` vs `SCAN` in Redis Production

- Using `KEYS *` in production Redis is not recommended. On the other hand, `SCAN` is a more efficient and safer alternative.

|Command|Performance|Blocking?|Reading Data|
|---|---|---|---|
|`KEYS *`|O(n) operation, where n is the numebr of keys in the database. This means that as the number of keys increases, the command's execution time grows linearly, leading to performance issues.|`KEYS *` is a blocking command, meaning that it will block other commands from executing until it finishes. This can cause delays and affect the overall performance of your Redis instance.|`KEYS *` loads all keys into memory, which can lead to high memory usage and potentially cause Redis to run out of memory.|
|`SCAN`|O(1) operation, making it much faster than `KEYS *` for large datasets.|`SCAN` is a non-blocking command, allowing other commands to execute while it's running.|`SCAN` uses a cursor to iterate over the keys, allowing you to process keys in chunks, reducing memory usage.|