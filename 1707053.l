/*c declarations
bison -d temp.y
flex 1707053.l
gcc lex.yy.c temp.tab.c -o x
*/
%option yylineno
%{
#include <stdio.h>
#include "temp.tab.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
float textToNum(char* s);
void yyerror(char *s);
int hash_table(char *s);
%}


%%
"#".*  { strcpy(yylval.str, yytext); return SLCOM; }
"Num" {return NUMERIC;}
"Whole" {return WHOLE;}
"Text" {return TEXT;}

"\""(.)*"\"" {
  strcpy(yylval.str,yytext);
  return STRING;
}
[+]?[0-9]+[.][0-9]+ {
  /* is float */
  yylval.f=atof(yytext);
  return NUMf;
}
[-][0-9]+[.][0-9]+ {
  /* is float */
  yylval.f=atof(yytext);
  return NUMf;

}
[0-9]+ {
     yylval.i=atoi(yytext);
     return NUMi;
}
"Match"  { return MATCH; }
"Check"    { return CHECK;  }
"NoMatch"  { return NOMATCH; }
"Show"    { return SHOW; }



"(" {return LPT;}
")" {return RPT;}

"{" {return LCB;}
"}" {return RCB;}
"[" {return LTB;}
"]" {return RTB;}
"," {return CM;}
";" {return SM;}

"+" {return ADD; }
"-" {return SUB; }
"MUL"     {return MULFN;}
"SUM"     {return SUMFN;}
"PLD" {return PALINDROMEFN;}
"*"         {return MUL ;}
"/" {return DIV;}
"Repeat" {return REPEAT;}
"Until" {return UNTIL;}
"iter" {return ITER;}
"do" {return DO;}
":" {return COL;}
">" {return GT;}
"<" {return LT;}
"=" {return EQL;}

[:%^]     {	return *yytext;	}
[a-z]+ {
   yylval.i= hash_table(yytext);
   return VAR;
}



"Whether" {return IF;}
"OrElse" {return ELSEIF;}
"Or" {return ELSE;}
"Null START" {return VOIDMAIN;}

[ \t\n]* {;}

. {
    yyerror("unknown character \n");
    printf("error is :%s \n",yytext);
 }
%%

/* user subroutines */

int hash_table(char *s){
  	int len = strlen(s);
    int hash_val = 0;
    int mod = 907;
    int positional_val = 1;
    for(int j = len-1;j>=0;j--){
      int x = s[j]-'a';
      hash_val += x*positional_val;
      hash_val = hash_val%mod;
      positional_val++;
    }
    hash_val = hash_val%mod;
    /*printf("%d is hasval for %s\n",hash_val,s);*/
    return hash_val;

}
