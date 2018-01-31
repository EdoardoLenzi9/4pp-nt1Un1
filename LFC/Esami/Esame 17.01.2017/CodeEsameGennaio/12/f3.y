%{
 #include <stdio.h>
 #include <stdlib.h>
 
 int yylex();
 int yyparse();
 void yyerror(char *s);

%}
%token a b c d e
%%
 S:  aAd
     |baAe 
     |baBD 
     |cAd 
     |cBc
 ;
 A:  ce
 ;
 B:  cC
 ;
 C:  eD
 ;
 D:
 ;
%%

int main() {
 yyparse();
 return 0;
}

void yyerror(char *s) {
 printf("Error when reading: %s", s);
}