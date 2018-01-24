%{
	#include "y.tab.h"
	int yylex();
	void yyerror(char*s);
	char* StringDuplicate(char*sString, int iSize);
%}

%option noyywrap

%%

[a-z]+	{yylval.lpszLowerWord = StringDuplicate(yytext, yyleng); return LOWER_WORD_TOKEN;}
[A-Z]+	{yylval.lpszUpperWord = StringDuplicate(yytext, yyleng);return UPPER_WORD_TOKEN;}
[0-9]+	{yylval.lpszNumbers = StringDuplicate(yytext, yyleng); return NUMBERS_TOKEN;}
[ \t]	{/*Nothing.*/}
.		{printf("Error\n");}

%%

char* StringDuplicate(char*sString, int iSize) {
	char*lpszResult = calloc(1, iSize+1);
	int i=0;
	for (;sString[i]!='\0';i+=1){
		lpszResult[i] = sString[i];
	}
	lpszResult[i] = '\0';
	return lpszResult;
}


void yyerror(char*s) {
	printf(s);
}