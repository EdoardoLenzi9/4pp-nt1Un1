%{
	#include <stdio.h>
	FILE*yyin;
%}

/* Try to delete some. */
//%start S
//%start A
//%start D

%%

S: A		{ printf("Parsed S.\n");}
 | D		{ printf("Parsed S.\n");} ;

A: 'a' 'b' C	{ printf("Parsed A.\n");} ;
C: 'c' ;

D: 'd' 'e' F	{ printf("Parsed D.\n");} ;
F: 'f'			{ /*printf("Parsed F.\n");*/} ;

%%

int main() {
	do {
		yyparse();
	} while(!feof(yyin));
	return 0;
}