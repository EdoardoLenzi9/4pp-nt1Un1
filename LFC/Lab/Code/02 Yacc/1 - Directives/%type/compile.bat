lex type_directive.l
yacc -d type_directive.y -o y.tab.c
gcc y.tab.c lex.yy.c -o Parser.exe

