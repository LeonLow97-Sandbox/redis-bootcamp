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

]]

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