return function(tokens)
    local i = 1
    local tok

    local ast = {} 
    local function push(x) table.insert(ast,x) end
    local function next() i=i+1; tok = tokens[i] end

    dprint '--parse--'
    while i <= #tokens do
        tok = tokens[i]

        if tok.type == "keyword" then
            local call = {
                type = "call",
                id = tok.value,
                args = {}
            }

            repeat
                dprint(i,tok.type)
                next()
                table.insert(call.args, tok)
            until tok.type == "end"
            
            call.args[#call.args] = nil

            dprint 'end'
            next()
            push(call)
        end
    end
    
    dprint 'parse'
    return ast
end
