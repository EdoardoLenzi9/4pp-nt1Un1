%{
	#include <stdlib.h>
	#include <stdio.h>
	#include <math.h>
	FILE*yyin;

	int pow1(int a, int b){
		int c = 1;
		for(int i = 0; i < b; i++)
			c *= a;
		return c;
	}
%}

%union {
	int iInteger;
}

%token INTEGER

%type <iInteger> E INTEGER

%left '+' '-'
%left '*' '/'
%right '^'

%%

S: E			{printf("%d", $1);};

E: E '+' E		{ $$ = $1 + $3; }
 | E '-' E		{ $$ = $1 - $3; }
 | E '*' E		{ $$ = $1 * $3; }
 | E '/' E		{ $$ = $1 / $3; }
 | E '^' E 	{ $$ = pow1($1, $3); } 
 | '-' E 	{ $$ = -$2; }
 | '(' E ')'	{ $$ = $2; }
 | INTEGER 		{ $$ = $1; };

%%
int main() {
	do {
		yyparse();
	} while(!feof(yyin));
}