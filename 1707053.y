/*c declaration*/
%{
# include<stdio.h>
# include <stdlib.h>
# include <stdarg.h>
# include <string.h>
# include <math.h>
#include <stdbool.h>
int yylex(void);
void yyerror(char *s);
int hash_table(char *s);
int symi[1000],stored[1000]={0},declared[1000]={0},type[1000];
float symf[1000];
char symstr[1000][100];

float switchval;
bool is_match = false;
bool execute_else = true;
bool printFromStmts = false; /* invoked when print statements are inside if else or switch block */
bool fromCase = false;
bool hasPrinted = false, canPrint = false;/* triggered false when condition is met & already another block is executed */
int type_of_var;
int ifstmtcnt = 0;
float caseARG = 0;

// loop variables
bool for_loop = false;
int start;
int end;
int inc;

FILE *fptr; // use appropriate location if you are using MacOS or Linux
%}
/*yacc declarations */

%error-verbose
%union {
	int i;
	float f;
  char str[100];
}
%token <i> SLCOM NUMERIC WHOLE TEXT MATCH CHECK NOMATCH SHOW LPT RPT LCB RCB LTB RTB CM SM ADD SUB MULFN SUMFN MUL DIV REPEAT COL GT LT EQL IF ELSEIF ELSE VOIDMAIN UNTIL DO ITER PALINDROMEFN
%token <i> VAR
%token <str> STRING
%token <i> NUMi
%token <f> NUMf

%right COL
%left LT GT EQU
%left ADD SUB
%left MUL DIV

%type <f>  exp factor term word function arg
/*grammar rules*/
%%
program: StartProgram { printf("\nSuccessfully COMPILED...... \n"); };

StartProgram: VOIDMAIN LPT RPT  LCB stmt RCB {printf("START function invoked\n");};


stmt: epsilon
          | exp SM stmt
          | SM stmt
          | declarations SM stmt
          | commentstmt stmt
					| showstmt SM stmt   /*print statement*/
					| assignment SM stmt
				  | ifstmt stmt         /*ifelse statement*/
					| switchstmt stmt
					| repeatstmt stmt
					| untildostmt  stmt
          ;


ifstmt : IFPredicate LPT arg RPT LCB stmt RCB  elifstmt {
	canPrint = false;
	hasPrinted = false;
	printFromStmts = false;
	ifstmtcnt = 0;
};
elifstmt: epsilon {
		printf("####ENDING OF IF ELSE STATEMENTS####\n___________________________________________\n");
	}
	| ELSEIF LPT arg RPT LCB stmt RCB  elifstmt {
	}
	| ELSEPredicate LCB stmt RCB {
		printf("####ENDING OF IF ELSE STATEMENTS####\n___________________________________________\n");
	}
	;

switchstmt: CHECKPredicate LPT arg RPT LCB allCases RCB {
	printf("####ENDING OF CASE STATEMENTS####\n___________________________________________\n");
	canPrint = false;
	hasPrinted = false;
	printFromStmts = false;
	caseARG = -1;
	fromCase = false;

}
;
allCases: epsilon  {}
	      | MATCH LPT arg RPT LCB stmt RCB allCases {}
	      | NOMATCHPredicate LCB stmt RCB {}
	      ;

repeatstmt : REPEAT LPT forArgs RPT LCB stmt RCB {
	for_loop = false;
	printf("####ENDING of Repeat loop####\n___________________________________________\n");
};

untildostmt : UNTIL LPT whileArgs RPT CM ITER LTB iteratorArg RTB DO COL LCB stmt RCB  {
	for_loop = false;
	printf("####ENDING of Until do loop####\n___________________________________________\n");
}

declarations: type declaration {printf("___________________________________________\nVariables properly declared.\n\n")};

type: NUMERIC {printf("Type declared is : Numeric\n___________________________________________\n");type_of_var=1;}| WHOLE {printf("Type declared is : Whole\n___________________________________________\n");type_of_var=2;} | TEXT {printf("Type declared is : Text\n___________________________________________\n");type_of_var=3;} ;

