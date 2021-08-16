local functions = {}

-- rounds the number
function functions.round(number)
	return number >= 0 and math.floor(number + 0.5) or math.ceil(number - 0.5)
end

-- checks if a number is an integer
function functions.isInteger(number)
	return math.floor(number) == number
end

-- random float number
function functions.randomFloat(min, max)
	return min + math.random() * (max - min);
end

-- checks if an file exists
function functions.checkFile(file)
	local test = io.open(file, "rb")
	if test then test:close() end
	return test ~= nil
end

-- reads a file and returns a table with each line as a string
function functions.readFile(file)
	if not functions.checkFile(file) then return {} end
	local lines = {}
	for line in io.lines(file) do
		lines[#lines + 1] = line
	end
	return lines
end

-- ask the user for input and returns it
function functions.askUser(question)
	local question = quesiton or ""
	return io.read()
end

-- run code only if in interpreter
function functions.interpreterCommand(args, code)
	if inInterpreter then
		code()
	else
		print("This command can only be used in the interpreter!")
	end
end

-- print the items from a table
function functions.printTable(list, showIndexes)
	for index, item in pairs(list) do
		local args = {item}
		if showIndexes == nil or showIndexes then
			table.insert(args, 1, index)
		end
		print(table.unpack(args))
	end
end

-- manage outputs and arguments
function functions.firstOfTable(args)
	local output = args[1]
	table.remove(args, 1)
	return output, args
end

return functions
