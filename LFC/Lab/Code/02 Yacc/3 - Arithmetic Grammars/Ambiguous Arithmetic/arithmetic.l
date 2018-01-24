%{
	/*Copied verbatim.*/
    #include <stdlib.h>
    #include <strings.h>
	#include "y.tab.h"
	typedef int bool;
	enum { false, true };

%}
Decimal			[0-9]+
Hexadecimal		"0x"[0-9A-Fa-f]+
Binary			"b"(0|1)+
Real			([0-9]+)?"."([0-9]+)
%%

"+"	|
"-"	|
"*"	|
"/"	|
"("	|
")"	|
"^"					{ return yytext[0];}

{Decimal}			{
						int iIntegerValue = 0;
						for (int i=0; i<yyleng; i+=1) {
							iIntegerValue*=10; iIntegerValue+=yytext[i]-'0';
						}
						yylval.iInteger = iIntegerValue;
						return INTEGER;
					}
{Hexadecimal}		{
						int iHexadecimalValue = 0;
						for (int i=0; i<yyleng; i+=1) {
							if ((yytext[i]>='A' && yytext[i]<='F') || (yytext[i]>='a' && yytext[i]<='f')) {
								iHexadecimalValue*=10; iHexadecimalValue+= 10 + yytext[i]-'A';
							} else {
								iHexadecimalValue*=10; iHexadecimalValue+=yytext[i]-'0';
							}
						}
						yylval.iInteger = iHexadecimalValue;
						return INTEGER;
					}
{Binary}			{
						int iBinaryValue = 0;
						for (int i=0; i<yyleng; i+=1) {
							iBinaryValue*=2; iBinaryValue+=yytext[i]-'0';
						}
						yylval.iInteger = iBinaryValue;
						return INTEGER;
					}
[ \t\r\n]			{}		
%%
int yywrap() {
	return 1;
}