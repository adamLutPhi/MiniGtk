
#=
Cannot reproduce file dialog examples #189 - Closed
rowlesmr opened this issue on Oct 1, 2015 · 6 comments
 Closed
Cannot reproduce file dialog examples
#189
rowlesmr opened this issue on Oct 1, 2015 · 6 comments
Comments
@rowlesmr rowlesmr commented on Oct 1, 2015
I have tried these in Julia v0.3.11 & Gtk 0.8.6 and Julia v0.4.0-rc3 & Gtk 0.9.2

I have copied the code from the readme.md file under the section "File dialogs" right at the end of the file.

I am running it in REPL.I have entered using Gtk and using Gtk.ShortNames.
=#

open_dialog("Pick some files", multiple=true) #gives a file dialog, but also gives a warning: GLib-GObject-WARNING **: g_object_set_property: object class 'GtkFileChooseDialog' has no property 'multiple'. I am not able to choose multiple files.

open_dialog("Pick a file", filters=("*.jl",)) #gives an error: ERROR: 'g_type' has no method matching g_type(::Type{(ASCIIString,)}). No dialog is opened. Removing the final , removes this error and opens a dialog box, but a warning is given: GLib-GObject-WARNING **: g_object_set_property: object class 'GtkFileChooseDialog' has no property 'filters'. The list of files is not filtered.

open_dialog("Pick a file", filters=(@FileFilter(mimetype="text/csv"),)) #gives an error: ERROR: @FileFilter not defined.

#=
What am I doing wrong?

Contributor
@vtjnash vtjnash commented on Oct 1, 2015
what OS? what version of Gtk/GLib are you using?

Author
@rowlesmr rowlesmr commented on Oct 1, 2015
Windows 7, service pack 1, 64 bit
Julia v0.3.11 & Gtk 0.8.6 and Julia v0.4.0-rc3 & Gtk 0.9.2

Gtk was installed by Pkg.add("Gtk")

Contributor
@lobingera lobingera commented on Oct 2, 2015
I can reproduce all mentioned errors/warnings with
=#
versioninfo()
#Julia Version 0.4.0-rc3
#=Commit 483d548* (2015-09-27 20:34 UTC)
Platform Info:
  System: Linux (x86_64-linux-gnu)
  CPU: Intel(R) Core(TM) i3-2120 CPU @ 3.30GHz
  WORD_SIZE: 64
  BLAS: libopenblas (USE64BITINT DYNAMIC_ARCH NO_AFFINITY Sandybridge)
  LAPACK: libopenblas
  LIBM: libopenlibm
  LLVM: libLLVM-3.3

lobi@orange4:~/juliarepo$ ../julia04/julia 
               _
   _       _ _(_)_     |  A fresh approach to technical computing
  (_)     | (_) (_)    |  Documentation: http://docs.julialang.org
   _ _   _| |_  __ _   |  Type "?help" for help.
  | | | | | | |/ _` |  |
  | | |_| | | | (_| |  |  Version 0.4.0-rc3 (2015-09-27 20:34 UTC)
 _/ |\__'_|_|_|\__'_|  |  
|__/                   |  x86_64-linux-gnu
=#
using Gtk

using Gtk.ShortNames # (non-)Official use of ShortNames

open_dialog("Pick some files", multiple=true)
#=WARNING: Base.Uint8 is deprecated, use UInt8 instead.

(julia:9963): GLib-GObject-WARNING **: g_object_set_property: object class 'GtkFileChooserDialog' has no property named 'multiple'
"""=#

julia> open_dialog("Pick a file", filters=("*.jl",))

#=ERROR: MethodError: `g_type` has no method matching g_type(::Type{Tuple{ASCIIString}})
 in setindex! at /home/lobi/.julia/v0.4/Gtk/src/GLib/gvalues.jl:64
 in gvalue at /home/lobi/.julia/v0.4/Gtk/src/GLib/gvalues.jl:18
 in setproperty! at /home/lobi/.julia/v0.4/Gtk/src/GLib/gvalues.jl:163
 in GtkFileChooserDialogLeaf at /home/lobi/.julia/v0.4/Gtk/src/GLib/gtype.jl:209
 in GtkFileChooserDialogLeaf at /home/lobi/.julia/v0.4/Gtk/src/selectors.jl:28
 in open_dialog at /home/lobi/.julia/v0.4/Gtk/src/selectors.jl:73 (repeats 2 times)
=#

open_dialog("Pick a file", filters=("*.jl"))

#=
(julia:9963): GLib-GObject-WARNING **: g_object_set_property: object class 'GtkFileChooserDialog' has no property named 'filters'
""
=#
open_dialog("Pick a file", filters=(@FileFilter(mimetype="text/csv"),))
#=
ERROR: UndefVarError: @FileFilter not defined
=#
@FileFilter(; name = nothing, pattern = "", mimetype = "")
#=
ERROR: UndefVarError: @FileFilter not defined
@silvernode silvernode commented on Oct 2, 2015
On Arch Linux, Gtk loads (using Gtk) but I have all sorts of errors. @window is undefined, as well as @frame. getting rid of the '@' symbol fixes window but not Frame. Frame is still undefined. I haven't been able to get the examples to work on any operating system. I don't know whether I am missing something or Gtk just does not work with Julia.

Contributor
@lobingera lobingera commented on Oct 2, 2015
@silvernode or Gtk just does not work with Julia, i'm using Gtk.jl for quite some time right now and apart from some dependency hicups and general julia restructuring, i'm fine. I think part of the issues above link to julia restructuring on tuples and e.g. String->AbstractString.

@vtjnash vtjnash closed this in JuliaGraphics/Gtk.jl@3f31e5e on Oct 2, 2015
Contributor
@vtjnash vtjnash commented on Oct 2, 2015
@silvernode you need using Gtk.ShortNames to use the abbreviations, otherwise everything uses the full name from the Gtk docs.
=#

#Solution:
#@rowlesmr I've fixed the examples. I have reserved keyword arguments in Gtk.jl to be used for the Gtk properties (e.g. https://developer.gnome.org/gtk3/stable/GtkFileChooser.html#GtkFileChooser--select-multiple), so the examples needed to be corrected to reflect this.
#me:links leads to no where 
