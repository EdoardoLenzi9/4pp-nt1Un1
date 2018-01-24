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
			int iValue;
			char*lpszIdentifier;
		};
		int iFirstLabel;
		int iSecondLabel;
		int iThirdLabel;
	};

	int Evaluate(struct OperationNode *lpOperationNode);
	struct OperationNode *BuildBooleanIdentifierNode(int iType, char* cValue);
	struct OperationNode* BuildOperationdNode(struct OperationNode* lpLeft, struct OperationNode*lpRight, int iType, int iValue);
	struct OperationNode *BuildCommandNode(struct OperationNode*lpLeft,struct OperationNode*lpRight,int iType,char*lpszIdentifier);
	void*Execute(struct OperationNode*lpCmd);

	/* Possible operations. */
	enum {
		ARITHMETIC_VALUE,
		ARITHMETIC_PLUS,
		ARITHMETIC_MINUS,
		ARITHMETIC_MULTIPLY,
		ARITHMETIC_DIVIDE,
		ARITHMETIC_UNARY_MINUS,
		
		COMPARATOR_EQUAL,
		COMPARATOR_DIFFERENT,
		COMPARATOR_GREATER_EQUAL,
		COMPARATOR_GREATER,
		COMPARATOR_LOWER_EQUAL,
		COMPARATOR_LOWER,
		
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
	void Translate(struct OperationNode*lpCmd);
	int iLabelCounter= 0;
%}

/* Parser/Lexer token agreement. */
%token BOP_OR BOP_AND UOP_NOT ID FALSE TRUE DECIMAL
%token BOP_PLUS OP_MINUS BOP_MULTIPLY BOP_DIVIDE BOP_GT BOP_LT BOP_GE BOP_LE BOP_NE BOP_EQ
%token CMD_ELSE CMD_IF CMD_PRINT CMD_WHILE
%token L_BRACKET R_BRACKET COMMA L_CURLY_BRACKET R_CURLY_BRACKET EQUAL

/*	Build union: i was forced to write "int bValue;" by the compiler.
	Bool type definition is not put close enough to lexer's file beginning.
	Writing int bValue is good enough because bool is defined as an int having 2 values: 0 and 1.
*/
%union {
	int iValue;
	int bValue;
	char *cString;
	struct OperationNode* lpOperationNode;
	//struct ExecutableNode*lpExecutableNode;
}

/* All non terminals are of type OperationNode. */
%type <lpOperationNode> B O C E T N A Cmd S
%type <cString> ID
%type <iValue> DECIMAL

/*
	The Grammar is LALR(1).
*/
%%
G: S						{ Translate($1); }
S: S Cmd					{ $$ = BuildCommandNode($1, $2, CONJUNCTION_OP, NULL); }
 | Cmd						{ $$ = BuildCommandNode($1, NULL, CONJUNCTION_OP, NULL); }

Cmd: ID EQUAL B				{ $$ = BuildCommandNode($3, NULL, ASSIGN_OP, $1); }
  | CMD_PRINT L_BRACKET B R_BRACKET
							{ $$ = BuildCommandNode($3, NULL, PRINT_OP, NULL); }
  | CMD_WHILE L_BRACKET B R_BRACKET L_CURLY_BRACKET S R_CURLY_BRACKET
							{ $$ = BuildCommandNode($3, $6, WHILE_OP, NULL); }

B: B BOP_OR O				{ $$ = BuildOperationdNode($1, $3, LOGIC_OR, false); }
 | O 						{ $$ = $1;} /* Done. */
O: O BOP_AND C				{ $$ = BuildOperationdNode($1, $3, LOGIC_AND, false); }
 | C						{ $$ = $1; } /* Done. */

C: C BOP_GT E				{ $$ = BuildOperationdNode($1, $3, COMPARATOR_GREATER, false); }
 | C BOP_LT E				{ $$ = BuildOperationdNode($1, $3, COMPARATOR_LOWER, false); }
 | C BOP_GE E				{ $$ = BuildOperationdNode($1, $3, COMPARATOR_GREATER_EQUAL, false); }
 | C BOP_LE E 				{ $$ = BuildOperationdNode($1, $3, COMPARATOR_LOWER_EQUAL, false); }
 | C BOP_EQ E				{ $$ = BuildOperationdNode($1, $3, COMPARATOR_EQUAL, false); }
 | C BOP_NE E				{ $$ = BuildOperationdNode($1, $3, COMPARATOR_DIFFERENT, false); }
 | E						{ $$ = $1; };

E: E BOP_PLUS T				{ $$ = BuildOperationdNode($1, $3, ARITHMETIC_PLUS, false); }
 | E OP_MINUS T				{ $$ = BuildOperationdNode($1, $3, ARITHMETIC_MINUS, false); }
 | T						{ $$ = $1; };

