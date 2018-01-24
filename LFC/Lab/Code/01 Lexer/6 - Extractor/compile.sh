flex *.l 
gcc lex.yy.c -o Lexer.out -std=c99
echo "\n EXECUTION \n"
./Lexer.out in.txt out.txt
cat out.txt
echo "\n END \n"
