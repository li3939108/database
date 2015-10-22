CC=clang
cflag=-lfl

isql: lex.yy.c
	$(CC)  -o $@ $< $(cflag)
lex.yy.c: scan.l
	flex $<
