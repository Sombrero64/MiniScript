local content = {
	-- program data
	["data"] = {
		["commands"] = {}, -- [name] = function(args)
		["variables"] = {}, -- [name] = value
		["procedures"] = {}, -- [name] = {code, inputs name}
		["labels"] = {} -- [name] = value
	},
	-- program info
	["program"] = {
		-- contents of the program
		["contents"] = {},
		-- program line number
		["index"] = 1,
		-- procedure output
		["report"] = "",
		-- procedure break
		["break"] = false,
		-- previous goto line
		["prev goto"] = 0
	},
	-- interpreter info
	["interpreter"] = {
		-- program path
		["filepath"] = ""
	}
}

local functions = require("modules/functions")
local parser = require("modules/parser")

local sub = string.sub
local nilCheck = functions.nilCheck

local calculate_operators = {
	["abs"] = math.abs, ["sqrt"] = math.sqrt, ["log"] = math.log, ["pow"] = math.pow,
	["sin"] = math.sin, ["cos"] = math.cos, ["tan"] = math.tan,
	["asin"] = math.asin, ["acos"] = math.acos, ["atan"] = math.atan
}

local list_edit_commands = {
	["add"] = function(list, x, y) -- (edit LIST add VALUE ~ INDEX)
		local y = tonumber(y) or #list + 1
		table.insert(list, y, x)
		return list
	end, ["del"] = function(list, x, y) -- (edit LIST del INDEX)
		local x = tonumber(x) or #list
		table.remove(list, x)
		return list
	end, ["set"] = function(list, x, y) -- (edit LIST set INDEX VALUE)
		local x = tonumber(x) or #list
		local y = y or ""
		list[x] = y
		return list
	end
}

-- get and return program data, define it if not found
local function getDataType(typeName, name, default)
	local name = name or ""
	local dtTable = content["data"][typeName]
	local dtItem = dtTable[name]
	if dtItem == nil then
		dtTable[name] = default
		dtItem = dtTable[name]
	end
	return dtItem 
end

-- get and return procedure, define it if not found
function content.getProcedure(name)
	return getDataType("procedures", name, {{}, ""})
end

-- check if comparable as numbers
local function comparableAsNumbers(inputs)
	for _, item in ipairs(inputs) do
		if tonumber(item) == nil then
			return false
		end
	end
	return true
end

-- combines each item and returns the result
local function combine(inputs, code)
	if #inputs >= 1 then
		local product = inputs[1] or ""
		table.remove(inputs, 1)
		for _, item in ipairs(inputs) do
			product = code(product, item)
		end
		return tostring(product)
	end
	return ""
end

-- compare each item and returns the result
local function gate(inputs, code)
	local ifNumbers = comparableAsNumbers(inputs)
	local previous = inputs[1]
	table.remove(inputs, 1)
	local condition = false
	
	for _, item in ipairs(inputs) do
		if ifNumbers then
			local x = tonumber(previous) or 0
			local y = tonumber(item) or 0
			condition = code(x, y)
		else
			condition = code(previous, item)
		end
		previous = item
	end
	
	return tostring(condition)
end

-- runs a command, used to run line
function content.runCommand(tokens)
	-- get command and inputs
	local name, inputs = "", {}
	for index, item in ipairs(tokens) do
		-- repeat function if table
		local value = item
		if type(item) == "table" then
			value = content.runCommand(item) or ""
		end
		
		-- set nil values to empty strings
		if value == nil then
			value = ""
		end
		
		-- get value of variable
		if sub(value, 1, 1) == "$" then
			local name = sub(value, 2) or ""
			local variable = content["data"]["variables"][name]
			value = variable or ""
		end
		
		-- push as command name or an input
		if index == 1 then
			name = value
		else
			table.insert(inputs, value)
		end
	end
	
	-- get and run command or procedure, then return result
	local command = content["data"]["commands"][name] or content.getProcedure(name)
	if type(command) == "function" then -- command
		local output = command(inputs)
		return output
	elseif type(command) == "table" then -- procedure
		local code, name = command[1], command[2] or ""
		content["data"]["variables"][name] = functions.encode(inputs) or {}
		
		local previous = content["program"]["index"]
		content["program"]["index"] = 0
		repeat
			content["program"]["index"] = content["program"]["index"] + 1
			local number = content["program"]["index"]
			local line = code[number] or ""
			local text = parser.cleanUpString(line)
			
			if string.gsub(line, "%s+", "") ~= "" then
				local tokens = parser.tokenizer(text)
				local set = parser.generate(tokens)
				local value = content.runCommand(set)
			end
			
			if content["program"]["break"] == true then
				content["program"]["break"] = false
				break
			end
		until content["program"]["index"] > #code
		
		content["program"]["index"] = previous
		return content["program"]["report"] or ""
	end
	return nil
