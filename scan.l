%{
//Headers
#include <stdio.h>

%}



DOT                   [.]
digit                 [0-9]
letter                [a-z]
integer               {digit}+
comp_op               [<>=]
name                  {letter}({digit}|{letter})* 
dotted_name           {name}{DOT}{name}
literal               "[^"]"
WHITE_SPACE           [ \t\r]

%%
{WHITE_SPACE}         {/* IGNORE white spaces */}       
"CREATE"              { printf("scanned CREATE\n");    }
{dotted_name}         { printf("scanned dotted name: \n");}
{name}                { printf("scanned name: \n");}

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
