%{
    /* Copied verbatim.*/
    #include "y.tab.h"
    char * DuplicateString(char*lpszString, int iSize);
    enum {false, true};

%}
%option stack
%s Variable Rule
%x VariableContent Comment RuleContent PrevalueSpaceStripper

VariableName   [A-Z]+
RuleName   [a-z]+
%%
<INITIAL,Variable>
{VariableName}              {yylval.lpszVariableName = DuplicateString(yytext, yyleng);
                             return VARIABLE;}

"="                         {BEGIN PrevalueSpaceStripper; return EQUAL;}

<PrevalueSpaceStripper>[ \t]*     {BEGIN VariableContent;}
<VariableContent>[^\n#]+   {yylval.lpszSequence = DuplicateString(yytext, yyleng);
                             BEGIN Variable; return SEQUENCE;}


<INITIAL,Rule>
{RuleName}                 {yylval.lpszRuleName = DuplicateString(yytext, yyleng);
                            return RULE;}

":"                         {BEGIN RuleContent; return COLON;}
<RuleContent>"$("[A-Z]+")"  {yylval.lpszReference = DuplicateString(yytext, yyleng);
                             return REFERENCE;}
<RuleContent>[ \t]+         {}                            
<RuleContent>[^ \t\n#$]+     {yylval.lpszSequence = DuplicateString(yytext, yyleng);
                             return SEQUENCE;}
<RuleContent>"\n"           {BEGIN Rule; REJECT;}

"#"                         {BEGIN Comment;}
<Comment>[^\n]*             {/*Strip out comments.*/ BEGIN INITIAL;}

[ \t\r\n]                   {/*nop*/}

.                           {return yytext[0];}
%%
/* code. */
char * DuplicateString(char*lpszString, int iSize) {
    char * lpszResult = NULL;
    lpszResult = calloc(1, sizeof(char)*(iSize+1));
    if (lpszResult!=NULL) {
        int i=0;
        for (; i<iSize; i+=1) { lpszResult[i] = lpszString[i]; }
        lpszResult[i] = '\0';
    }
    return lpszResult;
}