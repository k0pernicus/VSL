/**
VSL : Very Simple Language
Developer : Antonin Carette

VSL is a language to simplify a lot of scripting programs to make simple and heavy calculations.
Back-end is JavaScript!
*/

%{
    /*
    Symbols table (contains all global variables)
    */
    var symbols_table = {};
    /*
    Functions tables (contains all functions - parameters and global variables)
    */
    var symbols_fn = {};
    /*
    String which contains the name of the current function
    */
    var current_fn = "";
    /*
    Boolean to know if we are in a function or not - simply to know which variable to get (function or global)
    */
    var is_fn = false;
%}

/*
LEXICAL GRAMMAR
*/

%lex
%options flex

%%

\n[\s]*                             {return 'INDENT'}
^\n                                 {return ''}
\s                                  {return ''}

/*
    Reserved names
*/

'('                                 {return 'PARENTHESIS_BEGIN'}
')'                                 {return 'PARENTHESIS_END'}
'/*'                                {return 'COMMENT_BEGIN'}
'*/'                                {return 'COMMENT_END'}
'$'                                 {return 'END_STRING'}
','                                 {return 'COMMA'}

'init'                              {return 'INIT_SYMBOLE'}
'set'                               {return 'SET_SYMBOLE'}

'if'                                {return 'IF_SYMBOLE'}
'else'                              {return 'ELSE_SYMBOLE'}

'do'                                {return 'BLOCK_BEGIN'}

([a-z]([a-zA-Z0-9_?])*|[0-9]+)".."([a-z]([a-zA-Z0-9_?])*|[0-9]+)                    {return 'ITER_NBR'}

'in'                                {return 'ITER_IN'}
'for'                               {return 'ITER_SYMBOLE'}
'out'                               {return 'STDOUT_BEGIN'}

'fn'                                {is_fn = true; return 'FUNCTION_SYMBOLE'}

/*
    Operators
*/

'+'                                 {return 'PLUS_OPE'}
'-'                                 {return 'MINUS_OPE'}
'*'                                 {return 'MUL_OPE'}
'/'                                 {return 'SIMPLE_DIV_OPE'}
'//'                                {return 'INT_DIV_OPE'}
'%'                                 {return 'MODULO_OPE'}

'not'                               {return 'NOT_SYMBOLE'}
'<'                                 {return 'INF_BOPE'}
'<='                                {return 'INFE_BOPE'}
'>'                                 {return 'SUP_BOPE'}
'>='                                {return 'SUPE_BOPE'}
'='                                 {return 'EQUALS_BOPE'}
'!='                                {return 'NEQUALS_BOPE'}
'and'                               {return 'AND_BOPE'}
'or'                                {return 'OR_BOPE'}

[0-9]+                              {return 'DIGITAL'}

^[a-z]([a-zA-Z0-9_?])*              {return 'VAR'}

\"[^\"]+\"          {return 'STRING'}

<<EOF>>                             {return 'EOF'}

/lex

/*
PRECEDENCE
*/

%left 'IF_SYMBOLE' 'ELSE_SYMBOLE' 'BLOCK_BEGIN'
%left 'NOT_SYMBOLE'
%left 'AND_BOPE' 'OR_BOPE'
%left 'INF_BOPE' 'SUP_BOPE' 'EQUALS_BOPE'
%left 'PLUS_OPE' 'MINUS_OPE'
%left 'INT_DIV_OPE' 'SIMPLE_DIV_OPE' 'MUL_OPE'
%left 'MODULO_OPE'
%left 'PARENTHESIS_BEGIN' 'PARENTHESIS_END' 'COMMENT_BEGIN' 'COMMENT_END'

/*
EXPRESSIONS
*/

%start program

%%

program
    :   instructions EOF
        {
            var fs = require('fs');

            var file_name = process.argv.slice(2) + "";
            file_name = file_name.split('.')[0]

            fs.writeFile(file_name, $1, function(err) {
                if(err)
                    console.log(err);
                else
                    console.log("Success! JS file saved in "+ file_name+".");
            });
        }
    |   EOF
        {
            console.log("Nothing to do...");
        }
    ;

