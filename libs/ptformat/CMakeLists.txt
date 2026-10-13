# Port of libs/ptformat/wscript.

ardour_add_library(ptformat SHARED)

target_sources(ptformat PRIVATE ptformat.cc)

ardour_includes(ptformat PUBLIC .)
ardour_use(ptformat pbd)
ardour_uselib(ptformat GLIBMM)
target_compile_definitions(ptformat PRIVATE
        LIBPTFORMAT_DLL_EXPORTS=1
        "PACKAGE=\"libptformat\"")
