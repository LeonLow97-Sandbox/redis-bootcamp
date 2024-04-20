--[[

IF statement
============

IF condition1 THEN
    -- processing
ELSEIF condition2 THEN
    -- processing
ELSE
    -- processing
END

For Loop
==============

- Loops allows execution of statements on a block of codes based on a condition

FOR condition
DO
    -- statements...
END

While Loop
==========

WHILE condition
DO
    -- statements
END

]]

----------- IF STATEMENT -----------
x = 5
if x > 20 then
    print("x is greater than 5")
elseif x == 10 then
    print("x is equal to 10")
else
    print("x is less than 20 and not equal to 10")
end


-- Shorthen the IF statement
y = 10

z = y > 5 and print("x is greater than 5")


----------- FOR LOOP -----------
print("\nFOR LOOP")

for num = 1, 10 -- 10 is inclusive
do
    print(num)
end

-- Create 50 new elements in a table
t = {}
for i = 1, 50
do
    t[i] = i * 123
end

print(t[25], t[37], t[50], t[51])

-- Read (accept input) 5 values and store them in a table
-- a = {}
-- for i = 1, 5
-- do
--     print("Position " .. i .. ":")
--     a[i] = io.read()
-- end

-- print(a[1], a[2], a[3], a[4], a[5])

-- traverse all values in an array or table
-- `ipairs` iterate over all elements in an array
t1 = {45, 32, 76, 39, 40}
for i, v in ipairs(t1)
do
    print("index: " .. i .. " and value: " .. v)
end

print()

-- traverse all keys in a table
-- use `pairs` for table with key-value
myself = {
    name = "Leon",
    age = 27
}
for k, v in pairs(myself)
do
    print("key: " .. k .. " and value: " .. v)
end

print()

-- reverse for loop
-- e.g., reverse days of the week
days = {
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday"
}

for i = #days, 1, -1
do
    value = days[i]
    print(i .. ":" .. value)
end

print()

-- another way to reverse for loop
for i = 1, #days
do
    print(days[#days + 1 - i])
end

print()

----------- WHILE LOOP ------------
-- Lets sum numbers in a table
-- #table returns the length of the table
numbers = { 20, 30, 40, 50 }
print(#numbers)

sum, counter = 0, 1
while counter <= #numbers
do
    sum = sum + numbers[counter]
    counter = counter + 1
end

print("Total Sum: " .. sum)


-- another way with `repeat`
sum, counter = 0, 1
repeat
    sum = sum + numbers[counter]
    counter = counter + 1
until counter > #numbers

print("Total Sum: " .. sum)
