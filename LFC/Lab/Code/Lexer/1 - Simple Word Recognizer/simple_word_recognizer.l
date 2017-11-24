%{
	/*	This is copied verbatim to the lexer's source.
	*/
%}
%%

"if"		|
"else"		|
"then"		|
"end"		|
"while"		|
"for"		{fprintf(stdout, "This is a keyword: %s\n", yytext);}
[\t \n\r]+	{/*Do nothing.*/;}
.|\n		{ECHO; fprintf(stdout, " is not a keyword.\n");}

%%
int yywrap() {
	return 1;
}

int main() {
	yylex();
}