T: T BOP_MULTIPLY N			{ $$ = BuildOperationdNode($1, $3, ARITHMETIC_MULTIPLY, false); }
 | T BOP_DIVIDE N			{ $$ = BuildOperationdNode($1, $3, ARITHMETIC_DIVIDE, false); }
 | N 						{ $$ = $1; };
 
N: UOP_NOT N				{ $$ = BuildOperationdNode($2, NULL, LOGIC_NOT, false); }
 | OP_MINUS N				{ $$ = BuildOperationdNode($2, NULL, ARITHMETIC_UNARY_MINUS, false); }
 | A						{ $$ = $1; } /* Done. */
 
A: FALSE					{ $$ = BuildOperationdNode(NULL, NULL, LOGIC_VALUE, false); }
 | TRUE						{ $$ = BuildOperationdNode(NULL, NULL, LOGIC_VALUE, true); }
 | ID						{ $$ = BuildBooleanIdentifierNode(IDENTIFIER, $1); }
 | DECIMAL					{ $$ = BuildOperationdNode(NULL, NULL, ARITHMETIC_VALUE, $1); }
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
int Evaluate(struct OperationNode *lpOperationNode) {
	int iValue = false;
	if (lpOperationNode!=NULL) {
		switch (lpOperationNode->iType) {
			case IDENTIFIER: {
				char *lpszIdentifier = lpOperationNode->lpszIdentifier;
				struct Variable* vID = GetSymbolID(stTable, lpszIdentifier);
				if (vID==NULL) {
					printf("Unknown identifier: %s.\n", lpszIdentifier);
				} else {
					iValue = vID->bValue;
				}
				break;
			}
			case ARITHMETIC_VALUE:		{iValue = lpOperationNode->iValue;break;}
			case ARITHMETIC_PLUS:		{iValue = Evaluate(lpOperationNode->lpLeftOperationNode) + Evaluate(lpOperationNode->lpRightOperationNode); break;}
			case ARITHMETIC_MINUS:		{iValue = Evaluate(lpOperationNode->lpLeftOperationNode) - Evaluate(lpOperationNode->lpRightOperationNode); break;}
			case ARITHMETIC_MULTIPLY:	{iValue = Evaluate(lpOperationNode->lpLeftOperationNode) * Evaluate(lpOperationNode->lpRightOperationNode); break;}
			case ARITHMETIC_DIVIDE:		{iValue = Evaluate(lpOperationNode->lpLeftOperationNode) / Evaluate(lpOperationNode->lpRightOperationNode); break;}
				
			case COMPARATOR_EQUAL:			{iValue = Evaluate(lpOperationNode->lpLeftOperationNode) == Evaluate(lpOperationNode->lpRightOperationNode); break;}
			case COMPARATOR_DIFFERENT:		{iValue = Evaluate(lpOperationNode->lpLeftOperationNode) != Evaluate(lpOperationNode->lpRightOperationNode); break;}
			case COMPARATOR_GREATER_EQUAL:	{iValue = Evaluate(lpOperationNode->lpLeftOperationNode) >= Evaluate(lpOperationNode->lpRightOperationNode); break;}
			case COMPARATOR_GREATER:		{iValue = Evaluate(lpOperationNode->lpLeftOperationNode) > Evaluate(lpOperationNode->lpRightOperationNode); break;}
			case COMPARATOR_LOWER_EQUAL:	{iValue = Evaluate(lpOperationNode->lpLeftOperationNode) <= Evaluate(lpOperationNode->lpRightOperationNode); break;}
			case COMPARATOR_LOWER:			{iValue = Evaluate(lpOperationNode->lpLeftOperationNode) < Evaluate(lpOperationNode->lpRightOperationNode); break;}

			case LOGIC_VALUE:	{iValue = lpOperationNode->bValue; break;}
			case LOGIC_AND:		{iValue = Evaluate(lpOperationNode->lpLeftOperationNode) && Evaluate(lpOperationNode->lpRightOperationNode); break;}
			case LOGIC_OR:		{iValue = Evaluate(lpOperationNode->lpLeftOperationNode) || Evaluate(lpOperationNode->lpRightOperationNode); break;}
			case LOGIC_NOT:		{iValue = !Evaluate(lpOperationNode->lpLeftOperationNode); break;}
		}
	}
	return iValue;
}

