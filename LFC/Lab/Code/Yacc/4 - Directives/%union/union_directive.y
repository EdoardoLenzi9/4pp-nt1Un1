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

%%

S: S LOWER_WORD_TOKEN	{ printf("Lower case word.\n"); }
 | S UPPER_WORD_TOKEN	{ printf("Upper case word.\n"); }
 | S NUMBERS_TOKEN 		{ printf("Numbers.\n"); };
 |
%%

int main() {
	do {
		yyparse();
	} while(!feof(yyin));
	return 0;
}