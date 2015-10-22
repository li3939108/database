%{
//Headers
#include <stdio.h>

%}



DOT                   [.]
digit                 [0-9]
letter                [a-z]
integer               {digit}+
comp_op               [<>=]
table_name            {letter}({digit}|{letter})*
attribute_name        {table_name}
column_name           ({table_name}{DOT})?{attribute_name}
literal               "[^"]"
WHITE_SPACE           [ \t\r]

%%
{WHITE_SPACE}         {/* IGNORE white spaces */}       
"CREATE"              { printf("scanned CREATE\n");    }
{column_name}         { printf("scanned column: \n");}
{table_name}          { printf("scanned name: \n");}

%%
int main( int argc, char **argv ){
	++argv, --argc;  /* skip over program name */
	if ( argc > 0 ){
		yyin = fopen( argv[0], "r" );
	}else{
		yyin = stdin;
	}
	yylex();
}
