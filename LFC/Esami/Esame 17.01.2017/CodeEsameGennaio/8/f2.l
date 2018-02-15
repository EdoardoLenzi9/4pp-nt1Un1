%option noyywrap

%{
 #include "y.tab.h"
 #include <stdio.h>
%}

%%

"a"   {  yylval = 1; return a; }
"b"   {  yylval = 2; return b; }

%%