lsm_add_call("def",
    {
        "register",
        "any"
    },
    function(a,b)
        --Define the value of a register
        a.value = b == nil and nil or b.value
        return true
    end
)

lsm_add_call("sput",
    {
        min = 1,
        "any"
    },
    function(...)
        --Print strings
        for k,a in ipairs{...} do
            lsm_outf:write(tostring(a.value))
        end
        return true
    end
)

lsm_add_call("put",
    {
        "number"    
    },
    function(a)
        --Print char
        lsm_outf:write(string.char(a.value))
        return true
    end
)

lsm_add_call("sget",
    {
        "register"
    },
    function(a)
        --Get a line from input
        local l = lsm_inf:read("*l")
        a.value = l or nil
        return a.value ~= nil
    end
)

lsm_add_call("get",
    {
        "register"
    },
    function(a)
        --Get a character from input
        local c = lsm_inf:read(1)
        a.value = c and string.byte(c) or nil
        return a.value ~= nil
    end
)

lsm_add_call("inf",
    {
        "string"
    },
    function(f)
        local fp, err = io.open(f.value)
        if fp then
            lsm_inf = fp
            return true
        else
            return false
        end
    end
)

lsm_add_call("outf",
    {
        "string"
    },
    function(f)
        local fp, err = io.open(f.value)
        if fp then
            lsm_outf = fp
            return true
        else
            return false
        end
    end
)

lsm_add_call("eq",
    {
        min = 2,
        "any"
    },
    function(...)
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
)

lsm_add_call("exit",
    {
        min = 0,
        "number"
    },
    function(errno)
        exit(errno and errno.value or 0)
    end
)

lsm_add_call("add",
    {
        "number",
        "number",
        "register"
    },
    function(a,b,c)
        --Add numbers
        c.value = a.value + b.value
        return true
    end
)

lsm_add_call("sub",
    {
        "number",
        "number",
        "register"
    },
    function(a,b,c)
        --Subtract numbers
        c.value = a.value - b.value
        return true
    end
)

lsm_add_call("div",
    {
        "number",
        "number",
        "register"
    },
    function(a,b,c)
        --Divide numbers
        if b.value == 0 then
            return false
        end

        c.value = a.value / b.value
        return true
    end
)

lsm_add_call("mul",
    {
        "number",
        "number",
        "register"
    },
    function(a,b,c)
        --Multiply numbers
        c.value = a.value * b.value
        return true
    end
)

lsm_add_call("mod",
    {
        "number",
        "number",
        "register"
    },
    function(a,b,c)
        --Modulo division
        if b.value == 0 then
            return false
        end

        c.value = a.value % b.value
        return true
    end
)

lsm_add_call("pow",
    {
        "number",
        "number",
        "register"
    },
    function(a,b,c)
        --Exponentiate numbers
        c.value = math.pow(a.value, b.value)
        return true
    end
)

lsm_add_call("isnil",
    {
        "any"
    },
    function(a)
        --Sets success value to true if a is nil
        return a.value == nil
    end
)

lsm_add_call("arrdef",
    {
        min = 1,
        "register"
    },
    function(a, ...)
        --Create array
        a.value = {}
        for k,e in ipairs({...}) do
            a.value[k] = e.value
        end

        return true
    end
)

lsm_add_call("arrget",
    {
        "table",
        "any",
        "register"
    },
    function(a, idx, b)
        --Index array a with index idx and put the value in b
        b.value = a.value[idx.value]

        return b.value ~= nil
    end
)

lsm_add_call("arrset",
    {
        "table",
        "any",
        "any" 
    },
    function(a,k,v)
        --Set a key in an array
        a.value[k.value] = v.value

        return a.value ~= nil
    end
)

lsm_add_call("tonum",
    {
        "any",
        "register"
    },
    function(a, b)
    --Convert to number
        b.value = tonumber(a.value)

        return b.value ~= nil
    end
)

lsm_add_call("tostr",
    {
        "any",
        "register"
    },
    function(a, b)
    --Convert to string
        b.value = tostring(a.value)

        return b.value ~= nil
    end
)

lsm_add_call("gt",
    {
        "number",
        "number"
    },
    function(a,b)
        --Greater than
        return a.value > b.value
    end
)

lsm_add_call("lt",
    {
        "number",
        "number"
    },
    function(a,b)
        --Less than
        return a.value < b.value
    end
)

lsm_add_call("error",
    {
        "string"
    },
    function(err)
        lsm_error(str, nil, _file,_line)
    end
)

if lsm_host_isposix then
    --posix
    lsm_add_call("sigint",
        {
            "label"
        },
        function(lab)
            --SIGINT handler, takes a label as an argument
            --Makes the program jump to that label when SIGINT (ctrl-c) is recieved
            lsm_handlesigint = true
            lsm_sigintpc = lsm_lab[lab.id]

            return lsm_sigintpc ~= nil
        end
    )
else
    --windows, no sigint
    lsm_add_call("sigint",
        {},
        function()
            return false
        end
    )
end

lsm_add_call("goto",
    {
        "label"
    },
    function(lab)
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
)

lsm_add_call("back",
    {},
    function()
        --go back in the stack
        if #lsm_stack > 0 then
            lsm_pc = lsm_stack[#lsm_stack]  --jump back to the last place in the stack
            table.remove(lsm_stack, #lsm_stack) --remove last value from stack
            return true
        else
            lsm_error("Cannot go back", "Stack is empty", _file,_line)
        end
    end
)