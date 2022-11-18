module salix::MuSalix

/*

Simplified architecture (much!)
No support for commands/subscriptions (yet)
*/

import lang::html::AST;
import Type;
import List;

data Msg;

data Attr 
  = attr(str name, value val)
  | null();

alias M2M = Msg(Msg);

alias State = tuple[
  list[list[HTMLElement]] stack, // render stack
  list[M2M] mapStack, // message mapping (for nesting views)
  map[int, list[value]] events, // event + active mappers encoding
  int next // event counter for current round.
];

State _state = <[], [], (), 0>;

private void reset() {
  _state = <[], [], (), 0>;
}

void pushMap(M2M f) { _state.mapStack += [f]; }

void popMap() { _state.mapStack = _state.mapStack[0..-1]; }

void with(M2M f, void() block) {
  pushMap(f);
  block();
  popMap();
}

alias Info = map[str, value];

alias Parser = Msg(Info);

private int record(Parser msg) {
  int key = _state.next;
  _state.events[key] = _state.mapStack + [msg];
  _state.next += 1;
  return key;
}

Attr event(str typ, Parser msg) {
  int key = record(msg);
  return attr("on<typ>", "$do(<key>, event);");
}

Msg handle(int key, Info info) {
  list[value] fs = _state.events[key];
  if (Parser p := fs[-1]) {
    return ( p(info) | m2m(it) | int i <- [size(fs) - 2..-1], M2M m2m := fs[i] );
  }  
  throw "last element of event stack is not a parser but <fs[-1]>";
}

private void add(HTMLElement h) = push(pop() + [h]);

public void addNode(HTMLElement h) = add(h);

private void push(list[HTMLElement] l) { _state.stack += [l]; }

private list[HTMLElement] top() = _state.stack[-1];

private list[HTMLElement] pop() {
  list[HTMLElement] elts = top();
  _state.stack = _state.stack[..-1];
  return elts;
}

void build(list[value] vals, str tagName) {
  push([]); // start a new scope for this element's children
  
  if (vals != []) { 
    if (void() block := vals[-1]) { // argument block is just called
      block();
    }
    else if (HTMLElement h := vals[-1]) { // a computed node is simply added
      add(h);
    }
    else if (Attr _ := vals[-1]) {
      ; // deal with those later
    }
    else { // else (if not Attr), render as text.
      add(text("<vals[-1]>"));
    }
  }

  // construct the `elt` using the kids at the top of the stack
  // and any attributes in vals and add it to the parent's list of children.
  add(make(#HTMLElement, tagName, pop(), ( a.name: "<a.val>" | Attr a <- vals )));
}

// void embed(str key, HTMLElement() block) {
//   // do native stuff. 
// }

HTMLElement render(&T model, void(&T) block) {
  reset(); // start with clean slate
  push([]); 
  block(model);
  return pop()[0];
}

alias Page[&T] = tuple[HTMLElement(&T) render];

// Page[&T] index(str title, void(&T) view) {

// }


