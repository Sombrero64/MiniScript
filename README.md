<div align="center">
        <img width="500" src="media/logo.png" alt="MiniScript">
</div>

<div align="center">
        MiniScript - Version 2.0
</div>

<p align="center">
  ( <a href="">Releases</a> -
  <a href="">Documentation</a> -
  <a href="https://discord.gg/BSe84YHgRx">Discord Server</a> - 
	<a href="">License</a> )
</p>

<div align="center">

# MiniScript

</div>

**MiniScript** is a basic and simple scripting language written in [Lua](https://www.lua.org/), which features 38 commands and basic list and procedure support. Every behavior is made up of commands, which does something with its inputs and may output something, which in turn be used as another command's input.

```
set number 0
set break false
label loop
	set number (add $number 1)
	set break (not (equal $number 100))
	set fizz (equal (remainder $number 3) 0)
	set buzz (equal (remainder $number 5) 0)
	set output (join (check $fizz "Fizz" "") (check $buzz "Buzz" ""))
	print (check (equal $output "") $number $output)
goto (check $break loop)
```

<div align="center">

## Syntax and Semantics

</div>

The syntax and semantics are pretty basic to understand, therefore easier and faster to implement compared to the modern programming language.

* Entries or strings are separated by spaces.
Using quotes or apostrophes prevents this, so you can use spaces in one entry.
When doing this, you must use the respective character to close the string.
The first entry is the name of a command, and the rest are inputs or arguments.

* To write another command as an input, you use parentheses around that command.
All entries to a command must be in the same line, including command inputs and their parentheses.

* Variables stores a name and a string value.
To call a variable, use the dollar sign followed the name like `$name`.
You can name a variable with multiple spaces and use quotes to call it,
but the dollar sign must be at the beginning of the entry to call a variable.

* Comments uses the number sign or hash (`#`), and it can be either place on one line or at the end of a line.
Hashes cannot be used within quotes, and there’s no way to close a comment in a line.

* Procedures collects code between the command to **`end`**.
Procedures cannot recognize which end it is theirs, so it’s impossible to define a procedure within a procedure.
Same case in the interpreter’s console, because how it handles commands differently compared to the interpreter itself.

* Whitespace (spaces and tabs) from the left and comments to the right are removed while parsing.

<div align="center">

## Why MiniScript?

</div>

Ever scene I started programming, I wanted to create my own programming language with the features and syntax I wanted.
Unfortunately, around that time, I didn’t have the knowledge to design and write an interpreter for any language, let alone a complex one.
The only thing I can do related to designing programming languages is to create the appearance and functions of one.

However, after working on a game engine with its own scripting language, I decided to take what I learned and created MiniScript.
I decided to continue working on the project as it may have potential in the future, but for now, this is what I got so far.
I wanted to continue improving my language designing and implementing skills,
so I can create more professional, robust, and more reliable and powerful languages that people would actually want to use.
