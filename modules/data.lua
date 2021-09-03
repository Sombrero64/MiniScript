local content = {
	-- program data
	["data"] = {
		["commands"] = {}, -- [name] = function(args)
		["variables"] = {}, -- [name] = value
		["lists"] = {}, -- [name] = {...}
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
		["break"] = false
	},
	-- interpreter info
	["interpreter"] = {
		-- program path
		["filepath"] = ""
	}
}

local functions = require("modules/functions")
local parser = require("modules/parser")
local help = require("modules/help")

local sub = string.sub
local nilCheck = functions.nilCheck

local calculate_operators = {
	["absolute"] = math.abs, ["square"] = math.sqrt, ["log"] = math.log,
	["sin"] = math.sin, ["cos"] = math.cos, ["tan"] = math.tan,
	["asin"] = math.asin, ["acos"] = math.acos, ["atan"] = math.atan
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

-- get and return table, define it if not found
function content.getList(name)
	return getDataType("lists", name, {})
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
	elseif type(command) == "table" then -- procedure (todo)
		local code, name = command[1], command[2] or ""
		content["data"]["lists"][name] = inputs
		
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

-- runs each line in data.program.index
local function runContents()
	content["program"]["index"] = 1
	while content["program"]["index"] <= #content["program"]["contents"] do
		local number = content["program"]["index"]
		local line = content["program"]["contents"][number] or ""
		local text = parser.cleanUpString(line)
		if string.gsub(line, "%s+", "") ~= "" then
			local tokens = parser.tokenizer(text)
			local set = parser.generate(tokens)
			content.runCommand(set)
		end
		content["program"]["index"] = content["program"]["index"] + 1
	end
end

-- additional input are ~, endless inputs are ..., option inputs are /, code blocks are ;
content["data"]["commands"] = {
	-- set NAME VALUE
	["set"] = function(inputs)
		local name, value = inputs[1], inputs[2]
		if nilCheck(name, value) then
			content["data"]["variables"][name] = value
		end
	end,
	
	-- delete TYPE ~ NAME
	["delete"] = function(inputs)
		local typeEntry, name = inputs[1], inputs[2]
		local types = {"variable", "list", "procedure", "label", "switch"}
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
	
	-- list NAME ...
	["list"] = function(inputs)
		local name = inputs[1]
		table.remove(inputs, 1)
		if name ~= nil then
			content["data"]["lists"][name] = inputs
		end
	end,
	
	-- insert LIST VALUE ~ INDEX
	["insert"] = function(inputs)
		local name, value = inputs[1], inputs[2]
		if nilCheck(name, value) then
			local list = content.getList(name)
			local index = tonumber(inputs[3]) or #list + 1
			table.insert(list, index, value)
		end
	end,
	
	-- remove LIST INDEX
	["remove"] = function(inputs)
		local name, index = inputs[1], tonumber(inputs[2])
		if nilCheck(name, index) then
			local list = content.getList(name)
			table.remove(list, index)
		end
	end,
	
	-- replace LIST INDEX VALUE
	["replace"] = function(inputs)
		local name, index, value = inputs[1], tonumber(inputs[2]), inputs[3]
		if nilCheck(name, index, value) then
			local list = content.getList(name)
			list[index] = value
		end
	end,
	
	-- (item LIST INDEX)
	["item"] = function(inputs)
		local name, index = inputs[1] or "", tonumber(inputs[2])
		if nilCheck(name, index) then
			local list = content.getList(name)
			return list[index] or ""
		end
	end,
	
	-- (find LIST VALUE)
	["find"] = function(inputs)
		local name, value = inputs[1], inputs[2]
		if nilCheck(name, value) then
			local list = content.getList(name)
			local output = functions.find(list, value)
			return tostring(output) or "0"
		end
	end,
	
	-- (size LIST)
	["size"] = function(inputs)
		local name = inputs[1]
		if name ~= nil then
			local list = content.getList(name)
			local size = #list or 0
			return tostring(size)
		end
	end,
	
	-- (add ...)
	["add"] = function(inputs)
		return combine(inputs, function(a, b)
			local a = tonumber(a) or 0
			local b = tonumber(b) or 0
			return a + b
		end)
	end,
	
	-- (subtract ...)
	["subtract"] = function(inputs)
		return combine(inputs, function(a, b)
			local a = tonumber(a) or 0
			local b = tonumber(b) or 0
			return a - b
		end)
	end,
	
	-- (multiply ...)
	["multiply"] = function(inputs)
		return combine(inputs, function(a, b)
			local a = tonumber(a) or 1
			local b = tonumber(b) or 1
			return a * b
		end)
	end,
	
	-- (divide ...)
	["divide"] = function(inputs)
		return combine(inputs, function(a, b)
			local a = tonumber(a) or 1
			local b = tonumber(b) or 1
			return a / b
		end)
	end,
	
	-- (remainder ...)
	["remainder"] = function(inputs)
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
	
	-- (random MIN MAX)
	["random"] = function(inputs)
		local min, max = tonumber(inputs[1]), tonumber(inputs[2])
		if nilCheck(min, max) then
			local output = functions.randomFloat(min, max)
			return tostring(output) or "0"
		end
	end,
	
	-- (power NUMBER REPEATER)
	["power"] = function(inputs)
		local number, repeater = tonumber(inputs[1]), tonumber(inputs[2])
		if nilCheck(number, repeater) then
			local output = math.pow(number, repeater)
			return tostring(output) or "0"
		end
	end,
	
	-- (calculate operator X ~ Y)
	["calculate"] = function(inputs)
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
	
	-- (length STRING)
	["length"] = function(inputs)
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
	
	-- (lower STRING)
	["lower"] = function(inputs)
		local text = inputs[1] or ""
		return string.lower(text)
	end,
	
	-- (upper STRING)
	["upper"] = function(inputs)
		local text = inputs[1] or ""
		return string.upper(text)
	end,
	
	-- (not BOOLEAN)
	["not"] = function(inputs)
		local truth = inputs[1] or "false"
		return tostring(truth == "false")
	end,
	
	-- (all ...)
	["all"] = function(inputs)
		return combine(inputs, function(a, b)
			local a = a == "true"
			local b = b == "true"
			return a and b
		end)
	end,
	
	-- (any ...)
	["any"] = function(inputs)
		return combine(inputs, function(a, b)
			local a = a == "true"
			local b = b == "true"
			return a or b
		end)
	end,
	
	-- (equal ...)
	["equal"] = function(inputs)
		return gate(inputs, function(a, b)
			return a == b
		end)
	end,
	
	-- (order ...)
	["order"] = function(inputs)
		return gate(inputs, function(a, b)
			return a > b
		end)
	end,
	
	-- (check BOOLEAN IF ELSE)
	["check"] = function(inputs)
		local truth = inputs[1]
		local whenTrue = inputs[2] or ""
		local whenFalse = inputs[3] or ""
		
		if truth ~= nil then
			local state = truth == "true"
			local value = state and whenTrue or whenFalse
			return value
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
			content["program"]["index"] = line - 1
		end
	end,
	
	-- define NAME ~ INPUTS
	["define"] = function(inputs)
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
	
	-- help ~ COMMAND
	["help"] = function(inputs)
		local name = inputs[1]
		if name == nil then
			local index = 1
			for name, _ in pairs(help) do
				print(index, name)
				index = index + 1
			end
		elseif content["data"]["commands"][name] ~= nil then
			local contents = help[name] or {"", {}, "", ""}
			local name = {"", "== " .. name .. " ==", contents[1]}
			local info = {"", contents[3], "", contents[4], ""}
			
			for _, item in ipairs(name) do
				print(item)
			end
			
			for name, info in pairs(contents[2]) do
				print(name .. ": " .. info)
			end
			
			for _, item in ipairs(info) do
				print(item)
			end
		end
	end,

	-- about
	["about"] = function()
		local license = functions.readFile("LICENSE") or {}
		license = #license == 0 and {"license file missing"} or license
		local info = [[MiniScript Version 2.0
Written in Lua 5.1.5 with ZeroBrane Studio and Notepad++
Designed and Programmed by Daniel Lawson
Licensed under the MIT License

github.com/Sombrero64/MiniScript
www.lua.org
studio.zerobrane.com
notepad-plus-plus.org]]
		
		print("")
		print("=== MiniScript ===")
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
