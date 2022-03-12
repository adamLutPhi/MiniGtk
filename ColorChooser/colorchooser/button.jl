#GObject not defined 
GtkColorButtonLeaf() = GtkColorButtonLeaf(ccall((:gtk_color_button_new, libgtk), Ptr{GObject}, ()))
GtkColorButtonLeaf(color::GdkRGBA) = GtkColorButtonLeaf(ccall((:gtk_color_button_new_with_rgba, libgtk), Ptr{GObject},
    (Ref{GdkRGBA},), color))