declaration: VAR    {declared[$1] = 1;type[$1] = type_of_var;printf("Variable %d has been declared.\n",$1);}
           | declaration CM VAR  {declared[$3] = 1;type[$3] = type_of_var;printf("Variable %d has been declared.\n",$3);}
           | assignment
           | declaration CM assignment /*{printf("Variable %c has been declared\n",($3+'a'));}*/
           ;

	assignment: VAR COL NUMi {
			if(declared[$1]){
				if(type[$1]==2){
						stored[$1] = 1;
						symi[$1] = $3;
						printf("Value of %d has been assigned to variable %d.\n",symi[$1],$1);
				}
				else{
					yyerror("Type of variable and assignment type donot match.");
				}
			}
			else{
				if(type_of_var==2){
		        declared[$1] = 1;
		        stored[$1] = 1;
		        type[$1] = type_of_var;
		        symi[$1] = $3;
		        printf("Value of %d has been assigned to variable %d.\n",symi[$1],$1);
		    }
		    else{
		      yyerror("Type of variable and assignment type donot match.");
		    }
			}
	}
          | VAR COL NUMf  {
						if(declared[$1]){
							if(type[$1]==1){
									stored[$1] = 1;
									symf[$1] = $3;
									printf("Value of %f has been assigned to variable %d.\n",symf[$1],$1);
							}
							else{
								yyerror("Type of variable and assignment type donot match.");
							}
						}
						else{
              if(type_of_var==1){
                  declared[$1] = 1;
                  stored[$1] = 1;
                  type[$1] = type_of_var;
                  symf[$1] = $3;
                  printf("Value of %f has been assigned to variable %d.\n",symf[$1],$1);
              }
              else{
                yyerror("Type of variable and assignment type donot match.");
              }
						}
          }
          | VAR COL STRING  {
						if(declared[$1]){
							if(type[$1]==3){
									stored[$1] = 1;
									 strcpy(symstr[$1], $3);
	 							 	 printf("Value of %s has been assigned to variable %d.\n",symstr[$1],$1);
							}
							else{
								yyerror("Type of variable and assignment type donot match.");
							}
						}
						else{
	              if(type_of_var==3){
	                  declared[$1] = 1;
	                  stored[$1] = 1;
	                  type[$1] = type_of_var;
	                  strcpy(symstr[$1], $3);
	                  printf("Value of %s has been assigned to variable %d.\n",symstr[$1],$1);
	              }
	              else{
	                yyerror("Type of variable and assignment type donot match.");
	              }
            }
			  	}
          ;

					showstmt: SHOW LPT displayArgs RPT;

					displayArgs: STRING {
																if(for_loop){
																	if(start>end){
																		int temp = start;
																		start = end;
																		end = temp;
																	}
																	if(inc<0) inc = -1*inc;

																	printf("%d %d %d is in in new loop",start,end,inc);

																	for(int i = start;i<end;i+=inc){
																		fprintf(fptr,"%s\n",$1);
																	}
																}
					                      else if(printFromStmts){
																	if(canPrint && !hasPrinted){
																			fprintf(fptr,"%s\n",$1);
																			hasPrinted = true;
																			canPrint = false;
																	}
					                      }
					                      else{
					                        fprintf(fptr,"%s\n",$1);
					                      }
					                  }
										|  VAR {
																	if(for_loop){
																		if(declared[$1]){
																			if(stored[$1]){
																					if(type[$1]==1){
																						for(int i = start;i<end;i+=inc){
																							fprintf(fptr,"%f\n",symf[$1]);
																						}
																					}
																					else if(type[$1]==2){
																						for(int i = start;i<end;i+=inc){
																							fprintf(fptr,"%f\n",symi[$1]);
																						}
																					}
																					else {
																						for(int i = start;i<end;i+=inc){
																							fprintf(fptr,"%f\n",symstr[$1]);
																						}
																					}
																			}
																			else{
																				fprintf(fptr,"Variable %d has not been assigned any value yet\n",$1);
																			}
																		}
																		else{
																			fprintf(fptr,"Variable %d has not been declared\n",$1);
																		}
																	}
																	else if(printFromStmts){
										                    if(canPrint && !hasPrinted){
																					hasPrinted = true;
																					canPrint = false;
																					if(declared[$1]){
																						if(stored[$1]){
																								if(type[$1]==1){
																									fprintf(fptr,"%f\n",symf[$1]);
																								}
																								else if(type[$1]==2){
																									fprintf(fptr,"%d\n",symi[$1]);
																								}
																								else {
																									fprintf(fptr,"%s\n",symstr[$1]);
																								}
																						}
																						else{
																							fprintf(fptr,"Variable %d has not been assigned any value yet\n",$1);
																						}
																					}
																					else{
																						fprintf(fptr,"Variable %d has not been declared\n",$1);
																					}
										                        canPrint = false;
										                    }
										                  }
										                  else{
																				if(declared[$1]){
																					if(stored[$1]){
																							if(type[$1]==1){
																								fprintf(fptr,"%f\n",symf[$1]);
																							}
																							else if(type[$1]==2){
																								fprintf(fptr,"%d\n",symi[$1]);
																							}
																							else {
																								fprintf(fptr,"%s\n",symstr[$1]);
																							}
																					}
																					else{
																						fprintf(fptr,"Variable %d has not been assigned any value yet\n",$1);
																					}
																				}
																				else{
																					fprintf(fptr,"Variable %d has not been declared\n",$1);
																				}
										                  }
										                }
										| exp {
											if(for_loop){
												for(int i = start;i<end;i+=inc){
													fprintf(fptr,"%f\n",$1);
												}
											}
											else if(printFromStmts){
												if(canPrint && !hasPrinted){
														fprintf(fptr,"%f\n",$1);
														hasPrinted = true;
														canPrint = false;
												}
											}
											else{
												fprintf(fptr,"%f\n",$1);
											}
										}
					          ;

