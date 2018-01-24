%{
	#include "y.tab.h"
	int yylex();
	void yyerror(char*s);
%}

%option noyywrap

%%

"a" |
"b" |
"c"	|
"d" |
"e" |
"f" {printf("\n Lex %c \n", yytext[0]); return yytext[0];}
.	{printf("Error\n");}


%%

void yyerror(char*s) {
	printf(s);
}