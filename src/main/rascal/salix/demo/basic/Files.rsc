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

alias Model = tuple[Maybe[FSHandle] theFile, list[list[FSChange]] changes, str selectedPath];

Model init() = <nothing(), [], "">;

data Msg 
    = fileOpened(FSHandle fh)
    | fileChange(list[FSChange] changes)
    | openFile()
    | fileSelected(str path)
    | submitted(map[str, value] formData)
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
    case fileSelected(str path):
        m.selectedPath = path;
    case submitted(map[str, value] formData):
        iprintln(formData);
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

  h2("Normal file inputs");

  input(\type("file"), onChange(fileSelected));

  div("<m.selectedPath>");


  form(onSubmit(submitted), () {
    p("Select file:");
    input(\type("file"), name("file"));
    br();
    input(\type("text"), name("something"));
    br();
    input(\type("number"), name("anumber"));
    br();
    input(\type("submit"));
  });

}

