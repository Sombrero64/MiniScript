local data = require("modules/data")
local run = data.runLine

print([[MiniScript Interpreter 2.1
Type "run" with path to run a program
Type "about" for info on MiniScript]])

while true do
	local input = io.read() or ""
	local output = run(input)
	print(tostring(output))
end