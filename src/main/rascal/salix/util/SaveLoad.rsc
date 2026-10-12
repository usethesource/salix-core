module salix::util::SaveLoad

import salix::App;
import salix::Core;
import salix::HTML;
import IO;
import ValueIO;

data Msg
  = saveModel()
  | loadModel()
  | modelFileRead(value contents, value error)
  | modelFileDone()
  ;


void saveLoadButtons() {
  button(\type("button"), onClick(loadModel()), "Load");
  button(\type("button"), onClick(saveModel()), "Save");
}

@doc{Add model save and load actions to an application update function.
Pass the model type, for example `#Model`, to check loaded values.
Save downloads a UTF-8 file in ValueIO text format.
Load replaces the model. Invalid files leave the model unchanged and show an error.
The model must contain values that ValueIO can serialize.

Use `withSaveLoad(#Model, update)` as the update argument of `makeApp`.
Call `saveLoadButtons()` inside your view at the required position.
Read a downloaded file with `readTextValueFile(#Model, file)`.
Load a file written with `writeTextValueFile(file, model)`.
See `salix::demo::basic::SaveLoadCounter` for a complete example.}
&T(Msg, &T) withSaveLoad(type[&T] modelType, &T(Msg, &T) update, str filename = "model.rval") {
  return &T(Msg msg, &T model) {
    switch (msg) {
      case saveModel(): {
        try {
          str contents = iprintToString(model);
          // Check that ValueIO can read the complete model before download.
          readTextValueString(modelType, contents);
          do(downloadTextFile(modelFileDone(), filename, contents));
        }
        catch value error: showError("Cannot save model: <error>");
        return model;
      }
      case loadModel(): {
        do(uploadTextFile(modelFileRead));
        return model;
      }
      case modelFileRead(value contents, value error): {
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
      case modelFileDone(): return model;
      default: return update(msg, model);
    }
  };
}

private void showError(str message) {
  do(showAlert(modelFileDone(), message));
}
