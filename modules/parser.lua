local functions = require("modules/functions")
local parser = {}

-- removes whitespace and comments
function parser.cleanUpString(string)
	-- removes whitespace from the left
	local testString, text = "", ""
	for testIndex = 1, #string do
		testString = string.sub(string, testIndex, testIndex)
		if not (testString == "\t" or testString == " ") then
			text = string.sub(string, testIndex, #string)
			break
		end
	end
	
	-- removes comments
	local output = ""
	for i = 1, #text do
		local character = string.sub(text, i, i)
		if character == "#" then
			break
		else
			output = output .. character
		end
	end
	return output
end

-- creates a table of tokens out of a string
function parser.tokenizer(string)
	local tokens, wasAString = {""}, {false}
	local inString, stringToken = false, ""
	
	local function newItem()
		table.insert(tokens, "")
		table.insert(wasAString, false)
	end
	
	-- detect quotes or parentheses
	for i = 1, #string do
		local character = string.sub(string, i, i)
		if functions.contains({"'", '"'}, character) and not inString then -- open quotes
			inString, stringToken = true, character
			wasAString[#wasAString] = true
		elseif character == stringToken and inString then -- close quotes
			inString, stringToken = false, ""
		elseif functions.contains({"(", ")"}, character) and not inString then -- parentheses
			table.insert(tokens, character)
			table.insert(wasAString, false)
			newItem()
		elseif character == " " and not inString then -- spaces outside quotes
			newItem()
		else -- add to entry
			tokens[#tokens] = tokens[#tokens] .. character
		end
	end
	
	-- remove spaces except empty strings
	for index, token in pairs(tokens) do
		local truth = wasAString[index]
		if token == "" and not truth then
			tokens[index] = nil
		end
	end
	
	return tokens
end

-- creates a branching table out of tokens
function parser.generate(tokens)
	-- join items as a string
	local list = ""
	for index, token in pairs(tokens) do
		if token == "(" then
			list = list .. "{"
		elseif token == ")" then
			list = list .. "}, "
		else
			local newItem = '[[' .. token .. ']], '
			list = list .. newItem
		end
	end
	list = "{" .. list .. "}"
	
	-- use load to create list
	local makeTable = load("return " .. list)
	return makeTable()
end

return parser