clear 
rm *.out
flex *.l 
gcc *.c -o Lexer.out -std=c99
echo "\n EXECUTION \n"
./Lexer.out In.txt In1.txt
echo "\n\n END \n"