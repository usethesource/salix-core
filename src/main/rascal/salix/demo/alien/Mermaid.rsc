module salix::demo::alien::Mermaid

import salix::HTML;
import salix::Node;

void mermaid(str name, str diagram) {
  div(class("salix-alien"), id(name), attr("onclick", "$salix.registerAlien(\'<name>\', mermaidPatch_<name>); $mermaid.init(undefined, \'#<name>_mermaid\');"), () {
    script("function mermaidPatch_<name>(patch) {
           '  const src = patch.patches[0].patches[0].edits[0].contents;
           '  const element = document.querySelector(\'#<name>_mermaid\');
           '  element.innerHTML = src;
           '  element.removeAttribute(\'data-processed\');
           '  $mermaid.init(undefined, \'#<name>_mermaid\');
           '}
           ");
    script(\type("module"),
        "import mermaid from \'https://cdn.jsdelivr.net/npm/mermaid@9/dist/mermaid.esm.min.mjs\';
        'window.$mermaid = mermaid;
        '$mermaid.initialize({ startOnLoad: false, securityLevel: \'loose\' });");
    pre(id("<name>_mermaid"), diagram);
  });
}