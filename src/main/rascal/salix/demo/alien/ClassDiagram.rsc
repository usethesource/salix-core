module salix::demo::alien::ClassDiagram

import salix::Core;
import salix::HTML;
import salix::App;
import salix::Index;

import salix::demo::alien::Mermaid;

alias Model = bool;

Model init() = false;

SalixApp[Model] mermaidApp(str id = "alien") 
  = makeApp(id, init, withIndex("Mermaid", id, view), update);

App[Model] mermaidWebApp()
  = webApp(mermaidApp(), |project://salix/src/main/rascal|);


data Msg = doIt();

alias CD = void(C, R, N);

alias C = void(str, void(D));

alias N = void(str, str);

// from, rel+card, to, str label=""
alias R = void(str, str, str);

// modifier, name, type
alias D = void(str, str, str);

Model update(Msg msg, Model m) {
    switch (msg) {
        case doIt(): m = !m;
    }
    return m;
}

void view(Model m) {
    classDiagram("animal", "Animals", (C class, R link, N note) {
        note("", "From Duck till Zebra");
        note("Duck", "can fly can help in debugging");

        if (m) {
            class("BOOOM", (D decl) {
                ;
            });
        }

        class("Animal", (D decl) { 
            decl("+", "int", "age");
            decl("+", "String", "gender");
            decl("+", "", "isMammal()");
            decl("+", "", "mate()");
        });

        class("Duck", (D decl) {
            decl("+", "String", "beakColor");
            decl("+", "", "swim()");
            decl("+", "", "quack");
        });
        
        class("Fish", (D decl) {
            decl("-", "int", "sizeInFeet");
            decl("-", "", "canEat()");
        });
        
        class("Zebra", (D decl) {
            decl("+", "bool", "is_wild");
            decl("+", "", "run()");
        });

        link("Animal", "\<|--", "Duck");
        link("Animal", "\<|--", "Fish");
        link("Animal", "\<|--", "Zebra");
    });

    button(onClick(doIt()), "Do it");
}


void classDiagram(str cdname, str title, CD cd) {
  str diagram = "---\n<title>\n---\nclassDiagram\n";
  

  void klass(str name, void(D) block) {
    diagram += "\tclass <name>{\n\t}\n";
    void decl(str modifier, str typ, str dname) {
        diagram += "\t<name> : <modifier><typ == "" ? "" : "<typ> "><dname>\n";
    }

    block(decl);
  }
  
  void relation(str from, str how, str to) {
    diagram += "\t<from> <how> <to>\n";
  }

  void note(str \for, str txt) {
    // todo: escape \n etc. in txt
    if (\for != "") {
        diagram += "\tnote for <\for> \"<txt>\"\n";
    }
    else {
        diagram += "\tnote \"<txt>\"\n";
    }
  }
  
  cd(klass, relation, note);

  mermaid(cdname, diagram);
}

