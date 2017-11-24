cls
del %1.exe
del lex.yy.c
lex %1.l
gcc lex.yy.c -o %1.exe -std=c99