local _ = {}
local lsm_reg = {}

function _.def(a,b)
    --Define the value of a register
    a.value = b == nil and nil or b.value
    return true
end

function _.sput(a)
    --Print string
    io.stdout:write(tostring(a.value))
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

function _.add(...)
    --Add numbers
    local params = {...}
    local dest = params[1]
    local accum = 0

    for k,p in ipairs(params) do
        accum = accum+p.value
    end

    dest.value = accum
    return true
end

function _.mul(...)
    --Multiply numbers
    local params = {...}
    local dest = params[1]
    local accum = 1

    for k,p in ipairs(params) do
        accum = accum*p.value
    end

    dest.value = accum
    return true    
end

function _.div(a,b)
    --Divide numbers
    a.value = a.value/b.value
    return true    
end
function _.sub(a,b)
    --Subtract numbers
    --[[
    local params = {...}
    local dest = params[1]
    local accum = 0

    for k,p in ipairs(params) do
        accum = p.value-accum
    end

    dest.value = accum--]]
    a.value = a.value-b.value
    return true    
end


function _.tonum(s)
    --String to number
    s.value = tonumber(s.value)

    return s.value ~= nil
end

return _
