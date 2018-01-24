flex *.l 
bison -d *.y -o y.tab.c 
gcc lex.yy.c y.tab.c -o Parser.out -std=c99
echo "\n EXECUTION \n"
./Parser.out < D_input.txt
echo "\n END \n"
