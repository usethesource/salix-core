module salix::util::WithPopups

import salix::App;
import salix::HTML;
import salix::Core;
import salix::Index;
import salix::Node;

import salix::demo::basic::Counter;

import Node;
import List;


@doc{Some reasonable default CSS to make tooltips look reasonably.
Override with the `css` keyword param in `withPopupsWeb` or `withPopups`.
Please see the documentation on PopperJS for how to style the tooltips
(https://popper.js.org/docs/v2/).}
str DEFAULT_CSS = 
          ".tooltip {
          'background: #333;
          'color: white;
          'font-weight: bold;
          'padding: 4px 8px;
          'font-size: 13px;
          'border-radius: 4px;
          '}
          '.arrow,
          '.arrow::before {
          '  position: absolute;
          '  width: 8px;
          '  height: 8px;
          '  background: inherit;
          '}
          '
          '.arrow {
          '  visibility: hidden;
          '}
          '
          '.arrow::before {
          '  visibility: visible;
          '  content: \'\';
          '  transform: rotate(45deg);
          '}
          ";


@doc{Mapping CSS selectors to Popup values}
alias Popups = lrel[str selector, Popup popup];


@doc{A Popup has a literal `text``, a `placement` defaulting to `auto()`
and placement `strategy` defaulting to `fixed()`.
In the future we want to support arbitrary HTML in `text`.}
data Popup = popup(str text, Placement placement = \auto()
             , list[Modifier] modifiers = []
             , Strategy strategy = fixed());

@doc{Data type encoding PopperJS positions of the tooltip.
(see here https://popper.js.org/docs/v2/constructors/).}
data Placement 
  = \auto()
  | \auto-start()
  | \auto-end()
  | \top()
  | \top-start()
  | \top-end()
  | \bottom()
  | \bottom-start()
  | \bottom-end()
  | \right()
  | \right-start()
  | \right-end()
  | \left()
  | \left-start()
  | \left-end();

data Strategy = absolute() | fixed();

data Modifier; // todo

@doc{
Run a Salix app view function `appView` on a model value `appModel` and decorate
the resulting page with popups/tooltips according `popups`, which is a list relation
mapping CSS selectors (strings) to Popup values (see above). This function is primarily
intended for creating explanatory screenshots for documentation or slide decks.
The resulting page view is not interactive anymore; events are simply ignored. 
}
App[&T] withPopupsWeb(Popups popups, &T appModel, void(&T) appView, str title
                     , str extraCss=DEFAULT_CSS, list[str] css=[], list[str] scripts=[])
  = webApp(withPopups(popups, appModel, appView, title
                     , extraCss=extraCss, css=css, scripts=scripts), |project://salix/src/main/rascal|);


SalixApp[&T] withPopups(Popups popups, &T appModel, void(&T) appView, str title
                      , str extraCss=DEFAULT_CSS, list[str] css=[], list[str] scripts=[], str id = "root") 
  = makeApp(id, &T () { return appModel; }
    , withIndex(title, id, void(&T m) { withPopupView(popups, m, appView, extraCss); }, css=css, scripts=scripts)
        , &T(Msg _, &T _) { return appModel; }
        );


void withPopupView(Popups popups, &T model, void(&T) appView, str css) {

  for (int i <- [0..size(popups)], <_, Popup p> := popups[i]) {
    div(id("tt_<i>"), class("tooltip"), role("tooltip"), () {
      text(p.text);
      div(id("arrow_<i>"), class("arrow"), attr("data-popper-arrow", ""));
    });
  }

  appView(model);

  div(() {
    script(src("https://unpkg.com/@popperjs/core@2"));
    style_(css);

    list[str] pops = [ "Popper.createPopper(document.querySelector(\'<s>\'), document.querySelector(\'#tt_<i>\'),
                       '  {placement: \'<getName(p.placement)>\', strategy: \'<getName(p.strategy)>\'});" 
      | int i <- [0..size(popups)], <str s, Popup p> := popups[i] ];
    script(intercalate("\n", pops));
  });

}


App[Model] testWithCounter() 
  = withPopupsWeb([
    <"#thecount", popup("Pop!")>,
    <"#header", popup("This is the header",placement=\bottom-start())>
  ], <42>, view, "Counter"); 