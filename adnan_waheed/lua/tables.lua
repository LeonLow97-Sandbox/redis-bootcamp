--[[

Lua - Tables Data Types
=======================
1. They are similar to Redis Hashes
2. Its associated arrays
3. No fixed size - Add as many elements as you want
4. Tables are used to represent:
    - arrays
    - symbol tables
    - sets
    - records
    - queues and more.
5. Tables are objects, i.e., Keys and Values
6. Syntax to create a table

    variable = {}

]]

-- initialize a table
tbl1 = {}

tbl1[1] = 1
print(tbl1[1])

tbl1["name"] = "Leon" 
print(tbl1["name"])

-- Another way to add key and access value
tbl1.age = 27
print(tbl1["age"], tbl1.age)

-- address of table
print(tbl1)


-- Create a single dimention table with some predefined values
tbl_days = {
    "Monday", "Tuesday", "Wednesday"
}

print(tbl_days[1]) -- Monday, first index is 1 in Lua, not 0
print(tbl_days[2]) -- Tuesday

tbl_days[4] = "Thursday"
print(tbl_days[4]) -- Thursday


-- Create key-value pairs in a table
me = {
    name = "Leon",
    age = 27,
    school = "National University of Singapore",
    hobby = "Basketball"
}

print("\n\tMy name is " .. me["name"] .. " and I am " .. me["age"] .. " years old.\n")

print(me.school) -- National University of Singapore
print(me.gender) -- nil   (key does not exist)


-- Directly assign a value to a table key
print(me.hobby) -- Basketball
me.hobby = "Swimming"
print(me.hobby) -- Swimming


-- Removing fields
me.hobby = nil
print(me.hobby)


-- tables are long data structures
-- Force the first index to be 0 instead of 1
tbl_days2 = {
    [0] = "Monday", "Tuesday", "Wednesday"
}
print(tbl_days2[0]) -- Monday
print(tbl_days2[1]) -- Tuesday


-- mix and match "key-value" and "value" in a single table
table1 = {
    x = 10,
    y = 20,
    "one",
    "two",
    "three"
}
print(table1["x"], table1["y"])
print(table1[1]) -- "one"
print(table1[3]) -- "three"


-- table in table
myself = {
    name = "Leon Low",
    grades = {
        math = 90,
        science = 85,
        english = 30
    }
}
print(myself.grades.math, myself.grades.english)