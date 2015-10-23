%{
#include <stdio.h>
#include <stdlib.h>
%}


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
SELECT                {S}{WS}+{DISTINCT}?
D_T_Statement         {D_T}{WS}+{name}

%%

{WS}+                 {/* IGNORE white spaces */}       
{SELECT}              { printf("scanned SELECT\n");}
{dotted_name}         { printf("scanned dotted name: \n");}
{name}                { printf("scanned name: \n");}
.                     { perror("Unaccepted character\n") ; exit(EXIT_FAILURE); }

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
