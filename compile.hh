#include <unordered_map>
#include <unordered_set>
#include <fstream>
#include <iostream>
#include <string>
#include "node.cc"

using namespace std;

struct instruction {
    instruction * next;
    string optype;
    string arg1;
    string arg2;
    string arg3;
    instruction(string op, string s1, string s2, string s3) {
        next = NULL;
        this->optype = op;
        this->arg1 = s1;
        this->arg2 = s2;
        this->arg3 = s3;
    }
    void print() {
        cout<<optype<<','<<arg1<<','<<arg2<<','<<arg3<<endl; 
    }
};

struct classinfo {
    scope* sc;
    node* vardecls;
    node* methoddecls;
};

class Compiler {
    public:
        ofstream fout;
        void assemble(node* node);
        Compiler(string filename, bool toggleOptim) {
            this->toggleOptim = toggleOptim;
            fout.open(filename.substr(0, filename.find(".java"))+".s");
        }
        ~Compiler() {
            fout.close();
        }
    private:
        bool toggleOptim = false;
        unordered_map<string, int> strings;
        unordered_map<int, int> integers;
        unordered_map<string, string> returnType;
        unordered_map<string, classinfo*> classes;
        int labels = 0;
        void printTree(node* node);
        void writeList(instruction* root);
        void labelScope(node* node, scope* sc);
        string getVarType(node* node);
        scope* findScope(scope* currentScope, string id);
        instruction* compileLvalue(node* node);
        instruction* compileIndices(node* node);
        instruction* compileExpression(node* node);
        instruction* compileFunctionCall(node* node);
        instruction* compileMethod(node* node, string classname);
        instruction* compileMethods(node* node, string classname);
        instruction* compileDeclarations(node* node, string dtype);
        instruction* compileClass(node* node);
        instruction* compileClasses(node* node);
        instruction* compileStatement(node* node);
        instruction* compileStatements(node* node);
        instruction* compileMain(node* node);
};

node* copyNodes(node* statement);
