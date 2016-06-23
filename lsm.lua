#!/bin/env lua

local lex = require "lex"
local parse = require "parse"
local exec = require "exec"

lsm_version = "0.0.1"

local function eprintf(_,...) io.stderr:write(_:format(...)) end

function lsm_error(str, err,f,ln)
    err = err and (": ['%s']"):format(err) or ""

    eprintf(
        "lsm: Error: \n    %s%s\n    in %s:%i\n    at %s\n", str, err, f, ln, lsm_stage
    )
    os.exit(1)
end

local opt = {
    h = function()
        eprintf(
[=[Usage: %s [OPTION] [FILE]
Available options are:
    -h    Show this help message and exit
    -v    Show version information and exit
    -d    Debug mode
]=],
    arg[0])
    end,

    v = function()
        eprintf("lsm %s", lsm_version)
    end,

    d = function()
        dprint = print
        dprintf = function(s,...)
            print(s:format(...))
        end
        inspect = require "inspect"
    end
}

dprint  = function()end
dprintf = function()end
inspect = function()end

local file
local lsm_args = {}

for k,a in ipairs(arg) do
    if a:sub(1,1) == '-' then
        opt[a:sub(2)]()

    else
        if not file then
            --execute lsm file
            file = a
            local fp,err = io.open(a)
            if fp then
                io.input(fp)
            else
                eprintf("%s: Error: File %s can't be read [%s]\n",arg[0],a,err)
            end
        else
            --args for lsm program
            lsm_args[#lsm_args+1] = a
        end
    end
end

local data = io.read("*a")

if not file then file = "<stdin>" end

local tokens = lex(data, file)

local ast = parse(tokens, file)

exec(ast, lsm_args)
