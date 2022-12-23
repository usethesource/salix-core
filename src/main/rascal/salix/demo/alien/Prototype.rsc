module salix::demo::alien::Prototype

import salix::HTML;
import salix::Node;

import lang::json::IO;

@doc{
The contract for an "alien" element is as follows:
- its HTML "bounding box" should have CSS class "salix-alien"
- it should receive a globally unique id 
- it should have an onclick event handler specified as a raw attribute, which:
     - runs any init code required for any loaded JS etc. via script tags
     - registers itself, via `$salix.registerAlien(<id>, patch => ...)` 
       (where the closure receives the "patch" to be able to deal with changes)
  the event is programmatically triggered in the Salix bootstrap phase
  after all content has been loaded; after that, the handler is removed.
- events handled in the alien element should rerouted to salix to create messages.

The example here puts all JS inline, but this code can also be in a separate JS file.
If multiple aliens of the same type co-exist in the same page, pass the script loading to withIndex
to have a single script load for multiple alien elements.

Use withExtra to pass extra information (map[str,value] into the client.
}
void myAlienButton(str name, str label, Attr event) {
    // this div encapsulates a button element that is not managed by Salix.
    // the onClick event is used to mount/initialize the alien element
    // and to register the patcher to salix via the global $salix.
    div(class("salix-alien"), id(name),  attr("onClick", "$salix.registerAlien(\'<name>\', $<name>_patch)"), () {

        // the patch received from the server is a real patch
        // (the diff algorithm does not skip alien elements; Salix's patch
        // function, however, delegates to registered alien patchers for alien elements)
        script("function $<name>_patch(p) {
               '    console.log(JSON.stringify(p));
               '    // deal with any updates here, for instance, a changed label
               '    // or a changed event. 
               '}");
        button(id("<name>_button"), attr("onClick", "$salix.send(<asJSON(event.handler)>, {});"), label);
    });
}

