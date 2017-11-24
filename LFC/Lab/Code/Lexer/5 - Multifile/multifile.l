%{
	#include <stdlib.h>
	/*	This is copied verbatim to the lexer's source.
		This program keeps track of the number of lines, characters, words and blanks in many files.
	*/
	int iCurrentFile = 0;
	int iFiles = 0;
	char**lpszFileName = NULL;
	int iWords = 0, iLines = 1, iCharacters = 0, iBlanks = 0;
%}

word	[^ \t\r\n]

%%

{word}+				{iWords+=1; iCharacters+=yyleng;}
"\r"|"\n"|"\r\n"	{iLines+=1;}
[ \t]				{iBlanks+=1;}

%%
int yywrap() {
	FILE*fInput = NULL;
	if (iCurrentFile<iFiles) {
		printf("File number %d [Lines: %d, words: %d, characters: %d, blanks: %d.]\n", iCurrentFile+1, iLines, iWords, iCharacters, iBlanks);
		iWords = 0; iLines = 1; iCharacters = 0; iBlanks = 0;
		
		fclose(yyin);
		
		iCurrentFile+=1;
		
		fInput = fopen(lpszFileName[iCurrentFile], "r");
		if (fInput!=NULL) {
			yyin = fInput;
		}		
	}
	return fInput!=NULL ? 0 : 1;
}

int main(int iArgC, char**lpszArgV) {
	if (iArgC>1){
		iFiles=iArgC;
		lpszFileName = &lpszArgV[1];
		
		FILE*fInput = fopen(lpszFileName[iCurrentFile], "r");
		if (fInput!=NULL) {
			yyin = fInput;
			yylex();
		}
	}
}