local index = 1
local program = {}

local data = {
	variables = {},
	lists = {},
	procedures = {},
	labels = {}
}

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
		local stringType = ""

		-- create entries
		for i = 1, #line do
			local character = string.sub(line, i, i)
			if character == '"' or character == "'" then
				if stringType == "" then
					inString = true
					stringType = character
				elseif stringType == character then
					inString = false
					stringType = ""
				else
					entries[#entries] = entries[#entries] .. character
				end
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
				local variable = data.variables[name]
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

-- profroms an operation on each item and returns the product
local function combine(args, code)
	local output, args = functions.firstOfTable(args)
	if output ~= nil then
		local product = args[1] or ""
		table.remove(args, 1)
		for _, number in ipairs(args) do
			product = code(product, number)
		end
		data.variables[output] = tostring(product)
	end
end

commands = {
	-- set variable ~ value
	["set"] = function(args)
		local name = args[1]
		local value = args[2] or ""
		if name ~= nil then
			data.variables[name] = value
		end
	end,

	-- delete variable/list/procedure object
	["delete"] = function(args)
		local objectType = args[1]
		local name = args[2]
		if objectType ~= nil and name ~= nil then
			local typelists = {["variable"] = data.variables, ["list"] = data.lists, ["procedure"] = data.procedures}
			local list = typelists[objectType]
			if list ~= nil then
				list[name] = nil
			end
		end
	end,

	-- list list ...
	["list"] = function(args)
		local name, items = functions.firstOfTable(args)
		data.lists[name] = items
	end,
	
	-- insert list value ~ index
	["insert"] = function(args)
		local name, args = functions.firstOfTable(args)
		local list, value, index = data.lists[name], args[1]
		if list ~= nil and value ~= nil then
			local index = tonumber(args[2]) or #list + 1
			table.insert(list, index, value)
		end
	end,

	-- remove list index
	["remove"] = function(args)
		local name, args = functions.firstOfTable(args)
		local list, index = data.lists[name], tonumber(args[1])
		if list ~= nil and index ~= nil then
			table.remove(list, index)
		else
			throw("missing inputs")
		end
	end,

	-- replace list index value
	["replace"] = function(args)
		local name, args = functions.firstOfTable(args)
		local list, index, value = data.lists[name], tonumber(args[1]), args[2]
		if list ~= nil and index ~= nil and value ~= nil then
			list[index] = value
		end
	end,

	-- item return list index
	["item"] = function(args)
		local output, args = functions.firstOfTable(args)
		local name, args = functions.firstOfTable(args)
		local list, index = data.lists[name], tonumber(args[1])
		if list ~= nil and index ~= nil then
			data.variables[output] = list[index]
		end
	end,

	-- find return list value
	["find"] = function(args)
		local output, args = functions.firstOfTable(args)
		local name, args = functions.firstOfTable(args)
		local list, target = data.lists[name], args[1]
		if output ~= nil and list ~= nil and target ~= nil then
			for index, item in ipairs(list) do
				if item == target then
					data.variables[output] = tostring(index)
				end
			end
		end
	end,

	-- size return list
	["size"] = function(args)
		local output, args = functions.firstOfTable(args)
		local list = data.lists[args[1]]
		if output ~= nil and list ~= nil then
			local size = tostring(#list)
			data.variables[output] = size
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
		end)
	end,

	-- divide return ...
	["divide"] = function(args)
		combine(args, function(out, number)
			local number = tonumber(number) or 1
			return out / number
		end)
	end,

	-- remainder return ...
	["remainder"] = function(args)
		combine(args, function(out, number)
			local number = tonumber(number)
			return out % number
		end)
	end,

	-- round return number ~ up/down
	["round"] = function(args)
		local output, args = functions.firstOfTable(args)
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
		data.variables[output] = tostring(out)
	end,

	-- random return min max
	["random"] = function(args)
		local output, args = functions.firstOfTable(args)
		local min, max, out = tonumber(args[1]), tonumber(args[2]), 0
		if min ~= nil and max ~= nil then
			out = functions.randomFloat(min, max)
		end
		data.variables[output] = tostring(out)
	end,

	-- absolute return number
	["absolute"] = function(args)
		local output, args = functions.firstOfTable(args)
		local number = tonumber(args[1])
		if number ~= nil then
			number = math.abs(number)
		end
		data.variables[output] = tostring(number)
	end,

	-- join return ...
	["join"] = function(args)
		combine(args, function(out, string)
			return out .. string
		end)
	end,

	-- length return string
	["length"] = function(args)
		local output, args = functions.firstOfTable(args)
		local string = args[1] or ""
		data.variables[output] = #string
	end,

	-- sub return string start/letter ~ end
	["sub"] = function(args)
		local output, args = functions.firstOfTable(args)
		local str, start, finish, out = args[1], args[2], args[3], ""
		if str ~= nil and start ~= nil then
			-- input for end
			if finish ~= nil then
				out = string.sub(str, start, finish)
			else
				out = string.sub(str, start, start)
			end
		end
		data.variables[output] = out
	end,

	-- not return boolean
	["not"] = function(args)
		local output, args = functions.firstOfTable(args)
		local boolean = args[1]
		if output ~= nil and boolean ~= nil then
			data.variables[output] = tostring(boolean == "false")
		end
	end,

	-- any return ...
	["any"] = function(args)
		combine(args, function(out, boolean)
			return tostring(out == "true" or boolean == "true")
		end)
	end,

	-- all return ...
	["all"] = function(args)
		combine(args, function(out, boolean)
			return tostring(out == "true" and boolean == "true")
		end)
	end,

	-- equal return ...
	["equal"] = function(args)
		combine(args, function(out, value)
			local outNum, valueNum = tonumber(out), tonumber(value)
			local stateNum = outNum ~= nil and valueNum ~= nil
			return stateNum and (outNum == valueNum) or (out == value)
		end)
	end,

	-- order return ...
	["order"] = function(args)
		local output, args = functions.firstOfTable(args)
		local statement = false
		if output ~= nil then
			local previous = args[1] or ""
			previous = tonumber(previous) or previous
			table.remove(args, 1)
			for _, item in ipairs(args) do
				local item = tonumber(item) or item
				statement = previous > item
				previous = tonumber(item) or item
			end
			data.variables[output] = tostring(statement)
		end
	end,

	-- goto line
	["goto"] = function(args)
		local line = tonumber(args[1]) or data.labels[args[1]]
		if line ~= nil then
			index = line - 1
		end
	end,

	-- goif truth if_line ~ else_line
	["goif"] = function(args)
		local state = args[1]
		local ifLine = tonumber(args[2]) or data.labels[args[2]]
		local elseLine = tonumber(args[3]) or data.labels[args[3]]
		if state == "true" and ifLine ~= nil then
			index = ifLine - 1
		elseif elseLine ~= nil then
			index = elseLine - 1
		end
	end,
	
	-- label name ~ index
	["label"] = function(args)
		local name = args[1]
		local index = args[2] or index
		if name ~= nil then
			data.labels[name] = index
		end
	end,

	-- check return truth if_value ~ else_value
	["check"] = function(args)
		local output, args = functions.firstOfTable(args)
		local state, ifValue, elseValue = args[1], args[2], args[3]
		if state == "true" and ifValue ~= nil then
			data.variables[output] = ifValue
		elseif elseValue ~= nil then
			data.variables[output] = elseValue
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
			local anwser = io.read() or ""
			data.variables[output] = anwser
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
		else
			print("command error, check if strings.lua exists")
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
		else
			print("invalid or missing file")
		end
	end,

	-- reset
	["reset"] = function(args)
		data = {variables = {}, lists = {}, procedures = {}, labels = {}}
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
			data.procedures[name] = {block, args[2]}
		end
	end,

	-- call name ...
	["call"] = function(args)
		local name, args = functions.firstOfTable(args)
		local procedure = data.procedures[name]
		if procedure ~= nil then
			-- run procedure
			local code, input = procedure[1], procedure[2]
			if code ~= nil then
				if input ~= nil then
					data.lists[input] = args
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
	local command = io.read() or ""
	local name, args = parse(command)
	call(name, args)
end
