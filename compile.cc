#include "compile.hh"

void Compiler::printTree(node* node) {
    for (int i = 0; i < node->children.size(); i++) {
        cout<<node->nodeType<<"->"<<node->children.at(i)->nodeType<<endl;
        printTree(node->children.at(i));
    }
}

scope* Compiler::findScope(scope* currentScope, string id) {
    if (currentScope == NULL) return currentScope;
    if (currentScope->values.find(id) != currentScope->values.end()) {
        return currentScope;
    } else {
        return findScope(currentScope->parent, id);
    }
}

void Compiler::labelScope(node *statement, scope* sc) {
    if (statement->nodeType == "MAINCLASS" || statement->nodeType == "NEWSCOPE" || statement->nodeType == "CLASSDECL" ||
        statement->nodeType == "PUBLICMETHOD" || statement->nodeType == "PRIVATEMETHOD") {
        scope* child = new scope();
        child->parent = sc;
        statement->scope = child;
    } else {
        statement->scope = sc;
    }
    for (int i = 0; i < statement->children.size(); i++) {
        labelScope(statement->children.at(i), statement->scope);
    }
}

string Compiler::getVarType(node* node) {
    if (node->nodeType.substr(0, 4) != "TYPE") {
        return node->data.type;
    } else {
        return getVarType(node->children[0]);
    }
}

instruction* Compiler::compileLvalue(node* statement) {
    string type = statement->nodeType;
    instruction* head = new instruction("", "", "", "");
    instruction* ins = head;
    if (type == "ID|INDEX") {
        node* index = statement->children[0];
        ins->next = compileExpression(index->children[0]);
        while (ins->next != NULL) ins = ins->next;
        int pos = index->children[0]->data.stackPos;
        ins->next = new instruction("ldr", "r1", "sp", "#"+to_string((pos+1)*-4));
        ins = ins->next;
        ins->next = new instruction("lsl", "r1", "r1", "#2");
        ins = ins->next;
        scope* sc = findScope(statement->scope, statement->varid);
        pos = sc->values[statement->varid].stackPos;
        ins->next = new instruction("ldr", "r0", "sp", "#"+to_string((pos+1)*-4));
        ins = ins->next;
        ins->next = new instruction("add", "r0", "r0", "r1");
        statement->data.type = sc->values[statement->varid].type;
    } else if (type == "INTERNALCALL") {
        scope* sc = findScope(statement->scope, "this");
        int pos = sc->values["this"].stackPos;
        ins->next = new instruction("ldr", "r0", "sp", "#"+to_string((pos+1)*-4));
        ins = ins->next;
        pos = sc->parent->values[statement->varid2].stackPos;
        ins->next = new instruction("add", "r0", "r0", "#"+to_string(pos*4));
        statement->data.type = sc->parent->values[statement->varid2].type;
    } else if (type == "OBJVARREF") {
        scope* sc = findScope(statement->scope, statement->varid);
        int pos = sc->values[statement->varid].stackPos;
        string type = sc->values[statement->varid].type;
        ins->next = new instruction("ldr", "r0", "sp", "#"+to_string((pos+1)*-4));
        ins = ins->next;
        pos = classes[type]->sc->values[statement->varid2].stackPos;
        ins->next = new instruction("add", "r0", "r0", "#"+to_string(pos*4));
        statement->data.type = classes[type]->sc->values[statement->varid2].type;
    } else if (type == "LVALUE|INDEX") {
        ins->next = compileLvalue(statement->children[0]);
        while (ins->next != NULL) ins = ins->next;
        int lvalpos = statement->scope->stackTop;
        ins->next = new instruction("str", "r0", "sp", "#"+to_string((1+statement->scope->stackTop++)*-4));
        ins = ins->next;
        node* index = statement->children[1];
        // 1D array only so far
        ins->next = compileExpression(index->children[0]);
        while (ins->next != NULL) ins = ins->next;
        int pos = index->children[0]->data.stackPos;
        ins->next = new instruction("ldr", "r1", "sp", "#"+to_string((pos+1)*-4));
        ins = ins->next;
        ins->next = new instruction("lsl", "r1", "r1", "#2");
        ins = ins->next;
        ins->next = new instruction("ldr", "r0", "sp", "#"+to_string((1+lvalpos)*-4));
        ins = ins->next;
        ins->next = new instruction("add", "r0", "r0", "r1");
        statement->data.type = statement->children[0]->data.type;
    } else if (type == "LVALUEREF") {
        ins->next = compileLvalue(statement->children[0]);
        while (ins->next != NULL) ins = ins->next;
        ins->next = new instruction("ldr", "r0", "r0", "#0");
        ins = ins->next;
        string type = statement->children[0]->data.type;
        int pos = classes[type]->sc->values[statement->varid2].stackPos;
        ins->next = new instruction("add", "r0", "r0", "#"+to_string(pos*4));
        statement->data.type = classes[type]->sc->values[statement->varid2].type;
    }
    return head;
}

