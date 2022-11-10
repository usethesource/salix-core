module salix::Extension


data Extension(str name="", list[Asset] assets = []);

data Asset
  = css(str url)
  | js(str url)
  ;