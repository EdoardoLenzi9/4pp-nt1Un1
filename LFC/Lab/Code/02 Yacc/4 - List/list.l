%{
	#include "y.tab.h"
%}

%option noyywrap
%%
"item"	{return ITEM;}
[ \t\n\r]	{/*Nope*/}
. {printf("Error: syntax error.");}
%%