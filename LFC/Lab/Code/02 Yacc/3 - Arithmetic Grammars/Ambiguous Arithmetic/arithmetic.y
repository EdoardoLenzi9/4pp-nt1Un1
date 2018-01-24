%{
/* Meaningful example of s-attributed grammar.*/
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <math.h>

int yylex();
int yyparse();
FILE *yyin;
void yyerror(char *s);

int pow1(int a, int b){
	int c = 1;
	for(int i = 0; i < b; i++)
		c *= a;
	return c;
}

%}

%union{
	int iInteger;
}

%token INTEGER

%type	<iInteger> 	Expression INTEGER

%left '+' '-'
%left '*' '/'
%right '^'
%nonassoc SpecialSymbol

%%
S: Expression					{printf("%d", $1);}

Expression:	Expression	'+'		Expression	{$$= $1+$3;}
	|		Expression	'-'		Expression	{$$= $1-$3;}
	|		Expression	'/'		Expression	{$$= $1/$3;}
	|		Expression	'*'		Expression	{$$= $1*$3;}
	|		Expression	'^' 	Expression	{$$= pow1($1, $3);}  
	|		'-'	Expression					{$$= -$2;}			%prec SpecialSymbol
	|		'('	Expression ')'				{$$= $2;}
	|		INTEGER							{$$= $1;}
	;
	
%%
int main(){
    do {
        yyparse();
    } while (!feof(yyin));

}

void yyerror(char *s) {
	printf("Error when reading: %s", s);
}
