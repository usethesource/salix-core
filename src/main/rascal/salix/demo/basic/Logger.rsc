@license{
  Copyright (c) Tijs van der Storm <Centrum Wiskunde & Informatica>.
  All rights reserved.
  This file is licensed under the BSD 2-Clause License, which accompanies this project
  and is available under https://opensource.org/licenses/BSD-2-Clause.
}
@contributor{Tijs van der Storm - storm@cwi.nl - CWI}

module salix::demo::basic::Logger


import salix::HTML;
import salix::App;
import salix::Core;
import salix::Index;

App[Model] loggerWebApp(loc path) = webApp(loggerApp(path), |project://salix/src/main/rascal|);

SalixApp[Model] loggerApp(loc path, str id = "root") 
  = makeApp(id, Model() { return <path, false, []>; }, withIndex("Logger", id, view), update, subs=subs);

alias Model = tuple[loc path, bool running, list[FSChange] changes];


data Msg = changeDetected(list[FSChange] changes) | toggle();

list[Sub] subs(Model m) = [observeFS(changeDetected, <m.path.path, "directory">) | m.running ];

Model update(Msg msg, Model t) {
  switch (msg) {
   case changeDetected(list[FSChange] changes): t.changes += changes;
   case toggle(): t.running = !t.running;
  }
  return t;
}

void view(Model m) {
  h2("Logger with FS watching API (Chrome)");
  button(onClick(toggle()), "On/Off");

  

  for (FSChange c <- m.changes) {
    p("<c>");
  }
}



