CC=clang++
cflag=-lfl

isql: lex.yy.cc
	$(CC)  -o $@ $< $(cflag)
lex.yy.cc: scan.l
	flex -o $@ $<

