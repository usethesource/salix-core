module salix::Index


import salix::Core;
import salix::HTML;
import String;


void(&T) withIndex(str myTitle, str myId, void(&T) view, list[str] css = [], list[str] scripts = []) {
  return void(&T model) {
     index(myTitle, myId, () {
       view(model);
     }, css=css, scripts=scripts);
  };
}


void index(str myTitle, str myId, void() block, list[str] css = [], list[str] scripts = []) {
  html(() {
    head(() {
      title_(myTitle);
            
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

