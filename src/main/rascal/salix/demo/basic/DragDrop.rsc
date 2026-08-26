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
import salix::Core;
import IO;

SalixApp[Model] dragDropApp(str id = "root") 
  = makeApp(id, init, withIndex("Drag and drop", id, view), update);

App[Model] dragDropWebApp()
  = webApp(dragDropApp(),|project://salix-core/src/main/rascal|);


alias Model = tuple[int zone];

Model init() = <-1>;

data Msg 
    = beingDragged(str id)
    | dropped(int zone, str id)
    | draggingOver()
    ;

Model update(Msg msg, Model m) {
  switch (msg) {
    case beingDragged(str x): println("being dragged: <x>");
    case dropped(int zone, str x): {
        println("this was dropped: <x> at <zone>");
        m.zone = zone;
    }
  }
  return m;
}

void draggableDiv(str x, void() block) {
    div(draggable("true"), onDragStart(beingDragged(x)),id(x), block);
}

void droppableDiv(int x, void() block) {
    div(style(("border": "solid")), onDragOver(draggingOver()), onDrop(partial(dropped, x)), block);
}

void view(Model m) {
    h2("My first drag and drop");
  
    draggableDiv("thing", () {
        p("this is draggable");
    });


    for (int i <- [1..4]) {
        droppableDiv(i, () {
            p("drop zone <i>");
            if (m.zone == i) {
                p("the thing is here");
            }
        });
    };
}

