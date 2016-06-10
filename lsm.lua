local lex = require "lex"
local parse = require "parse"
local exec = require "exec"

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
