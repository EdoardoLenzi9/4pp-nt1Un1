clear 
rm *.out
flex *.l 
gcc *.c *.h -o Lexer.out -std=c99
cp *.txt Input.txt
echo "\n EXECUTION \n"
./Lexer.out
echo "\n\n END \n"