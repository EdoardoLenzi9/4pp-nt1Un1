flex %1.l
rem yacc -d grammar.y -o y.tab.c
gcc lex.yy.c -o %1.exe -std=c99