local functions = {}

-- finds an item that equals TARGET and returns its index
function functions.find(table, target)
	for index, item in pairs(table) do
		if item == target then
			return index
		end
	end
	return nil
end

-- managable functions.find()
function functions.contains(table, target)
	return functions.find(table, target) ~= nil
end

-- check if all items in TABLE are not nil
function functions.nilCheck(...)
	local table = {...} or {}
	for _, item in ipairs(table) do
		if item == nil then
			return false
		end
	end
	return true
end

-- rounds the number either up or down
function functions.round(number)
	return number >= 0 and math.floor(number + 0.5) or math.ceil(number - 0.5)
end

-- returns a random float number
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

-- prints items
function functions.printTable(arr, indentLevel)
	local pT = functions.printTable
    local str = ""
    local indentStr = "#"

    if(indentLevel == nil) then
        print(pT(arr, 0))
        return
    end
	for i = 0, indentLevel do
		indentStr = indentStr .. "\t"
	end

    for index, value in pairs(arr) do
        if type(value) == "table" then
            str = str .. indentStr .. tostring(index) .. ": " .. tostring(value) .. "\n" .. pT(value, (indentLevel + 1))
        else
			str = str .. indentStr .. tostring(index) .. ": " .. tostring(value) .. "\n"
        end
    end
    return str
end

return functions