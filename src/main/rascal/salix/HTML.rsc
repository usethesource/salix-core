@license{
  Copyright (c) Tijs van der Storm <Centrum Wiskunde & Informatica>.
  All rights reserved.
  This file is licensed under the BSD 2-Clause License, which accompanies this project
  and is available under https://opensource.org/licenses/BSD-2-Clause.
}
@contributor{Tijs van der Storm - storm@cwi.nl - CWI}
@contributor{Bert Lisser - berlt@cwi.nl - CWI}

module salix::HTML

import salix::Node;
import salix::Core;
import List;
import String; 

data Msg;
 
@doc{Create a text node.}
void text(value v) = _text(v);


@doc{The element render functions below all call build
to interpret the list of values; build will call the
second argument (_h1 etc.) to construct the actual
Node values.}

void html(value vals...) = build(vals, "html");
void head(value vals...) = build(vals, "head");
void script(value vals...) = build(vals, "script");
void link(value vals...) = build(vals, "link");
void title_(value vals...) = build(vals, "title");
void style_(value vals...) = build(vals, "style");

void h1(value vals...) = build(vals, "h1");
void h2(value vals...) = build(vals, "h2");
void h3(value vals...) = build(vals, "h3");
void h4(value vals...) = build(vals, "h4");
void h5(value vals...) = build(vals, "h5");
void h6(value vals...) = build(vals, "h6");
void div(value vals...) = build(vals, "div");
void p(value vals...) = build(vals, "p");
void hr(value vals...) = build(vals, "hr");
void pre(value vals...) = build(vals, "pre");
void blockquote(value vals...) = build(vals, "blockquote");
void span(value vals...) = build(vals, "span");
void a(value vals...) = build(vals, "a");
void code(value vals...) = build(vals, "code");
void em(value vals...) = build(vals, "em");
void strong(value vals...) = build(vals, "strong");
void i(value vals...) = build(vals, "i");
void b(value vals...) = build(vals, "b");
void u(value vals...) = build(vals, "u");
void sub(value vals...) = build(vals, "sub");
void sup(value vals...) = build(vals, "sup");
void br(value vals...) = build(vals, "br");
void ol(value vals...) = build(vals, "ol");
void ul(value vals...) = build(vals, "ul");
void li(value vals...) = build(vals, "li");
void dl(value vals...) = build(vals, "dl");
void dt(value vals...) = build(vals, "dt");
void dd(value vals...) = build(vals, "dd");
void img(value vals...) = build(vals, "img");
void iframe(value vals...) = build(vals, "iframe");
void canvas(value vals...) = build(vals, "canvas");
void math(value vals...) = build(vals, "math");
void form(value vals...) = build(vals, "form");
void input(value vals...) = build(vals, "input");
void textarea(value vals...) = build(vals, "textarea");
void button(value vals...) = build(vals, "button");
void select(value vals...) = build(vals, "select");
void option(value vals...) = build(vals, "option");
void section(value vals...) = build(vals, "section");
void nav(value vals...) = build(vals, "nav");
void article(value vals...) = build(vals, "article");
void aside(value vals...) = build(vals, "aside");
void header(value vals...) = build(vals, "header");
void footer(value vals...) = build(vals, "footer");
void address(value vals...) = build(vals, "address");
void main(value vals...) = build(vals, "main");
void body(value vals...) = build(vals, "body");
void figure(value vals...) = build(vals, "figure");
void figcaption(value vals...) = build(vals, "figcaption");
void table(value vals...) = build(vals, "table");
void caption(value vals...) = build(vals, "caption");
void colgroup(value vals...) = build(vals, "colgroup");
void col(value vals...) = build(vals, "col");
void tbody(value vals...) = build(vals, "tbody");
void thead(value vals...) = build(vals, "thead");
void tfoot(value vals...) = build(vals, "tfoot");
void tr(value vals...) = build(vals, "tr");
void td(value vals...) = build(vals, "td");
void th(value vals...) = build(vals, "th");
void fieldset(value vals...) = build(vals, "fieldset");
void legend(value vals...) = build(vals, "legend");
void label(value vals...) = build(vals, "label");
void datalist(value vals...) = build(vals, "datalist");
void optgroup(value vals...) = build(vals, "optgroup");
void keygen(value vals...) = build(vals, "keygen");
void output(value vals...) = build(vals, "output");
void progress(value vals...) = build(vals, "progress");
void meter(value vals...) = build(vals, "meter");
void audio(value vals...) = build(vals, "audio");
void video(value vals...) = build(vals, "video");
void source(value vals...) = build(vals, "source");
void track(value vals...) = build(vals, "track");
void embed(value vals...) = build(vals, "embed");
void object(value vals...) = build(vals, "object");
void param(value vals...) = build(vals, "param");
void ins(value vals...) = build(vals, "ins");
void del(value vals...) = build(vals, "del");
void small(value vals...) = build(vals, "small");
void cite(value vals...) = build(vals, "cite");
void dfn(value vals...) = build(vals, "dfn");
void abbr(value vals...) = build(vals, "abbr");
void time(value vals...) = build(vals, "time");
void var(value vals...) = build(vals, "var");
void samp(value vals...) = build(vals, "samp");
void kbd(value vals...) = build(vals, "kbd");
void s(value vals...) = build(vals, "s");
void q(value vals...) = build(vals, "q");
void mark(value vals...) = build(vals, "mark");
void ruby(value vals...) = build(vals, "ruby");
void rt(value vals...) = build(vals, "rt");
void rp(value vals...) = build(vals, "rp");
void bdi(value vals...) = build(vals, "bdi");
void bdo(value vals...) = build(vals, "bdo");
void wbr(value vals...) = build(vals, "wbr");
void details(value vals...) = build(vals, "details");
void summary(value vals...) = build(vals, "summary");
void menuitem(value vals...) = build(vals, "menuitem");
void menu(value vals...) = build(vals, "menu");


