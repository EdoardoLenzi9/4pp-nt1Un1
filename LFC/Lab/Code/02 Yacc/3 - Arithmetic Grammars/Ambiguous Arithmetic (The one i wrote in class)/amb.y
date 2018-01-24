%{
	#include <stdlib.h>
	#include <stdio.h>
	#include <math.h>
	FILE*yyin;
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
S: E		{printf("%d", $1);};

E: E '+' E	{ $$ = $1 + $3; }
 | E '-' E	{ $$ = $1 - $3; }
 | E '*' E	{ $$ = $1 * $3; }
 | E '/' E	{ $$ = $1 / $3; }
 | E '^' E 	{ $$ = pow($1, $3); }
 | '(' E ')'	{ $$ = $2; }
 | INTEGER 	{ $$ = $1; };

%%
int main() {
	do {
		yyparse();
	} while(!feof(yyin));
}