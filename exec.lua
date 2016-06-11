local inspect = require "inspect"

local calls = require "calls"

lsm_reg = {}
lsm_success = false

return function(ast)
    dprint '---exec---'
    dprint(inspect(ast))

    for k,op in pairs(ast) do
        if op.type == "call" then
            lsm_success = calls[op.id](unpack(op.args))

        elseif op.type == "condcall" then
            if op.inv then
                --!call
                lsm_success = lsm_success or calls[op.id](unpack(op.args))
            else
                --&call
                lsm_success = lsm_success and calls[op.id](unpack(op.args)) or lsm_success
            end
        end
    end
end
