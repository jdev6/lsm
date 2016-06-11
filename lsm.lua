#!/bin/env lua

local lex = require "lex"
local parse = require "parse"
local exec = require "exec"

lsm_version = "0.0.1"

local eprintf = function(_,...) io.stderr:write(_:format(...)) end

function lsm_error(errstr)
    io.stderr:write("lsm: Error:"..errstr:gsub("#n","\n    ").."\n")
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
    end
}

dprint = function()end

local file

for k,a in ipairs(arg) do
    if a:sub(1,1) == '-' then
        opt[a:sub(2)]()

    else
        file = a
        local fp,err = io.open(a)
        if fp then
            io.input(fp)
        else
            eprintf("%s: Error: File %s can't be read [%s]\n",arg[0],a,err)
        end
    end
end

local data = io.read("*a")

local tokens = lex(data, file)

local ast = parse(tokens)

exec(ast)
