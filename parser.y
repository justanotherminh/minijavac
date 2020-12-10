%{
    #include "compile.hh"
    #include <cstdio>
    #include <cstring>
    void yyerror(char *);
    extern "C" int yylex();
    extern int yylineno;
    extern char* yytext;
    extern FILE *yyin;

    node* root;
%}
%union{
    node* node;
    int integer;
    char * string;
}
%type <node> Program MainClass VarDecls VarDecl Statements Statement Exp Type InitVal VarsInit PrimeType LeftValue Index ExpList
%type <node> ClassDecls ClassDecl MaybeExtId MethodDecls MethodDecl MaybeFormalList FormalList TypeList MaybeExpList NextExp MethodCall 

%token <node> CLASS STAR FWDSLASH AMPAMP PIPEPIPE SM GR LEQ GEQ EQEQ NEQ PUBLIC STATIC VOID MAIN PARSEINT
%token <node> LPAREN RPAREN STRING INT SEMICOLON BOOLEAN LBRACKET RBRACKET LCURLY RCURLY EXTENDS 
%token <node> COMMA EQ TRUE FALSE DOT EXCL PLUS MINUS LENGTH NEW THIS PRINT PRINTLN IF ELSE WHILE RETURN

%token <integer> INTEGER_LITERAL
%token <string> STRING_LITERAL ID

%left RETURN
%left PIPEPIPE
%left AMPAMP
%left SM GR LEQ GEQ EQEQ NEQ
%left PLUS MINUS
%left STAR FWDSLASH
/* Rule Section */
%%

Program : MainClass ClassDecls {
    $$ = new node("PROGRAM");
    $$->addChild($1);
    $$->addChild($2);
    root = $$;
};
ClassDecls : ClassDecl ClassDecls {
    $$ = new node("CLASSDECLS");
    $$->addChild($1);
    $$->addChild($2);
} | {
    $$ = new node("CLASSDECLS");
};
MainClass : CLASS ID LCURLY PUBLIC STATIC VOID MAIN LPAREN STRING LBRACKET RBRACKET ID RPAREN LCURLY Statements RCURLY RCURLY {
    $$ = new node("MAINCLASS");
    $$->varid = $2;
    $$->varid2 = $12;
    $$->addChild($15);
};
Statements : Statement Statements {
    $$ = new node("STATEMENTS");
    $$->lineNo = yylineno;
    $$->addChild($1);
    $$->addChild($2);
} | {
    $$ = new node("STATEMENTS");
    $$->lineNo = yylineno;
};
ClassDecl : CLASS ID MaybeExtId LCURLY VarDecls MethodDecls RCURLY {
    $$ = new node("CLASSDECL");
    $$->varid = $2;
    $$->lineNo = yylineno;
    $$->addChild($3);
    $$->addChild($5);
    $$->addChild($6);
};
MaybeExtId : EXTENDS ID {
    $$ = new node("EXTENDS");
    $$->varid = $2;
} | {
    $$ = new node("NOEXTEND");
};
VarDecls : VarDecls VarDecl {
    $$ = new node("VARDECLS");
    $$->addChild($2);
    $$->addChild($1);
} | {
    $$ = new node("VARDECLS");
};
VarDecl : Type ID InitVal VarsInit SEMICOLON {
    $$ = new node("VARDECL");
    $$->lineNo = yylineno;
    $$->addChild($3);
    $$->addChild($4);
    $$->addChild($1);
    $$->varid = $2;
};
VarsInit : COMMA ID InitVal VarsInit {
    $$ = new node("VARSINIT");
    $$->lineNo = yylineno;
    $$->varid = $2;
    $$->addChild($3);
    $$->addChild($4);
} | {
    $$ = new node("VARSINIT");
};
InitVal : EQ Exp {
    $$ = new node("INITVAL");
    $$->lineNo = yylineno;
    $$->addChild($2);
} | {
    $$ = new node("INITVAL");
};
MethodDecls : MethodDecl MethodDecls {
    $$ = new node("METHODDECLS");
    $$->addChild($1);
    $$->addChild($2);
} | {
    $$ = new node("METHODDECLS");
};
MethodDecl : PUBLIC Type ID LPAREN MaybeFormalList RPAREN LCURLY Statements RCURLY {
    $$ = new node("PUBLICMETHOD");
    $$->lineNo = yylineno;
    $$->addChild($8);
    $$->varid = $3;
    $$->addChild($5);
    $$->addChild($2);
} | Type ID LPAREN MaybeFormalList RPAREN LCURLY Statements RCURLY {
    $$ = new node("PRIVATEMETHOD");
    $$->lineNo = yylineno;
    $$->addChild($7);
    $$->varid = $2;
    $$->addChild($4);
    $$->addChild($1);
}
MaybeFormalList : FormalList {
    $$ = new node("DECLINPUTS");
    $$->addChild($1);
} | {
    $$ = new node("NOINPUT");
};
FormalList : Type ID TypeList {
    $$ = new node("DECLINPUT");
    $$->addChild($1);
    $$->varid = $2;
    $$->addChild($3);
};
TypeList : COMMA Type ID TypeList {
    $$ = new node("DECLINPUT");
    $$->addChild($2);
    $$->varid = $3;
    $$->addChild($4);
} | {
    $$ = new node("DECLINPUT");
};
Type : Type LBRACKET RBRACKET {
    $$ = new node("TYPE|ARRAYS");
    $$->addChild($1);
} | PrimeType {
    $$ = new node("TYPE|PRIMETYPE");
    $$->addChild($1);
};
PrimeType : INT {
    $$ = new node("INT_TYPE");
    $$->data.type = "int";
} | BOOLEAN {
    $$ = new node("BOOLEAN_TYPE");
    $$->data.type = "boolean";
} | STRING {
    $$ = new node("STRING_TYPE");
    $$->data.type = "String";
} | ID {
    $$ = new node("CLASS_TYPE");
    $$->data.type = $1;
};

