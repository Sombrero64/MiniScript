-- [name] = {structure, inputs, about, example}
return {
	["set"] = {
		"set NAME VALUE",
		{["NAME"] = "Variable Name", ["VALUE"] = "String Value"},
		[[sets the value of a variable (NAME) to VALUE]],
		[[set foo "foo"
set bar "bar"]]
	}, ["delete"] = {
		"delete TYPE ~ NAME",
		{["TYPE"] = "Data Type (variable/list/procedure/label/all)", ["NAME"] = "Data Name"},
		[[deletes NAME of TYPE
if TYPE is all, delete all program data]],
		[[delete variable foo
delete list bar]]
	}, ["list"] = {
		"list NAME ...",
		{["NAME"] = "List Name", ["..."] = "Items"},
		[[sets the items in NAME to ...]],
		[[list fruits apples bananas oranges]]
	}, ["insert"] = {
		"insert LIST VALUE ~ INDEX",
		{["LIST"] = "List Name", ["VALUE"] = "Item Value", ["INDEX"] = "Item Index"},
		[[adds a new item to LIST at INDEX
without INDEX, place it at the end of LIST]],
		[[insert fruits grapes
insert fruits pears 2]]
	}, ["remove"] = {
		"remove LIST INDEX",
		{["LIST"] = "List Name", ["INDEX"] = "Item Index"},
		[[removes the item at INDEX from LIST]],
		[[remove fruits 1]]
	}, ["replace"] = {
		"replace LIST INDEX VALUE",
		{["LIST"] = "List Name", ["INDEX"] = "Item Index", ["VALUE"] = "String Values"},
		[[sets the value of an item at INDEX from LIST to VALUE]],
		[[replace fruits 1 Pineapples]]
	}, ["item"] = {
		"(item LIST INDEX)",
		{["LIST"] = "List Name", ["INDEX"] = "Item Index"},
		[[returns the value of the item at INDEX from LIST]],
		[[set fruit1 (item fruits 1)]]
	}, ["find"] = {
		"(find LIST VALUE)",
		{["LIST"] = "List Name", ["VALUE"] = "Target Value"},
		[[finds the first item in LIST that equals to VALUE
returns the item's index if found
returns nothing if no such item exists]],
		[[set index (find fruits "bananas")]]
	}, ["size"] = {
		"(size LIST)",
		{["LIST"] = "List Name"},
		[[returns the size (amount of items) of LIST]],
		[[set fruitCount (size fruits)]]
	}, ["add"] = {
		"(add ...)",
		{["..."] = "Numbers"},
		[[adds each item in ... as numbers and returns the result
starts at the first item]],
		[[print (add 2 2)]]
	}, ["subtract"] = {
		"(subtract ...)",
		{["..."] = "Numbers"},
		[[subtracts each item in ... as numbers and returns the result
starts at the first item]],
		[[print (subtract 4 2)]]
	}, ["multiply"] = {
		"(multiply ...)",
		{["..."] = "Numbers"},
		[[multiply each item in ... as numbers and returns the result
starts at the first item]],
		[[print (multiply 2 2)]]
	}, ["divide"] = {
		"(divide ...)",
		{["..."] = "Numbers"},
		[[divides each item in ... as numbers and returns the result
starts at the first item]],
		[[print (divide 4 2)]]
	}, ["remainder"] = {
		"(remainder ...)",
		{["..."] = "Numbers"},
		[[divides each item in ... as numbers and returns the remainder
starts at the first item]],
		[[print (remainder 6 4)]]
	}, ["join"] = {
		"(join ...)",
		{["..."] = "Strings"},
		[[joins each item in ... into a longer string and returns it
starts at the first item]],
		[[print (join "vanilla " "crazy " "cake")]]
	}, ["round"] = {
		"(round NUMBER ~ FORCE)",
		{["NUMBER"] = "Number", ["FORCE"] = "Rounding Force (up/down)"},
		[[rounds NUMBER and returns the result
with FORCE, make it round only up or down
without FORCE, make the rounding conditional]],
		[[print (round 6.5)
print (round 6.4 up)
print (round 6.7 down)]]
	}, ["random"] = {
		"(random MIN MAX)",
		{["MIN"] = "Minimum", ["MAX"] = "Maximum"},
		[[returns a random number bewteen MIN and MAX
use it with round for random integers]],
		[[print (random 1 10)
print (round (random 1 100))]]
	}, ["power"] = {
		"(power NUMBER REPEATER)",
		{["NUMBER"] = "Number", ["REPEATER"] = "Multiplication Repeat"},
		[[returns NUMBER to the power of REPEATER]],
		[[print (power 2 6)]]
	}, ["calculate"] = {
		"(calculate OPERATOR X ~ Y)",
		{["OPERATOR"] = "Opearation", ["X"] = "Number", ["Y"] = "Number"},
		[[calculates X and Y with OPEARTOR
supported: absolute, square, sin, cos, tan, asin, acos, atan, log
log uses Y, Y is 1 by default]],
		[[print (calculate absolute -5)
print (calculate log 5)]]
	}, ["length"] = {
		"(length STRING)",
		{["STRING"] = "String"},
		[[returns the length (amount of characters) of STRING]],
		[[print (length "fluffy cake")]]
	}, ["sub"] = {
		"(sub STRING START ~ END)",
		{["STRING"] = "String", ["START"] = "Start / Character", ["END"] = "End"},
		[[returns a section of STRING bewteen indexs of START and END
without END, get character at START]],
		[[print (sub "fast fox" 6 8)]]
	}, ["lower"] = {
		"(lower STRING)",
		{["STRING"] = "String"},
		[[returns STRING with each character lowercased]],
		[[print (lower "This IS A test")]]
	}, ["upper"] = {
		"(upper STRING)",
		{["STRING"] = "String"},
		[[returns STRING with each character uppercased]],
		[[print (upper "This IS A test")]]
	}, ["not"] = {
		"(not BOOLEAN)",
		{["BOOLEAN"] = "Boolean Value"},
		[[returns the opposite of BOOLEAN
true to false, and vice versa]],
		[[print (not false)
print (not true)]]
	}, ["any"] = {
		"(any ...)",
		{["..."] = "Booleans"},
		[[returns true if at least one item in ... is true]],
		[[print (any true true false)]]
	}, ["all"] = {
		"(all ...)",
		{["..."] = "Booleans"},
		[[returns true if all in ... is true]],
		[[print (all true true)]]
	}, ["equal"] = {
		"(equal ...)",
		{["..."] = "Values"},
		[[returns true or false depending if all items are equal
if all items can be converted into numbers,
evaluate all items as numbers instead of strings]],
		[[print (equal "fox", "fox"),
print (equal 6.0 "6")]]
	}, ["order"] = {
		"(order ...)",
		{["..."] = "Values"},
		[[returns true or false depending if all items are
correctly ordered from greatest to least
if all items can be converted into numbers,
evaluate all items as numbers instead of strings]],
		[[print (order 16 12.3 9.6 6.5)]]
	}, ["check"] = {
		"(check BOOLEAN IF ELSE)",
		{["BOOLEAN"] = "Boolean", ["IF"] = "Value If True", ["ELSE"] = "Value If False"},
		[[checks the Boolean value of BOOLEAN
and return either IF or ELSE depending if it's true or false]],
		[[print (check false "on" "off")
print (check true "on" "off")]]
	}, ["print"] = {
		"print ...",
		{["..."] = "Strings"},
		[[prints all items in ... to the console in one line]],
		[[print "Hello, world!"]]
	}, ["ask"] = {
		"(ask)",
		{},
		[[asks the user for some input
and returns it as a string]],
		[[print "What's your name?"
set name (ask)]]
	}, ["goto"] = {
		"goto LINE",
		{["LINE"] = "Line Number / Label Name"},
		[[goes to LINE (as number or label)
line numbers are changed to 1 while calling a procedure]],
		[[print home
print sweet
goto 1]]
	}, ["label"] = {
		"label NAME ~ LINE",
		{["NAME"] = "Label Name", ["LINE"] = "Label Value"},
		[[defines a goto label at the current line number or LINE]],
		[[label loop
	print looping
goto loop]]
	}, ["define"] = {
		"define NAME ~ INPUTS",
		{["NAME"] = "Procedure Name", ["INPUTS"] = "Inputs List Name"},
		[[defines a procedure and collects code bewteen the command to end
INPUTS names the list that stores procedure call inputs
one procedure can be defined at a time]],
		[[define foo
	print "foo"
end

foo]]
	}, ["exit"] = {
		"exit ~ VALUE",
		{["VALUE"] = "Procedure Output"},
		[[stops procedure call
VALUE outputs value when a procedure is called]],
		[[define root rootInputs
	set number (item rootInputs 1)
	exit (multiply $number $number)
end

print (root 4)]]
	}, ["run"] = {
		"run ~ PATH",
		{["PATH"] = "File Path"},
		[[gets contents from a file at PATH and runs it
without PATH, use the recent path instead]],
		[[run hello
run fizzbuzz]]
	}, ["help"] = {
		"help ~ COMMAND",
		{["COMMAND"] = "Command"},
		[[display information on a command
without COMMAND, display every available command]],
		[[help print]]
	}, ["about"] = {
		"about",
		{},
		[[display information about miniscript]],
		[[about]]
	}
}