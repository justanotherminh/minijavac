%{
    #include "node.cc"
    #include "y.tab.h"
    #include <stdio.h>
    #include <stdlib.h>
    extern "C" int yylex();
    void    yyerror(char *);

%}
  
/* Rule Section */
%% 

"class" {return CLASS;}
"id" {return ID;}
"public" {return PUBLIC;}
"static" {return STATIC;}
"void" {return VOID;}
"main" {return MAIN;}
"(" {return LPAREN;}
")" {return RPAREN;}
"[" {return LBRACKET;}
"]" {return RBRACKET;}
"{" {return LCURLY;}
"}" {return RCURLY;}
"," {return COMMA;}
"=" {return EQ;}
"." {return DOT;}
";" {return SEMICOLON;}
"!" {return EXCL;}
"+" {return PLUS;}
"-" {return MINUS;}
"*" {return STAR;}
"/" {return FWDSLASH;}
"&&" {return AMPAMP;}
"||" {return PIPEPIPE;}
"<" {return SM;}
">" {return GR;}
"<=" {return LEQ;}
">=" {return GEQ;}
"==" {return EQEQ;}
"!=" {return NEQ;}
"length" {return LENGTH;}
"if" {return IF;}
"else" {return ELSE;}
"while" {return WHILE;}
"return" {return RETURN;}
"this" {return THIS;}
"true" {return TRUE;}
"false" {return FALSE;}
"new" {return NEW;}
"String" {return STRING;}
"int" {return INT;}
"boolean" {return BOOLEAN;}
"extends" {return EXTENDS;}
"Integer.parseInt" {return PARSEINT;}
"System.out.print" {return PRINT;}
"System.out.println" {return PRINTLN;}
[a-zA-Z][a-zA-Z0-9\_]* {yylval.string = strdup(yytext);return ID;}
[0-9]+ {yylval.integer = atoi(strdup(yytext));return INTEGER_LITERAL;}
\"(\\.|[^"\\])*\" {yylval.string = strdup(yytext);return STRING_LITERAL;}
"/*"([^*]|\*+[^*/])*\*+\/ {}
"//".* {}
[ \t\n] {}

%%

int yywrap(void) {
    return 1;
}