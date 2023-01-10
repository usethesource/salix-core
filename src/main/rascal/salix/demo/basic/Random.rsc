@license{
  Copyright (c) Tijs van der Storm <Centrum Wiskunde & Informatica>.
  All rights reserved.
  This file is licensed under the BSD 2-Clause License, which accompanies this project
  and is available under https://opensource.org/licenses/BSD-2-Clause.
}
@contributor{Tijs van der Storm - storm@cwi.nl - CWI}

module salix::demo::basic::Random

import salix::HTML;
import salix::Core;
import salix::App;
import salix::Index;


SalixApp[Model] randomApp(str id = "root") 
  = makeApp(id, init, withIndex("Random", id, view), update);

// Single
App[Model] randomWebApp() = webApp(randomApp(), |project://salix/src/main/rascal|);


alias Model = tuple[int dieFace];

Model init() = <1>;

data Msg = roll() | newFace(int face);

Model update(Msg msg, Model m) {
  switch (msg) {    
    case roll():  do(random(newFace, 1, 6)); 
    case newFace(int n): m.dieFace = n; 
  }
  return m;
}

void view(Model m) {
  button(onClick(roll()), "Roll");
  text(m.dieFace);
}
   
// Twice

App[TwiceModel] twiceWebApp()
  = webApp(
      makeApp("root", twiceInit, withIndex("Twice", "root", twiceView), twiceUpdate), 
      |project://salix/src/main/rascal|
    ); 

TwiceModel twiceInit() = twice(init(), init());

data TwiceModel = twice(Model model1, Model model2);

data Msg = sub1(Msg msg) | sub2(Msg msg);

TwiceModel twiceUpdate(Msg msg, TwiceModel m) {
  switch (msg) {
    case sub1(Msg s):
      m.model1 = mapCmds(sub1, s, m.model1, update);   
    case sub2(Msg s):
      m.model2 = mapCmds(sub2, s, m.model2, update);
  }
  return m;
}

void twiceView(TwiceModel m) {
  h2("Two times roll a die");
  mapView(sub1, m.model1, view);
  mapView(sub2, m.model2, view);
}


