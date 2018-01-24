%{
	#include <stdio.h>
	FILE*yyin;
%}

%union {
	char *lpszCommand;
}

%token IF_TOKEN ELSE_TOKEN
%token TRUE_TOKEN FALSE_TOKEN
%token COMMAND

%type <lpszCommand> COMMAND S C

/*
	Two possibilities: shifting or reducing.
	The difference lies in what happens when you have many nested "if"s
	
	Two possibilities:
	
	if (true) if (false) command1 else command2			The else block belongs to the last if.
	\_______/                     							Achieved through shifting.
	          \_______________________________/

	When running this example yacc will announce: "conflicts: 1 shift/reduce" and will apply shift over reduce.
	Shifting is the most reasonable choise because it will bind the last else to the closest "if".
	Reducing would have cut out a piece of the grammar: have a look at "DanglingElse_automaton_after.png".
	
	if (true) if (false) command1 else command2			The else block belongs to the first if.
	\_______/                     \___________/				Can be achieved only through rewriting.
	          \_________________/

*/

%%
S: IF_TOKEN '(' B ')' S							{ printf("Unmatched if () %s\n", $5); }
 | IF_TOKEN '(' B ')' S ELSE_TOKEN S			{ printf("Matched if () %s", $5); printf(" else %s\n", $7);  }
 | C											{ $$ = $1; } ;
 
B: TRUE_TOKEN									{}
 | FALSE_TOKEN  								{};
 
C: COMMAND										{ $$ = $1; };

%%

int main() {
	do {
		yyparse();
	} while(!feof(yyin));
	return 0;
}