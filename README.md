# minijavac
A compiler for a subset of Java on ARM 32-bit. This Java subset has been around for a long time, and I've seen at least 5 different universities using this grammar (with some very small variations). This compiler can compile any Java program that can be parsed by the grammar below, with the exception of programs with arrays with more than 2 dimensions. It would not be a terribly difficult upgrade to support arrays with arbitrary number of dimensions, but I have no incentive to do so.

Grammar:
```
 Program  : MainClass ClassDecl*
 MainClass : class id { public static void main "(" String [] id ")"
               { Statement* }}
 ClassDecl : class id (extends id)? { VarDecl* MethodDecl* }
           
   VarDecl : Type id (= Exp)? (, id (= Exp)? )* ;

MethodDecl : public? Type id "(" FormalList? ")"
               {Statement*}

FormalList : Type id (, Type id)*

 PrimeType : int
           : boolean
           : id
	   : String

      Type : PrimeType
           : Type [ ]

 Statement : VarDecl
	   : { Statement* }
           : if "(" Exp ")" Statement else Statement
           : while "(" Exp ")" Statement
           : System.out.println "(" Exp ")" ;
           : System.out.print "(" Exp ")" ;
           : LeftValue = Exp ;
	   : return Exp ;
	   : MethodCall ;

MethodCall : LeftValue "(" ExpList? ")" 

       Exp : Exp op Exp
           : ! Exp
           : + Exp       
           : - Exp
           : "(" Exp ")"
	   : LeftValue
           : LeftValue . length
           : INTEGER_LITERAL
	   : STRING_LITERAL
           : true
           : false
           : MethodCall
	   : new id "(" ")"
	   : new PrimeType Index


     Index :  [ Exp ]
           : Index [Exp]

   ExpList : Exp (, Exp)*

LeftValue  : id
	   : LeftValue Index
	   : LeftValue . id
	   : new id "(" ")" . id
	   : this . id
```
