%{
	#include "stdio.h"
	FILE*yyin;
%}

%token ITEM;
%%
S: ITEM S { printf("a list of item found");}
 | ITEM  {printf("item found");} ;
 
%%
int main(){
	do {
		yyparse();
	} while(!feof(yyin));
	return 0;
}

void yyerror(char*s) {
	printf("%s", s);
}