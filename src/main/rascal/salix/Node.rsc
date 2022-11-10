@license{
  Copyright (c) Tijs van der Storm <Centrum Wiskunde & Informatica>.
  All rights reserved.
  This file is licensed under the BSD 2-Clause License, which accompanies this project
  and is available under https://opensource.org/licenses/BSD-2-Clause.
}
@contributor{Tijs van der Storm - storm@cwi.nl - CWI}

module salix::Node

import List;

// TODO: make attrs/props/events kw params to save memory
// TODO: make attrs map[str, Attribute] to deal with namespaces

@doc{The basic Html node type, defining constructors for
elements, text nodes, and native nodes (which are managed in js).}
data Node
  = element(str tagName, list[Node] kids, map[str, str] attrs, map[str, str] props, map[str, Hnd] events)
  | native(str kind, str id, map[str,str] attrs, map[str, str] props, map[str, Hnd] events, map[str,value] extra = ())
  | txt(str contents)
  | empty() 
  ;  

@doc{An abstract type for represent event handlers.}
data Hnd;  

@doc{Generalized attributes to be produced by explicit attribute construction
functions (such as class(str), onClick(Msg), or \value(str)).
null() acts as a zero element and is always ignored.}
data Attr
  = attr(str name, str val)
  | prop(str name, str val)
  | event(str name, Hnd handler, map[str,str] options = ())
  | null()
  ;

@doc{Helper functions to partition list of Attrs into attrs, props and events} 
map[str,str] attrsOf(list[Attr] attrs) = ( k: v | attr(str k, str v) <- attrs ) 
                                       + ((attr("class", _) <- attrs) ? ( "class" : "<for (attr("class", str v) <- attrs) {><v> <}>"[..-1])
                                                                      : ())
                                       ;

map[str,str] propsOf(list[Attr] attrs) = ( k: v | prop(str k, str v) <- attrs );

map[str,Hnd] eventsOf(list[Attr] attrs) = ( k: v | event(str k, Hnd v) <- attrs );



Node bareHtml(Node n) {
  return visit(n) {
  	case element(str t, list[Node] kids, map[str,str] as, _, _) => element(t, kids, as, (), ())
  	case native(_, _, _, _, _, extra = _) => element("div", [], (), (), ()) 
  }
}

str toHtml(element(str n, list[Node] kids, map[str, str] attrs, _ , _)) 
  = "\<<n> <attrs2str(attrs)>\><kids2html(kids)>\</<n>\>";

str toHtml(txt(str s)) = s;
  
str kids2html(list[Node] kids)
  = ( "" | it + toHtml(k) | Node k <- kids );

str attrs2str(map[str, str] attrs)
  = intercalate(" ", [ "<a>=\"<attrs[a]>\"" | str a <- attrs ]);  
