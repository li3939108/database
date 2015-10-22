%{
//Headers


%}



DOT              [.]
DIGIT            [0-9]
letter           [a-z]
integer          {digit}+
comp_op          [<>=]
table_name       {letter}({digit}|{letter})*
attribute_name   {table_name}
column_name      ({table_name}{DOT})?attribute_name
literal          "[^"]"

%%



%%