arg: exp {
	$$=$1;

	if(!fromCase){
		if($$!=0.0){
			if(!hasPrinted) {
				canPrint = true;
			}
		}
		else{
			canPrint = false;
		}
	}

	else{
		if(caseARG<=0){ ///this is the case argument
				caseARG = $$;
		}
		else{
			if(caseARG==$$){
				canPrint=true;
			}
		}
	}

}
;

iteratorArg : exp {
	inc = $1;
	printf("start: %d end: %d inc: %d\n",start,end,inc);
}
whileArgs: exp {
	printf("\n___________________________________________\n####Beginning of Until do loop####\n");
	for_loop = true;
	start = $1;
	end = 0;

}

forArgs: exp COL exp {
	printf("\n___________________________________________\n####Beginning of Repeat loop####\n");
	for_loop = true;
	start = $1;
	end = $3;
	if(start>end){
		int temp = start;
		start=end;
		end=temp;
	}
	inc = 1;
	printf("start: %d end: %d inc: %d\n",start,end,inc);
}
| exp COL exp COL exp {
	printf("\n___________________________________________\n####Beginning of Repeat loop####\n");
	for_loop = true;
	start = $1;
	end = $3;
	if(start>end){
		int temp = start;
		start=end;
		end=temp;
	}
	inc = $5;
	printf("start: %d end: %d inc: %d\n",start,end,inc);
};

	exp: function {$$=$1;}
	   |exp GT word {
				if($1>$3){
					$$=1.0;
				}
				else{
					$$=0.0;
				}
	   }
		| exp LT word {
			if($1<$3){
				$$=1.0;
			}
			else{
				$$=0.0;
			}
		}
	|	exp EQL word {
			if($1==$3){
				$$=1.0;
			}
			else{
				$$=0.0;
			}
		}
	| word {
		$$=$1;
	}
	| LPT exp RPT {
		$$=$2;
	}
	| SUB exp {
		$$ = -1.0 * $2;
	}
	;

	word: word ADD term {$$=$1+$3;}
	| word SUB term {$$=$1-$3;}
	|term {$$=$1;}
	;

	term : term MUL factor {$$ = $1*$3;} | term DIV factor {$$ = $1/$3;} | factor {$$=$1;} | function {$$=$1;};

	function: SUMFN LPT factor CM factor RPT {$$=$3+$5; fprintf(fptr,"Function invoked: SUM(%f,%f)= %f\n",$3,$5,$$);}
								| MULFN LPT factor CM factor RPT {$$=$3*$5; fprintf(fptr,"Function invoked: MUL(%f,%f)= %f\n",$3,$5,$$);}
								| PALINDROMEFN LPT STRING RPT {
									int i = 0;
									char x[100];
									char s[100];

									strcpy(s,$3);
									int len = strlen(s);
								//	printf("%s is %d\n",s,len);


									for(int j = len-1 ; j>=0 ; j--){
										x[i] = s[j];
										i++;
									}
									x[i] = '\0';
									bool isPalin = true;

									for(int i = 0 ;i <len;i++){
										if(s[i]!=x[i]){
											isPalin = false;
											//printf("FALSE FOR %c & %c\n",s[i],x[i]);
											break;
										}
									}
									if(isPalin) {
										fprintf(fptr,"Function invoked: PLD: %s is a palindromic string\n",$3);
										$$ = 1.0;
									}
									else {
										fprintf(fptr,"Function invoked: PLD: %s is not a palindromic string\n",$3);
										$$ = 0.0;
									}
								}
								| PALINDROMEFN LPT VAR RPT {
									if(type[$3]!=3){
										yyerror("ERROR: Not a string variable!!\n");
									}
									else{
										int i = 0;
										char x[100];
										char s[100];

										strcpy(s,symstr[$3]);
										int len = strlen(s);
									//	printf("%s is %d\n",s,len);


										for(int j = len-1 ; j>=0 ; j--){
											x[i] = s[j];
											i++;
										}
										x[i] = '\0';
										bool isPalin = true;

										for(int i = 0 ;i <len;i++){
											if(s[i]!=x[i]){
												isPalin = false;
												//printf("FALSE FOR %c & %c\n",s[i],x[i]);
												break;
											}
										}
										if(isPalin) fprintf(fptr,"%s is a palindromic string\n",s);
										else fprintf(fptr,"%s is not a palindromic string\n",s);
									}

								}
								;
	factor : NUMi {$$=$1*1.0;}
				 | NUMf {$$=$1;}
				 | VAR {
					 if(declared[$1]){
						 if(stored[$1]){
								 if(type[$1]==1){
									 $$=symf[$1];
								 }
								 else if(type[$1]==2){
									 $$=symi[$1]*1.0;
								 }
								 else{
									 yyerror("Strings cannot be an expression\n");
								 }
						 }
						 else{
							 printf("Variable %d has not been assigned any value yet\n",$1);
						 }
					 }
					 else{
						 printf("Variable %d has not been declared\n",$1);
					 }
				 }
				 ;
ELSEPredicate: ELSE {
				 if(!hasPrinted){
					 canPrint = true;
				 }
				 };
IFPredicate: IF {
				printf("\n___________________________________________\n####Beginning of IF ELSE statement####\n");
				printFromStmts = true;
				canPrint = false;
				hasPrinted = false;
				ifstmtcnt = 0;
};

CHECKPredicate: CHECK {
				printf("\n___________________________________________\n####Beginning of CASE statement####\n");
				fromCase = true;
				printFromStmts = true;
				canPrint = false;
				hasPrinted = false;
				caseARG = -1.0;
};

NOMATCHPredicate: NOMATCH{
	if(!hasPrinted){
 	 canPrint = true;
  }
};

epsilon : ; /* epsilon means null */
commentstmt: SLCOM {printf("Single line comment encountered.\n");}

          %%


          int yywrap(){
          return 1;
          }
          void yyerror(char *s)
          {
            fprintf(stderr,"%s\n",s);
          }
          int main()
          {
	          freopen("Input.txt","r",stdin);

   					fptr = fopen("Output.txt","w");
	          yyparse();
          }
