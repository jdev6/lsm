##lsm

Simple toy programming language written in lua.

#Syntax

```
,This is a comment. Comments are single-line and start with a ','
,Operations in lsm are done with calls. A call is structured like this:
somecall arg1 arg2 arg3 ... ;
,For example, to print hello world, you use the call 'sput':
sput "Hello world\n";
,Calls must end with semicolons.

,Registers start with @:
def @x 42;
sput @x;

You can also precede a call with '&' to make it execute if the last call was succesful, and '!' for the inverse:
sget @x;
eq @x "foo";
&sput "bar\n";
!sput "no foos given\n";
```

#Calls

`def @a,x` Set the value of @a to x

`sput ...` Write the concatenation of ... (strings) to stdout

`put c` Write character c to stdout

`get @x` Get a character from stdin and put it in @x as a number

`sget @x` Same as `get` but reads a line

`add a b c` Adds a and b and puts result in c

`mul a b c` Same as above with multiplication

`div a b c` Division

`sub a b c` Substraction

`eq ...` Sets the success code to true if all arguments are equal

`tonum x y` Converts x to a number and puts the result in y

`tostr x y` Converts x to a string and puts the result in y

`exit err` Exit with error code err

more to add in the future
