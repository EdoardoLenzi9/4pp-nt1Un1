%{
	/* Text processing tools require sophisticated data structures to work. The symbol table is one of them.
		This specific implementation of the symbol table complys to the one described in the book
		"Algoritmi e strutture dati, seconda edizione" Alan Bertossi, Alberto Montresor. Pgg: 129-140.
		
		The regular expression matching identifiers matches exactly the same thing
		the function "Mystery" matches. (Slides: Introduction.pdf - 9/28) Don't you find it more intuitive?
	*/
	#include "symbol_table.h"
	struct SymbolTable * ctTable = NULL;
	int iNextSymbol = 0;
	char* StringDuplicate(char*sString, int iSize);
%}

%%

[a-zA-Z_][a-zA-Z0-9_]*	{
	fprintf(stdout, "This is a C identifier: %s\n", yytext);
	if (GetIdentifier(ctTable, StringDuplicate(yytext, yyleng), iNextSymbol, NULL) == -1) {
		fprintf(stdout, "\tNew Symbol in table.\n");
		iNextSymbol+=1;
	} else {
		fprintf(stdout, "\tSymbol alredy in table.\n");
	}
						}
[\t \n\r]+				{/*Do nothing.*/;}
.						{ECHO; fprintf(stdout, " is not a keyword.\n");}

%%

/* Error has been solved: it was caused by a wrong reference to the saved symbol. */
char* StringDuplicate(char*sString, int iSize) {
	char*lpszResult = calloc(1, iSize+1);
	int i=0;
	for (;sString[i]!='\0';i+=1){
		lpszResult[i] = sString[i];
	}
	lpszResult[i] = '\0';
	return lpszResult;
}

int yywrap() {
	return 1;
}

int main() {
	ctTable = CreateSymbolTable(23,1);
	if (ctTable!=NULL) {
		yylex();
		DestroySymbolTable(ctTable, true);
	}
}