instruction* Compiler::compileExpression(node* statement) {
    instruction* head = new instruction("", "", "", "");
    instruction* ins = head;
    string type = statement->nodeType;
    if (type == "INTEGER_LITERAL") {
        if (integers.find(statement->data.value.intValue) == integers.end()) {
            integers[statement->data.value.intValue] = integers.size();
        }
        ins->next = new instruction("ldr", "r0", ".int"+to_string(integers[statement->data.value.intValue]), "");
        ins = ins->next;
        ins->next = new instruction("str", "r0", "sp", "#"+to_string((1+statement->scope->stackTop)*-4));
        statement->data.type = "int";
        statement->data.stackPos = statement->scope->stackTop++;
    } else if (type == "STRING_LITERAL") {
        string content = statement->data.value.stringValue;
        for (int i = 0; i < content.size(); i++) {
            if (content[i] == '\t') {
                content.replace(i, 1, "\\t");
            } else if (content[i] == '\n') {
                content.replace(i, 1, "\\n");
            } else if (content[i] == '\\') {
                content.replace(i, 1, "\\\\");
            } else if (content[i] == '\"') {
                content.replace(i, 1, "\\\"");
            } else if (content[i] == '\'') {
                content.replace(i, 1, "\\\'");
            }
            i++;
        }
        if (strings.find(content) == strings.end()) {
            strings[content] = strings.size();
        }
        ins->next = new instruction("ldr", "r0", "=str"+to_string(strings[content]), "");
        ins = ins->next;
        ins->next = new instruction("str", "r0", "sp", "#"+to_string((1+statement->scope->stackTop)*-4));
        statement->data.type = "String";
        statement->data.stackPos = statement->scope->stackTop++;
    } else if (type == "BOOLEAN_LITERAL") {
        ins->next = new instruction("mov", "r0", "#"+to_string(statement->data.value.booleanValue), "");
        ins = ins->next;
        ins->next = new instruction("str", "r0", "sp", "#"+to_string((1+statement->scope->stackTop)*-4));
        statement->data.type = "boolean";
        statement->data.stackPos = statement->scope->stackTop;
        statement->scope->stackTop++;
    } else if (type == "PAREN") {
        head = compileExpression(statement->children[0]);
        statement->data = statement->children[0]->data;
    } else if (type == "EXP|ID") {
        scope* sc = findScope(statement->scope, statement->varid);
        if (classes.find(sc->name) != classes.end()) {
            sc = findScope(statement->scope, "this");
            int pos = sc->values["this"].stackPos;
            ins->next = new instruction("ldr", "r0", "sp", "#"+to_string((pos+1)*-4));
            ins = ins->next;
            pos = sc->parent->values[statement->varid].stackPos;
            ins->next = new instruction("ldr", "r0", "r0", "#"+to_string(pos*4));
            ins = ins->next;
            ins->next = new instruction("str", "r0", "sp", "#"+to_string((1+statement->scope->stackTop)*-4));
            statement->data.type = sc->parent->values[statement->varid].type;
            statement->data.stackPos = statement->scope->stackTop++;
        } else {
            statement->data = sc->values[statement->varid];
        }
    } else if (type == "EXP|LVALUE") {
        ins->next = compileLvalue(statement->children[0]);
        while (ins->next != NULL) ins = ins->next;
        ins->next = new instruction("ldr", "r0", "r0", "#0");
        ins = ins->next;
        ins->next = new instruction("str", "r0", "sp", "#"+to_string((1+statement->scope->stackTop)*-4));
        scope* sc = findScope(statement->scope, statement->children[0]->varid);
        statement->data.type = statement->children[0]->data.type;
        statement->data.stackPos = statement->scope->stackTop++;
    } else if (type.substr(0, 5) == "MATH|" || type.substr(0, 5) == "BOOL|" || type.substr(0, 5) == "COMP|") {
        ins->next = compileExpression(statement->children[0]);
        while (ins->next != NULL) ins = ins->next;
        ins->next = compileExpression(statement->children[1]);
        while (ins->next != NULL) ins = ins->next;
        int leftPos = statement->children[0]->data.stackPos;
        int rightPos = statement->children[1]->data.stackPos;
        ins->next = new instruction("ldr", "r0", "sp", "#"+to_string((leftPos+1)*-4));
        ins = ins->next;
        ins->next = new instruction("ldr", "r1", "sp", "#"+to_string((rightPos+1)*-4));
        ins = ins->next;
        if (statement->children[0]->data.type == "String") {
            ins->next = new instruction("sub", "sp", "sp", "#"+to_string(statement->scope->stackTop*4));
            ins = ins->next;
            ins->next = new instruction("mov", "r5", "r0", "");
            ins = ins->next;
            ins->next = new instruction("mov", "r6", "r1", "");
            ins = ins->next;
            ins->next = new instruction("mov", "r0", "#1000", ""); // Hacky solution cus it's not worth my time
            ins = ins->next;
            ins->next = new instruction("bl", "malloc", "", "");
            ins = ins->next;
            ins->next = new instruction("mov", "r8", "r0", "");
            ins = ins->next;
            ins->next = new instruction("mov", "r1", "r5", "");
            ins = ins->next;
            ins->next = new instruction("bl", "strcpy", "", "");
            ins = ins->next;
            ins->next = new instruction("mov", "r1", "r6", "");
            ins = ins->next;
            ins->next = new instruction("mov", "r0", "r8", "");
            ins = ins->next;
            ins->next = new instruction("bl", "strcat", "", "");
            ins = ins->next;
            ins->next = new instruction("add", "sp", "sp", "#"+to_string(statement->scope->stackTop*4));
        } else {
            string opcode = type.substr(5);
            if (opcode == "ADD") {
                ins->next = new instruction("add", "r0", "r0", "r1");
            } else if (opcode == "SUB") {
                ins->next = new instruction("sub", "r0", "r0", "r1");
            } else if (opcode == "MUL") {
                ins->next = new instruction("mul", "r0", "r0", "r1");
            } else if (opcode == "DIV") {
                ins->next = new instruction("bl", "__aeabi_idiv", "", "");
            } else if (opcode == "AND") {
                ins->next = new instruction("and", "r0", "r0", "r1");
            } else if (opcode ==  "OR") {
                ins->next = new instruction("orr", "r0", "r0", "r1");
            } else if (opcode == "SM") {
                ins->next = new instruction("mov", "r2", "r1", "");
                ins = ins->next;
                ins->next = new instruction("mov", "r1", "r0", "");
                ins = ins->next;
                ins->next = new instruction("mov", "r0", "#0", "");
                ins = ins->next;
                ins->next = new instruction("cmp", "r1", "r2", "");
                ins = ins->next;
                ins->next = new instruction("movlt", "r0", "#1", "");
            } else if (opcode == "GR") {
                ins->next = new instruction("mov", "r2", "r1", "");
                ins = ins->next;
                ins->next = new instruction("mov", "r1", "r0", "");
                ins = ins->next;
                ins->next = new instruction("mov", "r0", "#0", "");
                ins = ins->next;
                ins->next = new instruction("cmp", "r1", "r2", "");
                ins = ins->next;
                ins->next = new instruction("movgt", "r0", "#1", "");
            } else if (opcode == "LEQ") {
                ins->next = new instruction("mov", "r2", "r1", "");
                ins = ins->next;
                ins->next = new instruction("mov", "r1", "r0", "");
                ins = ins->next;
                ins->next = new instruction("mov", "r0", "#0", "");
                ins = ins->next;
                ins->next = new instruction("cmp", "r1", "r2", "");
                ins = ins->next;
                ins->next = new instruction("movle", "r0", "#1", "");
            } else if (opcode == "GEQ") {
                ins->next = new instruction("mov", "r2", "r1", "");
                ins = ins->next;
                ins->next = new instruction("mov", "r1", "r0", "");
                ins = ins->next;
                ins->next = new instruction("mov", "r0", "#0", "");
                ins = ins->next;
                ins->next = new instruction("cmp", "r1", "r2", "");
                ins = ins->next;
                ins->next = new instruction("movge", "r0", "#1", "");
            } else if (opcode == "EQUAL") {
                ins->next = new instruction("sub", "r0", "r0", "r1");
                ins = ins->next;
                ins->next = new instruction("rsbs", "r1", "r0", "#0");
                ins = ins->next;
                ins->next = new instruction("adc", "r0", "r0", "r1");
            } else if (opcode == "NEQUAL") {
                ins->next = new instruction("subs", "r0", "r0", "r1");
                ins = ins->next;
                ins->next = new instruction("movne", "r0", "#1", "");
            }
        }
        ins = ins->next;
        ins->next = new instruction("str", "r0", "sp", "#"+to_string((1+statement->scope->stackTop)*-4));
        statement->data.stackPos = statement->scope->stackTop;
        if (type.substr(0, 5) == "COMP|") {
            statement->data.type = "boolean";
        } else {
            statement->data.type = statement->children[0]->data.type;
        }
        statement->scope->stackTop++;
    } else if (type.substr(0, 5) == "UNARY") {
        ins->next = compileExpression(statement->children[0]);
        while (ins->next != NULL) ins = ins->next;
        int pos = statement->children[0]->data.stackPos;
        ins->next = new instruction("ldr", "r0", "sp", "#"+to_string((pos+1)*-4));
        ins = ins->next;
        string opcode = type.substr(6);
        if (opcode == "NOT") {
            ins->next = new instruction("rsbs", "r1", "r0", "#0");
            ins = ins->next;
            ins->next = new instruction("adc", "r0", "r0", "r1");
        } else if (opcode == "NEG") {
            ins->next = new instruction("mov", "r1", "#-1", "");
            ins = ins->next;
            ins->next = new instruction("mul", "r0", "r0", "r1");
        }
        ins = ins->next;
        ins->next = new instruction("str", "r0", "sp", "#"+to_string((1+statement->scope->stackTop)*-4));
        statement->data.type = statement->children[0]->data.type;
        statement->data.stackPos = statement->scope->stackTop;
        statement->scope->stackTop++;
    } else if (type == "PARSEINT") {
        ins->next = compileExpression(statement->children[0]);
        int stackPos = statement->children[0]->data.stackPos;
        while (ins->next != NULL) ins = ins->next;
        ins->next = new instruction("ldr", "r0", "sp", "#"+to_string((stackPos+1)*-4));
        ins = ins->next;
        ins->next = new instruction("sub", "sp", "sp", "#"+to_string(statement->scope->stackTop*4));
        ins = ins->next;
        ins->next = new instruction("bl", "atoi", "", "");
        ins = ins->next;
        ins->next = new instruction("add", "sp", "sp", "#"+to_string(statement->scope->stackTop*4));
        ins = ins->next;
        ins->next = new instruction("str", "r0", "sp", "#"+to_string((1+statement->scope->stackTop)*-4));
        statement->data.type = statement->children[0]->data.type;
        statement->data.stackPos = statement->scope->stackTop;
        statement->scope->stackTop++;
    } else if (type == "EXP|LENGTH") {
        if (statement->children.size() > 0) {
            ins->next = compileLvalue(statement->children[0]);
            while (ins->next != NULL) ins = ins->next;
            ins->next = new instruction("ldr", "r0", "r0", "#0");
            ins = ins->next;
            ins->next = new instruction("ldr", "r0", "r0", "#-4");
        } else {
            scope* sc = findScope(statement->scope, statement->varid);
            int pos = sc->values[statement->varid].stackPos;
            ins->next = new instruction("ldr", "r0", "sp", "#"+to_string((1+pos)*-4));
            ins = ins->next;
            if (sc->values[statement->varid].type == "String") {
                ins->next = new instruction("sub", "sp", "sp", "#"+to_string(statement->scope->stackTop*4));
                ins = ins->next;
                ins->next = new instruction("bl", "strlen", "", "");
                ins = ins->next;
                ins->next = new instruction("add", "sp", "sp", "#"+to_string(statement->scope->stackTop*4));
            } else {
                ins->next = new instruction("ldr", "r0", "r0", "#-4");
            }
            ins = ins->next;
        }
        ins->next = new instruction("str", "r0", "sp", "#"+to_string((1+statement->scope->stackTop)*-4));
        statement->data.type = "int";
        statement->data.stackPos = statement->scope->stackTop;
        statement->scope->stackTop++;
    } else if (type == "FUNCTIONCALL") {
        ins->next = compileFunctionCall(statement);
        while (ins->next != NULL) ins = ins->next;
        ins->next = new instruction("str", "r0", "sp", "#"+to_string((1+statement->scope->stackTop)*-4));
        statement->data.stackPos = statement->scope->stackTop;
        statement->scope->stackTop++;
    } else if (type == "NEWARRAY") {
        head = compileIndices(statement->children[1]);
        ins = head;
        while (ins->next != NULL) ins = ins->next;
        // Only handles up to 2 dimensions
        int d1stackpos = statement->children[1]->data.stackPos;
        ins->next = new instruction("ldr", "r0", "sp", "#"+to_string((1+d1stackpos)*-4));
        ins = ins->next;
        ins->next = new instruction("mov", "r5", "r0", "");
        ins = ins->next;
        ins->next = new instruction("add", "r0", "r0", "#1"); // Extra space to store size
        ins = ins->next;
        ins->next = new instruction("lsl", "r0", "r0", "#2");
        ins = ins->next;
        ins->next = new instruction("sub", "sp", "sp", "#"+to_string(statement->scope->stackTop*4));
        ins = ins->next;
        ins->next = new instruction("bl", "malloc", "", "");
        ins = ins->next;
        ins->next = new instruction("str", "r5", "r0", "#0"); 
        ins = ins->next;
        ins->next = new instruction("add", "r0", "r0", "#4"); // Size stored before 0th element
        ins = ins->next;
        ins->next = new instruction("add", "sp", "sp", "#"+to_string(statement->scope->stackTop*4));
        ins = ins->next;
        ins->next = new instruction("str", "r0", "sp", "#"+to_string((1+statement->scope->stackTop)*-4));
        if (statement->children[1]->children.size() == 2) {
            ins->next = new instruction("mov", "r8", "#-1", "");
            int labelno = labels++;
            ins->next = new instruction("b", ".matrixend"+to_string(labelno), "", "");
            ins = ins->next;
            ins->next = new instruction("LABEL", ".matrixbegin"+to_string(labelno), "", "");
            ins = ins->next;
            int d2stackpos = statement->children[1]->children[1]->data.stackPos;
            ins->next = new instruction("ldr", "r0", "sp", "#"+to_string((1+d2stackpos)*-4));
            ins = ins->next;
            ins->next = new instruction("mov", "r6", "r0", "");
            ins = ins->next;
            // Malloc rows here
            ins->next = new instruction("add", "r0", "r0", "#1"); // Extra space to store size
            ins = ins->next;
            ins->next = new instruction("lsl", "r0", "r0", "#2");
            ins = ins->next;
            ins->next = new instruction("sub", "sp", "sp", "#"+to_string(statement->scope->stackTop*4));
            ins = ins->next;
            ins->next = new instruction("bl", "malloc", "", "");
            ins = ins->next;
            ins->next = new instruction("str", "r6", "r0", "#0"); 
            ins = ins->next;
            ins->next = new instruction("add", "r0", "r0", "#4"); // Size stored before 0th element
            ins = ins->next;
            ins->next = new instruction("add", "sp", "sp", "#"+to_string(statement->scope->stackTop*4));
            ins = ins->next;
            ins->next = new instruction("ldr", "r4", "sp", "#"+to_string((1+statement->scope->stackTop)*-4));
            ins = ins->next;
            ins->next = new instruction("str", "r0", "s4", "r8");
            // End malloc rows
            ins->next = new instruction("LABEL", ".matrixend"+to_string(labelno), "", "");
            ins = ins->next;
            ins->next = new instruction("add", "r8", "r8", "#1");
            ins = ins->next;
            ins->next = new instruction("cmp", "r8", "r5", "");
            ins = ins->next;
            ins->next = new instruction("blt", ".matrixbegin"+to_string(labelno), "", "");
        }
        statement->data.type = statement->children[0]->data.type;
        statement->data.stackPos = statement->scope->stackTop;
        statement->scope->stackTop++;
    } else if (type == "NEWCLASSINSTANCE") {
        ins->next = new instruction("sub", "sp", "sp", "#"+to_string(statement->scope->stackTop*4));
        ins = ins->next;
        ins->next = new instruction("bl", statement->varid+"_init", "", "");
        ins = ins->next;
        ins->next = new instruction("add", "sp", "sp", "#"+to_string(statement->scope->stackTop*4));
        ins = ins->next;
        ins->next = new instruction("str", "r0", "sp", "#"+to_string((1+statement->scope->stackTop)*-4));
        statement->data.type = statement->varid;
        statement->data.stackPos = statement->scope->stackTop;
        statement->scope->stackTop++;
    }
    return head;
}

