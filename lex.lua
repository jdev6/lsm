require "is"

local COMMENT  = ','
local END      = ';'
local LABEL    = '>'
local COND     = '&'
local CONDINV  = '!'
local BEGINPRD = '[' --begin preprocessor directive
local ENDPRD   = ']' --end
local REGISTER = '@'

local escaped = {
    ['n'] = '\n',
    ['"'] = '"',
    ['r'] = '\r',
    ['v'] = '\v',
    ['t'] = '\t',
    ['f'] = '\f',
    ['\n'] = ''
}

local function lex(data, file)
    lsm_stage = "lexer"

    local i = 1
    local c
    local tokens = {}
    local currfile = file
    local fileslns = { [currfile] = 1 } --each file and its lines

    local function push(tok)
        table.insert(tokens,tok)
    end

    local function next()
        i=i+1
        c = data:sub(i,i) 
        if c == '\n' then
                --add line
                fileslns[currfile] = fileslns[currfile] + 1 
                push {
                    type = 'line'
                }
        end
    end

    dprint '---lex---'
    push {
        type = "file",
        value = file
    }
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
            until c == '\n' or c == ''

        elseif c == LABEL then
            --Label (>)
            local label = ""
            next()
            repeat
                label = label .. c
                next()
            until not (isalnum(c) or c == '_')
            dprintf("Label: %s", label)
            push {
                type = "label",
                value = label
            }

        elseif c == BEGINPRD then
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
                until isspace(c) or c == ENDPRD
                --Skip spaces
                if c ~= ENDPRD then
                    repeat next() until not isspace(c)
                end
                dprint("dirarg",arg)
                table.insert(dirargs, arg)
            until c == ENDPRD
            next()

            --Execute preproccessor directive:

            if dirargs[1] == "source" then
                --Source
                local oldfile = currfile
                local lexedsources = {}
                for k,file in ipairs(dirargs) do
                    if not fileslns[file] then
                        if k ~= 1 then
                            local fp,err = io.open(file)
                            if fp then
                                --Try to read file
                                local data = fp:read("*a")
                                local nfileslns
                                lexedsources[k-1], nfileslns = lex(data, file)

                                for k,v in ipairs(nfileslns) do
                                    fileslns[k] = v
                                end

                            else
                                --Error opening file
                                lsm_error("Cannot open file ", err,currfile,fileslns[currfile])
                            end
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
                    value = oldfile
                }
            elseif dirargs[1] == "line" then
                --line
                push {
                    type = "number",
                    value = fileslns[currfile]
                }

            elseif dirargs[1] == "file" then
                --file
                push {
                    type = "string",
                    value = currfile
                }
            end

        elseif isalpha(c) or c == '_' then
            --Keywords
            local keyw = ""
            repeat
                keyw = keyw .. c
                next()
            until not (isalnum(c) or c == '_')

            dprintf("Keyword: %s",keyw)
            push {
                value = keyw,
                type = "keyword"
            }
        elseif c == COND then
            --Conditional call
            next()
            push {
                type = "cond"
            }

        elseif c == CONDINV then
            --Inversed contidional call
            next()
            push {
                type = "cond",
                inv = true
            }

        elseif isdigit(c) or c == '.' or c == '-' then
            --Number literals
            local val = ""
            repeat
                val = val .. c
                next()
            until not (isdigit(c) or c == '.' or c == 'x')

            local nval = tonumber(val)
            if not nval then
                lsm_error("Invalid number", val, currfile,fileslns[currfile])
            end
            dprintf("Number: %i",nval)
            push {
                value = nval,
                type = "number"
            }

        elseif c == REGISTER then
            --Registers
            local reg = ""
            next()
            repeat
                reg = reg .. c
                next()
            until not (isalnum(c) or c == '_')

            dprintf("Register: %s",reg)
            push {
                value = reg,
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
            lsm_error("Unexpected "..c, "Syntax error", currfile,fileslns[currfile])
            --lsm_error("#nSyntax error: Unexpected '"..c.."' in "..file..":"..line)
            next()
        end
    end

    return tokens, fileslns
end

return lex
