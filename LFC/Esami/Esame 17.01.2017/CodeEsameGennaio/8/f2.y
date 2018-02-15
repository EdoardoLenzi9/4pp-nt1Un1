%{
 #include <stdio.h>
 #include <stdlib.h>
 
 int yylex();
 int yyparse();
 void yyerror(char *s);

%}

%token a b num

%%
S: EE '\n' { printf("%d\n", $1); /*\n per far andare avanti all'infinito la calcolatrice*/ } 
E: a | b { printf("--%d\n", $1);
%%

int main() {
 yyparse();
 return 0;
}

void yyerror(char *s) {
 printf("Error when reading: %s", s);
}