instruction* Compiler::compileDeclarations(node* statement, string dtype) {
    // Evaluation results are stored in r0
    if (statement->children.size() == 0) return NULL;
    node* initval = statement->children[0];
    instruction* ins;
    instruction* head;
    if (initval->children.size() > 0) {
        ins = compileExpression(initval->children[0]);
        head = ins;
        statement->scope->values[statement->varid] = initval->children[0]->data;
        while (ins->next != NULL) ins = ins->next;
    } else {
        ins = new instruction("mov", "r0", "#0", "");
        head = ins;
        ins->next = new instruction("str", "r0", "sp", "#"+to_string((1+statement->scope->stackTop)*-4));
        ins = ins->next;
        statement->scope->values[statement->varid].type = dtype;
        statement->scope->values[statement->varid].stackPos = statement->scope->stackTop++;
    }
    ins->next = compileDeclarations(statement->children[1], dtype);
    return head;
}

instruction* Compiler::compileIndices(node* statement) {
    instruction* head = new instruction("", "", "", "");
    instruction* ins = head;
    ins->next = compileExpression(statement->children[0]);
    statement->data = statement->children[0]->data;
    while (ins->next != NULL) ins = ins->next;
    if (statement->children.size() == 2) {
        ins->next = compileIndices(statement->children[1]);
    }
    return head;
}

