# Port of libs/lua/wscript.

ardour_add_library(lua STATIC OUTPUT_NAME liblua)

target_sources(lua PRIVATE lua.cc luastate.cc)

ardour_includes(lua PUBLIC .)
ardour_uselib(lua SIGCPP DL)
# autowaf.ensure_visible_symbols(obj, True)
target_compile_options(lua PRIVATE -fvisibility=default)
