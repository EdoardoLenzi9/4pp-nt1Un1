lex token_directive.l
yacc -d token_directive.y -o y.tab.c
gcc y.tab.c lex.yy.c -o Parser.exe