instruction* Compiler::compileFunctionCall(node* statement) {
    node* funexec = statement->children[0];
    node* args = funexec->children[0];
    instruction* head = new instruction("", "", "", "");
    instruction* ins = head;
    int pos;
    string label;
    if (funexec->children.size() == 2) {
        node* lvalue = funexec->children[1];
        int lvalpos;
        if (lvalue->nodeType == "NEWINSTANCECALL") {
            ins->next = new instruction("sub", "sp", "sp", "#"+to_string(statement->scope->stackTop*4));
            ins = ins->next;
            ins->next = new instruction("bl", lvalue->varid+"_init", "", "");
            ins = ins->next;
            ins->next = new instruction("add", "sp", "sp", "#"+to_string(statement->scope->stackTop*4));
            ins = ins->next;
            lvalpos = statement->scope->stackTop;
            ins->next = new instruction("str", "r0", "sp", "#"+to_string((1+statement->scope->stackTop++)*-4));
            ins = ins->next;
            label = lvalue->varid+"_"+lvalue->varid2;
        } else if (lvalue->nodeType == "LVALUEREF") {
            ins->next = compileLvalue(lvalue->children[0]);
            while (ins->next != NULL) ins = ins->next;
            ins->next = new instruction("ldr", "r0", "r0", "#0");
            ins = ins->next;
            lvalpos = statement->scope->stackTop;
            ins->next = new instruction("str", "r0", "sp", "#"+to_string((1+statement->scope->stackTop++)*-4));
            ins = ins->next;
            label = lvalue->children[0]->data.type+"_"+lvalue->varid2;
        }
        if (funexec->children[0]->nodeType != "NOINPUT") {
            node* callinput = funexec->children[0]->children[0];
            int rnum = 1;
            while (callinput->children.size() > 0) {
                ins->next = compileExpression(callinput->children[0]);
                while (ins->next != NULL) ins = ins->next;
                pos = callinput->children[0]->data.stackPos;
                ins->next = new instruction("ldr", "r"+to_string(rnum++), "sp", "#"+to_string((pos+1)*-4));
                ins = ins->next;
                callinput = callinput->children[1];
            }
        }
        if (lvalue->nodeType == "INTERNALCALL") {
            scope * classScope = statement->scope;
            while (classScope->parent != NULL) classScope = classScope->parent;
            label = classScope->name+"_"+lvalue->varid2;
            scope* sc = findScope(lvalue->scope, "this");
            pos = sc->values["this"].stackPos;
            ins->next = new instruction("ldr", "r0", "sp", "#"+to_string((pos+1)*-4));
            ins = ins->next;
        } else if (lvalue->nodeType == "OBJVARREF") {
            scope* sc = findScope(lvalue->scope, lvalue->varid);
            pos = sc->values[lvalue->varid].stackPos;
            ins->next = new instruction("ldr", "r0", "sp", "#"+to_string((pos+1)*-4));
            ins = ins->next;
            label = sc->values[lvalue->varid].type+"_"+lvalue->varid2;
        } else {
            ins->next = new instruction("ldr", "r0", "sp", "#"+to_string((1+lvalpos)*-4));
            ins = ins->next;
        }
    } else {
        if (funexec->children[0]->nodeType != "NOINPUT") {
            node* callinput = funexec->children[0]->children[0];
            int rnum = 1;
            while (callinput->children.size() > 0) {
                ins->next = compileExpression(callinput->children[0]);
                while (ins->next != NULL) ins = ins->next;
                pos = callinput->children[0]->data.stackPos;
                ins->next = new instruction("ldr", "r"+to_string(rnum++), "sp", "#"+to_string((pos+1)*-4));
                ins = ins->next;
                callinput = callinput->children[1];
            }
        }
    }
    ins->next = new instruction("sub", "sp", "sp", "#"+to_string(statement->scope->stackTop*4));
    ins = ins->next;
    ins->next = new instruction("bl", label, "", "");
    ins = ins->next;
    ins->next = new instruction("add", "sp", "sp", "#"+to_string(statement->scope->stackTop*4));
    statement->data.type = returnType[label];
    return head;
}

