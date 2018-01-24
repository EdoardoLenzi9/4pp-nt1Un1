flex *.l 
#bison -d left_recursive_list.y -o y.tab.c # process kill memory
bison -d right_recursive_list.y -o y.tab.c # memory exausted
gcc lex.yy.c y.tab.c -o Parser.out -std=c99 
echo "\n EXECUTION \n"
./Parser.out < input.txt
echo "\n END \n"
