local calls = {}

function calls.def(a,b)
    --Define the value of a register
    a.value = b == nil and nil or b.value
    return true
end

function calls.sput(...)
    --Print strings
    for k,a in ipairs{...} do
        lsm_outf:write(tostring(a.value))
    end
    return true
end

function calls.put(a)
    --Print char
    lsm_outf:write(string.char(a.value))
    return true
end

function calls.sget(a)
    --Get a line from stdin
    a.value = lsm_inf:read("*l")
    return true
end

function calls.get(a)
    --Get a character from stdin
    a.value = string.byte(lsm_inf:read(1))
    return true
end

function calls.eq(...)
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

function calls.exit(errno)
    exit(errno and errno.value or 0)
end

function calls.add(a,b,c)
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

function calls.sub(a,b,c)
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

function calls.div(a,b,c)
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

function calls.mod(a,b,c)
    --Perform modulo division
    if not a or not b or not c then
        return false

    elseif type(a.value) == "number" and type(b.value) == "number" then
        c.value = a.value % b.value
        return true
    else
        c.value = nil
        return false
    end
end

function calls.mul(a,b,c)
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

function calls.pow(a,b,c)
    --Exponentiation
    if not a or not b or not c then
        return false

    elseif type(a.value) == "number" and type(b.value) == "number" then
        c.value = math.pow(a.value, b.value)
        return true
    else
        c.value = nil
        return false
    end
end

function calls.isnil(a)
    --Sets success value to true if a is nil
    return a.value == nil
end

function calls.arrdef(a, ...)
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

function calls.arrget(a, idx, b)
    if not a or not idx or not b then
        return false
    end
    --Index array a with index idx and put the value in b
    b.value = a.value[idx.value]

    return b.value ~= nil
end

function calls.arrset(a,k,v)
    --Set a key in an array
    if not a or not k or not v then
        return false
    end
    a.value[k.value] = v.value

    return a.value ~= nil
end

function calls.tonum(a, b)
    --String to number
    if not a or not b then
        return false
    end
    b.value = tonumber(a.value)

    return b.value ~= nil
end

function calls.tostr(a, b)
    --Number to string
    if not a or not b then
        return false
    end
    b.value = tostring(a.value)

    return b.value ~= nil
end

function calls.gt(a,b)
    --Greater than
    return a.value > b.value
end

function calls.lt(a,b)
    --Less than
    return a.value < b.value
end

function calls.error(err,ext)
    local str = err.value

    lsm_error(str, ext and ext.value or nil, _file,_line)
end

if lsm_host_isposix then
    function calls.sigint(lab)
        --SIGINT handler, takes a label as an argument
        --Makes the program jump to that label when SIGINT (ctrl-c) is recieved
        lsm_handlesigint = true
        lsm_sigintpc = lsm_lab[lab.id]

        return lsm_sigintpc ~= nil
    end
else
    function calls.sigint()
        return false
    end
end

calls["goto"] = function(lab) --must do this cause goto is a reserved lua keyword
    --jump to position in code that label has
    if lsm_lab[lab.id] then
        if lab.stack then
            lsm_stack[#lsm_stack+1] = lsm_pc --insert into stack
        end
        lsm_pc = lsm_lab[lab.id] - 1
        return true
    else
        lsm_error("Label doesn't exist", lab.id, _file,_line)
    end
end

function calls.back()
    --go back in the stack
    if #lsm_stack > 0 then
        lsm_pc = lsm_stack[#lsm_stack]  --jump back to the last place in the stack
        table.remove(lsm_stack, #lsm_stack) --remove last value from stack
        return true
    else
        lsm_error("Cannot go back", "Stack is empty", _file,_line)
    end
end

return calls