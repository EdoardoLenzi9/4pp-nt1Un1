%{
	#include <stdio.h>
	#include <string.h>
	#include <stdlib.h>
	#include <math.h>
	int yylex();
	int yyparse();
	FILE *yyin;
	void yyerror(char *s);
%}

%union{
	int iInteger;
}

%token INTEGER REAL

%type	<iInteger> 	S Expression Term Factor Exponent Value INTEGER

%%
S: Expression					{printf("%d", $1);}

Expression:	Expression '+' Term	{$$=$1+$3;}
	|		Expression '-' Term	{$$=$1-$3;}
	|		Term				{$$=$1;}
	;

Term:		Term '/' Exponent	{$$=$1/$3;}
	|		Term '*' Exponent	{$$=$1*$3;}
	|		Exponent			{$$=$1;}
	;

Exponent:	Factor '^' Exponent		{$$=pow($1, $3);}
	|		Factor					{$$=$1;}
	;
	
Factor:		'-' Value				{$$=-$2;}
	|		Value					{$$=$1;}
	;
	
Value:		'(' Expression ')'	{$$=$2;}
	|		INTEGER				{$$=$1;}
	;
	
%%
int main(){
    do {
        yyparse();
    } while (!feof(yyin));

}

void yyerror(char *s) {
	printf("%s", s);
}
