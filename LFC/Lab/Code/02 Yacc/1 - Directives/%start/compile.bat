lex start_directive.l
yacc -d start_directive.y -o y.tab.c
gcc y.tab.c lex.yy.c -o Parser.exe

