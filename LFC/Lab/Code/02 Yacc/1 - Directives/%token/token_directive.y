%{
	#include <stdio.h>
	FILE*yyin;
%}

%token A_TOKEN B_TOKEN C_TOKEN D_TOKEN E_TOKEN F_TOKEN

%%

S: A		{ printf("Parsed S.\n");}
 | D		{ printf("Parsed S.\n");} ;

A: A_TOKEN B_TOKEN C	{ printf("Parsed A.\n");} ;
C: C_TOKEN ;

D: D_TOKEN E_TOKEN F	{ printf("Parsed D.\n");} ;
F: F_TOKEN

%%

int main() {
	do {
		yyparse();
	} while(!feof(yyin));
	return 0;
}