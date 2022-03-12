#GObject not defined
#Error while running choosing color reason: module could not be found.
#=
https://github.com/JuliaGraphics/Gtk.jl/issues/530

=#
chooser = ccall((:gtk_color_chooser_dialog_new, Gtk.libgtk), Ptr{GObject}, (Cstring, Ptr{GObject}), "pick color", GtkNullContainer())
ccall((:gtk_dialog_run, Gtk.libgtk), Cint, (Ptr{GtkDialog},), chooser)

#=solution #merged
https://github.com/JuliaGraphics/Gtk.jl/commit/7c8802a6fa5ce0002b529d5017ffe72365ea4b4a



=#
