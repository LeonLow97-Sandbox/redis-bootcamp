-- Expressions

--[[

    Arithmetic Operations
    ---------------------

    +   Addition
    -   Subtraction
    *   Multiplication
    /   Division

    - applicable on real numbers

    Relationship Operations
    -----------------------

    <   less than
    >   greater than
    <=  less than or equal to
    >=  greater than or equal to

    ==  test for equality
    ~=  test for negation of equality

    Logical Operators
    -----------------

    and
    or
    not

    returns true or false

    String Operations
    -----------------

    The two dots ..     means Concatenation

]]

-- Arithmetic Operations
n1, n2, n3, n4, n5 = 10, 20, 30, 0.25, 10
print(n1, n2, n3, n4)

print(
    n1 + n2,
    n1 * n2,
    n1 / n3,
    n1 - n2,
    (n1 * n2) + n3
)

-- Relationsgip Operations
print(
    n1 > n2,
    n2 > n1,
    n2 >= n1,
    n2 <= n1,
    n1 == n2,
    n1 == n5,
    n1 ~= n5
)

-- Output: true, treating both as string, it was checking the alphabetical order
print("2" > "15") 

print("0" == 0) -- Output: false

print("acai" < "acai") -- false
print("acai" == "acai") -- true
print("2" == "222") -- false

bool1 = true
bool2 = false
print(
    bool1 == bool2, -- false
    bool1 ~= bool2, -- true
    not bool1 -- false
)

-- Logical Operators
print(4 and 5) -- Output: 5, both are true and it returns the last "truthy" value
print(-2 and -1) -- Output: -1
print(-1 and -2) -- Output: -2

print(12 and nil) -- Output: nil, equation is now false so returns nil
print(nil and 12) -- Output: nil

print(12 and false) -- Output: false
print(false and 12) -- Output: false

print(12 and true) -- Output: true
print(true and 12) -- Outpu: 12

print(false and 6) -- false

print(not nil)      -- true
print(not false)    -- true
print(not 0)        -- false
print(not not nil)  -- false

print(4 or 5) -- 4
print(10 or 9) -- 10
print(9 or 10) -- 9
print(false or 4) -- 4, returns the first argument that is "truthy"
print(true or 4) -- true
print(false or nil or 100) -- 100

bool1 = true
bool2 = false

print(
    bool1 and bool2,    -- false
    bool1 or bool2      -- true
)

-- String Operations
msg1 = "My name is"
msg2 = "Leon Low."

print(msg1 .. " " .. msg2)

print(1 .. 20) -- 120

print("Hi, this is " .. "Darrel and I love Java more than Golang.")