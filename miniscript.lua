local index = 1
local program = {}
local variables = {}
local lists = {}
local procedures = {}

-- define commands and functions
-- additional input are ~, endless inputs are ..., option inputs are /

local commands = {}
local functions = require("functions")
local strings = require("strings")

-- generate name and arguments with line
local function parse(line)
	-- check if comments
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
		for index, item in pairs(entries) do
			if string.sub(item, 1, 1) == "$" then
				local name = string.sub(item, 2)
				local variable = variables[name]
				entries[index] = (variable ~= nil and variable or "")
			end
		end

		local name = entries[1]
		table.remove(entries, 1)
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

-- manage outputs and arguments
local function varReturn(args)
	local output = args[1]
	table.remove(args, 1)
	return output, args
end

-- profroms an operation on each item and returns the product
local function combine(args, code, product)
	local output, args = varReturn(args)
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

commands = {
	-- set variable ~ value
	["set"] = function(args)
		local name = args[1]
		local value = args[2] or ""
		if name ~= nil then
			variables[name] = value
		end
	end,

	-- delete variable/list/procedure object
	["delete"] = function(args)
		local objectType = args[1]
		local name = args[2]
		if objectType ~= nil and name ~= nil then
			local typeLists = {["variable"] = variables, ["list"] = lists, ["procedure"] = procedures}
			local list = typeLists[objectType]
			if list ~= nil then
				list[name] = nil
			end
		end
	end,

	-- list list ...
	["list"] = function(args)
		local name, items = varReturn(args)
		lists[name] = items
	end,
	
	-- insert list value ~ index
	["insert"] = function(args)
		local name, args = varReturn(args)
		local list, value, index = lists[name], args[1]
		if list ~= nil and value ~= nil then
			local index = tonumber(args[2]) or #list + 1
			table.insert(list, index, value)
		end
	end,

	-- remove list index
	["remove"] = function(args)
		local name, args = varReturn(args)
		local list, index = lists[name], tonumber(args[1])
		if list ~= nil and index ~= nil then
			table.remove(list, index)
		end
	end,

	-- replace list index value
	["replace"] = function(args)
		local name, args = varReturn(args)
		local list, index, value = lists[name], tonumber(args[1]), args[2]
		if list ~= nil and index ~= nil and value ~= nil then
			list[index] = value
		end
	end,

	-- item return list index
	["item"] = function(args)
		local output, args = varReturn(args)
		local name, args = varReturn(args)
		local list, index = lists[name], tonumber(args[1])
		if list ~= nil and index ~= nil then
			variables[output] = list[index]
		end
	end,

	-- find return list value
	["find"] = function(args)
		local output, args = varReturn(args)
		local name, args = varReturn(args)
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
		local output, args = varReturn(args)
		local list = lists[args[1]]
		if list ~= nil then
			local size = tostring(#list)
			variables[output] = size
		end
	end,

	-- add return ...
	["add"] = function(args)
		combine(args, function(out, number)
			local number = tonumber(number) or 0
			return out + number
		end)
	end,

	-- subtract return ...
	["subtract"] = function(args)
		combine(args, function(out, number)
			local number = tonumber(number) or 0
			return out - number
		end)
	end,

	-- multiply return ...
	["multiply"] = function(args)
		combine(args, function(out, number)
			local number = tonumber(number) or 1
			return out * number
		end, 1)
	end,

	-- divide return ...
	["divide"] = function(args)
		combine(args, function(out, number)
			local number = tonumber(number) or 1
			return out / number
		end, "!FIRST")
	end,

	-- remainer return ...
	["remainer"] = function(args)
		combine(args, function(out, number)
			local number = tonumber(number)
			return out % number
		end, "!FIRST")
	end,

	-- round return number ~ up/down
	["round"] = function(args)
		local output, args = varReturn(args)
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
		local output, args = varReturn(args)
		local min, max, out = tonumber(args[1]), tonumber(args[2]), 0
		if min ~= nil and max ~= nil then
			out = functions.randomFloat(min, max)
		end
		variables[output] = tostring(out)
	end,

	-- absolute return number
	["absolute"] = function(args)
		local output, args = varReturn(args)
		local number = tonumber(args[1])
		if number ~= nil then
			number = math.abs(number)
		end
		variables[output] = tostring(number)
	end,

	-- join return ...
	["join"] = function(args)
		combine(args, function(out, string)
			return out .. string
		end, "")
	end,

	-- length return string
	["length"] = function(args)
		local output, args = varReturn(args)
		local string = args[1] or ""
		variables[output] = #string
	end,

	-- sub return string start/letter ~ end
	["sub"] = function(args)
		local output, args = varReturn(args)
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
		local output, args = varReturn(args)
		local boolean = args[1]
		if boolean ~= nil then
			variables[output] = tostring(boolean == "false")
		end
	end,

	-- any return ...
	["any"] = function(args)
		combine(args, function(out, boolean)
			return tostring(out == "true" or boolean == "true")
		end, "!FIRST")
	end,

	-- all return ...
	["all"] = function(args)
		combine(args, function(out, boolean)
			return tostring(out == "true" and boolean == "true")
		end, "!FIRST")
	end,

	-- equal return ...
	["equal"] = function(args)
		combine(args, function(out, value)
			local outNum, valueNum = tonumber(out), tonumber(value)
			local stateNum = outNum ~= nil and valueNum ~= nil
			return stateNum and (outNum == valueNum) or (out == value)
		end, "!FIRST")
	end,

	-- order return ...
	["order"] = function(args)
		combine(args, function(out, value)
			local outNum, valueNum = tonumber(out), tonumber(value)
			local stateNum = outNum ~= nil and valueNum ~= nil
			return stateNum and (outNum > valueNum) or (out > value)
		end, "!FIRST")
	end,

	-- goto line
	["goto"] = function(args)
		local line = tonumber(args[1])
		if line ~= nil then
			index = line - 1
		end
	end,
	
	-- step line
	["step"] = function(args)
		local count = tonumber(args[1])
		if line ~= nil then
			index = index + (line - 1)
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
		local output, args = varReturn(args)
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
	end,
	
	-- about
	["about"] = function(args)
		functions.printTable(strings.about, false)
	end,
	
	-- help ~ command
	["help"] = function(args)
		local help, command = strings.help, args[1]
		if help ~= nil then
			if command ~= nil then
				local commandTable = help[command]
				functions.printTable(commandTable, false)
			else
				local output = {}
				for name, _ in pairs(help) do
					table.insert(output, name)
				end
				print("commands: #" .. #output)
				functions.printTable(output)
			end
		end
	end,

	-- run path
	["run"] = function(args)
		local path = args[1] or ""
		if functions.checkFile(path) then
			program = functions.readFile(path)
			index = 1
			while index <= #program do
				local line = program[index]
				local name, args = parse(line)
				call(name, args)
				index = index + 1
			end
		end
	end,

	-- reset
	["reset"] = function(args)
		variables, lists = {}, {}
	end,

	-- parse line
	["parse"] = function(args)
		local line = args[1]
		if line ~= nil then
			local name, args = parse(line)
			call(name, args)
		end
	end,

	-- define name ~ inputs
	["define"] = function(args)
		local name, inputs = args[1], args[2]
		if name ~= nil then
			local line = ""
			local block = {}
			repeat
				index = index + 1
				line = program[index]
				table.insert(block, line)
			until string.sub(line, 1, 3) == "end"
			procedures[name] = {block, args[2]}
		end
	end,

	-- call name ...
	["call"] = function(args)
		local name, args = varReturn(args)
		local procedure = procedures[name]
		if procedure ~= nil then
			-- run procedure
			local code, input = procedure[1], procedure[2]
			if code ~= nil then
				if input ~= nil then
					lists[input] = args
				end
				local previous = index
				index = 1
				for _, line in ipairs(code) do
					local name, args = parse(line)
					call(name, args)
					index = index + 1
				end
				index = previous
			end
		end
	end,
	
	-- if truth if_line ~ else_line
	["if"] = function(args)
		local truth, ifValue, elseValue = args[1], args[2], args[3]
		if truth == "true" and ifValue ~= nil then
			local name, args = parse(ifValue)
			call(name, args)
		elseif elseValue ~= nil then
			local name, args = parse(elseValue)
			call(name, args)
		end
	end
}

-- interpreter loop
functions.printTable(strings.start, false)
while true do
	local command = functions.askUser() or ""
	local name, args = parse(command)
	call(name, args)
end
