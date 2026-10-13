# libs/widgets/wscript (obj.includes also carries INCLUDES_GLIB)
ardour_target(widgets SHARED GLOB
        INCLUDES . ${PKG_GLIB_INCLUDE_DIRS}
        EXPORT_INCLUDES .
        USE pbd gtkmm2ext ytkmm
        USELIB SIGCPP CAIROMM XML OSX GLIBMM GIOMM PANGOMM
        DEFINES LIBWIDGETS_DLL_EXPORTS=1 "PACKAGE=\"libwidgets\"")
