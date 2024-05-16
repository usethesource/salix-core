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

	constructor (appId, host) {

		// alien elements (identified by class) are not managed by salix's
		// patch machinery, and "booted" through the ALIEN_EVENT
		this.ALIEN_CLASS = 'salix-alien';
		this.ALIEN_EVENT = 'click';

		this.appId = appId;
		this.host = host;

		// functions which simulate "patch" for alien dom elements.
		// indexed by id attr of the dom node (required)
		this.theAliens = {};

		// currently active subscriptions
		this.subscriptions = {};
		
		// signals whether a new rendering is requested
		// during that time, we won't process events
		this.renderRequested = true;
		
		// queue of pending commands, events, subscription events
		this.queue = [];


		// Basic library of commands and subscriptions
		// can be extended by 'natives'.
		// TODO: this seems way too complex...
		
		this.Subscriptions = {
			timeEvery: (h, args) => {
				var timer = setInterval(() => {
					var data = {type: 'integer', value: (new Date().getTime() / 1000) | 0};
					this.handle({message: this.makeMessage(h, data)}); 
				}, args.interval);
				return () => clearInterval(timer);
			}
		};

		this.Commands = {
				random: args => {
					var to = args.to;
					var from = args.from;
					var random = Math.floor(Math.random() * (to - from + 1)) + from;
					return {type: 'integer', value: random};
				},
				setFocus: args => {
					var id = args.id;
					document.getElementById(id).focus();
					return {type: 'nothing'};
				}
		};

		this.Decoders = {
			succeed: function (args) {
				return function (e) { return {type: 'nothing'}; };
			},

			targetValue: function (args) {
				return function (e) { return {type: 'string', value: e.target.value}; };
			},

			targetInt: function (args) {
				return function (e) { return {type: 'integer', value: e.target.value}; };
			},

			targetReal: function (args) {
				return function (e) { return {type: 'real', value: e.target.value}; };
			},

			targetValues: function (args) {
				return function (e) { return {type: 'values', value1: e.value1, value2: e.value2}; };
			},
			
			targetChecked: function (args) {
				return function (e) { return {type: 'boolean', value: e.target.checked}; };
			},

			mouseXY: function(args) {
				return function (e) { return {type: 'mouseXY',
					clientX: e.clientX,
					clientY: e.clientY,
					movementX: e.movementX,
					movementY: e.movementY,
					offsetX: e.offsetX,
					offsetY: e.offsetY,
					pageX: e.pageX,
					pageY: e.pageY,
					screenX: e.screenX,
					screenY: e.screenY}			
				}
			},

			jsonPayload: function (args) {
				return function (obj) { return {type: 'json', payload: obj}; };
			},
			
			keyCode: function (args) {
				return function (e) {
					return {type: 'integer', value: e.keyCode};
				};
			}
		};	
	}

	makeURL(msg, data) {
	    var base = (this.host || '') + '/' + this.appId + '/' + msg;
	    if (data) {
			let str = JSON.stringify(data);
	    	base += '?payload=' + encodeURIComponent(str);
	    }
		
	    return base;
	}
	
	isAlienVDOM(vdom) {
		const vattrs = vdom.attrs || {};
		return vattrs['class'] === this.ALIEN_CLASS;
	}

	isAlienDOM(dom) {
		return dom.className === this.ALIEN_CLASS;
	}

	registerAlien(id, patcher, cmds, decs) {
		this.theAliens[id] = patcher;
		if (cmds) {
			for (var k in cmds) {
				if (cmds.hasOwnProperty(k)) {
					this.Commands[k] = cmds[k];
				}
			}
		}
		if (decs) {
			for (var k in decs) {
				if (decs.hasOwnProperty(k)) {
					this.Decoders[k] = decs[k];
				}
			}
		}
	}
	
	bootAlien(alien) {
		// this function triggers "init" code
		// hidden in some event handling attribute
		// also to register the alien to salix.
		const attr = 'on' + this.ALIEN_EVENT;
		const handler = alien[attr];
		if (handler === null) {
			return; // already booted
		}
		alien[attr] = null;
		alien.removeAttribute(attr);
		const newHandler = e => { 
			handler(e); // trigger init code
			// and then prevent further 'click's
			alien.removeEventListener(this.ALIEN_EVENT, newHandler);
		}
		alien.addEventListener(this.ALIEN_EVENT, newHandler);
		const ev = new Event(this.ALIEN_EVENT);
		alien.dispatchEvent(ev);
	}
	
	bootAliens() {
		const aliens = document.getElementsByClassName(this.ALIEN_CLASS);
		for (let i = 0; i < aliens.length; i++) {
			this.bootAlien(aliens[i]);
		}
	}

	start() {
		this.bootAliens(); 
	    fetch(this.makeURL('init'))
          .then(response => {
			if (!response.ok) {
				return Promise.reject(response);
			}
			return response.json();
		  })
		  .catch(this.serverError)
          .then(data => { this.step(data); this.doSome(); })
		  .catch(this.serverError);
	}

	serverError(err) {
		err.text().then(txt => {
			document.open();
			document.write(txt);
			document.close();
		});
	}
	
	root() {
		return document.body;
	}

		
	doSome() {
		if (!this.renderRequested) {
			while (this.queue.length > 0) {
			    document.body.style.cursor = 'progress';
				var event = this.queue.shift();
				if (this.isStale(event)) {
					console.log('Stale event');
					continue;
				}
				this.renderRequested = true;
				fetch(this.makeURL('msg', event.message))
				   .then(response => {
						if (!response.ok) {
							return Promise.reject(response);
						}
						return response.json();
				   })
				   .catch(this.serverError)
				   .then(data => {
						this.step(data);
				   })
				   .catch(error => {
						this.serverError(error);
				  	    this.renderRequested = false;
					    this.queue = [];
				    });
				
				break; // process one event at a time
			}
			document.body.style.cursor = 'auto';
		}
	}
	
	step(payload) {
		this.render(payload.patch);
		this.doCommands(payload.commands);
		this.subscribe(payload.subs);
		// I don't understand why, but putting these in 
		// .always on the get request doesn't work....
		this.renderRequested = false;
		window.requestAnimationFrame(() => this.doSome());
	}
	
	render(patch) {
		//console.log(JSON.stringify(patch, null, 2));
		this.patchDOM(this.root(), patch, this.replacer(this.root().parentNode, this.root()));	
		this.bootAliens();
	}
	
	doCommands(cmds) {
		var prepend = [];
		for (var i = 0; i < cmds.length; i++) {
			var cmd = cmds[i];
			if (cmd.none) { // legacy; let's move to list[Cmd] again...
				continue;
			}
			var data = this.Commands[cmd.name](cmd.args);

			prepend.push({message: this.makeMessage(cmd.handle, data)});
		}
		for (var i = prepend.length - 1; i >= 0; i--) {
			// unshift in reverse, so that first executed command
			// is handled first.
			this.queue.unshift(prepend[i]);
		}
	}
	
	subscribe(subs) {
		for (var i = 0; i < subs.length; i++) {
			var sub = subs[i];
			var id = sub.handle.id;
			if (this.subscriptions.hasOwnProperty(id)) {
				continue;
			}
			this.subscriptions[id] = this.Subscriptions[sub.name](sub.handle, sub.args);
		}
		this.unsubscribeStaleSubs(subs);
	}

	unsubscribeStaleSubs(subs) {
		// TODO: fix this abomination
		var toDelete = [];
		
		outer: for (var k in this.subscriptions) {
			if (this.subscriptions.hasOwnProperty(k)) {
				for (var i = 0; i < subs.length; i++) {
					var sub = subs[i];
					var id = sub.handle.id;
					if (('' + id) === k) {
						continue outer;
					}
				}
				toDelete.push(k);
			}
		}
		for (var i = 0; i < toDelete.length; i++) {
			this.subscriptions[toDelete[i]](); // shutdown
			delete subscriptions[toDelete[i]];
		}
	}

	isStale(event) {
		if (!event.target) {
			return false; // subscription, command
		}
		if (event.handler.stale) {
			return true;
		}
		return this.isStaleDOM(event.target);
	}
	
	isStaleDOM(dom) {
		if (dom === null) {
			return true;
		}
		if (dom === document) {
			return false;
		}
		return this.isStaleDOM(dom.parentNode);
	}

	/*
	 * Event handling
	 */

	// used by aliens
	send(hnd, event) { 
		this.handle({message: this.makeMessage(hnd.handle, this.getDecoder(hnd)(event))});
	}
	
	// event is either an ordinary event or {message: ...} from sub/send.
	handle(event) {
		// if doSome didn't do anything, we trigger the loop again here
		// because there's work now.
		if (this.queue.length == 0) {
			window.requestAnimationFrame(() => this.doSome());
		}
		this.queue.push(event);
	}
	
	getHandler(hnd) {
		var handler = event => {
			event.message = this.makeMessage(hnd.handle, this.getDecoder(hnd)(event));
			if (event.message) {
				event.handler = handler; // used to detect staleness
				this.handle(event);
			}
		}
		return handler;
	}
	
	makeMessage(handle, data) {
		if (!data) {
			return; // TODO: don't encode "not handling the event" by undefined data.
		}
		var result = {id: handle.id};
		if (handle.maps) {
			result.maps = handle.maps.join(';'); 
		}
		for (var k in data) {
			if (data.hasOwnProperty(k)) {
				result[k] = data[k];
			}
		}
		return result;
	}

	setEventListener(dom, key, handler) {
		var allHandlers = dom.salix_handlers || {};
		if (allHandlers.hasOwnProperty(key)) {
			dom.removeEventListener(key, allHandlers[key]);
			allHandlers[key].stale = true;
		}
		allHandlers[key] = handler;
		dom.addEventListener(key, handler);
		dom.salix_handlers = allHandlers;
		return handler;
	}

	getDecoder(hnd) {
		return this.Decoders[hnd.name](hnd.args);
	}
	


	getHandler(hnd) {
		var handler = event => {
			event.message = this.makeMessage(hnd.handle, this.getDecoder(hnd)(event));
			if (event.message) {
				event.handler = handler; // used to detect staleness
				this.handle(event);
			}
		}
		return handler;
	}

	/*
	 * DOM patching
	 */

	patchThis(dom, edits, attach) {
		edits = edits || [];


		for (var i = 0; i < edits.length; i++) {
			var edit = edits[i];

			switch (edit.type) {
			
			case 'replace':
				this.build(edit.html, attach);
				break;

			case 'setText': 
				dom.nodeValue = edit.contents;
				break;			
				
			case 'removeNode': 
				dom.removeChild(dom.lastChild);
				break;
				
			case 'appendNode':
				this.build(edit.html, this.appender(dom));
				break;
				
			case 'setAttr': 
				dom.setAttribute(edit.name, edit.val);
				break;
				
			case 'setProp': 
				dom[edit.name] = edit.val;
				break;
				
			case 'setEvent':
				var key = edit.name;
				var h = edit.handler;
				var handler = this.getHandler(h);
				this.setEventListener(dom, key, handler);
				break
			
			case 'removeAttr': 
				dom.removeAttribute(edit.name);
				break;
				
			case 'removeProp': 
				delete dom[edit.name];
				break;
				
			case 'removeEvent': 
				var key = edit.name;
				var handler = dom.salix_handlers[key];
				handler.stale = true;
				dom.removeEventListener(key, handler);
				delete dom.salix_handlers[key]
				break;
				
			case 'setExtra':
			case 'removeExtra':
				break; 

			default: 
				throw 'unsupported edit: ' + JSON.stringify(edit);
				
			}
		}
	}
	
	replacer(dom, oldKid) {
		return function (newKid) { dom.replaceChild(newKid, oldKid); };
	}
	
	appender(dom) {
		return function (kid) { dom.appendChild(kid); };
	}
	
	patchDOM(dom, tree, attach) {
		
		
		 
		

		// todo: this has to be also done for aliens
		// somehow, to be able to remove the alien
		this.patchThis(dom, tree.edits, attach);
		
		if (this.isAlienDOM(dom)) {
			// every alien element should have a unique id
			// to retrieve the associated patch closure
			this.theAliens[dom.getAttribute('id')](tree);
			return;
		}

		var patches = tree.patches || [];
		for (var i = 0; i < patches.length; i++) {
			var p = patches[i];
			var kid = dom.childNodes[p.pos];
			this.patchDOM(kid, p, this.replacer(dom, kid));
		}

	}

	

	
	
	build(vdom, attach) {
	    if (vdom.type === 'txt') {
	        attach(document.createTextNode(vdom.contents));
	        return;
	    }

	    var vattrs = vdom.attrs || {};
	    var vprops = vdom.props || {};
	    var vevents = vdom.events || {};

	    var elt = vprops.namespace != undefined
	            ? document.createElementNS(vprops.namespace, vdom.tagName)
	            : document.createElement(vdom.tagName);
	    
	    this.updateAttrsPropsAndEvents(elt, vattrs, vprops, vevents);       
	    
	    attach(elt);
	    for (var i = 0; i < vdom.kids.length; i++) {
	    	this.build(vdom.kids[i], this.appender(elt));
	    }
	}
	
	updateAttrsPropsAndEvents(elt, vattrs, vprops, vevents) {
		for (var k in vattrs) {
	        if (vattrs.hasOwnProperty(k)) {
	            elt.setAttribute(k, vattrs[k]);
	        }
	    }
	    
	    for (var k in vprops) {
	    	if (vprops.hasOwnProperty(k)) {
	    		elt[k] = vprops[k];
	    	}
	    }
	    
	    for (var k in vevents) {
	    	if (vevents.hasOwnProperty(k)) {
	    		this.setEventListener(elt, k, this.getHandler(vevents[k]));
	    	}
	    }
	}

	
	
	


}



