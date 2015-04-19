#VSL (Very Simple Language)

Developer : Antonin Carette

Last modifications : 04/19/2015

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
    *   [Modification](#modification)
    *   [Data structures](#data_struct)
        *   [List](#list)
        *   [Json](#json)
    *   [Conditions](#conditions)
    *   [Loop](#loop)
*   [Contact](#contact)

##<a name="simple_intro"></a>What? How? Who? Where? When?

VSL has been conceived to simplify a lot scripting programs to make simple and heavy calculations.  
VSL uses Jison as front-end, a back-end to JS and the V8 engine (from Google) to optimize the script.  
VSL requires nodeJS to work.

##<a name="installation"></a>Installation

Run this command as sudo/root (root directory):
```
    chmod +x install.sh
    [sudo] ./install.sh
```

##<a name="utilisation"></a>Utilisation

Run these commands to run your VSL program:
```
    VSL your_file.VSL
    node your_file
```

##<a name="syntax"></a>Syntax

####<a name="introduction"></a>Introduction

First, **each instruction must be finished with a new-line**.  
Secondly, indentation is very important to respect some obligations with loops or conditions for example.
VSL distringuished *allocation* and *modification* of variables.

This is the list of reserved names:
*   ```$```,
*   ```ìf```,
*   ```init```,
*   ```else```,
*   ```do```,
*   ```for```,
*   ```out```,
*   ```..```.

Comments are delimited between ```/*``` and ```*/```. In comments, you **must** write it between double-quotes!  

To finish, priority is given by ```(...)```.

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
*   ```<```
*   ```>```
*   ```and``` ('and' logical operator),
*   ```or``` ('or' logical operator),

####<a name="allocation"></a>Allocation

To allocate a variable, please to use the ```init``` keyword.  
**Ex**: ```init x 9``` will declared ```x``` and initialize it with ```9```.

The right part of the allocation have to be :
*   an *integer*,
*   a *float*,
*   a *string*,
*   a *char*.

####<a name="conditions"></a>Conditions

You can use these notations to use simple conditions :

*   **Without 'else' statement**

    ```
    init x 3
    do out "x < 4" $ if (x < 4)
    ```

    *OR*

    ```
    init x 3
    do (
        out "hi guy!" $
        out "x < 4" $
    ) if (x < 4)
    ```

*   **With 'else' statement**

    ```
    init x 3
    do (
        out "hi guy!" $
        out "x < 4" $
    ) if (x < 4) else (
        out "x > 4" $
    )
    ```

####<a name="loops"></a>Loop

There is a single loop in VSL.

```
do (
    out "Hello world" $
) for x in 0..2
```

This small example will print out twice "Hello world".

To call an decremental loop, use:

```
do (
    out "Hello world" $
) for x in 2..0
```

##<a name="contact"></a>Contact

Carette Antonin - antonin[dot]carette[at]gmail[dot]com
