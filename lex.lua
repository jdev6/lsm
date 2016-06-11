local function dprintf(s,...) dprint(s:format(...)) end
require "is"

local COMMENT = ','
local END     = ';'

local escaped = {
    ['n'] = '\n',
    ['"'] = '"',
    ['r'] = '\r',
    ['v'] = '\v',
    ['t'] = '\t',
    ['f'] = '\f'
}

return function(data)
    local i = 1
    local c
    local tokens = {}

    local function next() i=i+1; c = data:sub(i,i) end
    local function push(tok) table.insert(tokens,tok) end

    dprint '---lex---'
    while i <= #data do
        c = data:sub(i,i)

        if isspace(c) then
            next()
        
        elseif c == END then
            --End statement (;)
            push {
                type = 'end'
            }
            dprint 'End'
            next()    

        elseif c == COMMENT then
            --Comment (,)
            repeat
                next()
            until c == '\n'

        elseif isalpha(c) then
            --Keywords
            local keyw = ""
            repeat
                keyw = keyw .. c
                next()
            until not isalnum(c)
            dprintf("Keyword: %s",keyw)
            push {
                value = keyw,
                type = "keyword"
            }
        elseif c == '&' then
            --Conditional call
            next()
            push {
                type = "cond"
            }

        elseif c == '!' then
            --Inversed contidional call
            next()
            push {
                type = "cond",
                inv = true
            }

        elseif isdigit(c) then
            --Number literals
            local val = ""
            repeat
                val = val .. c
                next()
            until not isdigit(c)

            dprintf("Number: %s",val)
            push {
                value = tonumber(val),
                type = "number"
            }

        elseif c == '@' then
            --Registers
            local reg = ""
            repeat
                reg = reg .. c
                next()
            until not isalnum(c)

            dprintf("Register: %s",reg)
            push {
                value = reg:sub(2),
                type = "register"
            }
        
        elseif c == '"' then
            --String
            local str = ""
            next()
            repeat
                if c == '\\' then
                    --Backslash
                    next()
                    str = str .. escaped[c]
                    
                else
                    str = str .. c
                end
                next()
            until c == '"'
            next()

            dprintf("String: \"%s\"",str)
            push {
                value = str,
                type = "string"
            }

        else
            dprintf("Syntax error: Unexpected '%s'", c)
            next()
        end
    end

    return tokens
end
