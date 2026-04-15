module salix::util::Tree

import salix::HTML;
import salix::Node;

import Node;

void tree(void() block) {
    ul(class("tree"), block);
}

Attr open(bool val) = val ? attr("open", "<val>") : null();

void subtree(str label, bool flag, void() block) {
    li(() {
        details(open(flag), () {
            summary(label);
            ul(block);
        });
    });
}

void leaf(value vals...) = li(vals);

void nodeTree(node n, str(node) getLabel, list[value](node) getKids) {
    tree(() {
        nodeTree_(n, getLabel, getKids);
    });
}

default void nodeTree_(value v, str(node) _, list[value](node) _) {
    //leaf(v);
}

void nodeTree_(node n, str(node) getLabel, list[value](node) getKids) {
    subtree(getLabel(n), true /* todo? */, () {
        for (value k <- getKids(n)) {
            nodeTree_(k, getLabel, getKids);
        }
    });
}

// https://iamkate.com/code/tree-views/
public str TREE_CSS = "
'.tree {
'  --spacing: 1.5rem;
'  --radius: 10px;
'}
'
'.tree li {
'  display: block;
'  position: relative;
'  padding-left: calc(2 * var(--spacing) - var(--radius) - 2px);
'}
'
'.tree ul {
'  margin-left: calc(var(--radius) - var(--spacing));
'  padding-left: 0;
'}
'
'.tree ul li {
'  border-left: 2px solid #ddd;
'}
'
'.tree ul li:last-child {
'  border-color: transparent;
'}
'
'.tree ul li::before {
'  content: \'\';
'  display: block;
'  position: absolute;
'  top: calc(var(--spacing) / -2);
'  left: -2px;
'  width: calc(var(--spacing) + 2px);
'  height: calc(var(--spacing) + 1px);
'  border: solid #ddd;
'  border-width: 0 0 2px 2px;
'}
'
'.tree summary {
'  display: block;
'  cursor: pointer;
'}
'
'.tree summary::marker,
'.tree summary::-webkit-details-marker {
'  display: none;
'}
'
'.tree summary:focus {
'  outline: none;
'}
'
'.tree summary:focus-visible {
'  outline: 1px dotted #000;
'}
'
'.tree li::after,
'.tree summary::before {
'  content: \'\';
'  display: block;
'  position: absolute;
'  top: calc(var(--spacing) / 2 - var(--radius));
'  left: calc(var(--spacing) - var(--radius) - 1px);
'  width: calc(2 * var(--radius));
'  height: calc(2 * var(--radius));
'  border-radius: 50%;
'  background: #ddd;
'}
'
'.tree summary::before {
'  z-index: 1;
'  background: #696 url(\'expand-collapse.svg\') 0 0;
'}
'
'.tree details[open] \> summary::before {
'  background-position: calc(-2 * var(--radius)) 0;
'}";

