local calls = require "calls"

lsm_reg = {} --registers
lsm_lab = {} --labels

lsm_success = false
lsm_pc = 1 --program counter

return function(ast, args)
    lsm_stage = "execution"
    dprint '---exec---'
    dprint(inspect(ast))

    lsm_reg.argv = args
    lsm_reg.argc = #args

    local currfile = ""
    local fileslns = {} --each file and its lines

    while lsm_pc <= #ast do
        local op = ast[lsm_pc]
        --print(lsm_pc,op.id)

        if op.type == "line" then
            --increase line
            fileslns[currfile] = fileslns[currfile] + 1

        elseif op.type == "file" then
            --change file
            currfile = op.id
            fileslns[currfile] = fileslns[currfile] or 1

        elseif op.type == "call" then
            if not calls[op.id] then
                --nonexistent call
                lsm_error("Attempting to use a nonexistent call", op.id, currfile, fileslns[currfile])
            else
                lsm_success = calls[op.id](unpack(op.args))
            end

        elseif op.type == "condcall" then
            if not calls[op.id] then
                lsm_error("Attempting to use a nonexistent call", op.id, currfile, fileslns[currfile])
            else
                if op.inv then
                    --!call
                    lsm_success = lsm_success or calls[op.id](unpack(op.args))
                else
                    --&call
                    lsm_success = lsm_success and calls[op.id](unpack(op.args)) or lsm_success
                end
            end
        end

        lsm_pc = lsm_pc + 1 --increase pc
    end
end
