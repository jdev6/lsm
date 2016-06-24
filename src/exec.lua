local signal

if lsm_host_isposix then
    signal = require "posix.signal"
end

require "lsm.calls"

lsm_reg   = {} --registers
lsm_lab   = {} --labels
lsm_stack = {} --stack (to go back from a goto)

lsm_success = false
lsm_pc = 1 --program counter

return function(ast, args)
    lsm_stage = "execution"
    --dprint '---exec---'
    if lsm_print_ast then
        print(inspect(ast))
        exit(0)
    end

    args = args or {}

    lsm_reg.argv = args
    lsm_reg.argc = #args
    lsm_reg.prog = lsm_main_file

    local currfile = ""
    local fileslns = {} --each file and its lines

    local function lineinc(x) --line increase
        if x.line then
            fileslns[currfile] = x.line
        end
    end

    if lsm_host_isposix then
        --SIGINT handler
        signal.signal(signal.SIGINT, function()
            if lsm_handlesigint then
                lsm_pc = lsm_sigintpc
            else
                lsm_error("Sigint not handled", nil, currfile,fileslns[currfile])
            end
        end)
    end

    while lsm_pc <= #ast do
        local op = ast[lsm_pc]

        if op.type == "file" then
            --change file
            lineinc(op)

            currfile = op.id
            fileslns[currfile] = fileslns[currfile] or 1

        elseif op.type == "call" then
            lineinc(op)

            lsm_success = lsm_call(op.id, op.args, currfile, fileslns[currfile])

        elseif op.type == "condcall" then
            lineinc(op)

            if op.inv then
                --!call
                lsm_success = lsm_success or lsm_call(op.id, op.args, currfile, fileslns[currfile])
            else
                --&call
                lsm_success = lsm_success and lsm_call(op.id, op.args, currfile, fileslns[currfile])
            end
        end

        lsm_pc = lsm_pc + 1 --increase pc
    end
end
