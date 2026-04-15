module salix::demo::basic::Trees

import salix::Core;
import salix::util::Tree;
import salix::App;
import salix::Index;
import salix::HTML;

import Set;
import List;
import String;
import util::FileSystem;

SalixApp[Model] treesApp(str id = "root") 
  = makeApp(id, init, withIndex("Trees", id, view, 
        inlineCss=TREE_CSS), update);



App[Model] treesWebApp()
  = webApp(treesApp(),|project://salix-core/src/main/rascal|);


alias Model = str;

Model init() = "";

Model update(Msg msg, Model m) = m;

void view(Model m) {
    h2("Dealing with trees");
    tree(() {
        subtree("Giant planets", true, () {
            subtree("Gas giants", true, () {
                leaf("Jupiter");
                leaf("Saturn");
            });
        });
        subtree("Ice giants", true, () {
            leaf("Uranus");
            leaf("Neptune");
        });
    });

    h2("Filesystem");
    FileSystem fs = crawl(|cwd:///src/main/rascal|);
    nodeTree(fs, str(FileSystem f) { return split("/", f.l.path)[-1]; },
        list[value](FileSystem f) { 
            return f is directory ? sort(f.children) : []; });
}

