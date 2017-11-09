cls
del %1.exe
del lex.yy.c
flex %1.l
gcc lex.yy.c -o %1.exe -std=c99