flex f2.l 
bison -d f2.y -o y.tab.c 
gcc lex.yy.c y.tab.c -o Parser.out -std=c99
echo "\n EXECUTION \n"
./Parser.out 2a3b4a2
echo "\n END \n"