Statement : VarDecl {
    $$ = new node("STATEMENT|VARDECL");
    $$->addChild($1);
} | LCURLY Statements RCURLY {
    $$ = new node("NEWSCOPE");
    $$->addChild($2);
} | IF LPAREN Exp RPAREN Statement ELSE Statement {
    $$ = new node("IF|ELSE");
    $$->lineNo = yylineno;
    $$->addChild($3);
    $$->addChild($5);
    $$->addChild($7);
} | WHILE LPAREN Exp RPAREN Statement {
    $$ = new node("WHILE");
    $$->lineNo = yylineno;
    $$->addChild($3);
    $$->addChild($5);
} | PRINTLN LPAREN Exp RPAREN SEMICOLON {
    $$ = new node("STATEMENT|PRINTLN");
    $$->lineNo = yylineno;
    $$->addChild($3);
} | PRINT LPAREN Exp RPAREN SEMICOLON {
    $$ = new node("STATEMENT|PRINT");
    $$->lineNo = yylineno;
    $$->addChild($3);
} | LeftValue EQ Exp SEMICOLON {
    $$ = new node("STATEMENT|LVALUE");
    $$->lineNo = yylineno;
    $$->addChild($1);
    $$->addChild($3);
} | ID EQ Exp SEMICOLON {
    $$ = new node("STATEMENT|ASSIGN");
    $$->varid = $1;
    $$->addChild($3);
    $$->lineNo = yylineno;
} | RETURN Exp SEMICOLON {
    $$ = new node("STATEMENT|RETURN");
    $$->addChild($2);
} | MethodCall SEMICOLON {
    $$ = new node("FUNCTIONCALL");
    $$->addChild($1);
};

MethodCall : LeftValue LPAREN MaybeExpList RPAREN {
    $$ = new node("FUNCTIONEXEC");
    $$->lineNo = yylineno;
    $$->addChild($3);
    $$->addChild($1);
};
MethodCall : ID LPAREN MaybeExpList RPAREN {
    $$ = new node("FUNCTIONEXEC");
    $$->lineNo = yylineno;
    $$->varid = $1;
    $$->addChild($3);
};
MaybeExpList : ExpList {
    $$ = new node("CALLINPUTS");
    $$->addChild($1);
} | {
    $$ = new node("NOINPUT");
};
ExpList : Exp NextExp {
    $$ = new node("CALLINPUT");
    $$->addChild($1);
    $$->addChild($2);
};
NextExp : COMMA Exp NextExp {
    $$ = new node("CALLINPUT");
    $$->addChild($2);
    $$->addChild($3);
} | {
    $$ = new node("CALLINPUT");
};

