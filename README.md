#VSL (Very Simple Language)

Developer : Antonin Carette

Last modifications : 04/24/2015

Fork me, I'm (not yet) famous!

##Contents

*   [What? How? Who? Where? When?](#simple_intro)
*   [Installation](#installation)
*   [Utilisation](#utilisation)
*   [Syntax](#syntax)
    *   [Introduction](#introduction)
    *   [Operators](#operators)
        *   [Unary](#unary_ope)
        *   [Binary](#binary_ope)
    *   [Allocation](#allocation)
    *   [Re-allocation](#reallocation)
    *   [Conditions](#conditions)
    *   [Loop](#loop)
    *   [Functions](#functions)
*   [Examples](#examples)
*   [Contact](#contact)

##<a name="simple_intro"></a>What? How? Who? Where? When?

VSL has been conceived to simplify a lot scripting programs to make simple and heavy calculations.  
VSL uses Jison as front-end, a back-end to JS and the V8 engine (from Google) with nodeJS.  
VSL requires nodeJS to work.

##<a name="installation"></a>Installation

Please to install these softwares and libraries:
*   nodeJS (please to see how at [http://nodejs.org](http://nodejs.org))
*   jison (with npm : ```npm install jison -g```)

##<a name="utilisation"></a>Utilisation

Please to generate the JavaScript parser (for VSL) : ```jison src/vsl.jison```

After that, put this simple line to your .bashrc : ```alias vsl=node vsl.js```

To finish, run these commands to run your VSL program:
```
    vsl your_file.vsl
    node your_file
```

##<a name="syntax"></a>Syntax

####<a name="introduction"></a>Introduction

First, **each instruction must be finished with a new-line**.  
Secondly, indentation is very important to respect some obligations with loops or conditions for example.
VSL distringuished *allocation* and *modification* of variables.

This is the list of reserved names:
*   ```begin```,
*   ```do```,
*   ```else```,
*   ```end```,
*   ```false```,
*   ```for```,
*   ```fn```,
*   ```ìf```,
*   ```in```,
*   ```init```,
*   ```list```,
*   ```out```,
*   ```return```,
*   ```true```,
*   ```..```.

Comments are delimited between ```/*``` and ```*/```. For comments, you **must** write them between double-quotes!  

To print out a simple string, use ```out``` like ```out "x: " x```

Priority (for operations) is given by ```(...)```. Blocks are created by ```(``` and ```)```, or **```begin``` and ```end``` for functions only**.

####<a name="operators"></a>Operators

#####<a name="unary_ope"></a>Unary

You can use these operators to make unary operations:
*   ```!``` (not: boolean only)
*   ```-x``` (minus unary)

#####<a name="binary_ope"></a>Binary

You can use these operators to make binary operations:
*   ```+```,
*   ```-```,
*   ```*```,
*   ```/```,
*   ```//``` (integer division),
*   ```%``` (modulo),
*   ```=``` (equals)
*   ```!=``` (not equals)
*   ```<```
*   ```<=```
*   ```>```
*   ```>=```
*   ```and``` ('and' logical operator),
*   ```or``` ('or' logical operator),

####<a name="allocation"></a>Allocation

To allocate a variable, please to use the ```init``` keyword.  
**Ex**: ```init x``` will declared ```x```, without initialize it.  
**Ex2**: ```init x 9``` will declared ```x``` and initialize it with ```9```.  
**Ex3**: ```init x, y 1``` will declared ```x``` and ```y``` and initialize them with ```1```.

The right part of the allocation have to be :
*   an *integer*,
*   a *float*,
*   a *string*,
*   a *char*.
*   a *list*.

To allocate a list, please to use the ```list``` keyword.
**Ex**: ```init x list``` will declared an empty list.
**Ex2**: ```init x list 1 2 3 4``` will declared a list which contains ```1,2,3,4```.
**Ex3**: ```init x list 0..9``` will declared a list which contains all decimals between ```0``` and ```9``` (exclude).

####<a name="reallocation"></a>Re-allocation

To re-allocate a variable, please to use the ```set``` keyword.  
**Ex**: ```set x (2*3)``` will reallocate ```x``` with ```(2*3)```.  
**Ex2**: ```set x, y (2*3)``` will reallocate ```x``` and ```y``` with ```(2*3)```.  
**Ex3**: ```set x, y list 1..4``` will reallocate ```x``` and ```y``` with a list which contains ```1,2,3,4```.

####<a name="conditions"></a>Conditions

You can use these notations to use simple conditions :

*   **Without 'else' statement**

    ```
    init x 3
    do out "x < 4" if (x < 4)
    ```

    *OR*

    ```
    init x 3
    do (
        out "x < 4"
    ) if (x < 4)
    ```

*   **With 'else' statement**

    ```
    init x 3
    do (
        out "x < 4"
    ) if (x < 4) else (
        out "x > 4"
    )
    ```

####<a name="loops"></a>Loop

There is a single loop in VSL.

```
do (
    out "Hello world"
) for x in 0..2
```

This small example will print out twice "Hello world".

To call an decremental loop, use:

```
do (
    out "Hello world"
) for x in 2..0
```

If you want to use the variable declared, please to initialize it before the usage!

```
fn add x y begin
    init rst x + y
    out rst
end

init z 2

init x 0

do add(x x) for x in 0..z
```

####<a name="functions"></a>Functions

You can use simple functions without parameters, or with unlimited parameters...

```
fn x begin
    out "Hello world"
end
```

or

```
fn add y z begin
    return (y + z)
end
```

Usage:  

```

init z 1

/*
    "Declare a simple function"
*/

fn printHelloWorld begin
    /*
        "z is here a local variable"
    */
    init z 3
    out "Hello world"
    set z 4
    /*
        "out 4"
    */
    out "z: " z
end

/*
    "out the global variable z (1)"
*/
out z

do printHelloWorld() for x in 0..2
```

##<a name="examples"></a>Examples

* Hello world

```
out "Hello world"
```

or

```
fn printHelloWorld begin
  out "Hello world"
end

printHelloWorld()
```

* Multiplication table

```
fn mul a begin
    out "--------------------"
    out "mul " a
    init x 0
    do (
        init rst (a * x)
        out  a " * " x " = " rst
    ) for x in 0..10
end

init x 1
do (
  mul(x)
) for x in 1..10
```

* Fibonacci

This example will print out the 100 first Fibonacci decimals.

```
fn fibo limit begin
  init x, y, b 1

  out x "\n" y

  do (
    set b x
    set x y
    set y (y + b)
    out y
  ) for a in 0..limit
end

fibo(100)
```

##<a name="contact"></a>Contact

Carette Antonin - antonin[dot]carette[at]gmail[dot]com
