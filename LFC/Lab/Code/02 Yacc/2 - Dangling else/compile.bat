cls
del lex.yy.c
del y.tab.c
lex dangling_else.l
yacc -d dangling_else.y -o y.tab.c
gcc y.tab.c lex.yy.c -o Parser.exe

