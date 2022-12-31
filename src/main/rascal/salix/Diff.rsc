@license{
  Copyright (c) Tijs van der Storm <Centrum Wiskunde & Informatica>.
  All rights reserved.
  This file is licensed under the BSD 2-Clause License, which accompanies this project
  and is available under https://opensource.org/licenses/BSD-2-Clause.
}
@contributor{Tijs van der Storm - storm@cwi.nl - CWI}

module salix::Diff

import salix::Node;
import List;
import util::Math;
import IO;
import vis::Text;

//bool sanity(Node h1, Node h2) = apply(diff(h1, h2), h1) == h2;

@doc{Patch are positioned at pos in the parent element where
they originate. This allows sparse/shallow traversal during
patching: not all kids of an element will have changes, so
patches for those kids will not end up in the patch at all.
At each level a list of edits can be applied.
A root patch will have pos = - 1.}
data Patch
  = patch(int pos, list[Patch] patches = [], list[Edit] edits = [])
  ;

data EditType
  = setText() | replace() | removeNode() | appendNode()
  | setAttr() | setProp() | setEvent() | setExtra()
  | removeAttr() | removeProp() | removeEvent() | removeExtra()
  ;

data Node = none();
data Hnd = null();

data Edit
  = edit(EditType \type, str contents="", Node html=none(), Hnd handler=null(),
        str name="", str val="", value extra=());

// nodes at this level are always assumed to be <html> nodes,
// however, we only diff their bodies. This is (unfortunately)
// need because some extensions (charts/treeview) modify the
// head of a document in ways we cannot know about.
Patch diff(Node old, Node new) {
  // println("OLD:");
  // println(prettyNode(old));
  // println("NEW:");
  // println(prettyNode(new));
  
  Patch p = diff(old.kids[1], new.kids[1], -1);
  // println(prettyNode(p));
  return p;
} 

Patch diff(Node old, Node new, int idx) {
  if (old.\type is empty) {
    return patch(idx, edits = [edit(replace(), html=new)]);
  }

  if (old.\type != new.\type) {
    return patch(idx, edits = [edit(replace(), html=new)]);
  }
  
  if (old.\type is txt, new.\type is txt) {
    if (old.contents != new.contents) {
      return patch(idx, edits = [edit(setText(), contents=new.contents)]);
    }
    return patch(idx);
  }
  
  // if (old.\type is native, new.\type is native) {
  //   edits = diffMap(old.props, new.props, setProp(), removeProp())
  //     + diffMap(old.attrs, new.attrs, setAttr(), removeAttr())
  //     + diffEventMap(old.events, new.events);
  //   if (old.id != new.id) {
  //     edits += edit(setProp(), name="id", val=new.id);
  //   }
  //   return patch(idx, edits = edits);  
  // }
  
  if (old.\type is element, old.tagName != new.tagName) {
    return patch(idx, edits = [edit(replace(), html=new)]);
  }

  // same kind of elements
  edits = diffMap(old.attrs, new.attrs, setAttr(), removeAttr())
    + diffMap(old.props, new.props, setProp(), removeProp())  
    + diffEventMap(old.events, new.events)
    + diffExtra(old.extra, new.extra);
  
  return diffKids(old.kids, new.kids, patch(idx, edits = edits));
}

Patch diffKids(list[Node] oldKids, list[Node] newKids, Patch myPatch) {
  oldLen = size(oldKids);
  newLen = size(newKids);
  
  for (int i <- [0..min(oldLen, newLen)]) {
    Patch p = diff(oldKids[i], newKids[i], i);
    if (p.edits != [] || p.patches != []) {
      myPatch.patches += [p];
    }
  }
  
  myPatch.edits += oldLen <= newLen
      ? [ edit(appendNode(),html=newKids[i]) | int i <- [oldLen..newLen] ]
      : [ edit(removeNode()) | int _ <- [newLen..oldLen] ];
  
  return myPatch;
}


// something goes wrong with parameterized function type and binding them to constructors.
list[Edit] diffEventMap(map[str, Hnd] old, map[str, Hnd] new) {
  edits = for (str k <- old) {
    if (k in new) {
      if (new[k] != old[k]) {
        append edit(setEvent(),name=k, handler=new[k]);
      }
    }
    else {
      append edit(removeEvent(), name=k);
    }
  }
  edits += [ edit(setEvent(), name=k, handler=new[k]) | k <- new, k notin old ];
  return edits;
} 


list[Edit] diffMap(map[str, str] old, map[str, str] new, EditType upd, EditType del) {
  edits = for (str k <- old) {
    if (k in new) {
      if (new[k] != old[k]) {
        append edit(upd, name=k, val=new[k]);
      }
    }
    else {
      append edit(del, name=k);
    }
  }
  edits += [ edit(upd, name=k, val=new[k]) | k <- new, k notin old ];
  return edits;
} 

list[Edit] diffExtra(map[str, value] old, map[str, value] new) {
  edits = for (str k <- old) {
    if (k in new) {
      if (new[k] != old[k]) {
        append edit(setExtra(), name=k, extra=new[k]);
      }
    }
    else {
      append edit(removeExtra(), name=k);
    }
  }
  edits += [ edit(setExtra(), name=k, extra=new[k]) | k <- new, k notin old ];
  return edits;
} 
