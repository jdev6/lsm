#!/bin/env lua

local lex = require "lex"
local parse = require "parse"
local exec = require "exec"

lsm_version = "0.0.1"

local eprintf = function(_,...) io.stderr:write(_:format(...)) end

local opt = {
    h = function()
        eprintf(
[=[Usage: %s [OPTION] [FILE]
Available options are:
    -h    Show this help message and exit
    -v    Show version information and exit
]=],
    arg[0])
    end,

    v = function()
        eprintf("lsm %s", lsm_version)
    end
}

for k,a in ipairs(arg) do
    if a:sub(1,1) == '-' then
        opt[a:sub(2)]()

    else
        local fp,err = io.open(a)
        if fp then
            io.input(fp)
        else
            eprintf("%s: Error: File %s can't be read [%s]",arg[0],a,err)
        end
    end
end
DEBUG = false
if DEBUG then
    dprint = print
else
    dprint = function() end
end

local data = io.read("*a")

local tokens = lex(data)

local ast = parse(tokens)

exec(ast)
