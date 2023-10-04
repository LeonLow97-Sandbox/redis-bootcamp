# Redis Lists

- Lists are very flexible data structure in Redis.
- A list acts as a simple collection of elements
    - 1,2,3,4,5,6,...
- List stores sequence of objects
- A list is a sequence of **ordered** elements
- The order of the elements depends on the elements insertion sequence.
- A list can be encoded and memory optimized.
- A list is like an array - from programming perspective.
- Element in a list are **strings**.
- A list can contain > 4 billion elements.

## Redis List - Use Cases

- Event Queue
    - Lists are used in many tools like Resque, Celery, Logstash.
- Most recent data
    - Twitter does this by storing the latest tweets of a user in a list.