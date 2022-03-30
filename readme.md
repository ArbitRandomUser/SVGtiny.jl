Julia bindings to libsvgtiny.
Primarily written so that i can get svg's into Luxor.
You will need to have `libsvgtiny` installed. 

http://www.netsurf-browser.org/projects/libsvgtiny/

More documentation and functionality (might be) incoming,
for now one function is exported ...
drawsvg(fname::String) , which draws an svg by the filename
fname into the current Luxor Drawing. 
example usage in `test.jl`

```julia
include("svgtiny.jl")
using .SVGtiny
using Luxor

Drawing(1000,1000,"./tiger.png")
drawsvg("tiger.svg")
finish()
preview()
```
![tiger](https://user-images.githubusercontent.com/58146965/160806316-152cca10-25d3-44bc-a31c-641beb2c3f12.png)
