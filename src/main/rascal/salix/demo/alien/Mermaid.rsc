module salix::demo::alien::Mermaid

import salix::Node;
import salix::Core;
import salix::HTML;
import salix::App;
import salix::Index;

import IO;
import List;
import lang::json::IO;

alias Model = bool;

Model init() = false;

SalixApp[Model] mermaidApp(str id = "alien") 
  = makeApp(id, init, withIndex("Mermaid", id, view), update);

App[Model] mermaidWebApp()
  = webApp(mermaidApp(), |project://salix/src/main/rascal|);


data Msg = doIt();

alias CD = void(C, R, N);

alias C = void(str, list[Attr], void(D));

alias N = void(str, str);

// from, rel+card, to, str label=""
alias R = void(str, str, str, list[Attr]);

// modifier, name, type
alias D = void(str, str, str, list[Attr]);

Model update(Msg msg, Model m) {
    switch (msg) {
        case doIt(): m = !m;
    }
    return m;
}

void view(Model m) {
    classDiagram("animal", "Animals", [], (C class, R link, N note) {
        note("", "From Duck till Zebra");
        note("Duck", "can fly can help in debugging");

        if (m) {
            class("BOOOM", [], (D decl) {
                ;
            });
        }

        class("Animal", [onClick(doIt())], (D decl) { 
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



void classDiagram(str cdname, str title, list[Attr] attrs, CD cd) {
  str diagram = "---\n<title>\n---\nclassDiagram\n";
  
  list[Attr] events = [];

  void klass(str name, list[Attr] cattrs, void(D) block) {
    diagram += "\tclass <name>{\n\t}\n";
    void decl(str modifier, str typ, str dname, list[Attr] dattrs) {
        diagram += "\t<name> : <modifier><typ == "" ? "" : "<typ> "><dname>\n";
    }

    block(decl);
    for (Attr a <- cattrs, a is event) {
        events += [a];
        diagram += "\tclick <name> call callback_<cdname>_<size(events)>() \"Click\"\n";
    }
  }
  
  void relation(str from, str how, str to, list[Attr] rattrs) {
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
  
  div(class("salix-alien"), id(cdname), attr("onclick", "$salix.registerAlien(\'<cdname>\', mermaidPatch_<cdname>);"), () {
    script("function mermaidPatch_<cdname>(patch) {
           '  console.log(JSON.stringify(patch));
           '  console.log(JSON.stringify(mermaid));
           '  document.getElementById(\'<cdname>_mermaid\').innerHTML = patch.patches[0].edits[0].content;
           '}
           '<for (int i <- [0..size(events)]) {>
           'function callback_<cdname>_<i+1>() { 
           '   $salix.send(<asJSON(events[i].handler)>);
           '}
           '<}>");
    script(\type("module"),
        "import mermaid from \'https://cdn.jsdelivr.net/npm/mermaid@9/dist/mermaid.esm.min.mjs\';
        'mermaid.initialize({ startOnLoad: true, securityLevel: \'loose\' });");
    pre(id("<cdname>_mermaid"), class("mermaid"), diagram);
  });
}

