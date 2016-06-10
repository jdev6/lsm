local _ = {}
local registers = {}

function _.def(a,b)
    --Define the value of a register
    registers[a.value] = b.value
end

function _.sput(a)
    --Print string
    if a.type == "register" then
        print(registers[a.value])

    elseif a.type == "string" then
        print(a.value)

    end
end

function _.put(a)
    --Print char
    if a.type == "register" then
        io.write(string.char(registers[a.value]))

    elseif a.type == "number" then
        io.write(string.char(a.value))
    
    end
end
return _
