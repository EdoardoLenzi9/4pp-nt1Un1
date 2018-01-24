%{
    #include <stdlib.h>

    int iLine = 0;
    int iColumn = 0;
%}

%s FirstDate 
%x SecondDate Motivation Amount Info

%%

"#".+                               {iColumn+=yyleng;}

"$"                                 {iColumn+=1;
                                        fprintf(yyout, "INSERT INTO Movement(StartDate, EndingDate, Description, Amount, Information) VALUES (");
                                        BEGIN FirstDate;
                                    }
([0-9]{2}"/"?){3}                   {iColumn+=yyleng; fprintf(yyout, "to_date('%s', 'DD/MM/YY'), ", yytext); BEGIN SecondDate;}
<SecondDate>([0-9]{2}"/"?){3}       {iColumn+=yyleng;fprintf(yyout, "to_date('%s', 'DD/MM/YY'), ", yytext); BEGIN Motivation;}

<Motivation>[^-0-9]+                {iColumn+=yyleng;
                                        fprintf(yyout, "'%s', ", yytext); BEGIN Amount;
                                    }

<Amount>"-"?[0-9\.]+","[0-9]{2}[ \t]+"EUR"        {
                                                    int i=0, j=0;
                                                    for (;i<yyleng; i+=1, j+=1) {
                                                        if (yytext[i]=='.') {
                                                            i+=1;
                                                        }
                                                        if (i!=j) {
                                                            yytext[j]=yytext[i];
                                                        }
                                                    }
                                                    yytext[j]='\0';
                                                    for (int i=0; i<yyleng; i+=1) {
                                                        if (yytext[i]==','){yytext[i]='.';}
                                                        if (yytext[i]==' '){
                                                            yytext[i]='\0'; break;
                                                        }
                                                    }
                                                    fprintf(yyout, "%s, ", yytext);
                                                    BEGIN Info;
                                                }
<Info>[^$]*                         {
                                        for (int i=0; i<yyleng; i+=1) {
                                            if (yytext[i]=='\n'||yytext[i]=='\r') {
                                                yytext[i]=' ';
                                            }
                                        }
                                        fprintf(yyout, "'%s');\n", yytext);
                                        BEGIN INITIAL;
                                    }

[ \t]+                              {iColumn+=yyleng;}
[\r\n|\r|\n]                        {iColumn=0; iLine+=1;}
.                                   {printf("ERROR in line: %d, column: %d.", iLine, iColumn); yyterminate();}
%%
int yywrap(){return 1;}
int main(int iArgC, char**lpszArgV) {
    FILE*fInput = fopen(lpszArgV[1], "r");
    FILE*fOutput = fopen(lpszArgV[2], "w");
    if (fInput!=NULL && fOutput!=NULL) {
        yyin = fInput;
        yyout = fOutput;

        fprintf(yyout, "SET search_path TO EstrattoConto;\nDROP TABLE IF EXISTS Movement;\nCREATE TABLE Movement(\n\tStartDate DATE,\n\tEndingDate DATE,\n\tAmount REAL,\n\tDescription TEXT,\n\tInformation TEXT\n);\n");
        yylex();
        fprintf(yyout, "SELECT * FROM   Movement;\n");
    }
}