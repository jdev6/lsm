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

local function lex(data, file)
    local i = 1
    local c
    local tokens = {}

    local function next() i=i+1; c = data:sub(i,i) end
    local function push(tok) table.insert(tokens,tok) end

    dprint '---lex---'
    push {
        type = "file",
        value = file
    }
    local line = 1
    while i <= #data do
        c = data:sub(i,i)

        if isspace(c) then
            if c == '\n' then
                --add line
                line = line + 1
                push {
                    type = 'line'
                }
            end
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

        elseif c == '[' then
            --Begin preproccessor directive
            local dirargs = {}

            --Skip spaces
            repeat next() until not isspace(c)

            --Proccess preprocessor directive arguments
            repeat
                local arg = ""
                repeat
                    arg = arg .. c
                    next()
                until isspace(c) or c == ']'
                --Skip spaces
                if c ~= ']' then
                    repeat next() until not isspace(c)
                end
                dprint("dirarg",arg)
                table.insert(dirargs, arg)
            until c == ']'
            next()

            --Execute preproccessor directive:
            if dirargs[1] == "source" then
                --Source
                local lexedsources = {}
                for k,file in ipairs(dirargs) do
                    if k ~= 1 then
                        local fp,err = io.open(file)
                        if fp then
                            local data = fp:read("*a")
                            lexedsources[k-1] = lex(data, file)
                        else
                            --Error opening file
                            lsm_error("#nCannot open file: ["..err.."] in "..file..":"..line)
                        end
                    end
                end

                for n,lexsrc in ipairs(lexedsources) do
                    for k,tok in ipairs(lexsrc) do
                        table.insert(tokens, tok)
                    end
                end

                push {
                    type = "file",
                    value = file
                }
            end

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
            lsm_error("#nSyntax error: Unexpected '"..c.."' in "..file..":"..line)
            next()
        end
    end

    return tokens
end

return lex