instruction* Compiler::compileStatement(node* statement) {
    string type = statement->nodeType;
    instruction* head = new instruction("", "", "", "");
    instruction* ins = head;
    if (type == "STATEMENT|RETURN") {
        ins->next = compileExpression(statement->children[0]);
        while (ins->next != NULL) ins = ins->next;
        int pos = statement->children[0]->data.stackPos;
        ins->next = new instruction("ldr", "r0", "sp", "#"+to_string((pos+1)*-4));
        ins = ins->next;
        ins->next = new instruction("b", statement->scope->name+"_return", "", "");
    } else if (type == "NEWSCOPE") {
        statement->scope->stackTop = statement->scope->parent->stackTop;
        ins->next = compileStatements(statement->children[0]);
    } else if (type == "STATEMENT|VARDECL") {
        node* vardecl = statement->children[0];
        ins->next = compileDeclarations(vardecl, getVarType(vardecl->children[2]));
    } else if (type == "STATEMENT|ASSIGN") {
        ins->next = compileExpression(statement->children[0]);
        int pos = statement->children[0]->data.stackPos;
        while (ins->next != NULL) ins = ins->next;
        ins->next = new instruction("ldr", "r1", "sp", "#"+to_string((pos+1)*-4));
        ins = ins->next;
        scope* sc = findScope(statement->scope, statement->varid);
        if (classes.find(sc->name) != classes.end()) {
            sc = findScope(statement->scope, "this");
            pos = sc->values["this"].stackPos;
            ins->next = new instruction("ldr", "r0", "sp", "#"+to_string((pos+1)*-4));
            ins = ins->next;
            pos = sc->parent->values[statement->varid].stackPos;
            ins->next = new instruction("str", "r1", "r0", "#"+to_string(pos*4));
        } else {
            pos = sc->values[statement->varid].stackPos;
            ins->next = new instruction("str", "r1", "sp", "#"+to_string((pos+1)*-4));
        }
    } else if (type == "STATEMENT|PRINT" || type == "STATEMENT|PRINTLN") {
        ins->next = compileExpression(statement->children[0]);
        while (ins->next != NULL) ins = ins->next;
        if (statement->children[0]->data.type == "String") {
            int stackPos = statement->children[0]->data.stackPos;
            ins->next = new instruction("ldr", "r0", "sp", "#"+to_string((stackPos+1)*-4));
            ins = ins->next;
            if (type == "STATEMENT|PRINTLN") {
                ins->next = new instruction("sub", "sp", "sp", "#"+to_string(statement->scope->stackTop*4));
                ins = ins->next;
                ins->next = new instruction("bl", "printf", "", "");
                ins = ins->next;
                ins->next = new instruction("add", "sp", "sp", "#"+to_string(statement->scope->stackTop*4));
                ins = ins->next;
                if (strings.find("\\n") == strings.end()) {
                    strings["\\n"] = strings.size();
                }
                ins->next = new instruction("ldr", "r0", "=str"+to_string(strings["\\n"]), "");
                ins = ins->next;
            }
        } else if (statement->children[0]->data.type == "int") {
            string fmt = "%d";
            if (type == "STATEMENT|PRINTLN") fmt += "\\n";
            if (strings.find(fmt) == strings.end()) {
                strings[fmt] = strings.size();
            }
            ins->next = new instruction("ldr", "r0", "=str"+to_string(strings[fmt]), "");
            ins = ins->next;
            int stackPos = statement->children[0]->data.stackPos;
            ins->next = new instruction("ldr", "r1", "sp", "#"+to_string((1+stackPos)*-4));
            ins = ins->next;
        } else if (statement->children[0]->data.type == "boolean") {
            string T = "true";
            string F = "false";
            if (type == "STATEMENT|PRINTLN") {
                T += "\\n";
                F += "\\n";
            }
            if (strings.find(T) == strings.end()) {
                strings[T] = strings.size();
            }
            if (strings.find(F) == strings.end()) {
                strings[F] = strings.size();
            }
            int stackPos = statement->children[0]->data.stackPos;
            ins->next = new instruction("ldr", "r1", "sp", "#"+to_string((stackPos+1)*-4));
            ins = ins->next;
            ins->next = new instruction("ldr", "r2", "=str"+to_string(strings[T]), "");
            ins = ins->next;
            ins->next = new instruction("ldr", "r3", "=str"+to_string(strings[F]), "");
            ins = ins->next;
            ins->next = new instruction("mov", "r0", "r3", "");
            ins = ins->next;
            ins->next = new instruction("cmp", "r1", "#0", "");
            ins = ins->next;
            ins->next = new instruction("movgt", "r0", "r2", "");
            ins = ins->next;
        }
        ins->next = new instruction("sub", "sp", "sp", "#"+to_string(statement->scope->stackTop*4));
        ins = ins->next;
        ins->next = new instruction("bl", "printf", "", "");
        ins = ins->next;
        ins->next = new instruction("add", "sp", "sp", "#"+to_string(statement->scope->stackTop*4));
    } else if (type == "FUNCTIONCALL") {
        ins->next = compileFunctionCall(statement);
    } else if (type == "IF|ELSE") {
        statement->children[1]->scope->name = statement->scope->name;
        statement->children[2]->scope->name = statement->scope->name;
        ins->next = compileExpression(statement->children[0]);
        int pos = statement->children[0]->data.stackPos;
        while (ins->next != NULL) ins = ins->next;
        ins->next = new instruction("ldr", "r1", "sp", "#"+to_string((pos+1)*-4));
        ins = ins->next;
        ins->next = new instruction("cmp", "r1", "#0", "");
        ins = ins->next;
        int labelno = labels++;
        ins->next = new instruction("beq", ".endthen"+to_string(labelno), "", "");
        ins = ins->next;
        ins->next = compileStatement(statement->children[1]);
        while (ins->next != NULL) ins = ins->next;
        ins->next = new instruction("b", ".endelse"+to_string(labelno), "", "");
        ins = ins->next;
        ins->next = new instruction("LABEL", ".endthen"+to_string(labelno), "", "");
        ins = ins->next;
        ins->next = compileStatement(statement->children[2]);
        while (ins->next != NULL) ins = ins->next;
        ins->next = new instruction("LABEL", ".endelse"+to_string(labelno), "", "");
    } else if (type == "WHILE") {
        statement->children[1]->scope->name = statement->scope->name;
        int labelno = labels++;
        ins->next = new instruction("b", ".loopend"+to_string(labelno), "", "");
        ins = ins->next;
        ins->next = new instruction("LABEL", ".loopbegin"+to_string(labelno), "", "");
        ins = ins->next;
        ins->next = compileStatement(statement->children[1]);
        while (ins->next != NULL) ins = ins->next;
        ins->next = new instruction("LABEL", ".loopend"+to_string(labelno), "", "");
        ins = ins->next;
        ins->next = compileExpression(statement->children[0]);
        int pos = statement->children[0]->data.stackPos;
        while (ins->next != NULL) ins = ins->next;
        ins->next = new instruction("ldr", "r1", "sp", "#"+to_string((pos+1)*-4));
        ins = ins->next;
        ins->next = new instruction("cmp", "r1", "#0", "");
        ins = ins->next;
        ins->next = new instruction("bne", ".loopbegin"+to_string(labelno), "", "");
    } else if (type == "STATEMENT|LVALUE") {
        ins->next = compileExpression(statement->children[1]);
        while (ins->next != NULL) ins = ins->next;
        ins->next = compileLvalue(statement->children[0]);
        while (ins->next != NULL) ins = ins->next;
        int pos = statement->children[1]->data.stackPos;
        ins->next = new instruction("ldr", "r2", "sp", "#"+to_string((1+pos)*-4));
        ins = ins->next;
        ins->next = new instruction("str", "r2", "r0", "#0");
    }
    return head;
}