/* Build the AST. */
struct OperationNode *BuildOperationdNode(struct OperationNode* lpLeft, struct OperationNode*lpRight, int iType, int iValue) {
	struct OperationNode* lpResult = NULL;
	lpResult = calloc(1, sizeof(struct OperationNode)*sizeof(char));
	if (lpResult!=NULL) {
		lpResult->iType = iType;
		switch (iType) {
			case COMPARATOR_EQUAL:
			case COMPARATOR_DIFFERENT:
			case COMPARATOR_GREATER:
			case COMPARATOR_LOWER:
			case COMPARATOR_GREATER_EQUAL:
			case COMPARATOR_LOWER_EQUAL:
			case ARITHMETIC_MINUS: /* In this case the second value MUST be NULL. */
			case ARITHMETIC_PLUS:
			case ARITHMETIC_MULTIPLY:
			case ARITHMETIC_DIVIDE:
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
			case ARITHMETIC_VALUE:
			case LOGIC_VALUE: {
				if (lpLeft!=NULL) {
					lpResult->lpLeftOperationNode = lpLeft;
				} else {
					lpResult->iValue = iValue;
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
				if (iType==WHILE_OP) {
					lpResult->iFirstLabel = iLabelCounter; iLabelCounter+=1;
					lpResult->iThirdLabel = iLabelCounter; iLabelCounter+=1;
				}
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
				printf( "%d\n", Evaluate(lpCmd->lpLeftOperationNode));
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
					vID->iType = TYPE_INTEGER;
					vID->iValue = Evaluate(lpCmd->lpLeftOperationNode);
					SetSymbolID(stTable, lpszIdentifier, vID);
				} else {
					/* Fetch value. */
					vID->iValue = Evaluate(lpCmd->lpLeftOperationNode);
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

void Translate(struct OperationNode*lpCmd) {
		if (lpCmd!=NULL) {
			switch (lpCmd->iType) {
				case CONJUNCTION_OP: { Translate(lpCmd->lpLeftOperationNode); Translate(lpCmd->lpRightOperationNode); break; }
				case PRINT_OP: {
					Translate(lpCmd->lpLeftOperationNode);
					printf("\tprint\n");
					break;
					}
				case WHILE_OP: {printf("L%d:", lpCmd->iFirstLabel);
								Translate(lpCmd->lpLeftOperationNode);
								printf("\tL%d jump_if_false\n", lpCmd->iThirdLabel);
								Translate(lpCmd->lpRightOperationNode);
								printf("\tL%d jmp\nL%d:", lpCmd->iFirstLabel, lpCmd->iThirdLabel);
								break;}
				case ASSIGN_OP: {Translate(lpCmd->lpLeftOperationNode);
								printf( "\t%s =\n", lpCmd->lpszIdentifier);
								break;}
			case IDENTIFIER:			{printf("\t%s\n", lpCmd->lpszIdentifier); break; }
			case ARITHMETIC_VALUE:		{ printf("\t%d\n", lpCmd->iValue); break;}
			case ARITHMETIC_PLUS:		{ Translate(lpCmd->lpLeftOperationNode); Translate(lpCmd->lpRightOperationNode); printf("\t+\n"); break;}
			case ARITHMETIC_MINUS:		{ Translate(lpCmd->lpLeftOperationNode); Translate(lpCmd->lpRightOperationNode);printf("\t-\n"); break;}
			case ARITHMETIC_MULTIPLY:	{ Translate(lpCmd->lpLeftOperationNode); Translate(lpCmd->lpRightOperationNode);printf("\t*\n"); break;}
			case ARITHMETIC_DIVIDE:		{ Translate(lpCmd->lpLeftOperationNode); Translate(lpCmd->lpRightOperationNode);printf("\t/\n"); break;}
				
			case COMPARATOR_EQUAL:			{ Translate(lpCmd->lpLeftOperationNode); Translate(lpCmd->lpRightOperationNode);printf("\t==\n"); break;}
			case COMPARATOR_DIFFERENT:		{ Translate(lpCmd->lpLeftOperationNode); Translate(lpCmd->lpRightOperationNode);printf("\t!=\n"); break;}
			case COMPARATOR_GREATER_EQUAL:	{ Translate(lpCmd->lpLeftOperationNode); Translate(lpCmd->lpRightOperationNode);printf("\t>=\n"); break;}
			case COMPARATOR_GREATER:		{ Translate(lpCmd->lpLeftOperationNode); Translate(lpCmd->lpRightOperationNode);printf("\t>\n"); break;}
			case COMPARATOR_LOWER_EQUAL:	{ Translate(lpCmd->lpLeftOperationNode); Translate(lpCmd->lpRightOperationNode);printf("\t<=\n"); break;}
			case COMPARATOR_LOWER:			{ Translate(lpCmd->lpLeftOperationNode); Translate(lpCmd->lpRightOperationNode);printf("\t<\n"); break;}

			case LOGIC_VALUE:	{ printf("\t%d\n", lpCmd->iValue); break;break;}
			case LOGIC_AND:		{ Translate(lpCmd->lpLeftOperationNode); Translate(lpCmd->lpRightOperationNode); printf("\t&&\n");break;}
			case LOGIC_OR:		{ Translate(lpCmd->lpLeftOperationNode); Translate(lpCmd->lpRightOperationNode);printf("\t||\n");break;}
			case LOGIC_NOT:		{ Translate(lpCmd->lpLeftOperationNode); printf("\t!\n");break;}
			}
		}
}
