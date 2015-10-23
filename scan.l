%{
#include <stdio.h>
#include <stdlib.h>
#include <iostream>
using namespace std;
%}
%s                    DROP_TABLE_STATEMENT
%s                    SELECT_STATEMENT


DOT                   [.]
digit                 [0-9]
letter                [a-z]
integer               {digit}+
comp_op               [<>=]
pm_op                 [+-]
md_op                 [*/]
name                  {letter}({digit}|{letter})* 
dotted_name           {name}{DOT}{name}
literal               "[^"]"
WS                    [ \t\n\r]
V                     VALUES
S                     SELECT
C                     CREATE
T                     TABLE
W                     WHERE
F                     FROM
IT                    INTO
IS                    INSERT
BY                    BY
DP                    DROP
DT                    DELETE
OR                    OR
INT                   INT
STR                   STR20
AND                   AND
NOT                   NOT
NULL                  NULL
DISTINCT              DISTINCT
C_T                   {C}{WS}+{T}            
D_T                   {DP}{WS}+{T}
I_I                   {IS}{WS}+{IT}
D_F                   {DT}{WS}+{F}
SELECT                {S}({WS}+{DISTINCT})?

%%

{WS}+ {/* IGNORE white spaces */}       
{SELECT}{WS}+ {
	cout << "scanned SELECT" << endl;
	BEGIN(SELECT_STATEMENT);
}
{dotted_name} { 
	cout << "scanned dotted name: " << yytext << endl ;
}
{D_T}{WS}+ {
	cout << "START DROP TABLE" << endl ;
	BEGIN(DROP_TABLE_STATEMENT);
}
<DROP_TABLE_STATEMENT>{name} {/* drop-table-statement name*/
	cout << "scanned drop-table-statement" << yytext << endl ;
}
{name} {
	cout << "scanned name: " << yytext << endl ;
}
. {/* all other character */
	fprintf(stderr, "Error: unaccepted character: %s\n", yytext) ;
	exit(EXIT_FAILURE); 
}

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
