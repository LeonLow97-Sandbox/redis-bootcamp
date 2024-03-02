# Redis - Database Design

## For creating data structures

- Don't be afraid to generate lots of key-value pairs
- Feel free to store each row of the table in a different key
- Use **Redis Hash Map** data type
- Form key name from primary key values of the table by a separator (such as ":")

## To query data

- When you want to query a single row, directly form the key and retrieve its results
- When you want to query a range, use wild card "\*" towards your key.

## Example

### Employees Table

- RDBMS Table

```sql
CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    age INT,
    hire_date DATE,
    salary DECIMAL(20,2)
);
```

- Redis Data Structure
  - Key Name Nomenclature: `employee:employee_id` where employee_id is the primary key.

```
HMSET employee:1 first_name John last_name Doe age 30 hire_date 2020-01-01 salary 15000
HMSET employee:2 first_name Leon last_name Low age 27 hire_date 2020-10-01 salary 15000

127.0.0.1:6379> hmget employee:1 first_name
1) "John"

127.0.0.1:6379> hgetall employee:1
 1) "first_name"
 2) "John"
 3) "last_name"
 4) "Doe"
 5) "age"
 6) "30"
 7) "hire_date"
 8) "2020-01-01"
 9) "salary"
10) "15000"

// to get all employees
127.0.0.1:6379> scan 0 match employee:*
1) "0"
2) 1) "employee:2"
   2) "employee:1"

127.0.0.1:6379> keys employee:*
1) "employee:2"
2) "employee:1"
```

## Table with Multiple Primary Keys

- RDBMS

```sql
create table public.order_details (
    order_id SMALLINT NOT NULL,
    product_id SMALLINT NOT NULL,
    unit_price REAL NOT NULL,
    quantity SMALLINT NOT NULL,
    discount REAL NOT NULL,
    CONSTRAINT pk_order_details PRIMARY KEY (order_id, product_id)
);
```

- Redis Data Structure
  - Key Name Nomenclature: `order:product:order_id:product_id`

```
HMSET order:product:10248:11 unit_price 14 quantity 14 discount 0
HMSET order:product:10248:42 unit_price 9.8 quantity 10 discount 0

127.0.0.1:6379> hgetall order:product:10248:11
1) "unit_price"
2) "14"
3) "quantity"
4) "14"
5) "discount"
6) "0"

// get all keys of order and products
127.0.0.1:6379> scan 0 match order:product:*
1) "0"
2) 1) "order:product:10248:42"
   2) "order:product:10248:11"

127.0.0.1:6379> keys order:product:10248:*
1) "order:product:10248:42"
2) "order:product:10248:11"

// get all orders with product_id 11
127.0.0.1:6379> keys order:product:*:11
1) "order:product:10248:11"
```