// Node build(list[value] vals, str tagName)
//   = Node(list[Node] kids, list[Attr] attrs) {
//       return hnode(element(),tagName=tagName, kids=kids, attrs=attrsOf(attrs),props=propsOf(attrs),events=eventsOf(attrs));
//   };


/*
 * Attributes
 */
 
Attr style(tuple[str, str] styles...) = attr("style", intercalate("; ", ["<k>: <v>" | <k, v> <- styles ])); 
Attr style(map[str,str] styles) = attr("style", intercalate("; ", ["<k>: <styles[k]>" | k <- styles ])); 

Attr crossorigin(str val) = attr("crossorigin", val);
Attr integrity(str val) = attr("integrity", val);
Attr referrerpolicy(str val) = attr("referrerpolicy", val);

Attr align(str val) = attr("align", val);
Attr valign(str val) = attr("valign", val);

Attr property(str name, value val) = prop(name, "<val>");
Attr attribute(str name, str val) = attr(name, val);
Attr class(str val) = attr("class", val);
Attr classList(tuple[str, bool] classes...) = attr("class", intercalate(" ", [ k | <k, true > <- classes ]));
Attr id(str val) = attr("id", val);
Attr title(str val) = attr("title", val);
Attr hidden(bool h) = h ? attr("hidden", "true") : null(); // ???
Attr \type(str val) = attr("type", val);
Attr \value(str val) = prop("value", val);
Attr defaultValue(str val) = attr("defaultValue", val); // should be attr value?
Attr checked(bool checked) = checked ? attr("checked", "true") : null();
Attr placeholder(str val) = attr("placeholder", val);
Attr selected(bool selected) = selected ? attr("selected", "true") : null();

Attr accept(str val) = attr("accept", val);
Attr acceptCharset(str val) = attr("acceptCharset", val);
Attr action(str val) = attr("action", val);
Attr autocomplete(bool val) = attr("autocomplete", "<val>");
Attr autofocus(bool val) = attr("autofocus", "<val>");
Attr disabled(bool val) = val ? attr("disabled", "<val>") : null();
Attr enctype(str val) = attr("enctype", val);
Attr formaction(str val) = attr("formaction", val);
Attr \list(str val) = attr("list", val);
Attr maxlength(int val) = attr("maxlength", "<val>");
Attr minlength(int val) = attr("minlength", "<val>");
Attr method(str val) = attr("method", val);
Attr multiple(bool val) = val ? attr("multiple", "<val>") : null();
Attr name(str val) = attr("name", val);
Attr novalidate(bool val) = attr("novalidate", "<val>");
Attr pattern(str val) = attr("pattern", val);
Attr readonly(bool val) = attr("readonly", "<val>");
Attr required(bool val) = attr("required", "<val>");
Attr size(int val) = attr("size", "<val>");
Attr \for(str val) = attr("for", val);
Attr formm(str val) = attr("form", val);
Attr max(str val) = attr("max", val);
Attr min(str val) = attr("min", val);
Attr step(str val) = attr("step", val);
Attr cols(int val) = attr("cols", "<val>");
Attr rows(int val) = attr("rows", "<val>");
Attr wrap(str val) = attr("wrap", val);
Attr href(str val) = attr("href", val);
Attr target(str val) = attr("target", val);
Attr download(bool val) = attr("download", "<val>");
Attr downloadAs(str val) = attr("downloadAs", val);
Attr hreflang(str val) = attr("hreflang", val);
Attr media(str val) = attr("media", val);
Attr ping(str val) = attr("ping", val);
Attr \rel(str val) = attr("rel", val);

