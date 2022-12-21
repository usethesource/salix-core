module salix::demo::alien::FlowChart

import salix::Core;
import salix::HTML;
import salix::App;
import salix::Index;

import salix::demo::alien::Mermaid;

import String;
import Node;

alias Model = bool;

Model init() = false;

SalixApp[Model] flowChartApp(str id = "alien") 
  = makeApp(id, init, withIndex("FlowChart", id, view), update);

App[Model] flowChartWebApp()
  = webApp(flowChartApp(), |project://salix/src/main/rascal|);


data Msg = doIt();


alias S = void(str, void(N, E)); // subgraphs; should be self recursive on FL; does not pass type checker.

alias FL = void(N, E, S);

alias N = void(Shape, str, str);

alias E = void(str, str, str, str);


Model update(Msg msg, Model m) {
    switch (msg) {
        case doIt(): m = !m;
    }
    return m;
}

data Dir
  = td() | bt() | lr() | rl();

data Shape
  = square() | round() | stadium() | sub() | cyl() | circ() | asym() | rhombus()
  | hexa() | paral() | altParal() | trap() | circc();

str label2shape(Shape shape, str txt) {
    txt = "\"<txt>\"";
    switch (shape) {
        case square(): return "[<txt>]";
        case round(): return "(<txt>)";
        case stadium(): return "([<txt>])";
        case sub(): return "[[<txt>]]";
        case cyl(): return "[(<txt>)]";
        case circ(): return "((<txt>))";
        case asym(): return "\><txt>]";
        case rhombus(): return "{<txt>}";
        case hexa(): return "{{<txt>}}";
        case paral(): return "[/<txt>/]";
        case altParal(): return "[\\<txt>\\]";
        case trap(): return "[\\<txt>/]";
        case circc(): return "(((<txt>)))";
    }
    throw "unknown shape: <shape>";
}

void view(Model m) {

    flowChart("subs", "Three graphs", Dir::td(), (N n, E e, S sub) {
        if (m) {
            n(circc(), "c1", "dit is c1");
        }
        e("c1", "--\>", "a2", "");
        sub("one", (N n, E e) {
            e("a1", "--\>", "a2", "hallo");
        });
        sub("two", (N n, E e) {
            e("b1", "--\>", "b2", "ik ben");
        });
        sub("three", (N n, E e) {
            e("c1", "--\>", "c2", "een label");
        });
    });

    button(onClick(doIt()), "do it");
}

void flowChart(str flname, str title, Dir dir, FL block) {
  str diagram = "---\n<title>\n---\nflowchart <toUpperCase(getName(dir))>\n";

  void n(Shape shape, str id, str txt) {
    diagram += "\t<id><label2shape(shape, txt)>\n";
  }

  void e(str from, str via, str to, str label) {
    str l = label != "" ? "|<label>|" : "";
    diagram += "\t<from> <via> <l><to>\n";
  }

  void subgraph(str sname, void(N, E) sub) {
    diagram += "\tsubgraph <sname>\n";
    sub(n, e);
    diagram += "\tend\n";
  }

  block(n, e, subgraph);

  mermaid(flname, diagram);

}
