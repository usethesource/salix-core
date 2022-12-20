module salix::Index


import salix::Core;
import salix::HTML;
import salix::Extension;
import String;


void(&T) withIndex(str myTitle, str myId, void(&T) view, list[Extension] exts = [], list[str] css = [], list[str] scripts = []) {
  return void(&T model) {
     index(myTitle, myId, () {
       view(model);
     }, exts=exts, css=css, scripts=scripts);
  };
}


void index(str myTitle, str myId, void() block, list[Extension] exts = [], list[str] css = [], list[str] scripts = []) {
  html(() {
    head(() {
      title_(myTitle);
      
      for (Extension e <- exts) {
        for (Asset a <- e.assets) {
          switch (a) {
            case css(str c): link(\rel("stylesheet"), href(c));
            case js(str j): script(\type("text/javascript"), src(j));
            case inlineScript(str s, str t): script(\type(t), s);
            default: throw "Unknown asset: <a>";
          }
        }
      }
      
      for (str c <- css) {
        link(\rel("stylesheet"), href(c));
      }
      
      for (str s <- scripts + ["/salix/salix.js"]) {
        script(\type("text/javascript"), src(s));
      }
                  
      script("document.addEventListener(\"DOMContentLoaded\", function() {
             '  window.$salix = new Salix(\"<myId>\");
             '  $salix.start();
             '});");
    });
    
    body(block);
  });
}

