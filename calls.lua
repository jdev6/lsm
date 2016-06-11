local _ = {}

function _.def(a,b)
    --Define the value of a register
    a.value = b == nil and nil or b.value
    return true
end

function _.sput(...)
    --Print strings
    for k,a in ipairs({...}) do
        io.stdout:write(tostring(a.value))
    end
    return true
end

function _.put(a)
    --Print char
    io.stdout:write(string.char(a.value))
    return true
end

function _.sget(a)
    --Get a line from stdin
    a.value = io.stdin:read("*l")
    return true
end

function _.get(a)
    --Get a character from stdin
    a.value = string.byte(io.stdin:read(1))
    return true
end

function _.eq(...)
    --Check for equality
    local params = {...}
    local prev
    local eqs = true

    for k,p in ipairs(params) do
        if k > 1 then
            eqs = p.value == params[k-1].value
            if not eqs then return false end
        end
    end

    return true
end

function _.exit(errno)
    os.exit(errno)
end

function _.add(a,b,c)
    --Add numbers
    if not a or not b or not c then
        return false

    elseif type(a.value) == "number" and type(b.value) == "number" then
        c.value = a.value + b.value
        return true
    else
        c.value = nil
        return false
    end
end

function _.sub(a,b,c)
    --Subtract numbers
    if not a or not b or not c then
        return false

    elseif type(a.value) == "number" and type(b.value) == "number" then
        c.value = a.value - b.value
        return true
    else
        c.value = nil
        return false
    end
end

function _.div(a,b,c)
    --Divide numbers
    if not a or not b or not c then
        return false

    elseif type(a.value) == "number" and type(b.value) == "number" then
        c.value = a.value / b.value
        return true
    else
        c.value = nil
        return false
    end
end

function _.mul(a,b,c)
    --Multiply numbers
    if not a or not b or not c then
        return false

    elseif type(a.value) == "number" and type(b.value) == "number" then
        c.value = a.value * b.value
        return true
    else
        c.value = nil
        return false
    end
end

function _.arrdef(a, ...)
    --Create array
    if not a then
        return false
    end
    a.value = {}
    for k,e in ipairs({...}) do
        a.value[k] = e.value
    end

    return true
end

function _.arridx(a, idx, b)
    if not a or not idx or not b then
        return false
    end
    --Index array a with index idx and put the value in b
    b.value = a.value[idx.value]

    return b.value ~= nil
end

function _.arrset(a,k,v)
    --Set a key in an array
    if not a or not k or not v then
        return false
    end
    a.value[k.value] = v.value

    return a.value ~= nil
end

function _.tonum(a, b)
    --String to number
    if not a or not b then
        return false
    end
    b.value = tonumber(a.value)

    return b.value ~= nil
end

function _.tostr(a, b)
    --Number to string
    if not a or not b then
        return false
    end
    b.value = tostring(a.value)

    return b.value ~= nil
end


return _