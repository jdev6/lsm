return function(tokens)
    local i = 1
    local tok

    local ast = {} 
    local function push(x) table.insert(ast,x) end
    local function next() i=i+1; tok = tokens[i] end

    dprint '--parse--'
    local cond_call = false
    local cond_inv = false

    while i <= #tokens do
        tok = tokens[i]

        if tok.type == "keyword" then
            local call = {
                inv = cond_inv,
                type = cond_call and "condcall" or "call",
                id = tok.value,
                args = {}
            }
            
            cond_call, cond_inv = false, false

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
                    end
                    })
                    tok.value = nil
                end
                table.insert(call.args, tok)
            until tok.type == "end"
            
            call.args[#call.args] = nil

            dprint 'end'
            next()
            push(call)

        elseif tok.type == "cond" then
            cond_call = true
            cond_inv = tok.inv
            next()
        end
    end
    
    dprint 'parse'
    return ast
end
