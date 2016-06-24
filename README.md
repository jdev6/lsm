#lsm

Simple toy programming language written in lua.

###Installation
This is a [luarocks package](https://luarocks.org/modules/jdev6/lsm), so just install it with

`luarocks make` (you might need to use `sudo` on Linux)

###Syntax

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

###Tests

There are a lot of tests in the tests/ directory to try different things.

You can run them by typing `./test.sh tests`

I also made a sublime syntax file to make my life easier. Running `./test.sh sublime` will copy it to $HOME/.config/sublime-text-3/Packages/User/

###Calls

`def a x` Set the value of a to x

`sput ...` Write the concatenation of ... (strings) to stdout

`put c` Write character c to stdout

`get x` Get a character from stdin and put it in x as a number

`sget x` Same as `get` but reads a line

`add a b c` Adds a and b and puts result in c

`mul a b c` Same as above with multiplication

`div a b c` Division

`sub a b c` Subtraction

`pow a b c` Exponentiation

`goto label` Jump to the location in the code that label represents (See Flow control)

`back` Go back in the stack (See Flow control)

`sigint label` Jump to the location in the code that label represents when SIGINT is recieved (aka control-c handler) see tests/yes.lsm

`eq ...` Sets the success code to true if all arguments are equal

`gt a b` Sets the success code to true if a > b

`lt a b` Sets the success code to true if a < b

`tonum x y` Converts x to a number and puts the result in y

`tostr x y` Converts x to a string and puts the result in y

`arrdef a ...` Defines array a with the arguments pased.

Example : `arrdef a 2 4 6 8 ,defines a with array {2,4,6,8}`

`arrget a idx b` Indexes array a with index idx and puts its value in b

`arrset a idx b` Sets the value at index idx in array a to b

`exit err` Exit with error code err

more to add in the future

###Flow control

The only form of flow control in lsm are gotos (make sure you work in a raptor-safe environment when programming lsm)

Gotos can jump to a location in the code which is defined by a label, like this:

```
,this code outputs "bop" until it's terminated
>loop;
sput "bop\n"
goto >loop;
```

Or, you can use a special syntax to make gotos enter in the stack, which means that you can return from the label to where you called goto:

```
goto >start; ,uses normal syntax because we don't need to return from >start

>addxy;
    add @x @y @z;
    back; ,go back to where goto was called and continue, in this case line 11

>start;
    def @x 5;
    def @y 2;
    goto >>addxy; ,uses >> instead of > to tell goto to enter the stack
    sput @x " + " @y " is " @z "\n"; ,'5 + 2 is 7';
```

To explain what is happening here:

>     - First, we jump to >start (line 8)

>     - Then, in line 11, we jump to >addxy (line 3) but entering in the stack, this means that the stack (which is an array) will look like this: { line10 } (it isn't stored as lines internally, but as a number that represents the operation lsm is executing, but for the sake of simplicity we'll leave it like this)

>     - Next, when we arrive to back, lsm looks in the stack the most recent value, which in this case would be line10, jumps to its value + 1 (otherwise we would loop all the time between >addxy and line10), and removes it from the stack, in this case leaving it empty.

>     - Then we call sput and the program ends.

Combining gotos with conditional calls (&goto and !goto) you can simulate loops and more complex code in lsm (it also means that it's Turing complete).

###Preproccessor directives

The syntax is: `[ directive arguments ]`. They need to be surrounded with square braces and spaces between the braces and what's inside are optional (`[source foo]` = `[  source        foo]`)

`source ...` Copies contents from files ... (aka #include)

`file` Returns the name of the file in which the directive is in

`line` Returns the line number in which the directive is in

ex: 

```
,this two lines of code will output: "we are in line 2"
sput "we are in line" [line] "\n"
```