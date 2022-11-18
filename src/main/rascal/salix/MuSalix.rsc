module salix::MuSalix

import lang::html::AST;
import Type;

// TODO: use lang::html::AST 
// reflective make in `build

data Msg;

data Attr 
  = attr(str name, value val)
  | null();

alias M2M = Msg(Msg);

alias State = tuple[
  list[list[HTMLElement]] stack, // render stack
  list[M2M] mapStack, // message mapping 
  map[int, list[value]] events, // event + active mappers encoding
  int next // event counter for current round.
];

State _state = <[], [], (), 0>;

void pushMap(M2M f) { _state.mapStack += [f]; }
void popMap() { _state.mapStack = _state.mapStack[0..-1]; }

&T with(M2M f, &T() block) {
  pushMap(f);
  &T ret = block();
  popMap();
  return ret;
}

void withv(Msg(Msg) f, void() block) {
  pushMap(f);
  block();
  popMap();
}

Attr event(str typ, value msg) {
  int key = _state.next;
  _state.events[key] = _state.mapStack + [msg];
  _state.next += 1;
  return attr("on<typ>", "$do(<key>)");
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
      ;
    }
    else { // else (if not Attr), render as text.
      add(text(vals[-1]));
    }
  }

  // construct the `elt` using the kids at the top of the stack
  // and any attributes in vals and add it to the parent's list of children.
  add(make(#HTMLElement, tagName, pop(), ( a.name: "<a.val>" | Attr a <- vals )));
}

void embed(str key, HTMLElement() block) {
  // do native stuff. 
}

HTMLElement render(&T model, void(&T) block) {
  push([]); 
  block(model);
  return pop()[0];
}

alias Page[&T] = tuple[void(&T) render];

Page[&T] index(str title, void(&T) view) {

}
