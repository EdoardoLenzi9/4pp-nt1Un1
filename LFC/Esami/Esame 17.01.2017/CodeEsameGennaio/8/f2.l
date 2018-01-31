%option noyywrap

%{
 #include "y.tab.h"
 #include <stdio.h>
%}

%%

"a"   { return a; }
"b"   { return b; }
[0-9]+  { yylval = atoi(yytext); return num; }
[-+\n]  return *yytext;
[ \t]  ;
.   yyerror("Invalid character");

%%