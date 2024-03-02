# Mass insertion of data - Piping

- [Redis Bulk Loading](https://www.redis.io/topics/mass-insert)

## Using the `awk` command

```
awk -F ',' '{print "SET country:"$1 " " $2}' country_codes.csv

SET country:AF Afghanistan
SET country:AL Albania
SET country:DZ Algeria
SET country:AD Andorra
SET country:AO Angola
SET country:AI Anguilla
SET country:AQ Antarctica
SET country:AR Argentina
SET country:AM Armenia
SET country:AW Aruba
SET country:AU Australia
SET country:AT Austria
SET country:AZ Azerbaijan
SET country:BH Bahrain
SET country:BS Bahamas
SET country:BD Bangladesh
SET country:BB Barbados
SET country:BY Belarus
SET country:BE Belgium
...
```

- pipe it to a file `awk -F ',' '{print "SET country:"$1 " " $2}' country_codes.csv > country_codes_redis.csv`

## Sequentially mass insert data in Redis

- Added the data sequentially

```
cat country_codes_redis.csv | redis-cli

➜  bulk-loading git:(main) ✗ redis-cli
127.0.0.1:6379> keys *
  1) "country:NU"
  2) "country:IT"
  3) "country:MO"
  4) "country:TN"
  5) "country:ET"
  6) "country:MV"
  7) "country:PY"
  8) "country:PT"
  9) "country:PW"
 10) "country:NO"
 11) "country:SN"
 12) "country:JP"
 13) "country:ME"
 14) "country:TV"
 ...
```

## Pipe Mode

- Pipe mode offers a more efficient and optimised way to insert data into Redis, especially when dealing with large datasets.
- It leverages batch processing, reduced overhead, and optimized communication protocols to achieve better performance compared to traditional methods.

```
➜  bulk-loading git:(main) ✗ cat country_codes_redis.csv | redis-cli --pipe
All data transferred. Waiting for the last reply...
Last reply received from server.
errors: 0, replies: 165
```