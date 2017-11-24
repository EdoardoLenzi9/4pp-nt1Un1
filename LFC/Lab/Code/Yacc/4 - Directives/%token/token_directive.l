%{
	#include "y.tab.h"
	int yylex();
	void yyerror(char*s);
%}

%option noyywrap

%%

"(a)"	{return A_TOKEN;}
"(b)"	{return B_TOKEN;}
"(c)"	{return C_TOKEN;}
"(d)"	{return D_TOKEN;}
"(e)"	{return E_TOKEN;}
"(f)"	{return F_TOKEN;}
.	{printf("Error\n");}


%%

void yyerror(char*s) {
	printf(s);
}