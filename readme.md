julia bindings to libsvgtiny
primarily written so that i can get svg's into Luxor.
you will need to have `libsvgtiny` installed. 
http://www.netsurf-browser.org/projects/libsvgtiny/



more documentation incoming,
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

![tiger](https://user-images.githubusercontent.com/58146965/160720532-489f2660-76d4-468d-b362-6042761de120.png)
