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
    | dropped(int zone, DropXY dxy)
    | draggingOver(int zone)
    ;


Model update(Msg msg, Model m) {
  switch (msg) {
    case beingDragged(str x): println("being dragged: <x>");
    case draggingOver(int zone): println("entering zone: <zone>");
    case dropped(int zone, DropXY dxy): {
        println("this was dropped: <dxy.id> at <zone>");
        println("at x=<dxy.clientX>, y=<dxy.clientY>");
        m.zone = zone;
    }
  }
  return m;
}

void view(Model m) {
    h2("My first drag and drop");

    div(onDrag("thing", beingDragged), () {
        p("this is draggable");
    });
  
    for (int i <- [1..4]) {
        Msg(DropXY) f = partial(dropped, i);
        div(style(("border": "solid")), onDrop(draggingOver(i), f), () {
            p("drop zone <i>");
            if (m.zone == i) {
                p("the thing is here");
            }
        });
    }
}

