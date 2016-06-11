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

`sput str` Write str to stdout

`put c` Write character c to stdout

`get @x` Get a character from stdin and put it in @x as a number

`sget @x` Same as `get` but reads a line

`add @x,...` Adds arguments and puts the result in @x

`mul @x,...` ^ with multiplication

`div @x,...` division

`sub @x,...` substraction

`eq ...` Sets the success code to true if all arguments are equal

`tonum @x` Converts @x to a number and puts the result in @x

`exit err` Exit with error code err

more to add in the future
