%{
	/* Bottom up AST building, no execution up to now.*/
	#include <stdio.h>
	#include <string.h>
	#include <stdlib.h>
	#include "symbol_table.h"

	int yylex();
	int yyparse();
	FILE *yyin;
	void yyerror(char *s);
   
	struct CommandNode*EmitCommandCouple(struct CommandNode* lpLeft, struct CommandNode* lpRight);
	struct CommandNode*EmitCommand(char *lpszReference, char*lpszSequence);
	struct RuleNode*EmitRule(char*lpszRuleName, struct CommandNode*lpCommand);
	struct TombStone*EmitTombStone(struct RuleNode*lpRule, char*lpszReferenceValue);
	void PrintRule(struct RuleNode*lpRule);
	void PrintCommand(struct CommandNode*lpCommand);

	int bIsReference = false;
	struct SymbolTable* stRuleTable = NULL;
	struct SymbolTable* stReferenceTable = NULL;
	char*lpszCurrentRule = NULL;

	struct RuleDependency rdDependencies;
%}
%token VARIABLE RULE EQUAL COLON SEQUENCE REFERENCE

%union {
	struct RuleNode*lpRule;
	struct CommandNode*lpCommand;
	char*lpszVariableName;
	char*lpszRuleName;
	char*lpszReference;
	char*lpszSequence;
	char*lpszSequenceOrReference;
};

%type <lpszSequenceOrReference> C
%type <lpszReference> REFERENCE
%type <lpszSequence> SEQUENCE
%type <lpszRuleName> RULE
%type <lpszVariableName> VARIABLE
%type <lpCommand> CL
%type <lpRule> R RL RN
%%

S: DL RL							{
										/* Build graph according to dependencies. */
										for (int i=0; i<rdDependencies.iUsedDependencies; i+=1){
											struct FatherChildCouple*fccIthCouple =
											((struct FatherChildCouple*)
											&rdDependencies.fccDependency[ i * sizeof(struct FatherChildCouple) ]);
											char* lpszFatherRule = fccIthCouple->lpszFatherName;
											char* lpszChildRule = fccIthCouple->lpszChildName;

											struct TombStone*vFather = GetSymbolID(stRuleTable, lpszFatherRule);
											struct TombStone*vChild = GetSymbolID(stRuleTable, lpszChildRule);

											struct RuleNode* lpFatherNode = vFather->lpRule;
											struct RuleNode* lpChildNode = vChild->lpRule;

											if (lpFatherNode->vorChildren==NULL) {
												lpFatherNode->vorChildren = calloc(1, sizeof(struct RuleNode*)*vFather->iChildren*sizeof(char));
											}
											lpFatherNode->vorChildren[ vFather->iCurrentChild ] = lpChildNode;
											vFather->iCurrentChild+=1;


										}
										/* Top sort and rule execution here. */
									}
DL: DL D                            { /* A declaration list only plays the role of introducting declaration. */ }
  |                                 { /* Every declaration is elaborated by the corresponding semantic action. */};
D: VARIABLE EQUAL SEQUENCE          {
										/* Variable = Value */

										/* Check if variable does alredy exists.*/
										struct TombStone*tsTombStone = GetSymbolID(s	tReferenceTable, $1);
										if (tsTombStone!=NULL) {
											/* If it does, error and abort. */
											printf("Error: variable redefinition.\n"); YYABORT;
										} else {
											/* In case variable is new, declare it with its value.*/
											struct TombStone*vReferenceTombStone = EmitTombStone(NULL, $3);
											if (vReferenceTombStone!=NULL) {
												bool bIsSet = SetSymbolID(stReferenceTable, $1, vReferenceTombStone);
											} else {
												/*Allocation error. You should print something and abort.*/
											}
										}
									};

RL: RL R                            { /* Rule list is a fictionary rule, it only introduces the list of non terminals/terminals.*/ }
  |                                 { /* Every rule is elaborated in place by the corresponding semantic action. */ }
