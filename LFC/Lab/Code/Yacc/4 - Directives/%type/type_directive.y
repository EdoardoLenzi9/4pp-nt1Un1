%{
	#include <stdio.h>
	FILE*yyin;
%}

%token LOWER_WORD_TOKEN UPPER_WORD_TOKEN NUMBERS_TOKEN

%union {
	char*lpszLowerWord;
	char*lpszUpperWord;
	char*lpszNumbers;
}

%type <lpszLowerWord> LOWER_WORD_TOKEN
%type <lpszUpperWord> UPPER_WORD_TOKEN
%type <lpszNumbers> NUMBERS_TOKEN

%%

S: S LOWER_WORD_TOKEN	{ printf("Lower case word: %s.\n", $2); }
 | S UPPER_WORD_TOKEN	{ printf("Upper case word: %s.\n", $2); }
 | S NUMBERS_TOKEN 		{ printf("Numbers: %s.\n", $2); };
 |
%%

int main() {
	do {
		yyparse();
	} while(!feof(yyin));
	return 0;
}