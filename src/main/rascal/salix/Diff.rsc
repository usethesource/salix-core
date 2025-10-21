@license{
  Copyright (c) Tijs van der Storm <Centrum Wiskunde & Informatica>.
  All rights reserved.
  This file is licensed under the BSD 2-Clause License, which accompanies this project
  and is available under https://opensource.org/licenses/BSD-2-Clause.
}
@contributor{Tijs van der Storm - storm@cwi.nl - CWI}

module salix::Diff

import salix::Node;
import salix::util::LCS;
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
  = setText() | replace() | removeNode() | appendNode() | insertNode()
  | setAttr() | setProp() | setEvent() | setExtra()
  | removeAttr() | removeProp() | removeEvent() | removeExtra()
  ;

data Node = none();
data Hnd = null();

data Edit
  = edit(EditType \type, str contents="", Node html=none(), Hnd handler=null(),
        str name="", str val="", int pos=-1, value extra=());

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

bool nodeEq(Node x, Node y) {
  if (x.\type != y.\type) {
    return false;
  }

  if (x.\type is element) {
    if (x.tagName == y.tagName) {
      return true;
    }
  }
  
  if (x.\type is txt) {
    if (x.contents == y.contents) {
      return true;
    }
  }
  return false;
}

Patch diff(Node old, Node new, int idx) {
  //println("diffing: <old> against <new>");

  // Patch p = patch(idx);

  // if (!nodeEq(old, new)) {
  //   p.edits=[edit(replace(), html=new)];
  //   return p;
  // }

  // // they're nodeEq now, so if one of them is element, the other is too
  // if (old.\type is element) {
  //   p.edits = diffMap(old.attrs, new.attrs, setAttr(), removeAttr())
  //     + diffMap(old.props, new.props, setProp(), removeProp())  
  //     + diffEventMap(old.events, new.events)
  //     + diffExtra(old.extra, new.extra);
  // }

  // list[Node] oldKids = old.kids;
  // list[Node] newKids = new.kids;
  // LCSMatrix mx = lcsMatrix(oldKids, newKids, nodeEq);
  // list[Diff[Node]] d = getDiff(mx, oldKids, newKids, size(oldKids), size(newKids), nodeEq);

  // iprintln(d);

  // for (int i <- [0..size(d)]) {
  //   switch (d[i]) {
  //     case same(Node n1, Node n2): {
  //       Patch p2 = diff(n1, n2, i);
  //       if (p2.patches != [] || p2.edits != []) {
  //         p.patches += [p2];
  //       }
  //     }
  //     case add(Node n, int pos):
  //       p.edits += [edit(insertNode(), html=n, pos=pos)];
  //     case remove(Node _, int pos):
  //       p.edits += [edit(removeNode(), pos=pos)];
  //   }
  // }

  // return p;


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

bool isAlien(Node nk) = nk.\type is element
  && nk.tagName == "div"
  && "class" in nk.attrs
  && nk.attrs["class"] == "salix-alien";

str getId(Node n) = n.attrs["id"];

Patch diffKids(list[Node] oldKids, list[Node] newKids, Patch myPatch) {
  oldLen = size(oldKids);
  newLen = size(newKids);
  
  for (int i <- [0..min(oldLen, newLen)]) {
    Node ok = oldKids[i];
    Node nk = newKids[i];


    // aliens are not robust to diffing their internals
    // so if an existing alien moves or a new alien is created
    // we don't patch it but (re)build it from scratch;
    // this only happens if newKid is an alien
    // and oldKid is not. (the reverse case is not important:
    // in this case the the old alien would be "destroyed"
    // by patching it into the new (non-alien) node).
    // if both old and new are alien *and* have the same 
    // the custom patch algorithm handles the things
    // (covered by the else branch below).

    if (!isAlien(ok), isAlien(nk)) {
      myPatch.patches += [patch(i, edits=[edit(replace(), html=nk)])];
    }
    // else if (isAlien(ok), isAlien(nk), getId(ok) != getId(nk)) {
    //   myPatch.patches += [patch(i, edits=[edit(replace(), html=nk)])];
    // }
    else {
      Patch p = diff(oldKids[i], newKids[i], i);

      if (p.edits != [] || p.patches != []) {
        myPatch.patches += [p];
      }
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
