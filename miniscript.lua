local index = 1
local variables = {}
local lists = {}

-- define commands and functions
-- additional input are ~, endless inputs are ..., option inputs are /

local functions = {}

-- manage outputs and arguments
function functions.varReturn(args)
	local output = args[1]
	table.remove(args, 1)
	return output, args
end

-- profroms an operation on each item and returns the product
function functions.combine(args, code, product)
	local output, args = functions.varReturn(args)
	local product = product or 0
	if product == "!FIRST" then
		product = args[1]
		table.remove(args, 1)
	end
	
	for _, number in ipairs(args) do
		product = code(product, number)
	end
	variables[output] = tostring(product)
end

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
	--print(quesiton)
	return io.read()
end

commands = {
	-- set variable ~ value
	["set"] = function(args)
		local name = args[1]
		local value = args[2] or ""
		if name ~= nil then
			variables[name] = value
		end
	end,
	
	-- delete variable
	["delete"] = function(args)
		local name = args[1]
		if name ~= nil then
			variables[name] = nil
		end
	end,
	
	-- list list ...
	["list"] = function(args)
		local name, items = functions.varReturn(args)
		lists[name] = items
	end,
	
	-- delist list
	["delist"] = function(args)
		local name = args[1] or ""
		lists[name] = nil
	end,
	
	-- insert list value ~ index
	["insert"] = function(args)
		local name, args = functions.varReturn(args)
		local list, value, index = lists[name], args[1]
		if list ~= nil and value ~= nil then
			local index = tonumber(args[2]) or #list + 1
			table.insert(list, index, value)
		end
	end,
	
	-- remove list index
	["remove"] = function(args)
		local name, args = functions.varReturn(args)
		local list, index = lists[name], tonumber(args[1])
		if list ~= nil and index ~= nil then
			table.remove(list, index)
		end
	end,
	
	-- replace list index value
	["replace"] = function(args)
		local name, args = functions.varReturn(args)
		local list, index, value = lists[name], tonumber(args[1]), args[2]
		if list ~= nil and index ~= nil and value ~= nil then
			list[index] = value
		end
	end,
	
	-- item return list index
	["item"] = function(args)
		local output, args = functions.varReturn(args)
		local name, args = functions.varReturn(args)
		local list, index = lists[name], tonumber(args[1])
		if list ~= nil and index ~= nil then
			variables[output] = list[index]
		end
	end,
	
	-- find return list value
	["find"] = function(args)
		local output, args = functions.varReturn(args)
		local name, args = functions.varReturn(args)
		local list, target = lists[name], args[1]
		if list ~= nil and target ~= nil then
			for index, item in ipairs(list) do
				if item == target then
					variables[output] = tostring(index)
				end
			end
		end
	end,
	
	-- size return list
	["size"] = function(args)
		local output, args = functions.varReturn(args)
		local list = lists[args[1]]
		if list ~= nil then
			local size = tostring(#list)
			variables[output] = size
		end
	end,
	
	-- add return ...
	["add"] = function(args)
		functions.combine(args, function(out, number)
			return out + tonumber(number)
		end)
	end,
	
	-- subtract return ...
	["subtract"] = function(args)
		functions.combine(args, function(out, number)
			return out - tonumber(number)
		end)
	end,
	
	-- multiply return ...
	["multiply"] = function(args)
		functions.combine(args, function(out, number)
			return out * tonumber(number)
		end, 1)
	end,
	
	-- divide return ...
	["divide"] = function(args)
		functions.combine(args, function(out, number)
			return out / tonumber(number)
		end, "!FIRST")
	end,
	
	-- remainer return ...
	["remainer"] = function(args)
		functions.combine(args, function(out, number)
			return out % tonumber(number)
		end, "!FIRST")
	end,
	
	-- round return number ~ up/down
	["round"] = function(args)
		local output, args = functions.varReturn(args)
		local number, force, out = tonumber(args[1]), args[2], 0
		if number ~= nil then
			if force ~= nil then
				-- get function depending if up or down
				local mathFunction = force == "up" and math.ceil or (force == "down" and math.floor or nil)
				if mathFunction ~= nil then
					out = mathFunction(number)
				end
			else
				out = functions.round(number)
			end
		end
		variables[output] = tostring(out)
	end,
	
	-- random return min max
	["random"] = function(args)
		local output, args = functions.varReturn(args)
		local min, max, out = tonumber(args[1]), tonumber(args[2]), 0
		if min ~= nil and max ~= nil then
			out = functions.randomFloat(min, max)
		end
		variables[output] = tostring(out)
	end,
	
	-- absolute return number
	["absolute"] = function(args)
		local output, args = functions.varReturn(args)
		local number = tonumber(args[1])
		if number ~= nil then
			number = math.abs(number)
		end
		variables[output] = tostring(number)
	end,
	
	-- join return ...
	["join"] = function(args)
		functions.combine(args, function(out, string)
			return out .. string
		end, "")
	end,
	
	-- length return string
	["length"] = function(args)
		local output, args = functions.varReturn(args)
		local string = args[1] or ""
		variables[output] = #string
	end,
	
	-- sub return string start/letter ~ end
	["sub"] = function(args)
		local output, args = functions.varReturn(args)
		local str, start, finish, out = args[1], args[2], args[3], ""
		if str ~= nil and start ~= nil then
			-- input for end
			if finish ~= nil then
				out = string.sub(str, start, finish)
			else
				out = string.sub(str, start, start)
			end
		end
		variables[output] = out
	end,
	
	-- not return boolean
	["not"] = function(args)
		local output, args = functions.varReturn(args)
		local boolean = args[1]
		if boolean ~= nil then
			variables[output] = tostring(boolean == "false")
		end
	end,
	
	-- any return ...
	["any"] = function(args)
		functions.combine(args, function(out, boolean)
			return tostring(out == "true" or boolean == "true")
		end, "!FIRST")
	end,
	
	-- all return ...
	["all"] = function(args)
		functions.combine(args, function(out, boolean)
			return tostring(out == "true" and boolean == "true")
		end, "!FIRST")
	end,
	
	-- equal return ...
	["equal"] = function(args)
		functions.combine(args, function(out, value)
			local outNum, valueNum = tonumber(out), tonumber(value)
			local stateNum = outNum ~= nil and valueNum ~= nil
			return stateNum and (outNum == valueNum) or (out == value)
		end, "!FIRST")
	end,
	
	-- order return ...
	["order"] = function(args)
		functions.combine(args, function(out, value)
			local outNum, valueNum = tonumber(out), tonumber(value)
			local stateNum = outNum ~= nil and valueNum ~= nil
			return stateNum and (outNum > valueNum) or (out > value)
		end, "!FIRST")
	end,
	
	-- goto line
	["goto"] = function(args)
		local line = args[1]
		line = tonumber(line)
		if line ~= nil then
			index = line - 1
		end
	end,
	
	-- goif truth if_line ~ else_line
	["goif"] = function(args)
		local state = args[1]
		local ifLine = tonumber(args[2])
		local elseLine = tonumber(args[3])
		
		if state == "true" and ifLine ~= nil then
			index = ifLine - 1
		elseif elseLine ~= nil then
			index = elseLine - 1
		end
	end,
	
	-- check return truth if_value ~ else_value
	["check"] = function(args)
		local output, args = functions.varReturn(args)
		local state, ifValue, elseValue = args[1], args[2], args[3]
		if state == "true" and ifValue ~= nil then
			variables[output] = ifValue
		elseif elseValue ~= nil then
			variables[output] = elseValue
		end
	end,
	
	-- print string
	["print"] = function(args)
		print(table.unpack(args))
	end,
	
	-- ask return
	["ask"] = function(args)
		local output = args[1]
		if output ~= nil then
			local anwser = functions.askUser()
			variables[output] = anwser
		end
	end
}

-- generate name and arguments with line
local function parse(line)
	if string.sub(line, 1, 1) ~= "#" then
		local entries = {""}
		local inString = false
	
		-- create entries
		for i = 1, #line do
			local character = string.sub(line, i, i)
			if character == '"' then
				inString = not inString
			elseif character == " " and not inString then
				table.insert(entries, "")
			else
				entries[#entries] = entries[#entries] .. character
			end
		end
	
		-- get name and variables
		local name = entries[1]
		table.remove(entries, 1)
		for index, item in pairs(entries) do
			if string.sub(item, 1, 1) == "$" then
				local name = string.sub(item, 2)
				local variable = variables[name]
				entries[index] = (variable ~= nil and variable or "")
			end
		end
		return name, entries
	end
	return "", {}
end

-- gets the respective command then run it
local function call(name, args)
	local command = commands[name]
	if command ~= nil then
		command(args)
	end
end

-- runs the script
local function run(script)
	index, variables, lists = 1, {}, {}
	while index <= #script do
		local line = script[index]
		call(parse(line))
		index = index + 1
	end
end

-- interpreter loop
print("miniscript interpreter, enter a name of program")
while true do
	local programName = functions.askUser() or ""
	local program = functions.readFile(programName)
	run(program)
	print()
end
