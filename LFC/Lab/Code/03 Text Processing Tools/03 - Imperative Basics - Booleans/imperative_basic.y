%{
	/*
		Bottom up AST building, top down AST evaluation.
		
	*/
	#include <stdio.h>
	#include <string.h>
	#include <stdlib.h>
	
	/*
		Lexer and parser functions must be declared.
	*/
	int yylex();
	int yyparse();
	/*
		Also the file input stream must be declared, this is the variable you should overwrite to read
		a possible next input file.
	*/
	FILE *yyin;
	void yyerror(char *s);

	/* I define the bool type for my comfort.*/
	typedef int bool;
	enum { false, true };
	
	/* This is the basic structure used for the AST (abstract syntax tree) construction.*/
	struct Node {
		/* The purpose of the tree is to represent binary operations in general. It has 2 child nodes. */
		struct Node*lpLeftNode;
		struct Node*lpRightNode;
		/* According to iType AST evaluation changes. Check Evaluate(.) function. */
		int iType;
		/* In case a node holds a truth value: true | false, i keep track of it. */
		bool bValue;
	};
	
	struct Node* BuildBooleanNode(struct Node* lpLeft, struct Node*lpRight, int iType, bool bValue);
	
	/* Possible operations. */
	enum {
		LOGIC_AND,
		LOGIC_OR,
		LOGIC_NOT,
		LOGIC_VALUE
	};
%}

/* Parser/Lexer token agreement. */
%token BOP_OR BOP_AND UOP_NOT ID FALSE TRUE
%token CMD_ELSE CMD_IF
%token L_BRACKET R_BRACKET COMMA L_CURLY_BRACKET R_CURLY_BRACKET

/*	Build union: i was forced to write "int bValue;" by the compiler.
	Bool type definition is not put close enough to lexer's file beginning.
	Writing int bValue is good enough because bool is defined as an int having two values: 0 and 1.
*/
%union {
	int bValue;
	char *cString;
	struct Node* lpNode;
}

/* All non terminals are of type Node. */
%type <lpNode> B O A N
%type <cString> ID


/*
	The idea is simple: every node in the tree hols either a value [true, false] or an operation.
	The following operations are supported: && ,||, !.
	
	The Grammar is LALR(1).
*/
%%
S: B						{
								bool bResult = Evaluate($1);
								printf("Result: %s", bResult ? "true" : "false");
							}

B: B BOP_OR O				{ $$ = BuildBooleanNode($1, $3, LOGIC_OR, false); }
 | O 						{ $$ = $1;}; /* Done. */
O: O BOP_AND N				{ $$ = BuildBooleanNode($1, $3, LOGIC_AND, false); }
 | N						{ $$ = $1; };/* Done. */
N: UOP_NOT A				{ $$ = BuildBooleanNode($2, NULL, LOGIC_NOT, false);}
 | A						{ $$ = $1; }/* Done. */
A: FALSE					{ $$ = BuildBooleanNode(NULL, NULL, LOGIC_VALUE, false); }
 | TRUE						{ $$ = BuildBooleanNode(NULL, NULL, LOGIC_VALUE, true); }
 | ID						{ $$ = BuildBooleanNode(NULL, NULL, LOGIC_VALUE, true); /* Access symbol table here.*/}
 | L_BRACKET B R_BRACKET	{ $$ = $2; }/* Done. */
 
%%
	
int main(int iArgC, char**lpszArgV) {
    do { yyparse(); } while (!feof(yyin));
}

void yyerror(char *s) {
	printf("Error when reading: %s", s);
}

bool yywrap() {return true;}

/* Navigate through the tree and compute the tree value. */
bool Evaluate(struct Node *lpNode) {
	bool bSuccess = false;
	if (lpNode!=NULL) {
		switch (lpNode->iType) {
			case LOGIC_VALUE: {bSuccess = lpNode->bValue; break;}
			case LOGIC_AND: {bSuccess = Evaluate(lpNode->lpLeftNode) && Evaluate(lpNode->lpRightNode); break;}
			case LOGIC_OR: {bSuccess = Evaluate(lpNode->lpLeftNode) || Evaluate(lpNode->lpRightNode); break;}
			case LOGIC_NOT: {bSuccess = !Evaluate(lpNode->lpLeftNode); break;}
		}
	}
	return bSuccess;
}

/* Build the AST. */
struct Node *BuildBooleanNode(struct Node* lpLeft, struct Node*lpRight, int iType, bool bValue) {
	struct Node* lpResult = NULL;
	lpResult = calloc(1, sizeof(struct Node)*sizeof(char));
	if (lpResult!=NULL) {
		lpResult->iType = iType;
		switch (iType) {
			case LOGIC_AND:
			case LOGIC_OR: {
				lpResult->lpLeftNode = lpLeft;
				lpResult->lpRightNode = lpRight;
				break;
				}
			case LOGIC_NOT: {
				lpResult->lpLeftNode = lpLeft;
				break;
			}
			case LOGIC_VALUE: {
				if (lpLeft!=NULL) {
					lpResult->lpLeftNode = lpLeft;
				} else {
					lpResult->bValue = bValue;
				}
				break;
				}
			default:{
				/* Error. */
				break;
			}
		}
	}
}
