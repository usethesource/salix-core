module salix::demo::alien::Mermaid

import salix::Node;
import salix::Core;
import salix::HTML;

alias CD = void(C, R, N);

alias C = void(str, list[Attr], void(D));

alias N = void(str, str);

// from, rel+card, to, str label=""
alias R = void(str, str, str, list[Attr]);

// modifier, name, type
alias D = void(str, str, str, list[Attr]);


void example() {
    classDiagram("animal", "Animals", [], (C class, R link, N note) {
        note("", "From Duck till Zebra");
        note("Duck", "can fly can help in debugging");

        class("Animal", [], (D decl) {
            decl("+", "int", "age", []);
            decl("+", "String", "gender", []);
            decl("+", "", "isMammal()", []);
            decl("+", "", "mate()", []);
        });

        class("Duck", [], (D decl) {
            decl("+", "String", "beakColor", []);
            decl("+", "", "swim()", []);
            decl("+", "", "quack", []);
        });
        
        class("Fish", [], (D decl) {
            decl("-", "int", "sizeInFeet", []);
            decl("-", "", "canEat()", []);
        });
        
        class("Zebra", [], (D decl) {
            decl("+", "bool", "is_wild", []);
            decl("+", "", "run()", []);
        });

        link("Animal", "\<|--", "Duck", []);
        link("Animal", "\<|--", "Fish", []);
        link("Animal", "\<|--", "Zebra", []);
    });
}


void classDiagram(str name, str title, list[Attr] attrs, CD cd) {
  str diagram = "---\n<title>\n---\n";
  
  void klass(str name, list[Attr] cattrs, void(D) block) {
    void decl(str modifier, str typ, str dname, list[Attr] dattrs) {
        diagram += "<name> : <modifier><typ> <dname>\n";
    }
    block(decl);
  }
  
  void relation(str from, str how, str to, list[Attr] rattrs) {
    diagram += "<from> <how> <to>\n";
  }

  void note(str \for, str txt) {
    // todo: escape \n etc. in txt
    diagram += "note for <\for> \"<txt>\"\n";
  }
  
  cd(klass, relation, note);
  
  div(class("salix-alien"), id(name), attr("onclick", "event.salix.registerAlien();"), () {
    script(\type("module"),
        "import mermaid from \'https://cdn.jsdelivr.net/npm/mermaid@9/dist/mermaid.esm.min.mjs\';
        'mermaid.initialize({ startOnLoad: true });");
    pre(class("mermaid"), diagram);
  });
}

