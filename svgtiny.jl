module SVGtiny
using Luxor

using CEnum

const svgtiny_colour = Cint

struct svgtiny_shape
    path::Ptr{Cfloat}
    path_length::Cuint
    text::Ptr{Cchar}
    text_x::Cfloat
    text_y::Cfloat
    fill::svgtiny_colour
    stroke::svgtiny_colour
    stroke_width::Cint
end

struct svgtiny_diagram
    width::Cint
    height::Cint
    shape::Ptr{svgtiny_shape}
    shape_count::Cuint
    error_line::Cushort
    error_message::Ptr{Cchar}
end

@cenum svgtiny_code::UInt32 begin
    svgtiny_OK = 0
    svgtiny_OUT_OF_MEMORY = 1
    svgtiny_LIBDOM_ERROR = 2
    svgtiny_NOT_SVG = 3
    svgtiny_SVG_ERROR = 4
end

@cenum var"##Ctag#292"::UInt32 begin
    svgtiny_PATH_MOVE = 0
    svgtiny_PATH_CLOSE = 1
    svgtiny_PATH_LINE = 2
    svgtiny_PATH_BEZIER = 3
end

struct svgtiny_named_color
    name::Ptr{Cchar}
    color::svgtiny_colour
end


libsvgtiny = "libsvgtiny"
function svgtiny_create()
    ccall((:svgtiny_create, libsvgtiny), Ptr{svgtiny_diagram}, ())
end

function svgtiny_parse(diagram, buffer, size, url, width, height)
    ccall((:svgtiny_parse, libsvgtiny), svgtiny_code, (Ptr{svgtiny_diagram}, Ptr{Cchar}, Cint, Ptr{Cchar}, Cint, Cint), diagram, buffer, size, url, width, height)
end

function svgtiny_free(svg)
    ccall((:svgtiny_free, libsvgtiny), Cvoid, (Ptr{svgtiny_diagram},), svg)
end

const svgtiny_TRANSPARENT = 0x01000000

"""
    function run_luxor_instruction(segment::Array)

segment is an array of the form [s::Symbol,f1::float,f2::float...]
eval(s) should return a luxor function, and f1,f2.. are the args passed
to eval(s) to be run, make sure Luxor is imported for eval to work.
"""
function run_luxor_drawsegment(segment::Array)
    if isempty(segment)
        return
    end
    #println(segment)
    try
        eval(segment[1])(segment[2:end]...)
    catch e
        if e isa UndefVarError
            println("UNdefVarError, make sure you ran `using Luxor`")
        else
            throw(e)
        end
    end
end

function getcolor(num::Number)
    stringrep = string(num,base=16,pad=6)
    bytes = hex2bytes(stringrep)
    bytes[1]/255,bytes[2]/255,bytes[3]/255
end

function drawsvg(fname::String,width=1000,height=1000,action=:none)
    diag = svgtiny_create()
    svgtiny_parse(diag,read(fname),length(read(fname)),fname,width,height)
    diagjl = unsafe_load(diag)
    shapes = unsafe_wrap(Array,diagjl.shape,diagjl.shape_count,own=true)

    for shape in shapes #a shape is a cairo path
        path = unsafe_wrap(Array,shape.path,shape.path_length)
        argcounter=0
        segment = []
        for pathval in path #this actually is a cairo subpath
            if argcounter==0
                run_luxor_drawsegment(segment)
                empty!(segment)
                if pathval == 0.0
                    push!(segment,:move)
                    argcounter+=2
                elseif pathval == 1.0
                    push!(segment,:closepath)
                    argcounter+=0
                elseif pathval == 2.0
                    push!(segment,:line)
                    argcounter+=2
                elseif pathval == 3.0
                    push!(segment,:curve)
                    argcounter+=6
                end
            else
                argcounter-=1
                push!(segment,pathval)
            end
        end
        if shape.stroke!=svgtiny_TRANSPARENT && action==:none
            sethue(getcolor(shape.stroke))
            setline(shape.stroke_width)
            strokepreserve()
        end
        if shape.fill!=svgtiny_TRANSPARENT && action==:none
            sethue(getcolor(shape.fill))
            fillpreserve()
        end
        if action == :none
            newpath()
        end
    end
end
export drawsvg
end # module
