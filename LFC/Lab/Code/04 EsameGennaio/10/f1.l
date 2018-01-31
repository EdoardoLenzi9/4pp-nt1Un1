%{
 
%}

digit [0-9]
letters [a-z,A-Z]
other [\\\*\?"<"]
id ({other}|{digit}|{letters})+

%%
({other})?({other})?({id})({digit})+({id})?   {printf("SI ");}
{id}   {printf("FORSE ");}
.   {printf("NO ");}

%%
int yywrap() {
 return 1;
}

int main() {
 yylex();
}