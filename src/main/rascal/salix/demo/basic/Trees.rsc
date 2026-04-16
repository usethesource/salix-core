module salix::demo::basic::Trees

import salix::Core;
import salix::util::Tree;
import salix::App;
import salix::Index;
import salix::HTML;

import IO;
import Set;
import List;
import String;
import util::FileSystem;

SalixApp[Model] treesApp(str id = "root") 
  = makeApp(id, init, withIndex("Trees", id, view, 
        inlineCss=TREE_CSS), update);



App[Model] treesWebApp()
  = webApp(treesApp(),|project://salix-core/src/main/rascal|);


alias Model = set[loc];

data Msg = toggle(loc file);

Model init() = {};

Model update(Msg msg, Model m) {
    switch (msg) {
        case toggle(loc f): {
            if (f in m) {
                m -= {f};
            }
            else {
                m += {f};
            }
            println(m);
        }
    }
    return m;
} 


void renderFS(file(loc l), Model m) {
    leaf(() {
        // span(onClick(toggle(l)), style(("font-weight": "bold" | l in m )), l.file);
        text(l.file);
        input(\type("checkbox"), checked(l in m), onClick(toggle(l)));
    });
}

void renderFS(directory(loc l, set[FileSystem] kids), Model m) {
    subTree(l.file, true, () {
        for (FileSystem fs <- sort(kids)) {
            renderFS(fs, m);
        }
    });
}

void view(Model m) {
    h2("Dealing with trees");
    tree(() {
        subTree("Giant planets", true, () {
            subTree("Gas giants", true, () {
                leaf("Jupiter");
                leaf("Saturn");
            });
        });
        subTree("Ice giants", true, () {
            leaf("Uranus");
            leaf("Neptune");
        });
    });

    h2("Filesystem");
    FileSystem fs = crawl(|cwd:///src/main/rascal|);
    tree(() {
        renderFS(fs, m);
    });
}

