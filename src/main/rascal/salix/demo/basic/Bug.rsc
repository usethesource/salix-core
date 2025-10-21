module salix::demo::basic::Bug

import Content;

alias Model = tuple[real c];

alias App[&T] = Content;

alias DebugModel[&T]
  = tuple[int current, list[&T] models, list[Msg] messages, &T(Msg, &T) update]
  ;

data Msg;

App[DebugModel[&T]] debug(str appId,
                          &T() model, 
                          void(DebugModel[&T]) view,
                          &T(Msg, &T) upd,  
                          loc static) {
    throw "";
}
                        

App[DebugModel[Model]] debugCelsius() 
  = debug("celsius"
    , Model() { return <37.0>; }
    , void(DebugModel[Model] m) { ; }
    , Model(Msg x, Model m) { return m; }
    , |project://salix/src/main/rascal|);