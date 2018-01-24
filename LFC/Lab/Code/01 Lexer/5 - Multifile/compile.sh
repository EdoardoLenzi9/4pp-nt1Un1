flex *.l 
gcc lex.yy.c -o Lexer.out -std=c99
cp *.txt Input.txt
echo "\n EXECUTION \n"
./Lexer.out < Input.txt
echo "\n END \n"