instructions
    :   instruction INDENT
        {
            $$ = $1;
        }
    |   instruction INDENT ( instructions )
        {
            $$ = $1 + $3;
        }
    ;

instruction
    :   affect
        {
            $$ = $1 + ';' + '\n';
        }
    |   iter_statement
        {
            $$ = $1 + '\n';
        }
    |   if_statement
        {
            $$ = $1 + '\n';
        }
    |   function
        {
            $$ = '\n' + $1 + '\n\n';
        }
    |   modification
        {
            $$ = $1 + ';' + '\n';
        }
    |   operations
        {
            $$ = $1 + ';' + '\n';
        }
    |   stdout
        {
            $$ = $1 + ';' + '\n';
        }
    |   comments
        {
        }
    ;

affect
    :   INIT_SYMBOLE affect_var ( operations )
        {
            list_var = $2;
            list_var = list_var.split(' = ');
            if (!is_fn) {
                for (var i = 0; i < list_var.length; i++) {
                    var actual_var = list_var[i];
                    if (!symbols_table.hasOwnProperty(actual_var)) {
                        symbols_table[actual_var] = $3;
                    }
                    else
                        throw "ERROR: " + actual_var + " has already been initialized!!"
                }
            }
            else {
                for (var i = 0; i < list_var.length; i++) {
                    var actual_var = list_var[i];
                    if (!symbols_fn[current_fn]['global_var'].hasOwnProperty(actual_var) && !symbols_fn[current_fn]['parameters'].hasOwnProperty(actual_var)) {
                        symbols_fn[current_fn]['global_var'][actual_var] = $3;
                    }
                    else
                        throw "ERROR: " + actual_var + " has already been initialized in the function!!"
                }
            }
            $$ = 'var ' + $2 + ' = ' + $3;
        }
    ;

iter_statement
    :   BLOCK_BEGIN instruction ITER_SYMBOLE VAR ITER_IN ITER_NBR
        {
            var iter_nbr = $6;
            var first_nbr = get_first_nbr($6);
            var last_nbr = get_last_nbr($6);
            if (first_nbr <= last_nbr) {
                var iter = "++";
            }
            else {
                var iter = "--";
            }
            $$ = 'for ' + '( ' + 'var ' + $4 + ' = ' + first_nbr + ' ; ' + $4 + ' < ' + last_nbr + ' ; ' + $4 + iter + ' )' + '\n' + $2;
        }
    |   BLOCK_BEGIN PARENTHESIS_BEGIN INDENT instructions PARENTHESIS_END ITER_SYMBOLE VAR ITER_IN ITER_NBR
        {
            var iter_nbr = $9;
            var first_nbr = get_first_nbr($9);
            var last_nbr = get_last_nbr($9);
            if (first_nbr <= last_nbr) {
                var iter = "++";
            }
            else {
                var iter = "--";
            }
            $$ = 'for ' + '( ' + 'var ' + $7 + ' = ' + first_nbr + ' ; ' + $7 + ' < ' + last_nbr + ' ; ' + $7 + iter + ' )' + '{\n' + $4 + '\n};';
        }
    ;

