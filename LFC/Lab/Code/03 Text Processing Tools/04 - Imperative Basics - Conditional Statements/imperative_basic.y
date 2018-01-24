%{	/*
		Bottom up AST building, top down AST Evaluation.
	*/
	#include <stdio.h>
	#include <string.h>
	#include <stdlib.h>
	#include "symbol_table.h"
	
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

	/* This is the basic structure used for the AST (abstract syntax tree) construction.*/
	struct OperationNode {
		/* The purpose of the tree is to represent binary operations in general. It has 2 child BinaryOperationnodes. */
		struct OperationNode*lpLeftOperationNode;
		struct OperationNode*lpRightOperationNode;
		/* According to iType AST evaluation changes. Check Evaluate(.) function. */
		int iType;
		/* In case a BinaryOperationnode holds a truth value: true | false, i keep track of it. */
		union {
			bool bValue;
			char*lpszIdentifier;
		};
	};

	bool Evaluate(struct OperationNode *lpOperationNode);
	struct OperationNode *BuildBooleanIdentifierNode(int iType, char* cValue);
	struct OperationNode* BuildBooleanOperationNode(struct OperationNode* lpLeft, struct OperationNode*lpRight, int iType, bool bValue);
	struct OperationNode *BuildCommandNode(struct OperationNode*lpLeft,struct OperationNode*lpRight,int iType,char*lpszIdentifier);
	void*Execute(struct OperationNode*lpCmd);

	/* Possible operations. */
	enum {
		LOGIC_AND,
		LOGIC_OR,
		LOGIC_NOT,
		LOGIC_VALUE,
		IDENTIFIER,

		PRINT_OP,
		ASSIGN_OP,
		WHILE_OP,
		CONJUNCTION_OP
	};
	enum {
		TYPE_BOOLEAN,
		TYPE_INTEGER
	};
	
	/* The symbol table. */
	struct SymbolTable*stTable = NULL;
%}

/* Parser/Lexer token agreement. */
%token BOP_OR BOP_AND UOP_NOT ID FALSE TRUE
%token CMD_ELSE CMD_IF CMD_PRINT CMD_WHILE
%token L_BRACKET R_BRACKET COMMA L_CURLY_BRACKET R_CURLY_BRACKET EQUAL

/*	Build union: i was forced to write "int bValue;" by the compiler.
	Bool type definition is not put close enough to lexer's file beginning.
	Writing int bValue is good enough because bool is defined as an int having 2 values: 0 and 1.
*/
%union {
	int bValue;
	char *cString;
	struct OperationNode* lpOperationNode;
	//struct ExecutableNode*lpExecutableNode;
}

/* All non terminals are of type OperationNode. */
%type <lpOperationNode> B O N A Cmd S
%type <cString> ID


/*
	The idea is simple: every BinaryOperationnode in the tree hols either a value [true, false] or an operation.
	The following operations are supported: && ,||, !.
	
	The Grammar is LALR(1).
*/
%%
G: S						{ Execute($1); }
S: S Cmd					{ $$ = BuildCommandNode($1, $2, CONJUNCTION_OP, NULL); }
 | Cmd						{ $$ = BuildCommandNode($1, NULL, CONJUNCTION_OP, NULL); }

Cmd: ID EQUAL B				{ $$ = BuildCommandNode($3, NULL, ASSIGN_OP, $1); }
  | CMD_PRINT L_BRACKET B R_BRACKET
							{ $$ = BuildCommandNode($3, NULL, PRINT_OP, NULL); }
  | CMD_WHILE L_BRACKET B R_BRACKET L_CURLY_BRACKET S R_CURLY_BRACKET
							{ $$ = BuildCommandNode($3, $6, WHILE_OP, NULL); }


B: B BOP_OR O				{ $$ = BuildBooleanOperationNode($1, $3, LOGIC_OR, false); }
 | O 						{ $$ = $1;} /* Done. */
O: O BOP_AND N				{ $$ = BuildBooleanOperationNode($1, $3, LOGIC_AND, false); }
 | N						{ $$ = $1; } /* Done. */
N: UOP_NOT A				{ $$ = BuildBooleanOperationNode($2, NULL, LOGIC_NOT, false);}
 | A						{ $$ = $1; } /* Done. */
A: FALSE					{ $$ = BuildBooleanOperationNode(NULL, NULL, LOGIC_VALUE, false); }
 | TRUE						{ $$ = BuildBooleanOperationNode(NULL, NULL, LOGIC_VALUE, true); }
 | ID						{ $$ = BuildBooleanIdentifierNode(IDENTIFIER, $1); }
 | L_BRACKET B R_BRACKET	{ $$ = $2; }/* Done. */
 
%%
	
int main(int iArgC, char**lpszArgV) {
	if (iArgC>=1) {
		stTable = CreateSymbolTable(1, 13);
		FILE *myfile = fopen(lpszArgV[1], "r");
		if (!myfile) {
			printf("I can't open %s.\n", lpszArgV[1]);
		} else {
			yyin = myfile;

			do {
				yyparse();
			} while (!feof(yyin));
		}
		DestroySymbolTable(stTable, true);
	} else {
		printf("Not enough parameters.\n");
	}
}

void yyerror(char *s) {
	printf("Error when reading: %s", s);
}

bool yywrap() {return true;}

