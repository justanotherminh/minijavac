#include <stdlib.h>
#include <iostream>
#include <string>
#include <vector>
#include <map>
#pragma once

using namespace std;

union value_t {
    char* stringValue;
    int intValue;
    bool booleanValue;
    void* ptrValue;
};

struct _data {
    string type;
    value_t value;
    int stackPos = 0;
    vector<value_t> values;
    vector<int> dims;
};

struct scope {
    string name;
    map<string, _data> values;
    scope* parent;
    int stackTop = 0;
    void printScope() {
        cout<<"Name: "<<this->name<<endl;
        if (this->parent == NULL) {
            cout<<"Parent: None"<<endl;
        } else {
            cout<<"Parent: "<<this->parent->name<<endl;
        }
        cout<<"Vars: ";
        for (auto it = values.begin(); it != values.end(); ++it) {
            cout<<it->first<<':'<<it->second.type<<',';
        }
        cout<<endl;
    }
};

class node {
    public:
        // Fields
        vector<node*> children;
        string nodeType;
        scope* scope;
        _data data;
        string varid;
        string varid2;
        int lineNo;

        node(string nodeType) {
            this->nodeType = nodeType;
        }

        void addChild(node* child) {
            children.push_back(child);
        }   

        void setStringValue(char* s) {
            data.value.stringValue = s;
            data.type = "String";
        } 

        void setIntValue(int i) {
            data.value.intValue = i;
            data.type = "int";
        }

        void setBooleanValue(bool b) {
            data.value.booleanValue = b;
            data.type = "boolean";
        }
};