instruction* Compiler::compileStatements(node* node) {
    if (node->children.size() == 0) return NULL;
    instruction* head = compileStatement(node->children[0]);
    instruction* ins = head;
    while (ins->next != NULL) ins = ins->next;
    ins->next = compileStatements(node->children[1]);
    return head;
}

instruction* Compiler::compileClass(node* statement) {
    scope* sc = statement->scope;
    sc->name = statement->varid;
    node* vardecls = statement->children[1];
    instruction* head = new instruction("LABEL", statement->varid+"_init", "", "");
    instruction* ins = head;
    ins->next = new instruction("push", "fp", "lr", "");
    ins = ins->next;
    while (vardecls->children.size() > 0) {
        node* vardecl = vardecls->children[0];
        ins->next = compileDeclarations(vardecl, getVarType(vardecl->children[2]));
        while (ins->next != NULL) ins = ins->next;
        vardecls = vardecls->children[1];
    }
    classes[statement->varid]->sc = sc;
    ins->next = new instruction("sub", "sp", "sp", "#"+to_string(sc->stackTop*4));
    ins = ins->next;
    // Uses more memory than needed but requires less coding
    ins->next = new instruction("mov", "r0", "#"+to_string(sc->stackTop*4), "");
    ins = ins->next;
    ins->next = new instruction("bl", "malloc", "", "");
    ins = ins->next;
    ins->next = new instruction("add", "sp", "sp", "#"+to_string(sc->stackTop*4));
    ins = ins->next;
    ins->next = new instruction("mov", "r2", "r0", "");
    ins = ins->next;
    map<string, _data>::iterator it;
    for (it = sc->values.begin(); it != sc->values.end(); it++) {
        ins->next = new instruction("ldr", "r0", "sp", "#"+to_string((1+it->second.stackPos)*-4));
        ins = ins->next;
        ins->next = new instruction("str", "r0", "r2", "#"+to_string(it->second.stackPos*4));
        ins = ins->next;
    }
    ins->next = new instruction("mov", "r0", "r2", "");
    ins = ins->next;
    ins->next = new instruction("pop", "fp", "pc", "");
    ins = ins->next;
    ins->next = new instruction("bx", "lr", "", "");
    ins = ins->next;
    ins->next = compileMethods(statement->children[2], statement->varid);
    return head;
}

