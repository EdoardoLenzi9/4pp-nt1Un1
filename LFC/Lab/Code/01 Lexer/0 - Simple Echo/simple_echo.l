%{
	/* 
		'.' meta character matches any character but '\n' 
		therefore to rewrite the whole content we need to add the '\n' character.
		
		ECHO simply prints on yyout, yyleng characters from yytext buffer.
	*/
	int n = 0; 
%}
%%

.|\n		{printf(" %d ", n++); /*mi stampa il numero di caratteri*/} 
.|\n		{ECHO; /* mi stampa le stringhe */} 


%%
/* Depending on your C compiler you'll need to add this definition.*/
int yywrap() {
	return 1;
}

int main() {
	yylex();
}

/*
	flex Input.l
	gcc lex.yy.c -o Lexer.out -std=c99
	./Lexer.out < In.txt
*/