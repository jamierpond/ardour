# Ardour's private GTK2 stack: ztk (atk), ydk-pixbuf, ydk (gdk), ytk (gtk),
# their C++ bindings, and suil.
foreach (dir ztk ydk-pixbuf ydk ytk ztkmm ydkmm ytkmm suil)
    add_subdirectory(${dir})
endforeach ()
