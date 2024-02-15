## Redis HyperLogLog

- HyperLogLog is a probabilistic data structure.
- Main purpose of HyperLogLog is to count the approximate number of estimates of unique items.
- Keeps a counter of items that is incremented.
- It **does not store the data, but only the cardinality**
- Conceptually the HLL (HyperLogLog) is like using Sets to do the same task.
- Not 100% accurate (99.9%)
- By using HyperLogLog, we can save a tremendous amount of memory as it uses less disk space that ordinary sets.
- Allows you to maintain counts of millions of items with high efficiency. Good for large datasets, less CPU intensive.
- 3 Commands
  - `PFADD` add elements
  - `PFCOUNT` estimate the cardinality (number of elements of the set). The fewer number of items in HyperLogLog, the higher the accuracy the count of HyperLogLog.
  - `PFMERGE` merge multiple HyperLogLogs

### `PFADD`, `PFCOUNT`, `PFMERGE`

- `PFADD key [element[element...]]`
- `PFCOUNT key`
- `PFMERGE destination key1 key2`

```
127.0.0.1:6379> flushdb
OK
127.0.0.1:6379> pfadd hll1 1 2 3 4
(integer) 1
127.0.0.1:6379> pfadd hll1 1
(integer) 0

127.0.0.1:6379> pfcount hll1
(integer) 4

127.0.0.1:6379> pfadd hll2 2 3 4 5 6
(integer) 1
127.0.0.1:6379> pfadd hll3 20 30 40
(integer) 1
127.0.0.1:6379> pfmerge hll hll1 hll2 hll3
OK
127.0.0.1:6379> pfcount hll
(integer) 9
```

### Unique Website Visitors via HyperLogLog

- Apply HLL to count unique website visitors of a website
- Can count millions of records very quickly

```
127.0.0.1:6379> pfadd visitors:main_page 1 2 3 4
(integer) 1
127.0.0.1:6379> pfadd visitors:stocks 1 2 3 4
(integer) 1
127.0.0.1:6379> pfadd visitors:company 1 2
(integer) 1
127.0.0.1:6379> pfcount visitors:main_page
(integer) 4
127.0.0.1:6379> pfcount visitors:stocks
(integer) 4

// count the total number of visitors
127.0.0.1:6379> pfmerge visitors:total visitors:main_page visitors:stocks visitors:company
OK
127.0.0.1:6379> pfcount visitors:total
(integer) 4
```