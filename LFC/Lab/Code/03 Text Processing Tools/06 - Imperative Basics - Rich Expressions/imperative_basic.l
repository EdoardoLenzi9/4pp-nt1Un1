%{
	#include "y.tab.h"
%}
%x Comment
%%
"while"		{return CMD_WHILE;}
"else"		{return CMD_ELSE;}
"if"		{return CMD_IF;}

"&&"		{return BOP_AND;}
"||"		{return BOP_OR;}
"!"			{return UOP_NOT;}

">="		{return BOP_GE;}
"<="		{return BOP_LE;}
">"			{return BOP_GT;}
"<"			{return BOP_LT;}
"!="		{return BOP_NE;}
"=="		{return BOP_EQ;}

"+"			{return BOP_PLUS;}
"-"			{return OP_MINUS;}
"*"			{return BOP_MULTIPLY;}
"/"			{return BOP_DIVIDE;}

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
[0-9]+		{yylval.iValue=atoi(yytext);return DECIMAL;}
"#"					{BEGIN Comment;}
<Comment>[^#]*		{/*Ignore*/}
<Comment>"#"		{BEGIN INITIAL;}
.			{REJECT}
%%
