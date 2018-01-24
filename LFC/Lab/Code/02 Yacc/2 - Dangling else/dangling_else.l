%{
	#include "y.tab.h"
	int yylex();
	void yyerror(char*s);
	char* StringDuplicate(char*sString, int iSize);
%}

%option noyywrap

%%
[ \t]				{/*Ignore spaces.*/}
"("|")"				{ return yytext[0]; }
"if" 				{ return IF_TOKEN; }
"else"				{ return ELSE_TOKEN; }
"true"				{ return TRUE_TOKEN; }
"false"				{ return FALSE_TOKEN; }
/* I want commands to be prefix of a number to discriminate them.*/
"command"[0-9]+		{ yylval.lpszCommand = StringDuplicate(yytext, yyleng); return COMMAND;}
.					{ printf("%c", yytext[0]);}
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