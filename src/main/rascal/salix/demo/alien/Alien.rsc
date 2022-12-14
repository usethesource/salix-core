@license{
  Copyright (c) Tijs van der Storm <Centrum Wiskunde & Informatica>.
  All rights reserved.
  This file is licensed under the BSD 2-Clause License, which accompanies this project
  and is available under https://opensource.org/licenses/BSD-2-Clause.
}
@contributor{Tijs van der Storm - storm@cwi.nl - CWI}

module salix::demo::alien::Alien

import salix::App;
import salix::HTML;
import salix::Node;
import salix::Core;
import salix::Index;

import Set;
import util::Math;

alias Model = rel[str, str];

Model init() = {<"a", "b">, <"b", "c">, <"c", "a">};

SalixApp[Model] alienApp(str id = "alien") 
  = makeApp(id, init, withIndex("Alien", id, view), update);

App[Model] alienWebApp()
  = webApp(alienApp(), |project://salix/src/main/rascal|);

data Msg = changeIt();

Model update(Msg msg, Model m) {
  switch (msg) {
    case changeIt(): {
      int i = arbInt(size(m));
      tuple[str,str] edge = toList(m)[i];
      m += {<edge[1], "a<i>">};
    }
  }
  return m;
}

str initCode(str key) = 
    "var cy_<key> = cytoscape({container: document.getElementById(\'cyto_<key>\')});
    'event.salix.registerAlien(\'<key>\', (edits) =\> cytopatch(cy_<key>, event.salix, edits)); 
    '";

void cyto(str name, rel[str, str] graph) {
  withExtra(("graph": graph), () {
    div(class("salix-alien"), id(name), attr("onclick", initCode(name)), () {
        script(src("https://cdn.jsdelivr.net/npm/cytoscape@3.23.0/dist/cytoscape.umd.js"));
        script("function cytopatch(cy, salix, edits) {
               '  console.log(\'patching cyto \' + JSON.stringify(edits));
               '  var g = {elements: []};
               '  for (let i = 0; i \< edits[0].extra.length; i++) {
               '    let a = edits[0].extra[i][0];
               '    let b = edits[0].extra[i][1];
               '    g.elements.push({data: {id: a}});
               '    g.elements.push({data: {id: b}});
               '    g.elements.push({data: {id: a + b, source: a, target: b}})
               '  }
               '  g.style = [{selector: \'node\', style: {label: \'data(id)\'}}];
               '  console.log(JSON.stringify(g));
               '  cy.json(g);
               '  cy.layout({name: \'random\'}).run();
               '}");
        div(style(("width": "200px", "height": "200px")), id("cyto_" + name));
    });
  });
}


void view(Model m) {
  h2("Alien elements in Salix");
  cyto("mygraph", m);
  button(onClick(changeIt()), "Change it");
}

