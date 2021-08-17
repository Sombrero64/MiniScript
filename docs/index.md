<div align="center">
        <img width="500" src="logo.png" alt="RazerFlare">
</div>

**MiniScript** is a small and basic language, featuring 39 commands and basic list and procedure support. The sytnax is pretty basic:

1. Entries are separated by spaces, which be prevented by using quotes (`"`) or apostrophes (`'`).
2. When using either quotes or apostrophes, you must use their respective character to close the string. In other words, quotes closes quotes, and apostrophes closes apostrophes.
3. The first entry is the command's name, and the rest are inputs.
4. To get a variable's value, you write a dollar sign (`$`), then the name like `$foo`.
5. The dollar sign must be at the beginning of the entry in order to call a variable.
6. Comments uses number sign (`#`), and it must be at the beginning of the line.

```
set number 0

# loop
add number $number 1
remainer fizz $number 3
remainer buzz $number 5
equal fizz $fizz 0
equal buzz $buzz 0

# output
check fizz $fizz "Fizz" ""
check buzz $buzz "Buzz" ""
join output $fizz $buzz
equal outCheck $output ""
check output $outCheck $number $output
print $output

# repeat
equal repeat $number 100
not repeat $repeat
goif $repeat 3
```