R: RN COLON CL                      {
										/* Hyp: There exists a rule, whose name equals value lpszCurrentRule.
											Its data structure pointer is in $1.
										*/
										struct RuleNode*rnRule = $1;
										/* Associate the rule in $1 with the command list in $3. */
										rnRule->lpCommand = $3;
										/* Check whether or not the rule does exists: double check "sanity". */
										struct TombStone*tsTombStone = GetSymbolID(stRuleTable, rnRule->lpszRuleName);
										if (tsTombStone==NULL) {
											printf("Error: undefined rule.\n"); YYABORT;
										}
										/* For debugging/reporting purposes, print the rule you built up to now.*/
										PrintRule(rnRule);
										$$ = rnRule;
									}
RN: RULE                            {
										/* The purpose of this reduction is tricky. we'll see very many terminal handling of the like.*/
										lpszCurrentRule = $1;
										/* Remember the name of the current rule, will be usefull later. */
										struct RuleNode*rnRule = NULL;
										/* I'm going to declare a rule, check its presence.*/
										struct TombStone*tsTombStone = GetSymbolID(stRuleTable, $1);
										if (tsTombStone!=NULL) {
											/* Ops. */
											printf("Error: rule redefinition.\n"); YYABORT;
										} else {
											/* No rule was present, release a rule with nmae lpszCurrentRule and no command tree.*/
											rnRule = EmitRule($1, NULL);
											/* Emit a tombstone to keep track of it. */
											struct TombStone*vRuleTombStone = EmitTombStone(rnRule, NULL);
											if (vRuleTombStone!=NULL) {
												bool bIsSet = SetSymbolID(stRuleTable, rnRule->lpszRuleName, vRuleTombStone);
											} else {
												/* Allocation error. I should say something.*/
											}
										}
										$$ = rnRule;
									}                                    
CL: CL C                            {
										/* A list of commands is translated into a tree of commands. */
										struct CommandNode*lpNode = NULL;
										if (bIsReference==true) {lpNode = EmitCommand($2, NULL);}
										else {lpNode = EmitCommand(NULL, $2);}
										$$ = EmitCommandCouple($1, lpNode);
									}
  | C                               {
	  									/*
										  Dependening on the role of the command,
										  it is annotated into a specific data structure's field or another.
										  What matters is that the command is put into the tree.
										*/
										if (bIsReference==true){$$ = EmitCommand($1, NULL);}
										else {$$ = EmitCommand(NULL, $1);}
									}
C: REFERENCE                        {
										/* A reference is of the shape: $([A-Z]+).*/
										char*lpszReference = $1;
										/* Copy the [A-Z]+ part of the string, for subsequent testing.*/
										int iReferenceLenght = 0;
										for (;lpszReference[iReferenceLenght]!='\0'; iReferenceLenght+=1) {} iReferenceLenght+=1;
										char*lpszRealReference = calloc(1, iReferenceLenght);
										int i=0, j=2;
										for (;j<iReferenceLenght-3+1;j+=1, i+=1) {
											lpszRealReference[i]=lpszReference[j];
										}
										/* Test whether the [A-Z]+ part did refer to a real variable.*/
										struct TombStone*tsTombStone = GetSymbolID(stReferenceTable, lpszRealReference);
										if (tsTombStone==NULL) {
											/* User did something wrong.*/
											printf("Error: variable undefined.\n"); YYABORT;
										} else {
											/* Delete the $([A-Z]+) pattern.*/
											free($1);
											/* Return the value of the variable. */
											lpszReference = tsTombStone->lpszReferenceValue;
										}
										/* Free the [A-Z]+ part.*/
										free(lpszRealReference);
										bIsReference=true;
										$$ = lpszReference;
									}
 | SEQUENCE                         {
	 									/* Here i collect dependencies: when i find that a sequence is the name of an existing rule
											i conclude the lpszCurrentRule is father of Sequence.
										*/
										char*lpszSequence = $1;
										/* This version of the program allows 16 variables only: implement list's dinamic growth to unlock it. */
										if (rdDependencies.iUsedDependencies < rdDependencies.iDependencies) {
											/* In case there was room. I check if sequence refers to a rule.*/
											struct TombStone*vRuleTombStone = GetSymbolID(stRuleTable, lpszSequence);
											if (vRuleTombStone!=NULL) {
												/* I directly access the array of structures and add the couples by hand. */
												struct FatherChildCouple*fccIthCouple =
												((struct FatherChildCouple*)
												&rdDependencies.fccDependency[ rdDependencies.iUsedDependencies * sizeof(struct FatherChildCouple) ]);
												fccIthCouple->lpszFatherName = lpszCurrentRule;
												fccIthCouple->lpszChildName = vRuleTombStone->lpRule->lpszRuleName;
												rdDependencies.iUsedDependencies+=1;

												/* Keep track of the number of children a rule has. */
												struct TombStone*vFatherRuleTombStone = GetSymbolID(stRuleTable, lpszCurrentRule);
												if (vFatherRuleTombStone!=NULL) {
													vFatherRuleTombStone->iChildren+=1;
												}
											}
										}
										bIsReference=false; 
										$$ = lpszSequence;
									}