Attr ismap(bool val) = attr("ismap", "<val>");
Attr usemap(str val) = attr("usemap", val);
Attr shape(str val) = attr("shape", val);
Attr coords(str val) = attr("coords", val);
Attr src(str val) = attr("src", val);
Attr height(int val) = attr("height", "<val>");
Attr width(int val) = attr("width", "<val>");
Attr alt(str val) = attr("alt", val);
Attr autoplay(bool val) = attr("autoplay", "<val>");
Attr controls(bool val) = attr("controls", "<val>");
Attr loop(bool val) = attr("loop", "<val>");
Attr preload(str val) = attr("preload", val);
Attr poster(str val) = attr("poster", val);
Attr \default(bool val) = attr("default", "<val>");
Attr kind(str val) = attr("kind", val);
Attr srclang(str val) = attr("srclang", val);
Attr sandbox(str val) = attr("sandbox", val);
Attr seamless(bool val) = attr("seamless", "<val>");
Attr srcdoc(str val) = attr("srcdoc", val);
Attr reversed(bool val) = attr("reversed", "<val>");
Attr \start(int val) = attr("start", "<val>");
Attr align(str val) = attr("align", val);
Attr colspan(int val) = attr("colspan", "<val>");
Attr rowspan(int val) = attr("rowspan", "<val>");
Attr headers(str val) = attr("headers", val);
Attr scope(str val) = attr("scope", val);
Attr async(bool val) = attr("async", "<val>");
Attr charset(str val) = attr("charset", val);
Attr content(str val) = attr("content", val);
Attr defer(bool val) = attr("defer", "<val>");
Attr httpEquiv(str val) = attr("httpEquiv", val);
Attr language(str val) = attr("language", val);
Attr scoped(bool val) = attr("scoped", "<val>");
Attr accesskey(str char) = attribute("accesskey", char); // ??? keycode?
Attr contenteditable(bool val) = attr("contenteditable", "<val>");
Attr contextmenu(str val) = attr("contextmenu", val);
Attr dir(str val) = attr("dir", val);
Attr draggable(str val) = attr("draggable", val);
Attr dropzone(str val) = attr("dropzone", val);
Attr itemprop(str val) = attr("itemprop", val);
Attr lang(str val) = attr("lang", val);
Attr spellcheck(bool val) = attr("spellcheck", "<val>");
Attr tabindex(int val) = attr("tabindex", "<val>");
Attr challenge(str val) = attr("challenge", val);
Attr keytype(str val) = attr("keytype", val);
Attr _cite(str val) = attr("cite", val);
Attr \datetime(str val) = attr("datetime", val);
Attr pubdate(str val) = attr("pubdate", val);
Attr manifest(str val) = attr("manifest", val);

Attr valign(str val) = attr("valign", val);
Attr cellpadding(str val) = attr("cellpadding", val);
Attr cellspacing(str val) = attr("cellspacing", val);

/*
 * Events
 */
 
Attr onKeyPress(Msg(int) msg) = event("keypress", keyCode(msg));
Attr onKeyDown(Msg(int) msg) = event("keydown", keyCode(msg));
Attr onClick(Msg msg) = event("click", succeed(msg));

Attr onDoubleClick(Msg msg) = event("dblclick", succeed(msg));
Attr onMouseDown(Msg msg) = event("mousedown", succeed(msg));
Attr onMouseUp(Msg msg) = event("mouseup", succeed(msg));
Attr onMouseEnter(Msg msg) = event("mouseenter", succeed(msg));
Attr onMouseLeave(Msg msg) = event("mouseleave", succeed(msg));
Attr onMouseOver(Msg msg) = event("mouseover", succeed(msg));
Attr onMouseOut(Msg msg) = event("mouseout", succeed(msg));
Attr onSubmit(Msg msg) = event("submit", succeed(msg));
Attr onBlur(Msg msg) = event("blur", succeed(msg));
Attr onFocus(Msg msg) = event("focus", succeed(msg));

Attr onCheck(Msg(bool) f) = event("change", targetChecked(f));

Attr onInput(Msg(str) f) = event("input", targetValue(f)); 
Attr onInput(Msg(int) f) = event("input", targetInt(f));
Attr onInput(Msg(real) f) = event("input", targetReal(f));

Attr onChange(Msg(int) f) = event("change", targetInt(f));
Attr onChange(Msg(real) f) = event("change", targetReal(f));
Attr onChange(Msg(str) f) = event("change", targetValue(f));

Attr onCheck(Msg(bool) f) = event("check", targetChecked(f));
  
@doc{Smart constructors for constructing encoded event decoders.}
Hnd succeed(Msg msg) = handler("succeed", encode(msg));

Hnd targetValue(Msg(str) str2msg) = handler("targetValue", encode(str2msg));

Hnd targetChecked(Msg(bool) bool2msg) = handler("targetChecked", encode(bool2msg));

Hnd keyCode(Msg(int) int2msg) = handler("keyCode", encode(int2msg)); 

Hnd targetInt(Msg(int) int2msg) = handler("targetInt", encode(int2msg));

Hnd targetReal(Msg(real) real2msg) = handler("targetReal", encode(real2msg));

Hnd jsonPayload(Msg(map[str,value]) json2msg) = handler("jsonPayload", encode(json2msg));

