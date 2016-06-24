lsm_calls = {}

setmetatable(lsm_calls, {reqs = {}})

local gmt = getmetatable

function lsm_add_call(name, req, call)
    gmt(lsm_calls).reqs[name] = req --add requirements
    lsm_calls[name] = call --add call
end

require "lsm.lib.std"

function lsm_call(what, args, _file,_line)
    if not lsm_calls[what] then
        lsm_error("Attempting to use a nonexistent call", what, _file,_line)
    else
        local reqs = gmt(lsm_calls).reqs[what]
        local min = reqs.min or #reqs

        if #args < min then
            lsm_error(string.format(
                "Not enough arguments supplied to call %s, %i were expected but %i where provided",
                what, min, #args), nil, _file, _line
            )
        end

        for k,r in ipairs(reqs) do
            local a = args[k]

            --print(k,r,a.type,type(a.value))
            if not (
                min == 0 or
                r == "any" or
                r == a.type or
                a.type == "register" and type(a.value) == r
            )
            then
                lsm_error(string.format(
                    "Call '%s': Bad argument #%i; '%s' expected, got '%s'",
                    what, k, r, a.type == "register" and "register: "..type(a.value) or a.type),
                    nil, _file, _line
                )
            end
        end
        _G._file, _G._line = _file,_line 
        s = lsm_calls[what](unpack(args))
        _G._file, _G._line = nil,nil
        return s
    end
end