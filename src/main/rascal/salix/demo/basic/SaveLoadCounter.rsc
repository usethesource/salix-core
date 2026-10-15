module salix::demo::basic::SaveLoadCounter

import salix::App;
import salix::HTML;
import salix::Index;
import salix::util::SaveLoad;
import salix::demo::basic::Counter;


App[Model] saveLoadCounterWebApp() = webApp(
  makeApp("root", init, withIndex("Save and load a counter", "root", savedCounterView),
    withSaveLoad(#Model, update, filename="counter", extension="rval")),
  |project://salix-core/src/main/rascal|);

App[Model] saveLoadCounterWebAppAlternative() = webApp(
  makeApp("root", init, withIndex("Save and load a counter", "root", savedCounterView),
    update+saveLoadUpdate(#Model, filename="counter", extension="rval")),
  |project://salix-core/src/main/rascal|);

void savedCounterView(Model model) {
  div(id("root"), () {
    h2("Save and load a counter");
    counterView(model);
    div(() {
      loadButton(class("load-model"), "Load");
      saveButton(class("save-model"), "Save");
    });
  });
}
