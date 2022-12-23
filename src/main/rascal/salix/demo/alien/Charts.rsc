 module salix::demo::alien::Charts


//Attr onInput(Msg(real) f) = event("input", targetReal(f));


 Attr onChartClick(Msg(real, real) f) = event("click", targetCoords(f));

 Hnd targetCoords(Msg(real,real) reals2msg) = handler("targetCoords", encode(real2msg));

 Msg parseMsg("real,real", Handle h, map[str,str] p)
  = applyMaps(h, decode(h, #Msg(real,real))(toReal(p["xcoord"], toReal(p["ycoord"]))));

