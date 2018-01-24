%{
	int iLine = 0;
	int iColumn = 0;
%}

Declaration				"public"[ \t]+("static"[ \t]+)?"void"[ \t]+"main"

%%
"int"					{printf("This type has size: %d bytes.\n", sizeof(int));}
"float"					{printf("This type has size: %d bytes.\n", sizeof(float));}

{Declaration}			{printf("(String args[]);{...}\n");}

"I"{1,3}				{printf("Version: %s.\n", yytext);}

"a" |
"b" |
"c"						{printf("The character '%s' has size: %d bytes.\n", yytext, sizeof(char)); return 10;}

"0x"[0-9A-Fa-f]+			{printf("This is an exadecimal number: %s.\n", yytext);}

[a-zA-Z_][a-zA-Z0-9_]*	{printf("This is an identifier: %s.\n", yytext);}

[\t ]+					{iColumn+=yyleng;}
[\n|\r|\n\r]+			{iColumn=0; iLine+=1;}
.						{ECHO; fprintf(stdout, " at (%d, %d) is not a keyword.\n", iLine, iColumn);}

%%
int yywrap() {
	return 1;
}

int main() {
	printf("%d", yylex());
}