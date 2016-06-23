return function(tokens, file)
    lsm_stage = "parser"

    local i = 1
    local tok
    local currfile = file
    local fileslns = { [currfile] = 1 } --each file and its lines
    local pc = 1

    local ast = {} 
    local function push(x) pc=pc+1; table.insert(ast,x) end
    local function next() i=i+1; tok = tokens[i] end

    dprint '--parse--'
    local cond_call = false
    local cond_call_inv = false

    while i <= #tokens do
        tok = tokens[i]

        if tok.type == "line" then
            --Add another line
            fileslns[currfile] = fileslns[currfile] + 1
            push(tok)
            next()

        elseif tok.type == "file" then
            --Change file
            currfile = tok.value
            fileslns[currfile] = fileslns[currfile] or 1
            push {
                type = tok.type,
                id = tok.value
            }
            next()

        elseif tok.type == "label" then
            --labels in lsm_lab have a number that is the pc that they refer to, the 'position' in the code
            if not lsm_lab[tok.value] then
                lsm_lab[tok.value] = pc
            end
            next()

        elseif tok.type == "end" then
            --end
            next()

        elseif tok.type == "keyword" then
            local call = {
                inv = cond_call_inv,
                type = cond_call and "condcall" or "call",
                id = tok.value,
                args = {}
            }
            
            cond_call, cond_call_inv = false, false

            repeat
                dprint(i,tok.type)
                next()
                if tok.type == "register" then
                    tok.id = tok.value
                    setmetatable(tok, {
                    __index=function(self,k)
                        if k == "value" then
                            return lsm_reg[self.id]
                        else
                            return rawget(self,k)
                        end
                    end,

                    __newindex=function(self,k,v)
                        if k == "value" then
                            lsm_reg[self.id] = v
                        else
                            rawset(self,k,v)
                        end
                    end })

                    tok.value = nil
                elseif tok.type == "label" then
                    --Label
                    tok = {
                        type = tok.type,
                        id = tok.value
                    }

                elseif tok.type == "keyword" then
                    lsm_error("Unexpected keyword '"..tok.value.."'", nil, currfile, fileslns[currfile])
                end

                if tok.type ~= "line" then table.insert(call.args, tok) end
                
            until tok.type == "end" or tok == tokens[#tokens]
            
            call.args[#call.args] = nil

            dprint 'end'
            next()
            push(call)

        elseif tok.type == "cond" then
            cond_call = true
            cond_call_inv = tok.inv
            next()
        end
    end
    return ast
end
