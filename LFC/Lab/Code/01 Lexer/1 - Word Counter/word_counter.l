%{
	#include <stdlib.h>
	/*	This is copied verbatim to the lexer's source.
		This program keeps track of the number of lines, characters, words and blanks.
	*/
	int iWords = 0, iLines = 1, iCharacters = 0, iBlanks = 0;
%}

word	[^ \t\r\n]

%%


{word}				{iWords+=1; iCharacters+=yyleng;}
{word}+				{iWords+=1; iCharacters+=yyleng;}
{word}*				{iWords+=1; iCharacters+=yyleng;}
"\r"|"\n"|"\r\n"	{iLines+=1;}
[ \t]				{iBlanks+=1;}

<<EOF>>				{printf("Lines: %d, words: %d, characters: %d, blanks: %d.\n", iLines, iWords, iCharacters, iBlanks); return yytext[0];}

%%
int yywrap() {
	return 1;
}

int main() {
	printf("Codice di uscita %d", yylex());
}