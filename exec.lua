local inspect = require "inspect"

local calls = require "calls"

return function(ast)
    dprint '---exec---'
    dprint(inspect(ast))

    local registers = {}

    for k,op in pairs(ast) do
        if op.type == "call" then
           calls[op.id](unpack(op.args)) 
        end
    end
end