%%


void yyerror(char *s) {
	printf("%s");
}

int yywrap() {return 1;}

int main(int iArgC, char**lpszArgV) {
	FILE*fInput = NULL;
	if (iArgC>=1) {
		fInput = fopen(lpszArgV[1], "r");
		if (fInput!=NULL) {
			yyin=fInput;
		}
		
		rdDependencies.iDependencies = 16;
		rdDependencies.iUsedDependencies = 0;
		rdDependencies.fccDependency = calloc(1,rdDependencies.iDependencies*sizeof(struct FatherChildCouple)*sizeof(char));

		stRuleTable = CreateSymbolTable(13,1);
		stReferenceTable = CreateSymbolTable(13,1);
		do {
			yyparse();
		} while(!feof(yyin));
		DestroySymbolTable(stReferenceTable, true);
		DestroySymbolTable(stRuleTable, true);
	}
	return 0;
}

struct CommandNode*EmitCommandCouple(struct CommandNode* lpLeft, struct CommandNode* lpRight) {
	struct CommandNode*lpResult = calloc(1, sizeof(struct CommandNode)*sizeof(char));
	if (lpResult!=NULL) {
		lpResult->lpLeftCommand = lpLeft;
		lpResult->lpRightCommand = lpRight;
		lpResult->lpszReference = NULL;
		lpResult->lpszSequence = NULL;
	}
	return lpResult;
}

struct CommandNode*EmitCommand(char *lpszReference, char*lpszSequence){
	struct CommandNode*lpResult = calloc(1, sizeof(struct CommandNode)*sizeof(char));
	if (lpResult!=NULL) {
		lpResult->lpszReference = lpszReference;
		lpResult->lpszSequence = lpszSequence;
	}
	return lpResult;
}

struct RuleNode*EmitRule(char*lpszRuleName, struct CommandNode*lpCommand) {
	struct RuleNode*lpResult = calloc(1, sizeof(struct RuleNode)*sizeof(char));
	if (lpResult!=NULL) {
		lpResult->lpszRuleName = lpszRuleName;
		lpResult->lpCommand = lpCommand;
	}
	return lpResult;
}

struct TombStone* EmitTombStone(struct RuleNode*lpRule, char*lpszReferenceValue) {
	struct TombStone*vResult = calloc(1, sizeof(struct TombStone)*sizeof(char));
	if (vResult!=NULL) {
		vResult->iChildren = 0;
		vResult->iCurrentChild = 0;
		if (lpRule!=NULL) {
			vResult->lpRule = lpRule;
		} else {
			vResult->lpszReferenceValue = lpszReferenceValue;
		}
	}
	return vResult;
}

void PrintRule(struct RuleNode*lpRule) {
	if (lpRule!=NULL) {
		printf("%s: ", lpRule->lpszRuleName);
		PrintCommand(lpRule->lpCommand);
		printf("\n");
	}
}

void PrintCommand(struct CommandNode*lpCommand) {
	if (lpCommand!=NULL) {
		if (lpCommand->lpLeftCommand==NULL && lpCommand->lpRightCommand==NULL) {
			if (lpCommand->lpszReference!=NULL) {
				printf("%s ", lpCommand->lpszReference);
			} else {
				printf("%s ", lpCommand->lpszSequence);
			}
		}
		else {
			PrintCommand(lpCommand->lpLeftCommand);
			PrintCommand(lpCommand->lpRightCommand);
		}
	}
}