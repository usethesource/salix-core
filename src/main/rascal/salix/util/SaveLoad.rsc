module salix::util::SaveLoad

import salix::App;
import salix::Core;
import salix::HTML;
import IO;
import ValueIO;
import String;

data Msg
  = saveModel()
  | loadModel()
  | modelFileRead(value contents, value error)
  | modelFileDone()
  ;


@synopsis{Create a save button}
@examples{
`saveButton("Save...")`
}
void saveButton(value vals...) = build([\type("button"), onClick(saveModel())] + vals, "button");

@synopsis{Create a load button}
@examples{
`saveButton("Load...")`
}
void loadButton(value vals...) = build([\type("button"), onClick(loadModel())] + vals, "button");

@synopsis{Adds model save and load actions to an application update function.}
@description{
This wrapper gives access to the browser's own save and load file dialogs.
Use `withSaveLoad(#Model, update)` as the `update` argument of ((makeApp)).
Then call ((saveButton)) and ((loadButton)) inside your view at the required positions.

loaded models (in ValueIO format). The files are saved to disk in a UTF-8 ValueIO text format.
}
@examples{
* See ((salix::demo::basic::SaveLoadCounter)) for a complete example.
}
&T(Msg, &T) withSaveLoad(type[&T] modelType, &T(Msg, &T) update,
    str filename = "model", str extension = "rval")
  = update + saveLoadUpdate(modelType, filename=filename, extension=extension);

@synopsis{Creates model save and load actions as an application update function.}
@description{
This function gives access to the browser's own save and load file dialogs.
Use `update + saveLoadUpdate(#Model)` as the `update` argument of ((makeApp)).
Then call ((saveButton)) and ((loadButton)) inside your view at the required positions.

The files are saved to disk in a UTF-8 ValueIO text format.
}
@examples{
* See ((salix::demo::basic::SaveLoadCounter)) for a complete example.
}
&T(Msg, &T) saveLoadUpdate(type[&T] modelType,
    str filename = "model", str extension = "rval") {
  str suffix = extension == "" || startsWith(extension, ".") ? extension : ".<extension>";
  str savedFilename = suffix == "" || endsWith(filename, suffix) ? filename : "<filename><suffix>";

  &T updateOverload(saveModel(), &T model) = saveModelFile(modelType, model, savedFilename);
  &T updateOverload(loadModel(), &T model) = requestModelFile(model, suffix);
  &T updateOverload(modelFileRead(value contents, value error), &T model)
    = readModelFile(modelType, model, contents, error);
  &T updateOverload(modelFileDone(), &T model) = model;

  return updateOverload;
}

private &T saveModelFile(type[&T] modelType, &T model, str savedFilename) {
  try {
    str contents = iprintToString(model);
    // Check that ValueIO can read the complete model before download.
    readTextValueString(modelType, contents);
    do(downloadTextFile(modelFileDone(), savedFilename, contents));
  }
  catch value error: showError("Cannot save model: <error>");
  return model;
}

private &T requestModelFile(&T model, str suffix) {
  do(uploadTextFile(modelFileRead, accept=suffix));
  return model;
}

private &T readModelFile(type[&T] modelType, &T model, value contents, value error) {
  if (str message := error, message != "") {
    showError(message);
  }
  else if (str text := contents) {
    try {
      return readTextValueString(modelType, text);
    }
    catch value problem: showError("Cannot load model: <problem>");
  }
  return model;
}

private void showError(str message) {
  do(showAlert(modelFileDone(), message));
}
