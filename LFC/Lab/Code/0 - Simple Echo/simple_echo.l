%{
	/* This file just shows the very basic structure of the lex specification.
		A few reminders: '.' meta character matches anything but '\n' therefore to rewrite the whole content
		we need to add the '\n' character.
		
		ECHO simply prints on yyout, yyleng characters from yytext buffer.
	*/
%}
%%
.|\n		{ECHO;}
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