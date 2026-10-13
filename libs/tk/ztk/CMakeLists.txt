# Port of libs/tk/ztk/wscript.

ardour_add_library(ztk SHARED)

target_sources(ztk PRIVATE
        atk-enum-types.c
        atkaction.c
        atkcomponent.c
        atkdocument.c
        atkeditabletext.c
        atkgobjectaccessible.c
        atkhyperlink.c
        atkhyperlinkimpl.c
        atkhypertext.c
        atkimage.c
        atkmisc.c
        atknoopobject.c
        atknoopobjectfactory.c
        atkobject.c
        atkobjectfactory.c
        atkplug.c
        atkprivate.c
        atkrange.c
        atkregistry.c
        atkrelation.c
        atkrelationset.c
        atkselection.c
        atksocket.c
        atkstate.c
        atkstateset.c
        atkstreamablecontent.c
        atktable.c
        atktablecell.c
        atktext.c
        atkutil.c
        atkvalue.c
        atkversion.c
        atkwindow.c)

ardour_includes(ztk PUBLIC . PRIVATE .. ztk)
# obj.use names 'libztk-pixbuf', which no wscript defines.
ardour_uselib(ztk GLIB GOBJECT)
target_compile_definitions(ztk PRIVATE
        HAVE_CONFIG_H
        _LARGEFILE64_SOURCE
        _REENTRANT
        "G_LOG_DOMAIN=\"Gdk\""
        ATK_COMPILATION
        _FILE_OFFSET_BITS=64
        G_DISABLE_SINGLE_INCLUDES
        ATK_DISABLE_SINGLE_INCLUDES
        G_DISABLE_DEPRECATED
        ATK_DISABLE_DEPRECATED
        "ATK_LOCALEDIR=\"\"")

if (APPLE)
    ardour_uselib(ztk OSX)
endif ()