Exp : Exp PLUS Exp {
    $$ = new node("MATH|ADD");
    $$->lineNo = yylineno;
    $$->addChild($1);
    $$->addChild($3);
} | Exp MINUS Exp {
    $$ = new node("MATH|SUB");
    $$->lineNo = yylineno;
    $$->addChild($1);
    $$->addChild($3);
} | Exp STAR Exp {
    $$ = new node("MATH|MUL");
    $$->lineNo = yylineno;
    $$->addChild($1);
    $$->addChild($3);
} | Exp FWDSLASH Exp {
    $$ = new node("MATH|DIV");
    $$->lineNo = yylineno;
    $$->addChild($1);
    $$->addChild($3);
} | Exp AMPAMP Exp {
    $$ = new node("BOOL|AND");
    $$->lineNo = yylineno;
    $$->addChild($1);
    $$->addChild($3);
} | Exp PIPEPIPE Exp {
    $$ = new node("BOOL|OR");
    $$->lineNo = yylineno;
    $$->addChild($1);
    $$->addChild($3);
} | Exp SM Exp {
    $$ = new node("COMP|SM");
    $$->lineNo = yylineno;
    $$->addChild($1);
    $$->addChild($3);
} | Exp GR Exp {
    $$ = new node("COMP|GR");
    $$->lineNo = yylineno;
    $$->addChild($1);
    $$->addChild($3);
} | Exp LEQ Exp {
    $$ = new node("COMP|LEQ");
    $$->lineNo = yylineno;
    $$->addChild($1);
    $$->addChild($3);
} | Exp GEQ Exp {
    $$ = new node("COMP|GEQ");
    $$->lineNo = yylineno;
    $$->addChild($1);
    $$->addChild($3);
} | Exp EQEQ Exp {
    $$ = new node("COMP|EQUAL");
    $$->lineNo = yylineno;
    $$->addChild($1);
    $$->addChild($3);
} | Exp NEQ Exp {
    $$ = new node("COMP|NEQUAL");
    $$->lineNo = yylineno;
    $$->addChild($1);
    $$->addChild($3);
} | EXCL Exp {
    $$ = new node("UNARY|NOT");
    $$->lineNo = yylineno;
    $$->addChild($2);
} | PLUS Exp {
    $$ = new node("UNARY|POS");
    $$->lineNo = yylineno;
    $$->addChild($2);
} | MINUS Exp {
    $$ = new node("UNARY|NEG");
    $$->lineNo = yylineno;
    $$->addChild($2);
} | LPAREN Exp RPAREN {
    $$ = new node("PAREN");
    $$->lineNo = yylineno;
    $$->addChild($2);
} | PARSEINT LPAREN Exp RPAREN {
    $$ = new node("PARSEINT");
    $$->lineNo = yylineno;
    $$->addChild($3);
} | LeftValue {
    $$ = new node("EXP|LVALUE");
    $$->lineNo = yylineno;
    $$->addChild($1);
} | ID {
    $$ = new node("EXP|ID");
    $$->lineNo = yylineno;
    $$->varid = $1;
} | LeftValue DOT LENGTH {
    $$ = new node("EXP|LENGTH");
    $$->addChild($1);
} | ID DOT LENGTH {
    $$ = new node("EXP|LENGTH");
    $$->varid = $1;
} | INTEGER_LITERAL {
    $$ = new node("INTEGER_LITERAL");
    $$->lineNo = yylineno;
    $$->setIntValue($1);
} | STRING_LITERAL {
    $$ = new node("STRING_LITERAL");
    $$->lineNo = yylineno;
    char *str = strdup($1);
    str++;
    str[strlen(str)-1] = 0;
    $$->setStringValue(str);
} | TRUE {
    $$ = new node("BOOLEAN_LITERAL");
    $$->lineNo = yylineno;
    $$->setBooleanValue(true);
} | FALSE {
    $$ = new node("BOOLEAN_LITERAL");
    $$->lineNo = yylineno;
    $$->setBooleanValue(false);
} | MethodCall {
    $$ = new node("FUNCTIONCALL");
    $$->addChild($1);
} | NEW ID LPAREN RPAREN {
    $$ = new node("NEWCLASSINSTANCE");
    $$->varid = $2;
} | NEW PrimeType Index {
    $$ = new node("NEWARRAY");
    $$->addChild($2);
    $$->addChild($3);
};

Index : LBRACKET Exp RBRACKET {
    $$ = new node("ARRAYINDEX");
    $$->lineNo = yylineno;
    $$->addChild($2);
} | Index LBRACKET Exp RBRACKET {
    $$ = new node("ARRAYINDEX");
    $$->lineNo = yylineno;
    $$->addChild($3);
    $$->addChild($1);
};

LeftValue : LeftValue Index {
    $$ = new node("LVALUE|INDEX");
    $$->addChild($1);
    $$->addChild($2);
} | ID Index {
    $$ = new node("ID|INDEX");
    $$->lineNo = yylineno;
    $$->varid = $1;
    $$->addChild($2);
} | LeftValue DOT ID {
    $$ = new node("LVALUEREF");
    $$->addChild($1);
    $$->varid2 = $3;
} | ID DOT ID {
    $$ = new node("OBJVARREF");
    $$->varid = $1;
    $$->varid2 = $3;
} | NEW ID LPAREN RPAREN DOT ID {
    $$ = new node("NEWINSTANCECALL");
    $$->varid = $2;
    $$->varid2 = $6;
} | THIS DOT ID {
    $$ = new node("INTERNALCALL");
    $$->varid2 = $3;
}

%%

void yyerror(char* s) {
    fprintf(stderr, "%s on %d\n", s, yylineno);
}

int main(int argc, char* argv[] ) {
    yyin = fopen( argv[1], "r" );
    if (yyparse() != 0)
        return 1;
    Compiler comp(argv[1], false);
    comp.assemble(root);
    return 0;
}
