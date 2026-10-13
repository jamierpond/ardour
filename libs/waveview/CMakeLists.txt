# Port of libs/waveview/wscript.

ardour_add_library(waveview SHARED)

target_sources(waveview PRIVATE
        debug.cc
        wave_view.cc
        wave_view_private.cc)

ardour_includes(waveview PUBLIC .)
ardour_uselib(waveview SIGCPP PANGOMM CAIROMM BOOST XML TEMPORAL GLIBMM GIOMM)
ardour_use(waveview pbd canvas ardour gtkmm2ext temporal ytkmm)
target_compile_definitions(waveview PRIVATE
        LIBWAVEVIEW_DLL_EXPORTS=1
        "PACKAGE=\"libwaveview\"")
