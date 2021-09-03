local data = require("modules/data")
local functions = require("modules/functions")
local parser = require("modules/parser")

local runCommand = data.runCommand
local introText = [[MiniScript Interpreter 2.0
Type "run" with path to run a program
Type "help" to list all commands
Type "about" for info on MiniScript]]

print(introText)

while true do
	local input = io.read() or ""
	local text = parser.cleanUpString(input)
	if string.gsub(text, "%s+", "") ~= "" then
		local tokens = parser.tokenizer(text)
		local set = parser.generate(tokens)
		local output = data.runCommand(set)
		if output ~= nil then
			print(tostring(output))
		end
	end
end
