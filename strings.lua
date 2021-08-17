local strings = {}

strings.help = {
	["set"] = {"set name value", "sets the value of a variable"},
	["delete"] = {"delete variable/list/procedure name", "deletes a variable, list, or procedure"},
	["list"] = {"list name ...", "sets the items in a list"},
	["insert"] = {"insert list value ~ index", "adds a new item at the end or a specified index in a list"},
	["remove"] = {"remove list index", "removes an item from a list"},
	["replace"] = {"replace list index value", "sets the value of an item from a list"},
	["item"] = {"item output list index", "gets the value of an item in a list"},
	["find"] = {"find output list value", "gets the index of the first item that equals to the requested value"},
	["size"] = {"size output list", "gets the amount of items in a list"},
	["add"] = {"add output ...", "returns the sum of all inputs"},
	["subtract"] = {"subtract output ...", "returns the difference of all inputs"},
	["multiply"] = {"multiply output ...", "returns the product of all inputs"},
	["divide"] = {"divide output ...", "returns the quotient of all inputs"},
	["remainder"] = {"remainder output ...", "returns the remainder of all inputs"},
	["round"] = {"round output number ~ force", "rounds the number depending on the value, or only up or down"},
	["random"] = {"random output min max", "generates a random number bewteen two numbers"},
	["absolute"] = {"absolute output number", "returns the absolute value of the number"},
	["join"] = {"join output ...", "compines all inputs into a longer string"},
	["length"] = {"length output string", "returns the length of a string"},
	["sub"] = {"sub output string start/index ~ end", "gets a section of characters or a character from a string"},
	["not"] = {"not output value", "returns the opposite boolean value"},
	["any"] = {"any output ...", "returns true if any of the boolean inputs is true"},
	["all"] = {"any output ...", "returns true if all boolean inputs are true"},
	["equal"] = {"equal output ...", "returns true if all values are equal"},
	["order"] = {"order output ...", "returns true if the values are correctly ordered from greatest to smallest"},
	["goto"] = {"goto line", "sets the line number"},
	["goif"] = {"goif truth if else", "changes the line number to either IF or ELSE depending the boolean value"},
	["label"] = {"label name ~ line", "creates a new label at the command's line number or a requested line number"},
	["check"] = {"check output if else", "returns either IF or ELSE depending on the boolean value"},
	["print"] = {"print ...", "displays strings to the console"},
	["ask"] = {"ask output", "asks the user then returns the anwser"},
	["about"] = {"about", "display information on miniscript"},
	["help"] = {"help ~ command", "display information on a command or list every available command"},
	["run"] = {"run path", "runs a new program, stops current script"},
	["reset"] = {"reset", "removes all variables, lists, and procedures"},
	["parse"] = {"parse line", "parses and runs the string as code"},
	["define"] = {"define name ~ inputs", "defines a new proceure, stores code until the end keyword"},
	["call"] = {"call name ...", "run a proceure"},
	["if"] = {"if truth if_line ~ else_line", "runs either IF or ELSE depending on the boolean value"},
}

strings.about = {
	"MiniScript Version 1.3",
	"MiniScript is a basic and small programming language.",
	"Licensed under the MIT license, created by Daniel Lawson."
}

strings.start = {
	"MiniScript Version 1.3",
	"Use the run command to run a script.",
	"Use the help command for more info on each command."
}

return strings
