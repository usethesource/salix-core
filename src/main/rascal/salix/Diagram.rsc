module salix::Diagram

import salix::HTML;
import salix::SVG;
import salix::Node;
import salix::Core;


/*
<script src="https://cdn.jsdelivr.net/npm/plain-draggable@2.5.14/plain-draggable.min.js"></script>
https://cdn.jsdelivr.net/npm/leader-line@1.0.7/leader-line.min.js

Plan:

- when drag dropped: send event signaling coordinates update
- svg/container simply contains html elements representing nodes
- and invisible elements indicating edges
   (can we use onload? to invoke leaderline)
- these are drawn by leader-line

edits of properties are simply salix.
node add/remove etc. trigger
*/

alias BB = tuple[int x, int y, int left, int right, int top, int bottom, int width, int height];


Attr onDragEnd(Msg(BB) f) = event("click", dragBB(f));

Hnd dragBB(Msg(BB) bb2msg) = handler("dragBB", encode(bb2msg));



alias NF = void(str, void());
alias EF = void(str, str, str);

void myDiagram() {
    diagram("my diagram", "100px", "100px", (NF nf, EF ef) {
        nf("node1", () {
            p("hello");
        });
        ef("node1", "node1", "an edge");
    });
}

alias Diagrammer = tuple[void(void(NF,EF)) diagram];

Diagrammer diagrammer(str name, str w, str h) {
    map[str, void()] myNodes = ();

    /*

    order by:
    - pre-existing
    - then new ones

    pass new ones into JS for edge drawing

    */

    void nf(str name, void() block) {
        myNodes[name] = () {
            foreignObject(id(name), style(("border": "solid")), 
                attr("onload", "new PlainDraggable(evt.target);"), block);
        };
        curNodes += {name};
        if (name notin oldNodes) {
            newNodes += {name};
        }
    }

    void ef(str from, str to, str label) {
        line(attr("from", from), attr("to", to), attr("label", label));
        curEdges += {<from, to>};
        if (<from, to> notin oldEdges) {
            newEdges += {<from, to>};
        }
    }

    void diagram(void(NF, EF) block) {
        svg(id(name), width(w), height(h), () {
            block(nf, ef);
        });

        delNodes = oldNodes - curNodes;
        delEdges = oldEdges - curEdges;
        for (str x <- oldNodes & curNodes) {
            ;
        }
    }

    return <diagram>;
}

void diagram(str name, str w, str h, void(NF, EF) block) {

    map[str, void()] myNodes = ();

    void nf(str name, void() block) {
        myNodes[name] = () {
            foreignObject(id(name), style(("border": "solid")), 
                attr("onload", "new PlainDraggable(evt.target);"), block);
        };
    }

    void ef(str from, str to, str label) {
        line(attr("from", from), attr("to", to), attr("label", label));
    }

    svg(id(name), width(w), height(h), () {
        block(nf, ef);
    });

    div(class("salix-alien"), id("<name>-alien")
        , attr("onclick", "$salix.registerAlien(\'<name>\', $chartpatch_<name>);"), () {
        script(src("https://cdn.jsdelivr.net/npm/plain-draggable@2.5.14/plain-draggable.min.js"));
        script(src("https://cdn.jsdelivr.net/npm/leader-line@1.0.7/leader-line.min.js"));
    });

}
