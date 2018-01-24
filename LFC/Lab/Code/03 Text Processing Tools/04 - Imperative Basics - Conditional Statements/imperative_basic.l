%{
	#include "y.tab.h"
%}

%%
"while"		{return CMD_WHILE;}
"else"		{return CMD_ELSE;}
"if"		{return CMD_IF;}

"&&"		{return BOP_AND;}
"||"		{return BOP_OR;}
"!"			{return UOP_NOT;}

"{"			{return L_CURLY_BRACKET;}
"}"			{return R_CURLY_BRACKET;}
"("			{return L_BRACKET;}
")"			{return R_BRACKET;}
";"			{return COMMA;}
"="			{return EQUAL;}

"true"		{return TRUE;}
"false"		{return FALSE;}
"print"		{return CMD_PRINT;}
[ \t\r\n]	{}

[a-zA-Z]+	{
				char * cResult = calloc(1, sizeof(char)*yyleng);
				for (int i=0; i<yyleng; i+=1) {
					cResult[i] = yytext[i];
				}
				yylval.cString = cResult;
				return ID;
			}

.			{REJECT}
%%
