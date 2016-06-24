return function(tokens, file)
    lsm_stage = "parser"
    file = file or "<?>"

    if lsm_print_tokens then
        print(inspect(tokens))
        exit(0)
    end

    local i = 1
    local tok
    local currfile = file
    local fileslns = { [currfile] = 1 } --each file and its lines
    local pc = 1
    local lastline = 1

    local ast = {}

    local function lineinc(x)
        if fileslns[currfile] ~= lastline then
            x.line = fileslns[currfile]
        end
    end

    local function push(x)
        pc=pc+1
        lineinc(x)
        table.insert(ast,x)
    end

    local function next() i=i+1; tok = tokens[i] end

    --dprint '--parse--'
    local cond_call = false
    local cond_call_inv = false

    while i <= #tokens do
        tok = tokens[i]

        if tok.type == "line" then
            --Add another line
            fileslns[currfile] = fileslns[currfile] + 1
            --push(tok)
            next()

        elseif tok.type == "file" then
            --Change file
            currfile = tok.value
            lineinc(tok)
            fileslns[currfile] = fileslns[currfile] or 1
            push {
                type = tok.type,
                id = tok.value
            }
            next()

        elseif tok.type == "label" then
            --labels in lsm_lab have a number that is the pc that they refer to, the 'position' in the code
            lineinc(tok)
            if not lsm_lab[tok.value] then
                lsm_lab[tok.value] = pc
            end
            next()

        elseif tok.type == "end" then
            --end
            lineinc(tok)
            next()

        elseif tok.type == "keyword" then
            lineinc(tok)
            local call = {
                inv = cond_call_inv,
                type = cond_call and "condcall" or "call",
                id = tok.value,
                args = {}
            }
            
            cond_call, cond_call_inv = false, false

            repeat
                --dprint(i,tok.type)
                next()
                lineinc(tok)
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
                        id = tok.value,
                        stack = tok.stack
                    }

                elseif tok.type == "line" then
                    --Line
                    fileslns[currfile] = fileslns[currfile] + 1


                elseif tok.type == "keyword" then
                    lsm_error("Unexpected keyword", tok.value, currfile, fileslns[currfile])
                end

                if tok.type ~= "line" then table.insert(call.args, tok) end
                
            until tok.type == "end" or tok == tokens[#tokens]
            
            call.args[#call.args] = nil

            --dprint 'end'
            next()
            if tok then
                lineinc(tok)
            end
            push(call)

        elseif tok.type == "cond" then
            lineinc(tok)
            cond_call = true
            cond_call_inv = tok.inv
            next()
        end
    end
    return ast
end
