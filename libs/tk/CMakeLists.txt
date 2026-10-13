# libs/tk: Ardour's private GTK2 stack (ztk = atk, ydk-pixbuf = gdk-pixbuf,
# ydk = gdk, ytk = gtk, and their C++ bindings), plus suil. The root wscript
# lists each as a child directly; here they share this one entry point.

add_subdirectory(ztk)
add_subdirectory(ydk-pixbuf)
add_subdirectory(ydk)
add_subdirectory(ytk)
add_subdirectory(ztkmm)
add_subdirectory(ydkmm)
add_subdirectory(ytkmm)
add_subdirectory(suil)