end

-- runs a line
function content.runLine(line)
	local text = parser.cleanUpString(line)
	if string.gsub(line, "%s+", "") ~= "" then
		local tokens = parser.tokenizer(text)
		local set = parser.generate(tokens)
		return content.runCommand(set) or ""
	end
end

-- runs each line in data.program.contents
local function runContents()
	content["program"]["index"] = 1
	while content["program"]["index"] <= #content["program"]["contents"] do
		local number = content["program"]["index"]
		local line = content["program"]["contents"][number] or ""
		content.runLine(line)
		content["program"]["index"] = content["program"]["index"] + 1
	end
end

-- additional input are ~, endless inputs are ..., option inputs are /, code blocks are ;
content["data"]["commands"] = {
	-- var NAME VALUE
	["var"] = function(inputs)
		local name, value = inputs[1], inputs[2]
		if nilCheck(name, value) then
			content["data"]["variables"][name] = value
		end
	end,
	
	-- del TYPE ~ NAME
	["del"] = function(inputs)
		local typeEntry, name = inputs[1], inputs[2]
		local types = {"variable", "list", "label"}
		if typeEntry ~= nil then
			if typeEntry == "all" then
				for _, value in ipairs(types) do
					content["data"][value .. "s"] = {}
				end
			elseif name ~= nil and functions.contains(types, typeEntry) then
				content["data"][typeEntry .. "s"][name] = nil
			end
		end
	end,
	
	-- (list ...)
	["list"] = function(inputs)
		return functions.encode(inputs)
	end,
	
	-- (edit LIST TYPE X ~ Y)
	["edit"] = function(inputs)
		local list = inputs[1] or ""
		local func = inputs[2] or ""
		local x = inputs[3]
		local y = inputs[4] or ""
		
		list = functions.decode(list)
		func = list_edit_commands[func]
		
		if functions.nilCheck(list, func, x) then
			list = func(list, x, y) or {}
			return functions.encode(list)
		end
	end,
	
	-- (get LIST ~ INDEX)
	["get"] = function(inputs)
		local list = inputs[1] or ""
		list = functions.decode(list)
		local index = tonumber(inputs[2]) or #list
		return list[index] or ""
	end,
	
	-- (find LIST VALUE)
	["find"] = function(inputs)
		local list = inputs[1] or ""
		list = functions.decode(list)
		local target = inputs[2] or ""
		local index = functions.find(list, target) or 0
		return tostring(index)
	end,
	
	-- (size LIST)
	["size"] = function(inputs)
		local list = inputs[1] or ""
		list = functions.decode(list)
		return tostring(#list)
	end,
	
	-- (+ ...)
	["+"] = function(inputs)
		return combine(inputs, function(a, b)
			local a = tonumber(a) or 0
			local b = tonumber(b) or 0
			return a + b
		end)
	end,
	
	-- (- ...)
	["-"] = function(inputs)
		return combine(inputs, function(a, b)
			local a = tonumber(a) or 0
			local b = tonumber(b) or 0
			return a - b
		end)
	end,
	
	-- (* ...)
	["*"] = function(inputs)
		return combine(inputs, function(a, b)
			local a = tonumber(a) or 1
			local b = tonumber(b) or 1
			return a * b
		end)
	end,
	
	-- (/ ...)
	["/"] = function(inputs)
		return combine(inputs, function(a, b)
			local a = tonumber(a) or 1
			local b = tonumber(b) or 1
			return a / b
		end)
	end,
	
	-- (% ...)
	["%"] = function(inputs)
		return combine(inputs, function(a, b)
			local a = tonumber(a) or 1
			local b = tonumber(b) or 1
			return a % b
		end)
	end,
	
	-- (join ...)
	["join"] = function(inputs)
		return combine(inputs, function(a, b)
			return a .. b
		end)
	end,

	-- (round NUMBER ~ up/down)
	["round"] = function(inputs)
		local output = 0
		local number = tonumber(inputs[1]) or 0
		local force = inputs[2]
		if force ~= nil then
			local forceFunctions = {["up"] = math.ceil, ["down"] = math.floor}
			local forceFunction = forceFunctions[force]
			if forceFunction ~= nil then
				output = forceFunction(number)
			end
		else
			output = functions.round(number)
		end
		return tostring(output)
	end,
	
	-- (rand MIN MAX)
	["rand"] = function(inputs)
		local min, max = tonumber(inputs[1]), tonumber(inputs[2])
		if nilCheck(min, max) then
			local output = functions.randomFloat(min, max)
			return tostring(output) or "0"
		end
	end,
	
	-- (math operator X ~ Y)
	["math"] = function(inputs)
		local name = inputs[1]
		local x = tonumber(inputs[2])
		local y = tonumber(inputs[3])
		local operator_inputs = y == nil and {x} or {x, y}
		
		if nilCheck(opreator, x) then
			local operator = calculate_operators[name]
			if operator ~= nil then
				local output = operator(table.unpack(operator_inputs))
				return tostring(output) or "0"
			end
		end
	end,
	
	-- (len STRING)
	["len"] = function(inputs)
		local text = inputs[1] or ""
		return tostring(#text)
	end,
	
	-- (sub STRING START/INDEX ~ END)
	["sub"] = function(inputs)
		local text, start = inputs[1], tonumber(inputs[2])
		if nilCheck(text, start) then
			local finish = tonumber(inputs[3]) or start
			return sub(text, start, finish) or ""
		end
	end,
	
	-- (low STRING)
	["low"] = function(inputs)
		local text = inputs[1] or ""
		return string.lower(text)
	end,
	
	-- (up STRING)
	["up"] = function(inputs)
		local text = inputs[1] or ""
		return string.upper(text)
	end,
	
	-- (! BOOLEAN)
	["!"] = function(inputs)
		local truth = inputs[1] or "false"
		return tostring(truth == "false")
	end,
	
	-- (& ...)
	["&"] = function(inputs)
		return combine(inputs, function(a, b)
			local a = a == "true"
			local b = b == "true"
			return a and b
		end)
	end,
	
	-- (~ ...)
	["~"] = function(inputs)
		return combine(inputs, function(a, b)
			local a = a == "true"
			local b = b == "true"
			return a or b
		end)
	end,
	
	-- (= ...)
	["="] = function(inputs)
		return gate(inputs, function(a, b)
			return a == b
		end)
	end,
	
	-- (> ...)
	[">"] = function(inputs)
		return gate(inputs, function(a, b)
			return a > b
		end)
	end,
	
	-- (< ...)
	["<"] = function(inputs)
		return gate(inputs, function(a, b)
			return a < b
		end)
	end,
	
	-- (? VALUE IF ~ ELSE ~ OTHER)
	["?"] = function(inputs)
		local truth = inputs[1]
		local whenTrue = inputs[2] or ""
		local whenFalse = inputs[3] or ""
		local whenOther = inputs[4] or ""
		
		if truth ~= nil then
			if truth == "true" then
				return whenTrue
			elseif truth == "false" then
				return whenFalse
			else
				return whenOther
			end
		end
	end,
	
	-- print ...
	["print"] = function(inputs)
		local outputs = inputs or {}
		print(table.unpack(outputs))
	end,
	
	-- (ask)
	["ask"] = function()
		return io.read() or ""
	end,
	
	-- label NAME ~ LINE
	["label"] = function(inputs)
		local name = inputs[1] or ""
		local line = content["program"]["index"]
		local value = tonumber(inputs[2]) or line
		content["data"]["labels"][name] = value
	end,
	
	-- goto LINE/LABEL
	["goto"] = function(inputs)
		local input = inputs[1] or ""
		local line = tonumber(input) or content["data"]["labels"][input]
		
		if line ~= nil then
			content["program"]["prev goto"] = content["program"]["index"]
			content["program"]["index"] = line - 1
		end
	end,
	
	-- back
	["back"] = function()
		content["program"]["index"] = content["program"]["prev goto"]
	end,
	
	-- def NAME ~ INPUTS
	["def"] = function(inputs)
		local name = inputs[1]
		if name ~= nil then
			local program = content["program"]
			local line, block = "", {}
			local statement = false
			
			repeat
				program["index"] = program["index"] + 1
				line = program["contents"][program["index"]] or ""
				line = parser.cleanUpString(line)
				local tokens = parser.tokenizer(line) or {""}
				
				statement = tokens[1] == "end"
				if not statement then
					table.insert(block, line)
				end
			until statement or program["index"] > #program["contents"]
			
			local procedure = content.getProcedure(name)
			procedure[1] = block
			procedure[2] = inputs[2] or ""
		end
	end,
	
	-- exit ~ VALUE
	["exit"] = function(inputs)
		content["program"]["report"] = inputs[1] or ""
		content["program"]["break"] = true
	end,
	
	-- if BOOLEAN LINE ...
	["if"] = function(inputs)
		table.insert(inputs, 1, "if")
		local values = {}

		local elseIndex = -1
		for index, item in ipairs(inputs) do
			if elseIndex == -1 then
				table.insert(values, item)
			end
			if item == "else" and index % 2 ~= 0 then
				table.insert(values, inputs[index + 1])
				elseIndex = index
				break
			end
		end
		if elseIndex > -1 then
			values[elseIndex] = "true"
			table.insert(values, elseIndex, "if")
		end

		local value = ""
		for i = 1, #values / 3 do
			local truth = values[(i - 1) * 3 + 2]
			if truth == "true" then
				value = values[(i - 1) * 3 + 3]
				break
			end
		end

		local text = parser.cleanUpString(value)
		if string.gsub(text, "%s+", "") ~= "" then
			local tokens = parser.tokenizer(text)
			local set = parser.generate(tokens)
			local output = content.runCommand(set)
			return output or ""
		end
	end,

	-- loop REPEATER LINE
	["loop"] = function(inputs)
		local repeater = inputs[1] or ""
		local line = inputs[2] or ""
		if repeater == "true" then
			while true do
				content.runLine(line)
			end
		else
			repeater = tonumber(repeater) or 1
			for _ = 1, repeater do
				content.runLine(line)
			end
		end
	end,
	
	-- while NAME LINE
	["while"] = function(inputs)
		local variables = content["data"]["variables"]
		local name = inputs[1] or ""
		local line = inputs[2] or ""
		while variables[name] == "true" do
			content.runLine(line)
		end
	end,
	
	-- run ~ PATH
	["run"] = function(inputs)
		local path = inputs[1] or content["interpreter"]["filepath"]
		local file = functions.readFile(path)
		if file ~= nil then
			content["interpreter"]["filepath"] = path
			content["program"]["contents"] = file
			runContents()
		end
	end,

	-- about
	["about"] = function()
		local license = functions.readFile("LICENSE") or {}
		license = #license == 0 and {"license file missing"} or license
		local info = [[Written in Lua with ZeroBrane Studio and Notepad++.
Designed and Programmed by Daniel Lawson.

Licensed under the MIT License.
Examples are completely free of charage.
Copyright 2021 Daniel Lawson

github.com/Sombrero64/MiniScript
www.lua.org
studio.zerobrane.com
notepad-plus-plus.org]]
		
		print("")
		print("=== About MiniScript 2.1 ===")
		print(info)
		print("------------------")
		for _, line in ipairs(license) do
			print(line)
		end
		print("==================")
		print("")
	end
}

return content
