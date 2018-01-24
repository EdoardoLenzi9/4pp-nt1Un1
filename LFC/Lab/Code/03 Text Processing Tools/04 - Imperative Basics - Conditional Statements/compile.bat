cls
del %1.exe
del lex.yy.c
lex %1.l
yacc -d %1.y -o y.tab.c
gcc -g3 lex.yy.c y.tab.c symbol_table.c -o %1.exe -std=c99