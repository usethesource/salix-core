@license{
  Copyright (c) Tijs van der Storm <Centrum Wiskunde & Informatica>.
  All rights reserved.
  This file is licensed under the BSD 2-Clause License, which accompanies this project
  and is available under https://opensource.org/licenses/BSD-2-Clause.
}
@contributor{Tijs van der Storm - storm@cwi.nl - CWI}
module salix::demo::basic::Resize

import salix::HTML;
import salix::App;
import salix::Core;
import salix::Index;
import IO;

App[Model] resizeWebApp() = webApp(resizeApp(), |project://salix/src/main/rascal|);

SalixApp[Model] resizeApp(str id = "root") 
  = makeApp(id, init, withIndex("Resizable demo", id, view), update, subs=subs);

alias Model = tuple[bool resizable];

Model init() = <false>;

data Msg 
    = toggleResize()
    | resized(Resize res)
    ;

list[Sub] subs(Model m) = [ observeResize(resized, "thing") | m.resizable ];

Model update(Msg msg, Model t) {
  switch (msg) {
   case resized(<num i, num b>): println("Resized: <i>, <b>");
   case toggleResize(): t.resizable = !t.resizable;
  }
  return t;
}

void view(Model m) {
    h2("Observing resizes");
    map[str, str] resizable = m.resizable ? ("resize": "both", "overflow": "auto") : ();

    div(style(resizable + ("border": "solid", "width": "200px")), id("thing"), () {
        p("is this resizable? <m.resizable>");
    });
    
    button(onClick(toggleResize()), "Toggle resizable: <m.resizable>");  
}



