-- Strngs

--[[
1. Lua is eight-bit clean and so strings may contain
    characters with any numeric value, including embedded zeros.

2. Can store any binary data into a string
3. Automatic memory management
]]

a = 'this is a line' -- single quote
b = "this is another line" -- double quote

print(a, b)

-- Escape characters
-- \n, \r, \", \'
print("\nFirst line\nSecond line\n\tThird Line with tab\n")

print("My Quote \"Be better than you were yesterday!\"\n") -- escape double quotes

-- Initiate a variable with multi-line string, use double square brackets
html = [[
<html>
    <head>
        <title>Test Title</title>
    </head>
</html>
]]

print(html)

-- Adding string to number
print("10" + 2) -- Output: 12
print(2 + "10") -- Output: 12
print("10 + 2") -- Output: 10 + 2

print("-5.3e-10" * "2") -- Output: -1.06e-09
print("-5.3e-10" * 2) -- Output: -1.06e-09

-- print("test" + 2) -- error: attempt to add a 'string' with a 'number'

-- concatenating 2 numbers to a string
print(20 .. 40) -- Output: 2040 (this is a string)

-- converting number to string
print(tostring(20))
print(tostring(20) == "20") -- Output: true

-- Accept inputs
line = io.read()
print("You have entered: " .. line)

-- replacing strings, gsub is global substitution
x = "one string"
y = string.gsub(x, "one", "two")
print(x)
print(y)