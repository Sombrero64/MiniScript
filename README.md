# MiniScript
**MiniScript** is a very small and basic language, featuring 31 commands and basic list support. The sytnax is pretty basic:

1. Entries are sperated by spaces, which be prevented by using quotes.
2. The first entry is the command's name, and the rest are inputs.
3. To get a variable's value, you write a dollar sign (`$`), then the name like `$foo`.
4. Comments uses number sign (`#`), and it must be at the beginning of the line.

Ever scene I got started programming, I wanted my own language. I only made this to improve my interpreter programming skills, and this is my first interpreter I ever wrote for an actual language. You can learn MiniScript on [every command available](https://github.com/Sombrero64/MiniScript/blob/main/guides/commands.md).

```
print "Hello, world!"
```
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