instruction* Compiler::compileClasses(node* start) {
    node* statement = start;
    unordered_set<string> unloadedClasses;
    instruction* head = new instruction("", "", "", "");
    instruction* ins = head;
    if (statement->children.size() == 0) return head;
    while (statement->children.size() > 0) {
        unloadedClasses.insert(statement->children[0]->varid);
        statement = statement->children[1];
    }
    statement = start;
    while (!unloadedClasses.empty()) {
        while (statement->children.size() > 0) {
            node* classdecl = statement->children[0];
            if (unloadedClasses.find(classdecl->varid) == unloadedClasses.end()) {
                statement = statement->children[1];
                continue;
            }
            if (classdecl->children[0]->nodeType == "EXTENDS") {
                string parent = classdecl->children[0]->varid;
                if (unloadedClasses.find(parent) != unloadedClasses.end()) {
                    statement = statement->children[1];
                    continue;
                }
                node* parentvardecls = copyNodes(classes[parent]->vardecls);
                labelScope(parentvardecls, classdecl->scope);
                if (parentvardecls->children.size() > 0) {
                    node* current = classdecl->children[1];
                    if (current->children.size() == 0) {
                        classdecl->children[1] = parentvardecls;
                    } else {
                        while (current->children[1]->children.size() > 0) {
                            current = current->children[1];
                        }
                        current->children[1] = parentvardecls;
                    }
                }
                node* parentmethoddecls = copyNodes(classes[parent]->methoddecls);
                labelScope(parentmethoddecls, classdecl->scope);
                if (parentmethoddecls->children.size() > 0) {
                    node* current = classdecl->children[2];
                    if (current->children.size() == 0) {
                        classdecl->children[2] = parentmethoddecls;
                    } else {
                        while (current->children[1]->children.size() > 0) {
                            current = current->children[1];
                        }
                        current->children[1] = parentmethoddecls;
                    }
                }
            }
            classes[classdecl->varid] = new classinfo();
            classes[classdecl->varid]->vardecls = classdecl->children[1];
            classes[classdecl->varid]->methoddecls = classdecl->children[2];
            unloadedClasses.erase(classdecl->varid);
            statement = statement->children[1];
        }
        statement = start;
    }
    while (statement->children.size() > 0) {
        node* classdecl = statement->children[0];
        ins->next = compileClass(classdecl);
        while (ins->next != NULL) ins = ins->next;
        statement = statement->children[1];
    }
    return head;
}

