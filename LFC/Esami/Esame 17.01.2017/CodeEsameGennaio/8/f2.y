%{
 #include <stdio.h>
 #include <stdlib.h>
 
 int yylex();
 int yyparse();
 void yyerror(char *s);

%}

%token a b num

%%
S: S E '\n' { printf("%d\n", $2); }
 | ;
E: num { $$ = $1; }
 | E a E { $$ = $1 * $3; }
 | E b E { $$ = $1 + $3; } ;
%%

int main() {
 yyparse();
 return 0;
}

void yyerror(char *s) {
 printf("Error when reading: %s", s);
}