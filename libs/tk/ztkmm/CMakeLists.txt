# Port of libs/tk/ztkmm/wscript.

ardour_add_library(ztkmm SHARED)

target_sources(ztkmm PRIVATE
        action.cc
        component.cc
        document.cc
        editabletext.cc
        hyperlink.cc
        hypertext.cc
        image.cc
        implementor.cc
        init.cc
        noopobject.cc
        object.cc
        objectaccessible.cc
        relation.cc
        relationset.cc
        selection.cc
        stateset.cc
        streamablecontent.cc
        table.cc
        text.cc
        value.cc
        wrap_init.cc)

ardour_includes(ztkmm PUBLIC .)
ardour_use(ztkmm ztk)
ardour_uselib(ztkmm GLIBMM SIGCPP)
target_compile_options(ztkmm PRIVATE -w)
target_compile_definitions(ztkmm PRIVATE
        _LARGEFILE64_SOURCE
        _REENTRANT
        "G_LOG_DOMAIN=\"atkmm\""
        ATKMM_BUILD=1
        _FILE_OFFSET_BITS=64)
