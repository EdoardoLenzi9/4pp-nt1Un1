lex union_directive.l
yacc -d union_directive.y -o y.tab.c
gcc y.tab.c lex.yy.c -o Parser.exe

