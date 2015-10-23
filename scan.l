%{
#include <stdio.h>
#include <stdlib.h>
#include <iostream>
using namespace std;
%}
%s                    DROP_TABLE_STATEMENT
%s                    DELETE_STATEMENT
%s                    SELECT_STATEMENT
%s                    INSERT_STATEMENT

%s                    CREATE_TABLE_STATEMENT
%s                    C_T_S_EXPECT_LEFT_PARENTHESE
%s                    C_T_S_EXPECT_ATTR
%s                    C_T_S_EXPECT_TYPE
%s                    C_T_S_EXPECT_COLON_OR_RIGHT_PARENTHESE
%s                    C_T_S_EXPECT_WS


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

{SELECT}{WS}+ {
	cerr << "-----------" << endl << "scanned:\tSELECT [DISTINCT]" << endl;
	BEGIN(SELECT_STATEMENT);
}
{D_F}{WS}+ {
	cerr << "-----------" <<  endl << "scanned:\tDELETE FROM" << endl ;
	BEGIN(DELETE_STATEMENT);
}
{C_T}{WS}+ {
	cerr << "-----------" <<  endl << "scanned:\tCREATE TABLE" << endl;
	BEGIN(CREATE_TABLE_STATEMENT);
}
{D_T}{WS}+ {
	cerr << "-----------" <<  endl << "scanned:\tDROP TABLE" << endl ;
	BEGIN(DROP_TABLE_STATEMENT);
}
{I_I}{WS}+ {
	cerr << "-----------" <<  endl << "scanned:\tINSERT INTO" << endl ;
	BEGIN(INSERT_STATEMENT);
}
<SELECT_STATEMENT>{dotted_name} { 
	cerr << "column_name:\t" << yytext << endl ;
}
<DELETE_STATEMENT>{name} {/* DELETE from table */
	cerr << "delete table:\t" << yytext << endl ;
}
<DROP_TABLE_STATEMENT>{name} {
	cerr << "drop table:\t" << yytext << endl ;
	/* drop-table-statement finished*/
	BEGIN(INITIAL);
}
<INSERT_STATEMENT>{name} {
	cerr << "table to ins:\t" << yytext << endl;
}

<CREATE_TABLE_STATEMENT>{name} {
	cerr << "create table:\t" << yytext << endl;
	BEGIN(C_T_S_EXPECT_LEFT_PARENTHESE);
}
<C_T_S_EXPECT_LEFT_PARENTHESE>{WS}*\({WS}* {
	BEGIN(C_T_S_EXPECT_ATTR);
}
<C_T_S_EXPECT_ATTR>{name} {
	BEGIN(C_T_S_EXPECT_WS) ;
	cerr << "attribute :\t" << yytext <<endl ;
}
<C_T_S_EXPECT_WS>{WS}+ {
	BEGIN(C_T_S_EXPECT_TYPE) ;
}
<C_T_S_EXPECT_TYPE>({INT}|{STR}) {
	cerr << "the type is:\t" << yytext << endl ;
	BEGIN(C_T_S_EXPECT_COLON_OR_RIGHT_PARENTHESE) ;
}
<C_T_S_EXPECT_COLON_OR_RIGHT_PARENTHESE>{WS}*,{WS}* {
	BEGIN(C_T_S_EXPECT_ATTR);
}
<C_T_S_EXPECT_COLON_OR_RIGHT_PARENTHESE>{WS}*\){WS}* {
	cerr << 
	"CREATE TABLE statement scanned over" << endl << 
	"____________" << endl << endl  ;
	BEGIN(INITIAL);
}

{name} {
	cerr << "scanned name:\t" << yytext << endl ;
}
{WS}+ {/* IGNORE white spaces */}       
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