node* copyNodes(node* statement) {
    node* copy = new node(statement->nodeType);
    for (auto it = statement->children.begin(); it != statement->children.end(); it++) {
        copy->addChild(copyNodes(*it));
    }
    copy->data.type = statement->data.type;
    copy->varid = statement->varid;
    copy->varid2 = statement->varid2;
    return copy;
}

instruction* Compiler::compileMethod(node* statement, string classname) {
    string label = classname+"_"+statement->varid;
    returnType[label] = getVarType(statement->children[2]);
    statement->scope->name = label;
    instruction* head = new instruction("LABEL", label, "", "");
    instruction* ins = head;
    ins->next = new instruction("push", "fp", "lr", "");
    ins = ins->next;
    // Compile input
    statement->scope->values["this"].type = classname;
    statement->scope->values["this"].stackPos = statement->scope->stackTop++;
    ins->next = new instruction("str", "r0", "sp", "#-4");
    ins = ins->next;
    if (statement->children[1]->nodeType != "NOINPUT") {
        node* typelist = statement->children[1]->children[0];
        while (typelist->children.size() != 0) {
            int pos = typelist->scope->stackTop;
            typelist->scope->values[typelist->varid].type = getVarType(typelist->children[0]);
            typelist->scope->values[typelist->varid].stackPos = pos;
            ins->next = new instruction("str", "r"+to_string(pos), "sp", "#"+to_string((1+pos)*-4));
            ins = ins->next;
            typelist->scope->stackTop++;
            typelist = typelist->children[1];
        }
    }
    ins->next = compileStatements(statement->children[0]);
    while (ins->next != NULL) ins = ins->next;
    ins->next = new instruction("LABEL", label+"_return", "", "");
    ins = ins->next;
    ins->next = new instruction("pop", "fp", "pc", "");
    ins = ins->next;
    ins->next = new instruction("bx", "lr", "", "");
    return head;
}

instruction* Compiler::compileMethods(node* node, string classname) {
    if (node->children.size() == 0) return NULL;
    instruction* head = compileMethod(node->children[0], classname);
    instruction* ins = head;
    while (ins->next != NULL) ins = ins->next;
    ins->next = compileMethods(node->children[1], classname);
    return head;
}

instruction* Compiler::compileMain(node* node) {
    node->scope->values["argc"].stackPos = node->scope->stackTop++;
    node->scope->values[node->varid2].stackPos = node->scope->stackTop++;
    node->scope->values["argc"].type = "int";
    node->scope->values[node->varid2].type = "String";
    node->scope->name = "main";
    instruction* ins = new instruction("LABEL", "main", "", "");
    instruction* head = ins;
    ins->next = new instruction("push", "fp", "lr", "");
    ins = ins->next;
    ins->next = new instruction("str", "r0", "sp", "#"+to_string((1+node->scope->values["argc"].stackPos)*-4));
    ins = ins->next;
    ins->next = new instruction("add", "r1", "r1", "#4");
    ins = ins->next;
    ins->next = new instruction("str", "r1", "sp", "#"+to_string((1+node->scope->values[node->varid2].stackPos)*-4));
    ins = ins->next;
    ins->next = compileStatements(node->children[0]);
    while (ins->next != NULL) ins = ins->next;
    ins->next = new instruction("pop", "fp", "pc", "");
    ins = ins->next;
    ins->next = new instruction("bx", "lr", "", "");
    return head;
}

void Compiler::writeList(instruction* ins) {
    if (ins == NULL) return;
    string optype = ins->optype;
    if (optype == "push" || optype == "pop") {
        fout<<'\t'<<optype<<'\t'<<'{'<<ins->arg1<<", "<<ins->arg2<<'}';
    } else if (optype.substr(0, 3) == "mov" || optype == "cmp") {
        fout<<'\t'<<optype<<'\t'<<ins->arg1<<", "<<ins->arg2;
    } else if (optype == "ldr" || optype == "str") {
        if (ins->arg2[0] == '=' || ins->arg2[0] == '.') {
            fout<<'\t'<<optype<<'\t'<<ins->arg1<<", "<<ins->arg2;
        } else {
            fout<<'\t'<<optype<<'\t'<<ins->arg1<<", ["<<ins->arg2<<", "<<ins->arg3<<']';
        }
    } else if (optype == "add" || optype.substr(0, 3) == "sub" || optype == "mul" || optype == "lsl" ||
               optype == "rsbs" || optype == "adc" || optype == "and" || optype == "orr") {
        fout<<'\t'<<optype<<'\t'<<ins->arg1<<", "<<ins->arg2<<", "<<ins->arg3;
    } else if (optype[0] == 'b') {
        fout<<'\t'<<optype<<'\t'<<ins->arg1;
    } else if (optype == "LABEL") {
        fout<<ins->arg1<<':';
    }
    if (optype != "") {
        fout<<endl;
    }
    writeList(ins->next);
}

void Compiler::assemble(node* statement) {
    labelScope(statement, NULL);
    // printTree(statement);
    node* mainclass = statement->children[0];
    node* classdecls = statement->children[1];
    instruction* ins = compileClasses(classdecls);
    instruction* head = ins;
    while (ins->next != NULL) ins = ins->next;
    ins->next = compileMain(mainclass);
    fout<<".data\n.balign\t4\n";
    for (auto it = strings.begin(); it != strings.end(); it++) {
        fout<<"str"<<it->second<<":\n\t.asciz\t\""<<it->first<<"\""<<endl;
    }
    fout<<".text\n.balign\t4\n.global\tmain"<<endl;
    writeList(head);
    for (auto it = integers.begin(); it != integers.end(); it++) {
        fout<<".int"<<it->second<<":\n\t.word\t"<<it->first<<endl;
    }
}
