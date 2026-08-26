@license{
  Copyright (c) Tijs van der Storm <Centrum Wiskunde & Informatica>.
  All rights reserved.
  This file is licensed under the BSD 2-Clause License, which accompanies this project
  and is available under https://opensource.org/licenses/BSD-2-Clause.
}
@contributor{Tijs van der Storm - storm@cwi.nl - CWI}
module salix::demo::basic::DragDrop

import salix::App;
import salix::HTML;
import salix::Index;
import IO;

SalixApp[Model] dragDropApp(str id = "root") 
  = makeApp(id, init, withIndex("Drag and drop", id, view), update);

App[Model] dragDropWebApp()
  = webApp(dragDropApp(),|project://salix-core/src/main/rascal|);


alias Model = tuple[int count];

Model init() = <0>;

data Msg 
    = beingDragged()
    | dropped(str id)
    | draggingOver()
    ;

Model update(Msg msg, Model m) {
  switch (msg) {
    case beingDragged(): println("being dragged");
    case dropped(str x): println("this was dropped: <x>");
  }
  return m;
}

void view(Model m) {
  h2("My first drag and drop");
  
  div(draggable("true"), onDragStart(beingDragged()), id("thing"), () {
    p("this is draggable");
  });

  div(style(("border": "solid")), onDragOver(draggingOver()), onDrop(dropped), () {
    p("drop zone");
  });
}

