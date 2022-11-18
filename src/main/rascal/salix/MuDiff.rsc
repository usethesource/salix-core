module salix::MuDiff

import util::Math;
import List;
import Node;
import lang::html::AST;

data Patch
  = patch(int pos, list[Patch] patches = [], list[Edit] edits = [])
  ;

@doc{Primitive edit constructs.}
data Edit
  = setText(str contents)
  | replace(HTMLElement html)
  | removeNode() 
  | appendNode(HTMLElement html) 
  | setAttr(str name, str val)
  | removeAttr(str name)
  ; 


Patch diff(HTMLElement old, HTMLElement new, int idx) {
  if (getName(old) != getName(new)) {
    return patch(idx, edits = [replace(new)]);
  }
  
  if (old is text, new is text) {
    if (old.contents != new.contents) {
      return patch(idx, edits = [setText(new.contents)]);
    }
    return patch(idx);
  }
  
  // same kind of elements
  edits = diffMap(getKeywordParameters(old), getKeywordParameters(new), setAttr, removeAttr);  
  
  return diffKids(old.elems, new.elems, patch(idx, edits = edits));
}

Patch diffKids(list[HTMLElement] oldKids, list[HTMLElement] newKids, Patch myPatch) {
  oldLen = size(oldKids);
  newLen = size(newKids);
  
  for (int i <- [0..min(oldLen, newLen)]) {
    Patch p = diff(oldKids[i], newKids[i], i);
    if (p.edits != [] || p.patches != []) {
      myPatch.patches += [p];
    }
  }
  
  myPatch.edits += oldLen <= newLen
      ? [ appendNode(newKids[i]) | int i <- [oldLen..newLen] ]
      : [ removeNode() | int _ <- [newLen..oldLen] ];
  
  return myPatch;
}


list[Edit] diffMap(map[str, value] old, map[str, value] new, Edit(str, &T) upd, Edit(str) del) {
  edits = for (str k <- old) {
    if (k in new) {
      if (new[k] != old[k]) {
        append upd(k, new[k]);
      }
    }
    else {
      append del(k);
    }
  }
  edits += [ upd(k, new[k]) | k <- new, k notin old ];
  return edits;
} 

@doc{Applying a patch to an Node node; only for testing.}
HTMLElement apply(Patch p, HTMLElement html) {
  assert any(Edit e <- p.edits, e is replace) ==> p.patches == [];
  
  html = ( html | apply(e, it) | Edit e <- p.edits );
  
  assert p.patches != [] ==> html has elems;  

  for (Patch p <- p.patches) {
    assert p.pos < size(html.elems);
    html.elems[p.pos] = apply(p, html.elems[p.pos]);
  }

  return html;
}
  
HTMLElement apply(setText(str _txt), text(_)) = text(_txt);

HTMLElement apply(replace(HTMLElement html), _) = html;

HTMLElement apply(appendNode(HTMLElement html), HTMLElement e) = e[elems=e.elems + [html]];

HTMLElement apply(removeNode(), HTMLElement e) = e[elems = e.elems[..-1]];

HTMLElement apply(removeAttr(str name), HTMLElement html) 
  = setKeywordParameters(html, getKeywordParameters(html) - (name: 0));

HTMLElement apply(setAttr(str name, str val), HTMLElement html) 
  = setKeywordParameters(html, getKeywordParameters(html) + (name: val));

