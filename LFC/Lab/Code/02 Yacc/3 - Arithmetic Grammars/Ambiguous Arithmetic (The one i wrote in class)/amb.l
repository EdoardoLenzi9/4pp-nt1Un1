%{
	#include <stdlib.h>
	#include "y.tab.h"
	void yyerror(char *s);
%}
%option noyywrap
%%
"+" |
"-" |
"*" | 
"/" |
"^" |
"(" |
")"	{return yytext[0];}
[0-9]+		{yylval.iInteger=atoi(yytext); return INTEGER;}
.			{printf("Error: %C.\n", yytext[0]);}
%%

void yyerror(char *s) {
	printf("%s", s);
}