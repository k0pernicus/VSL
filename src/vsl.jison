/**
VSL : Very Simple Language
Developer : Antonin Carette

VSL is a language to simplify a lot of scripting programs to make simple and heavy calculations.
Back-end is JavaScript!
*/

%{
    var symbols_table = {};
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
'/*'                                {return 'COMMENT_OPENED'}
'*/'                                {return 'COMMENT_CLOSED'}
'$'                                 {return 'END_STRING'}

'init'                              {return 'INIT_SYMB'}

'if'                                {return 'IF_SYMBOLE'}
'else'                              {return 'ELSE_SYMBOLE'}

'do'                                {return 'BLOCK_BEGIN'}

[0-9]+".."[0-9]+                    {return 'ITER_NBR'}

'in'                                {return 'ITER_IN'}
'for'                               {return 'ITER_SYMBOLE'}
'out'                               {return 'STDOUT_BEGIN'}

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
'>'                                 {return 'SUP_BOPE'}
'='                                 {return 'EQUALS_BOPE'}
'and'                               {return 'AND_BOPE'}
'or'                                {return 'OR_BOPE'}

[0-9]+                              {return 'DIGITAL'}

^[a-z]([a-zA-Z0-9_?])*              {return 'VAR'}

\"[ :!?0-9a-zA-Zçàù<>.]*\"          {return 'STRING'}

<<EOF>>                             {return 'EOF'}

/lex

/*
PRECEDENCE
*/

%left 'IF_SYMBOLE' 'BLOCK_BEGIN'
%left 'PLUS_OPE' 'MINUS_OPE'
%left 'INT_DIV_OPE' 'SIMPLE_DIV_OPE' 'MUL_OPE'
%left 'MODULO_OPE'

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
            $$ = $1 + '\n' + $3;
        }
    ;

instruction
    :   affect
        {
            $$ = $1 + ';';
        }
    |   iter_statement
        {
            $$ = $1;
        }
    |   if_statement
        {
            $$ = $1;
        }
    |   operations
        {
            $$ = $1 + ';';
        }
    |   stdout
        {
            $$ = $1 + ';';
        }
    |   comments
        {
            $$ = '';
        }
    ;

affect
    :   INIT_SYMB VAR ( operations )
        {
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
            var iter_nbr = $6;
            var first_nbr = get_first_nbr($6);
            var last_nbr = get_last_nbr($6);
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
            $$ = 'if ' + '( ' + $8 + ' )' + ' {\n' + $4 + '\n};';
        }
    |   BLOCK_BEGIN PARENTHESIS_BEGIN INDENT instructions PARENTHESIS_END IF_SYMBOLE PARENTHESIS_BEGIN bool_operations PARENTHESIS_END ELSE_SYMBOLE PARENTHESIS_BEGIN INDENT instructions PARENTHESIS_END
        {
            $$ = 'if ' + '( ' + $8 + ' )' + ' {\n' + $4 + '\n}\nelse {\n' + $13 + '\n};';
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
            $$ = 'if (' + '!' + ' ( ' + $9 + ' ) )' + ' {\n' + $4 + '\n};';
        }
    |   BLOCK_BEGIN PARENTHESIS_BEGIN INDENT instructions PARENTHESIS_END IF_SYMBOLE NOT_SYMBOLE PARENTHESIS_BEGIN bool_operations PARENTHESIS_END ELSE_SYMBOLE PARENTHESIS_BEGIN INDENT instructions PARENTHESIS_END
        {
            $$ = 'if (' + '!' + ' ( ' + $9 + ' ) )' + ' {\n' + $4 + '\n}\nelse {\n' + $14 + '\n};';
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
    |   operations SUP_BOPE ( operations )
        {
            $$ = $1 + ' > ' + $3;
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
    :   STDOUT_BEGIN stdout_leaves END_STRING
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

comments
    :   COMMENT_OPENED INDENT stdout_leaves INDENT COMMENT_CLOSED
        {
        }
    ;

final_state
    :   leaf
        {
            $$ = $1;
        }
    ;

leaf
    :   DIGITAL
        {
            $$ = $1;
        }
    |   VAR
        {
            $$ = $1;
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