/* Navigate through the tree and compute the tree value. */
bool Evaluate(struct OperationNode *lpOperationNode) {
	bool bSuccess = false;
	if (lpOperationNode!=NULL) {
		switch (lpOperationNode->iType) {
			case IDENTIFIER: {
				char *lpszIdentifier = lpOperationNode->lpszIdentifier;
				struct Variable* vID = GetSymbolID(stTable, lpszIdentifier);
				if (vID==NULL) {
					printf("Unknown identifier: %s.\n", lpszIdentifier);
				} else {
					bSuccess = vID->bValue;
				}
				break;
			}
			case LOGIC_VALUE: {bSuccess = lpOperationNode->bValue; break;}
			case LOGIC_AND: {bSuccess = Evaluate(lpOperationNode->lpLeftOperationNode) && Evaluate(lpOperationNode->lpRightOperationNode); break;}
			case LOGIC_OR: {bSuccess = Evaluate(lpOperationNode->lpLeftOperationNode) || Evaluate(lpOperationNode->lpRightOperationNode); break;}
			case LOGIC_NOT: {bSuccess = !Evaluate(lpOperationNode->lpLeftOperationNode); break;}
		}
	}
	return bSuccess;
}

/* Build the AST. */
struct OperationNode *BuildBooleanOperationNode(struct OperationNode* lpLeft, struct OperationNode*lpRight, int iType, bool bValue) {
	struct OperationNode* lpResult = NULL;
	lpResult = calloc(1, sizeof(struct OperationNode)*sizeof(char));
	if (lpResult!=NULL) {
		lpResult->iType = iType;
		switch (iType) {
			case LOGIC_AND:
			case LOGIC_OR: {
				lpResult->lpLeftOperationNode = lpLeft;
				lpResult->lpRightOperationNode = lpRight;
				break;
				}
			case LOGIC_NOT: {
				lpResult->lpLeftOperationNode = lpLeft;
				break;
			}
			case LOGIC_VALUE: {
				if (lpLeft!=NULL) {
					lpResult->lpLeftOperationNode = lpLeft;
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
	return lpResult;
}

/* Build the AST. */
struct OperationNode *BuildBooleanIdentifierNode(int iType, char* cValue) {
	struct OperationNode* lpResult = NULL;
	lpResult = calloc(1, sizeof(struct OperationNode)*sizeof(char));
	if (lpResult!=NULL) {
		lpResult->iType = iType;
		switch (iType) {
			case IDENTIFIER: {
				lpResult->lpszIdentifier = cValue;
				lpResult->lpLeftOperationNode = NULL;
				lpResult->lpRightOperationNode = NULL;
				break;
				}
			default:{
				/* Error. */
				break;
			}
		}
	}
	return lpResult;
}

/* Build the AST. */
struct OperationNode *BuildCommandNode(
						struct OperationNode*lpLeft,
						struct OperationNode*lpRight,
						int iType,
						char*lpszIdentifier
						) {
	struct OperationNode* lpResult = NULL;
	lpResult = calloc(1, sizeof(struct OperationNode)*sizeof(char));
	if (lpResult!=NULL) {
		lpResult->iType = iType;
		switch (iType) {
			case PRINT_OP:{
				lpResult->lpszIdentifier = NULL;
				lpResult->lpLeftOperationNode = lpLeft;
				lpResult->lpRightOperationNode = NULL;
				break;
			}
			case CONJUNCTION_OP:
			case WHILE_OP:{
				lpResult->lpszIdentifier = NULL;
				lpResult->lpLeftOperationNode = lpLeft;
				lpResult->lpRightOperationNode = lpRight;
				break;
			}
			case ASSIGN_OP:{
				lpResult->lpszIdentifier = lpszIdentifier;
				lpResult->lpLeftOperationNode = lpLeft;
				lpResult->lpRightOperationNode = NULL;
				break;
			}
			default:{
				/* Error. */
				break;
			}
		}
	}
	return lpResult;
}

/* Execute the AST. */
void*Execute(struct OperationNode*lpCmd) {
	if (lpCmd!=NULL) {
		switch (lpCmd->iType) {
			case CONJUNCTION_OP:{
				Execute(lpCmd->lpLeftOperationNode);
				Execute(lpCmd->lpRightOperationNode);
				break;
			}
			case PRINT_OP:{
				printf( Evaluate(lpCmd->lpLeftOperationNode) ? "true\n" : "false\n");
				break;
			}
			case WHILE_OP:{
				while ( Evaluate(lpCmd->lpLeftOperationNode) ) {
					Execute(lpCmd->lpRightOperationNode);
				}
				break;
			}
			case ASSIGN_OP:{
				char *lpszIdentifier = lpCmd->lpszIdentifier;
				
				struct Variable* vID = GetSymbolID(stTable, lpszIdentifier);
				if (vID==NULL) {
					vID = calloc(1, sizeof(struct Variable)*sizeof(char));
					vID->iType = TYPE_BOOLEAN;
					vID->bValue = Evaluate(lpCmd->lpLeftOperationNode);

					SetSymbolID(stTable, lpszIdentifier, vID);
				} else {
					/* Fetch value. */
					vID->bValue = Evaluate(lpCmd->lpLeftOperationNode);
				}
				break;
			}
			default:{
				printf("Error\n");
				/* Error. */
				break;
			}
		}
	}
}