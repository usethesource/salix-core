module salix::demo::basic::Files

import salix::App;
import salix::HTML;
import salix::Index;
import salix::Core;

import util::Maybe;
import IO;

SalixApp[Model] filesApp(str id = "root") 
  = makeApp(id, init, withIndex("Files", id, view), update, subs = subs);

App[Model] filesWebApp()
  = webApp(filesApp(),|project://salix-core/src/main/rascal|);


list[Sub] subs(Model m) = [observeFile(fileChange, "it") | just(FSHandle fh) := m.theFile ];

alias Model = tuple[Maybe[FSHandle] theFile, list[list[FSChange]] changes];

Model init() = <nothing(), []>;

data Msg 
    = fileOpened(FSHandle fh)
    | fileChange(list[FSChange] changes)
    | openFile()
    ;

Model update(Msg msg, Model m) {
  switch (msg) {
    case openFile(): do(pickFile(fileOpened, "it"));
    case fileOpened(FSHandle fh): {
        println(fh);
        m.theFile = just(fh);
    } 
    case fileChange(list[FSChange] cs):
        m.changes += [cs];
  }
  return m;
}

void view(Model m) {
  h2("Dealing with files");
  button(onClick(openFile()), "Open file...");
  div("<m.theFile>");

  ul(() {
    for (list[FSChange] cs <- m.changes) {
        li("<cs>");
    }
  });

}

