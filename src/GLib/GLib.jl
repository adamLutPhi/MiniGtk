#from https://github.com/vtjnash/GLib.jl/blob/master/src/GLib.jl
# @vtjnash
#Cross-Referenced with: #checked 
#https://github.com/JuliaGraphics/Gtk.jl/blob/3bd7caf1eabf0c295d1f092d44c7ac4fccb67a56/src/GLib/GLib.jl
#requires Libffi_jll
#=
✓ Preferences✓ JLLWrappers✓ Libffi_jll✗ FreeType2_jll✗ Libgcrypt_jll✗ Libtiff_jll✓ Preferences✓ JLLWrappers✓ Libffi_jll
✗ FreeType2_jll✗ Libgcrypt_jll✗ Libtiff_jll✗ XML2_jll✗ Fontconfig_jll✗ XSLT_jll✗ Gettext_jll✗ Glib_jll✗ ATK_jll✗ gdk_pixbuf_jll
✗ Cairo_jll✗ HarfBuzz_jll✗ Pango_jll✗ GTK3_jll✗ Librsvg_jll
=also requires GTK3_jll -> errors while building (Pkg.precompile() ) 
there're some errors: 
in expression starting at C:\Users\adamus\.julia\packages\GTK3_jll\FbeBp\src\wrappers\x86_64-w64-mingw32.jl:4
in expression starting at C:\Users\adamus\.julia\packages\GTK3_jll\FbeBp\src\GTK3_jll.jl:2
this file vitally, heavily relies on Glib_jll 
=#
module GLib
#=requires
1. ] add Glib_jll [REPL] {an obscure name for a set of various Julia Libraries} #Requires looking into into
2. file , MutableTypes, {gvalues, gerror, glist,gtype.jl} in the same directory
=#
if isdefined(Base, :Experimental) && isdefined(Base.Experimental, Symbol("@optlevel"))
    @eval Base.Experimental.@optlevel 1
end

# Import `libgobject` and whatnot
using Glib_jll

if (false)
    function include(x)
        println("including $x")
        @time Base.include(x)
    end
end

import Base: convert, copy, show, size, length, getindex, setindex!, get,
    iterate, eltype, isempty, ndims, stride, strides, popfirst!,
    empty!, append!, reverse!, pushfirst!, pop!, push!, splice!, insert!,
    sigatomic_begin, sigatomic_end, Sys.WORD_SIZE, unsafe_convert, getproperty,
    getindex, setindex!

using Libdl  #--- define Libdl  

export GInterface, GType, GObject, GBoxed, @Gtype, @Gabstract, @Giface
#export GEnum, GError, GValue, gvalue, make_gvalue, g_type
export GEnum, GError, GValue, gvalue, make_gvalue, @make_gvalue, g_type
export GList, GSList, glist_iter, _GSList, _GList, gobject_ref, gobject_move_ref
export signal_connect, signal_emit, signal_handler_disconnect
export signal_handler_block, signal_handler_unblock
export g_timeout_add, g_idle_add, @idle_add
# export setproperty!, getproperty WARNING MAJOR NAME CHANGE (files affected )
export set_gtk_property!, get_gtk_property
export GConnectFlags
export @sigatom, cfunction_

#---- 3 cfunctions (new)

cfunction_(@nospecialize(f), r, a::Tuple) = cfunction_(f, r, Tuple{a...})

@generated function cfunction_(f, R::Type{rt}, A::Type{at}) where {rt,at<:Tuple}
    quote
        @cfunction($(Expr(:$, :f)), $rt, ($(at.parameters...),))
    end
end

const gtk_eventloop_f = Ref{Function}()

# local function, handles Symbol and makes UTF8-strings easier
const AbstractStringLike = Union{AbstractString,Symbol}

bytestring(s) = String(s)
bytestring(s::Symbol) = s
bytestring(s::Ptr{UInt8}) = unsafe_string(s)
# bytestring(s::Ptr{UInt8}, own::Bool=false) = unsafe_string(s)

g_malloc(s::Integer) = ccall((:g_malloc, libglib), Ptr{Nothing}, (Csize_t,), s) # include(joinpath("..", "..", "deps", "ext_glib.jl")) #g_malloc(s::Integer) = ccall((:g_malloc, libglib), Ptr{Nothing}, (Csize_t,), s)
g_free(p::Ptr) = ccall((:g_free, libglib), Nothing, (Ptr{Nothing},), p) # ccall((:g_type_init, libgobject), Void, ())  #g_free(p::Ptr) = ccall((:g_free, libglib), Nothing, (Ptr{Nothing},), p)

include("MutableTypes.jl")
using .MutableTypes

include("gerror.jl")
include("glist.jl")
include("signals.jl")
include("gtype.jl")#ERROR 

#include("gvalues.jl")#ERROR
#include("gwrap.jl") #Excluded with new releases 

export @g_type_delegate
macro g_type_delegate(eq)
    @assert isa(eq, Expr) && eq.head == :(=) && length(eq.args) == 2
    new = eq.args[1]
    real = eq.args[2]
    newleaf = esc(Symbol(string(new, __module__.suffix)))
    realleaf = esc(Symbol(string(real, __module__.suffix)))
    new = esc(new)
    macroreal = QuoteNode(Symbol(string('@', real)))
    quote
        $newleaf = $realleaf
        macro $new(args...)
            Expr(:macrocall, $macroreal, map(esc, args)...)
        end
    end
end

if Base.VERSION >= v"1.4.2"
    precompile(Tuple{typeof(addref),Any})   # time: 0.003988418 #errors out
    # precompile(Tuple{typeof(gc_ref),Any})   # time: 0.002649791
end#ERROR #addref undefined


end # module
