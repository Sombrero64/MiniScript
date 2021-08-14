##### `set` and `delete`
The `set` command sets the value of variable, and `delete` is used to remove a variable when you no longer needed it.

| Input | Description |
| ----------- | ----------- |
| Name (String) | The name of the variable. |
| Value (Any, Optional) | The new value. Defaults to `""`. |

| Input | Description |
| ----------- | ----------- |
| Name (String) | The name of the variable. |

```
set name "John"
print $name
```

##### `list` and `delist`
The `list` command sets the contents a list to the addtional inputs. This is used to create a new list. The `delist` command is used to remove a list. Indexes starts at one.

| Input | Description |
| ----------- | ----------- |
| Name | The name of the list. |
| Value (Additional, Optional) | The items in the list. Leave blank for an empty list. |

| Input | Description |
| ----------- | ----------- |
| Name | The name of the list. |

```
list fruits "Apples" "Bananas" "Oranges"
```

##### `insert`, `remove`, and `replace`
The `insert` command adds a new item in a list, and the `remove` command removes an item. Lastly, `replace` sets the value of an item.

| Input | Description |
| ----------- | ----------- |
| Name | The name of the list. |
| Value | The value of the new item. |
| Index (Number, Optional) | The position where it's placed. Leave blank to place at the end. | 

| Input | Description |
| ----------- | ----------- |
| Name | The name of the list. |
| Index (Number) | The position where it's placed. |

| Input | Description |
| ----------- | ----------- |
| Name | The name of the list. |
| Index (Number) | The position where it's placed. | 
| Value | The value of the new item. |

```
list fruits "Apples" "Bananas" "Oranges"
insert fruits "Grapes"
remove fruits 2
replace fruits 1 "Pears"
```

##### `item`, `find`, and `size`
The `item` and `find` commands are used to get an item from a list. `item` gets the value of item by index, while `find`, well finds the first item with a targeted value. The `size` outputs the amount of items in a list.

| Input | Description |
| ----------- | ----------- |
| Variable Output | The item's value. |
| List Name | The name of the list. | 
| Index (Number) | The position where it's placed. |

| Input | Description |
| ----------- | ----------- |
| Variable Output | The first item's index. |
| List Name | The name of the list. | 
| Target Value | The position where it's placed. |

| Input | Description |
| ----------- | ----------- |
| Variable Output | List's item amount. |
| List Name | The name of the list. | 

```
list fruits "Apples" "Bananas" "Oranges"
item foo fruits 1
find bar fruits "Oranges"
size moo fruits
```

##### `add`, `subtract`, `multiply`, `divide` and `remainer`
These four functions (`add`, `subtract`, `multiply`, `divide`) does their respective operations on each input and returns the result to a variable. The `remainer` works simlarly to `divide`, but it returns the remainer instead of the quotient.

| Input | Description |
| ----------- | ----------- |
| Variable Output | Result |
| Numbers (Number, Additional) | Numbers |

```
add sum 2 2
subtract dif 6 1.5 2
multiply pro 12 2
divide quo 6 3 0.25
remainer rem 10 3
```

##### `round` and `absolute`
`round` is used to round a number, either depending on the decimal value, or only up or down. The `absolute` command is used to report the absolute value of a number.

| Input | Description |
| ----------- | ----------- |
| Variable Output | Result |
| Number (Number) | Number |
| Force (Optional) | Force the rounding to be up or down. Can be set only to `"up"` or `"down"`. |

| Input | Description |
| ----------- | ----------- |
| Variable Output | Result |
| Number (Number) | Number |

```
round foo -6.5
round bar 6.5 up
round moo -6.5 down

absolute foo $foo
absolute moo $moo
```

##### `random`
The `random` command generates a random float bewteen two numbers. Use the `round` function for random integers.

| Input | Description |
| ----------- | ----------- |
| Variable Output | Result |
| Min (Number) | Minimum |
| Max (Number) | Maximum |

```
random number 0 100
round number $number
```

##### `join`
`join` compines all inputs into a longer string.

| Input | Description |
| ----------- | ----------- |
| Variable Output | Result |
| Strings (Additional) | Minimum |

```
join string "vanilla " "crazy " "cake"
```

##### `length`
`length` is used to return the length (the amount of characters in it) of a string.

| Input | Description |
| ----------- | ----------- |
| Variable Output | Result |
| String | String |

```
length stringSize "vanilla crazzy cake"
```

##### `sub`
`sub` is used to get a section of characters in a string. If you provide one numeric input, it returns a character by index instead.

| Input | Description |
| ----------- | ----------- |
| Variable Output | Result |
| String | String |
| Start/Index (Number) | The start of the section. Returns one character if END is empty. |
| End (Number, Optional) | The end of the section. |

```
sub letter hello 3
sub fox "fast fluffy fox" 13 15
```

##### `not`
`not` returns the opposte boolean value of a string (`"true"` or `"false"`).

| Input | Description |
| ----------- | ----------- |
| Variable Output | Result |
| Boolean (Boolean) | Boolean |

```
set state true
not state $state
```

##### `any` and `all`
The commands `any` (any is true) and `all` (all are true) checks the boolean values of each string if they matched the respective condition.

| Input | Description |
| ----------- | ----------- |
| Variable Output | Result |
| Booleans (Boolean, Additional) | Booleans |

```
any out1 true false true
all out2 true true
```

##### `equal` and `order`
The commands `equal` and `order` checks the equally of inequally of each value. `equal` returns true if every input is equal to each other, while `order` returns true if the order of the inputs is correctly ordered from greatest to smallest.

| Input | Description |
| ----------- | ----------- |
| Variable Output | Result |
| Values (Additional) | Values |

```
equal out1 apples apples
order out2 84 42
```

##### `goto` and `goif`
The `goto` command tells the interpreter to go to a specific line number. The `goif` function acts similarly, but it goes to line numbers depending the boolean value.

| Input | Description |
| ----------- | ----------- |
| Line Number (Boolean) | Line Number |
| If Line (Number) | Goes this line number if true. |
| Else Line (Optional) | Goes the line number if false. Doesn't do anything when empty. |

```
goto 1
goif true 2 3
```

##### `check`
The `check` command is used to set a variable to two possible values depending on the boolean value.

| Input | Description |
| ----------- | ----------- |
| Variable Name | The name of the variable. |
| If Line (Number) | Return this if true. |
| Else Line (Optional) | Return this if false. Doesn't do anything when empty. |

```
check true light "green" "red"
```

##### `print` and `ask`
The `print` command displays the inputs as strings to the console, and the `ask` command asks the user then returns their anwser.

| Input | Description |
| ----------- | ----------- |
| Strings (Optional, Additional) | Strings |

| Input | Description |
| ----------- | ----------- |
| Variable Name | The name of the variable. |

```
print "What's your name?"
ask name
```