if_statement
    :   BLOCK_BEGIN instruction IF_SYMBOLE PARENTHESIS_BEGIN bool_operations PARENTHESIS_END
        {
            $$ = 'if ' + '( ' + $5 + ' )' + '\n' + $2;
        }
    |   BLOCK_BEGIN PARENTHESIS_BEGIN INDENT instructions PARENTHESIS_END IF_SYMBOLE PARENTHESIS_BEGIN bool_operations PARENTHESIS_END
        {
            $$ = 'if ' + '( ' + $8 + ' )' + ' {\n' + $4 + '};';
        }
    |   BLOCK_BEGIN PARENTHESIS_BEGIN INDENT instructions PARENTHESIS_END IF_SYMBOLE PARENTHESIS_BEGIN bool_operations PARENTHESIS_END ELSE_SYMBOLE PARENTHESIS_BEGIN INDENT instructions PARENTHESIS_END
        {
            $$ = 'if ' + '( ' + $8 + ' )' + ' {\n' + $4 + '} else {\n' + $13 + '};';
        }
    /*
        NOT SYMBOL ADDED...
    */
    |   BLOCK_BEGIN instruction IF_SYMBOLE NOT_SYMBOLE PARENTHESIS_BEGIN bool_operations PARENTHESIS_END
        {
            $$ = 'if (' + $4 + ' ( ' + $6 + ' ) )' + '\n' + $2;
        }
    |   BLOCK_BEGIN PARENTHESIS_BEGIN INDENT instructions PARENTHESIS_END IF_SYMBOLE NOT_SYMBOLE PARENTHESIS_BEGIN bool_operations PARENTHESIS_END
        {
            $$ = 'if (' + '!' + ' ( ' + $9 + ' ) )' + ' {\n' + $4 + '};';
        }
    |   BLOCK_BEGIN PARENTHESIS_BEGIN INDENT instructions PARENTHESIS_END IF_SYMBOLE NOT_SYMBOLE PARENTHESIS_BEGIN bool_operations PARENTHESIS_END ELSE_SYMBOLE PARENTHESIS_BEGIN INDENT instructions PARENTHESIS_END
        {
            $$ = 'if (' + '!' + ' ( ' + $9 + ' ) )' + ' {\n' + $4 + '} else {\n' + $14 + '};';
        }
    ;

function
    /*
        Without parameter
    */
    :   FUNCTION_SYMBOLE fn_id PARENTHESIS_BEGIN INDENT instructions PARENTHESIS_END
        {
            $$ = 'function ' + $2 + ' () {\n' + $5 + '}';
            is_fn = false;
            /*
                Name of the current function is now null
            */
            current_fn = "";
        }
    /*
        With parameters
    */
    |   FUNCTION_SYMBOLE fn_id var_leaves PARENTHESIS_BEGIN INDENT instructions PARENTHESIS_END
        {
            $$ = 'function ' + $2 + ' ( ' + $3 + ' ) {\n' + $6 + '}';
            is_fn = false;
            /*
                Name of the current function is now null
            */
            current_fn = "";
        }
    ;

modification
    :   SET_SYMBOLE affect_var ( operations )
        {
            list_var = $2;
            list_var = list_var.split(' = ');
            if (!is_fn) {
                for (var i = 0; i < list_var.length; i++) {
                    var actual_var = list_var[i];
                    if (symbols_table.hasOwnProperty(actual_var)) {
                        symbols_table[actual_var] = $3;
                    }
                }
            }
            else {
                for (var i = 0; i < list_var.length; i++) {
                    var actual_var = list_var[i];
                    if (symbols_fn[current_fn]['global_var'].hasOwnProperty(actual_var))
                        symbols_fn[current_fn]['global_var'][actual_var] = $3;
                    else {
                        if (symbols_fn[current_fn]['parameters'].hasOwnProperty($2))
                            throw "ERROR : You canno't modify the parameter " + $2 + " !";
                        else
                            throw "ERROR : " + $2 + " has not been initialized...";
                    }
                }
            }
            $$ = $2 + ' = ' + $3;
        }
    ;

operations
    :   final_state
        {
            $$ = $1;
        }
    |   PARENTHESIS_BEGIN operations PARENTHESIS_END
        {
            $$ = '(' + $2 + ')';
        }
    |   operations PLUS_OPE ( operations )
        {
            $$ = $1 + ' + ' + $3;
        }
    |   operations MINUS_OPE ( operations )
        {
            $$ = $1 + ' - ' + $3;
        }
    |   operations MUL_OPE ( operations )
        {
            $$ = $1 + ' * ' + $3;
        }
    |   operations SIMPLE_DIV_OPE ( operations )
        {
            $$ = $1 + ' / ' + $3;
        }
    |   operations INT_DIV_OPE ( operations )
        {
            $$ = 'Math.floor(' + $1 + ' / ' + $3 + ')';
        }
    |   operations MODULO_OPE ( operations )
        {
            $$ = '(' + $1 + '%' + $3 + ')';
        }
    ;

bool_operations
    :   bool_operation
        {
            $$ = $1;
        }
    |   bool_operation AND_BOPE ( bool_operations )
        {
            $$ = $1 + ' && ' + $3;
        }
    |   bool_operation OR_BOPE ( bool_operations )
        {
            $$ = $1 + ' || ' + $3;
        }
    ;

