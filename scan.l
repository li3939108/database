%{
#include <stdio.h>
#include <stdlib.h>
#include <iostream>

#define GREEN_TEXT  "\e[1;32m"
#define RED_TEXT "\e[1;31m"
#define NORMAL_TEXT "\e[0m"
#define HLINE  "---------------"


using namespace std;

void err_out_START(const char str[]) ;
void err_out_OVER(const char str[]) ;
%}

%s                    DROP_TABLE_STATEMENT
%s                    DELETE_STATEMENT
%s                    SELECT_STATEMENT
%s                    INSERT_STATEMENT

%s                    CREATE_TABLE_STATEMENT
%s                    C_T_S_EXPECT_LEFT_PARENTHESIS
%s                    C_T_S_EXPECT_ATTR
%s                    C_T_S_EXPECT_TYPE
%s                    C_T_S_EXPECT_COMMA_OR_RIGHT_PARENTHESIS
%s                    C_T_S_EXPECT_WS

%s                    I_S_EXPECT_LEFT_PARENTHESIS
%s                    I_S_EXPECT_ATTR
%s                    I_S_VALUES_EXPECT_LEFT_PARENTHESIS_OR_SELECT
%s                    I_S_EXPECT_VALUES
%s                    I_S_EXPECT_COMMA_OR_RIGHT_PARENTHESIS
%s                    I_S_VALUES_EXPECT_COMMA_OR_RIGHT_PARENTHESIS
%s                    I_S_VALUES_EXPECT_value


DOT                   [.]
digit                 [0-9]
letter                [a-z]
integer               {digit}+
comp_op               [<>=]
pm_op                 [+-]
md_op                 [*/]
name                  {letter}({digit}|{letter})* 
dotted_name           {name}{DOT}{name}
literal               \"[^"]\"
value                 {literal}|{integer}|{NULL}
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
LEFT_PARENTHESIS      [(]
RIGHT_PARENTHESIS     [)]
COMMA                 [,]

%%

{SELECT}{WS}+ {
	err_out_START("SELECT [DISTINCT]");
	BEGIN(SELECT_STATEMENT);
}
{D_F}{WS}+ {
	err_out_START("DELETE FROM");
	BEGIN(DELETE_STATEMENT);
}
{C_T}{WS}+ {
	err_out_START("CREATE TABLE" );
	BEGIN(CREATE_TABLE_STATEMENT);
}
{D_T}{WS}+ {
	err_out_START("DROP TABLE" );
	BEGIN(DROP_TABLE_STATEMENT);
}
{I_I}{WS}+ {
	err_out_START("INSERT INTO");
	BEGIN(INSERT_STATEMENT);
}
<SELECT_STATEMENT>{dotted_name} { 
	cerr << "column_name:\t" << yytext << endl ;
}
<DELETE_STATEMENT>{name} {/* DELETE from table */
	cerr << "delete table:\t" << yytext << endl ;
}
<DROP_TABLE_STATEMENT>{name} {
	cerr << "table to Drop:\t" << yytext << endl ;
	err_out_OVER("DROP TABLE");
	BEGIN(INITIAL);
}




<INSERT_STATEMENT>{name} {
	cerr << "table to ins:\t" << yytext << endl;
	BEGIN(I_S_EXPECT_LEFT_PARENTHESIS);
}
<I_S_EXPECT_LEFT_PARENTHESIS>{WS}*{LEFT_PARENTHESIS}{WS}* {
	BEGIN(I_S_EXPECT_ATTR);
}
<I_S_EXPECT_ATTR>{name} {
	BEGIN(I_S_EXPECT_COMMA_OR_RIGHT_PARENTHESIS) ;
	cerr << "attribute :\t" << yytext <<endl ;
}
<I_S_EXPECT_COMMA_OR_RIGHT_PARENTHESIS>{WS}*{COMMA}{WS}* {
	BEGIN (I_S_EXPECT_ATTR) ;
}
<I_S_EXPECT_COMMA_OR_RIGHT_PARENTHESIS>{WS}*{RIGHT_PARENTHESIS}{WS}* {
	BEGIN(I_S_EXPECT_VALUES) ;
}
<I_S_EXPECT_VALUES>{V} {
	BEGIN(I_S_VALUES_EXPECT_LEFT_PARENTHESIS_OR_SELECT);
}
<I_S_VALUES_EXPECT_LEFT_PARENTHESIS_OR_SELECT>{WS}*{LEFT_PARENTHESIS}{WS}* {
	BEGIN(I_S_VALUES_EXPECT_value);
}
<I_S_VALUES_EXPECT_value>{value} {
	cerr << "value:      \t" << yytext << endl;
	BEGIN(I_S_VALUES_EXPECT_COMMA_OR_RIGHT_PARENTHESIS);
}
<I_S_VALUES_EXPECT_COMMA_OR_RIGHT_PARENTHESIS>{WS}*{COMMA}{WS}* {
	BEGIN(I_S_VALUES_EXPECT_value) ;
}
<I_S_VALUES_EXPECT_COMMA_OR_RIGHT_PARENTHESIS>{WS}*{RIGHT_PARENTHESIS}{WS}* {
	err_out_OVER("INSERT INTO");
	BEGIN(INITIAL);
}


<CREATE_TABLE_STATEMENT>{name} {
	/* Enter CREATE TABLE statement */
	cerr << "create table:\t" << yytext << endl;
	BEGIN(C_T_S_EXPECT_LEFT_PARENTHESIS);
}
<C_T_S_EXPECT_LEFT_PARENTHESIS>{WS}*{LEFT_PARENTHESIS}{WS}* {
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
	BEGIN(C_T_S_EXPECT_COMMA_OR_RIGHT_PARENTHESIS) ;
}
<C_T_S_EXPECT_COMMA_OR_RIGHT_PARENTHESIS>{WS}*{COMMA}{WS}* {
	BEGIN(C_T_S_EXPECT_ATTR);
}
<C_T_S_EXPECT_COMMA_OR_RIGHT_PARENTHESIS>{WS}*{RIGHT_PARENTHESIS}{WS}* {
	err_out_OVER("CREATE TABLE");
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

void err_out_START(const char str[]) {
	#ifndef  NO_ERROR_OUTPUT
	cerr << GREEN_TEXT << HLINE << endl << "Scan start:\t" <<
	str << NORMAL_TEXT << endl;
	#endif
}
void err_out_OVER(const char str[]){
	#ifndef  NO_ERROR_OUTPUT
	cerr << RED_TEXT << "Scan over:\t" <<
	str <<  endl << 
	HLINE << NORMAL_TEXT <<  endl  ;
	#endif
}
int main( int argc, char **argv ){
	++argv, --argc;  /* skip over program name */
	if ( argc > 0 ){
		yyin = fopen( argv[0], "r" );
	}else{
		yyin = stdin;
	}
	yylex();
}
