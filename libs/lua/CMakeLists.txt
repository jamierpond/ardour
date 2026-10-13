# libs/lua/wscript
ardour_target(lua STATIC GLOB
        OUTPUT_NAME liblua
        INCLUDES .
        EXPORT_INCLUDES .
        USELIB SIGCPP DL
        OPTIONS -fvisibility=default)
