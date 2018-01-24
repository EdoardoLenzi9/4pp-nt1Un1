cls
del %1.exe
del lex.yy.c
lex %1.l
rem yacc -d grammar.y -o y.tab.c
gcc lex.yy.c symbol_table.c -o %1.exe -std=c99