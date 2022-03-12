#=
A minor syntax issue with GtkWindowLeaf attributes #392 -  Open
pauljurczak opened this issue on Oct 9, 2018 · 4 comments


@pauljurczak pauljurczak commented on Oct 9, 2018 • 
Evaluating GtkWindowLeaf outputs:
GtkWindowLeaf(name="", parent, width-request=600, height-request=-1, visible=TRUE, ...
Can it be modified to:
GtkWindowLeaf(name="", parent, width_request=600, height_request=-1, visible=true, ...
so it's syntactically correct in Julia?

Collaborator
@tknopp tknopp commented on Oct 9, 2018
not sure why booleans are printed uppercase. @vtjnash may know.

Author
@pauljurczak pauljurczak commented on Oct 9, 2018
@tknopp There is also width-request vs width_request.

Collaborator
@tknopp tknopp commented on Oct 9, 2018
There is a reason for that but I actually don't know exactly what since I did not design that part of Gtk.jl

Collaborator
@jonathanBieler jonathanBieler commented on Oct 9, 2018 • 
I think the reason things are called like is that that's how they are called in Gtk. 

Takeaway: Gtk.jl just calls a GObject introspection method and prints the results:

Gtk.jl/src/GLib/gvalues.jl

Lines 209 to 238 in 4190f44
=#
#Problem:
function gtkwindowleafcall(GObject, GValue)
    props = ccall((:g_object_class_list_properties, libgobject), Ptr{Ptr{GParamSpec}},
        (Ptr{Nothing}, Ptr{Cuint}), G_OBJECT_GET_CLASS(w), n)
    v = gvalue(String)
    first = true
    for i = 1:unsafe_load(n)
        param = unsafe_load(unsafe_load(props, i))
        if !first 
            print(io, ", ")
        else
            first = false
        end
        print(io, GLib.bytestring(param.name))
        if (param.flags & READABLE) != 0 &&
           (param.flags & DEPRECATED) == 0 &&
           (ccall((:g_value_type_transformable, libgobject), Cint,
               (Int, Int), param.value_type, g_type(AbstractString)) != 0)
            ccall((:g_object_get_property, libgobject), Nothing,
                (Ptr{GObject}, Ptr{UInt8}, Ptr{GValue}), w, param.name, v)
            str = ccall((:g_value_get_string, libgobject), Ptr{UInt8}, (Ptr{GValue},), v)
            value = (str == C_NULL ? "NULL" : GLib.bytestring(str))
            if param.value_type == g_type(AbstractString) && str != C_NULL
                print(io, "=\"", value, '"')
            else
                print(io, '=', value)
            end
        end
    end
    print(io, ')')
    ccall((:g_value_unset, libgobject), Ptr{Nothing}, (Ptr{GValue},), v)
end
#ERROR: Invalid Access to an Invalid a Slot Number 
#I guess one could "translate" those names into Julia friendly ones, since that's just for showing in the REPL it should be safe.



