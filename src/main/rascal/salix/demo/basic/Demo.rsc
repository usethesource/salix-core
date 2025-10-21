module salix::demo::basic::Demo

import salix::demo::basic::Counter;

import salix::App;
import salix::HTML;
import salix::Index;
import salix::Core;

////////////////////////////////////////////////////////////////////////
// Composing models and views
////////////////////////////////////////////////////////////////////////

alias TwiceModel = tuple[Model fst, Model snd];

TwiceModel twiceInit() = <init(), init()>;

data Msg
  = first(Msg msg)
  | second(Msg msg)
  ;

TwiceModel twiceUpdate(Msg msg, TwiceModel m) {
    switch (msg) {
        case first(Msg f): 
            m.fst = update(f, m.fst);
        case second(Msg f): 
            m.snd = update(f, m.snd);
            
    }
    return m;
}

void twiceView(TwiceModel m) {
    h2("Two counters");
    ul(() {
        li(() {
            mapView(first, m.fst, counterView);
        });
        li(() {
            mapView(second, m.snd, counterView);
        });
    });
}


App[TwiceModel] twiceWebApp(str id="demo")
  = webApp(makeApp(id, twiceInit, withIndex("Counters", id, twiceView
        , css=["https://cdn.simplecss.org/simple.min.css"]), twiceUpdate),
      |project://salix-core/src/main/rascal|);


////////////////////////////////////////////////////////////////////////
// Blending in control-flow
////////////////////////////////////////////////////////////////////////


alias NModel = tuple[list[Model] ns];

private int N = 10;

NModel nInit() = <[ init() | int _ <- [0..N] ]>;

data Msg = nth(int n, Msg msg);

NModel nUpdate(nth(int i, Msg msg), NModel m) {
    m.ns[i] = update(msg, m.ns[i]);
    return m;
}

void nView(NModel m) {
    h2("<N> counters");
    ul(() {
        for (int i <- [0..N]) {
            if (i % 2 == 0) {
                li(() {
                    boxed(() {
                        mapView(partial(nth, i), m.ns[i], counterView);
                    });
                });
            }
        }
    });
}

App[NModel] nWebApp(str id="demo")
  = webApp(makeApp(id, nInit, withIndex("Counters", id, nView
        , css=["https://cdn.simplecss.org/simple.min.css"]), nUpdate),
      |project://salix-core/src/main/rascal|);


//////////////////////////////////////////////////////////////////////////
// Higher order components
//////////////////////////////////////////////////////////////////////////

void boxed(void() block) = div(style(("border": "solid")), block);