bool_operation
    :   operations INF_BOPE ( operations )
        {
            $$ = $1 + ' < ' + $3;
        }
    |   operations INFE_BOPE ( operations )
        {
            $$ = $1 + ' <= ' + $3;
        }
    |   operations SUP_BOPE ( operations )
        {
            $$ = $1 + ' > ' + $3;
        }
    |   operations SUPE_BOPE ( operations )
        {
            $$ = $1 + ' >= ' + $3;
        }
    |   operations EQUALS_BOPE ( operations )
        {
            $$ = $1 + ' == ' + $3;
        }
    |   operations NEQUALS_BOPE ( operations )
        {
            $$ = $1 + ' != ' + $3;
        }
    ;

stdout
    :   STDOUT_BEGIN stdout_leaves
        {
            $$ = 'console.log' + '( ' + $2 + ' )';
        }
    ;

stdout_leaves
    :   STRING
        {
            $$ = $1;
        }
    |   VAR
        {
            $$ = $1;
        }
    |   VAR ( stdout_leaves )
        {
            $$ = $1 + ' + ' + $2;
        }
    |   STRING ( stdout_leaves )
        {
            $$ = $1 + ' + ' + $2;
        }
    ;

fn_id
    :   VAR
        {
            if (current_fn == "") {
                current_fn = $1;
                symbols_fn[current_fn] = {};
                symbols_fn[current_fn]['global_var'] = {};
                symbols_fn[current_fn]['parameters'] = {};
            }
            else {
                throw "ERROR: you can't declare a function in a function!"
            }
        }
    ;

affect_var
:   VAR
    {
        $$ = $1;
    }
|   VAR COMMA ( affect_var )
    {
        $$ = $1 + ' = ' + $3;
    }
;

var_leaves
    :   VAR
        {
            if (symbols_fn[current_fn]['parameters'].hasOwnProperty($1)) {
                throw "ERROR: " + $1 + " has already been declared in the function!"
            }
            else {
                symbols_fn[current_fn]['parameters'][$1] = false;
                $$ = $1;
            }
        }
    |   VAR ( var_leaves )
        {
            if (symbols_fn[current_fn]['parameters'].hasOwnProperty($1)) {
                throw "ERROR: " + $1 + " has already been declared in the function!"
            }
            else {
                symbols_fn[current_fn]['parameters'][$1] = false;
                $$ = $1 + ', ' + $2;
            }
        }
    ;

comments
    :   COMMENT_BEGIN INDENT STRING INDENT COMMENT_END
        {
            $$ = '';
        }
    ;

final_state
    :   leaf
        {
            $$ = $1;
        }
        /*
        Only for parameters call (in a function...)
        */
    |   leaf ( final_state )
        {
            $$ = $1 + ', ' + $2;
        }
    ;

leaf
    :   DIGITAL
        {
            $$ = $1;
        }
    |   VAR PARENTHESIS_BEGIN final_state PARENTHESIS_END
        {
            $$ = $1 + '( ' + $3 + ' )';
        }
    |   VAR PARENTHESIS_BEGIN PARENTHESIS_END
        {
            $$ = $1 + '()';
        }
    |   VAR
        {
            /*
            No function
            */
            if (!is_fn) {
                if (symbols_table.hasOwnProperty($1))
                    $$ = $1;
                else
                    throw "ERROR : " + $1 + " has not been initialized yet!";
            }
            else {
                /*
                Function
                */
                if (symbols_fn[current_fn]['global_var'].hasOwnProperty($1) || symbols_fn[current_fn]['parameters'].hasOwnProperty($1))
                        symbols_fn[current_fn]['global_var'][$1] = true
                else
                    throw "ERROR : " + $1 + " has not been initialized as parameter!";
            }
        }
    ;

%%

function get_first_nbr(nbr) {
    var first_nbr = nbr.split('..')[0];
    return first_nbr;
}

function get_last_nbr(nbr) {
    var last_nbr = nbr.split('..')[1];
    return last_nbr;
}
