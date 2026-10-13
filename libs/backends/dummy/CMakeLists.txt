# Port of libs/backends/dummy/wscript.

ardour_add_library(dummy_audiobackend SHARED)
target_sources(dummy_audiobackend PRIVATE
        dummy_audiobackend.cc)
ardour_includes(dummy_audiobackend PRIVATE .)
ardour_use(dummy_audiobackend ardour pbd ltc)
ardour_uselib(dummy_audiobackend GLIBMM XML OSX)
target_compile_definitions(dummy_audiobackend PRIVATE
        "PACKAGE=\"dummy-backend\""
        ARDOURBACKEND_DLL_EXPORTS)
