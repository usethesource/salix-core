/**
 * Copyright (c) Tijs van der Storm <Centrum Wiskunde & Informatica>.
 * All rights reserved.
 *
 * This file is licensed under the BSD 2-Clause License, which accompanies this project
 * and is available under https://opensource.org/licenses/BSD-2-Clause.
 * 
 * Contributors:
 *  - Tijs van der Storm - storm@cwi.nl - CWI
 */

 class Salix {

    constructor() {
        this.busy = false;
    }
	
	makeURL(msg, data) {
	    let base = '/' + msg;
	    if (data) {
	    	base += '?' + new URLSearchParams(data).toString();
	    }
	    return base;
	}
	
	
	root() {
		return document.body;
	}

    makePayload(key, event) {
        return {
            key: key,
            value: event.target.value,
            checked: event.target.checked || false,
            type: event.type
        };
    }

    _do(key, event) {
        if (this.busy) {
            return; // ignore event
        }
        busy = true;
        document.body.style.cursor = 'progress';
        fetch(makeURL('_do', this.makePayload(key, event)))
            .then(response => response.json())
            .then(payload => {
                this.render(payload);
                document.body.style.cursor = 'auto';
                this.busy = false;   
            })
            .catch(error => {
                console.log(error);
                document.body.style.cursor = 'auto';
                this.busy = false;
            });
    }
	
	render(patch) {
		this.patchDOM(root(), patch, this.replacer(this.root().parentNode, this.root()));	
	}

	nodeType(node) {
		for (var type in node) { break; }
		return type;
	}


	patchThis(dom, edits, attach) {
		edits = edits || [];

		for (var i = 0; i < edits.length; i++) {
			var edit = edits[i];
			var type = nodeType(edit);

			switch (type) {
			
			case 'replace':
				build(edit[type].html, attach);

			case 'setText': 
				dom.nodeValue = edit[type].contents;
				break;			
				
			case 'removeNode': 
				dom.removeChild(dom.lastChild);
				break;
				
			case 'appendNode':
				build(edit[type].html, appender(dom));
				break;
				
			case 'setAttr': 
				dom.setAttribute(edit[type].name, edit[type].val);
				break;
							
			case 'removeAttr': 
				dom.removeAttribute(edit[type].name);
				break;
								
			default: 
				throw 'unsupported edit: ' + JSON.stringify(edit);
				
			}
		}
	}
	
	replacer(dom, oldKid) {
		return newKid => dom.replaceChild(newKid, oldKid);
	}
	
	appender(dom) {
		return kid => dom.appendChild(kid);
	}
	
	patchDOM(dom, tree, attach) {
		// if (dom.salix_native) {
		// 	dom.salix_native.patch(tree.patch.edits, attach)
		// } 
		// else {
		// 	patchThis(dom, tree.patch.edits, attach);
		// }
		
		// NB: (native || replace in edits) implies tree.patch.patches == []
		var patches = tree.patch.patches || [];
		for (var i = 0; i < patches.length; i++) {
			var p = patches[i];
			var kid = dom.childNodes[p.patch.pos];
			this.patchDOM(kid, p, replacer(dom, kid));
		}
		
	}
	
	
	build(vdom, attach) {
	    if (vdom.text) {
	        attach(document.createTextNode(vdom.text.contents));
	        return;
	    }

	    var type = this.nodeType(vdom);
	    var vattrs = vdom[type].attrs;

	    // if (vdom.native) {
	    // 	var native = vdom.native;
	    // 	builders[native.kind](attach, native.id, vattrs, vprops, vevents, native.extra);
	    // 	return;
	    // }

	    // an element
	    
	    var elt = vprops.namespace != undefined
	            ? document.createElementNS(vprops.namespace, vdom.element.tagName)
	            : document.createElement(vdom.element.tagName);
	    
	    this.updateAttrs(elt, vattrs);       
	    
	    attach(elt);
	    for (var i = 0; i < vdom.element.kids.length; i++) {
	    	build(vdom.element.kids[i], appender(elt));
	    }
	    
	}
	
    updateAttrs(elt, vattrs) {
		for (var k in vattrs) {
	        if (vattrs.hasOwnProperty(k)) {
	            elt.setAttribute(k, vattrs[k]);
	        }
	    }
	}

 }


