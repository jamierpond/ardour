# Port of libs/tk/ytk/wscript.

ardour_add_library(ytk SHARED)

target_sources(ytk PRIVATE
        fnmatch.c
        gtkaboutdialog.c
        gtkaccelgroup.c
        gtkaccellabel.c
        gtkaccelmap.c
        gtkaccessible.c
        gtkaction.c
        gtkactiongroup.c
        gtkactivatable.c
        gtkadjustment.c
        gtkaliasdef.c
        gtkalignment.c
        gtkarrow.c
        gtkaspectframe.c
        gtkassistant.c
        gtkbbox.c
        gtkbin.c
        gtkbindings.c
        gtkbox.c
        gtkbuildable.c
        gtkbuilder.c
        gtkbuilderparser.c
        gtkbutton.c
        gtkcelleditable.c
        gtkcelllayout.c
        gtkcellrenderer.c
        gtkcellrendereraccel.c
        gtkcellrenderercombo.c
        gtkcellrendererpixbuf.c
        gtkcellrendererprogress.c
        gtkcellrendererspin.c
        gtkcellrendererspinner.c
        gtkcellrenderertext.c
        gtkcellrenderertoggle.c
        gtkcellview.c
        gtkcheckbutton.c
        gtkcheckmenuitem.c
        gtkcolorbutton.c
        gtkcolorsel.c
        gtkcolorseldialog.c
        gtkcombobox.c
        gtkcomboboxentry.c
        gtkcomboboxtext.c
        gtkcontainer.c
        gtkdialog.c
        gtkdrawingarea.c
        gtkeditable.c
        gtkentry.c
        gtkentrybuffer.c
        gtkentrycompletion.c
        gtkeventbox.c
        gtkexpander.c
        gtkfilechooser.c
        gtkfilechooserbutton.c
        gtkfilechooserdefault.c
        gtkfilechooserdialog.c
        gtkfilechooserembed.c
        gtkfilechooserentry.c
        gtkfilechoosersettings.c
        gtkfilechooserutils.c
        gtkfilechooserwidget.c
        gtkfilefilter.c
        gtkfilesystem.c
        gtkfilesystemmodel.c
        gtkfixed.c
        gtkfontbutton.c
        gtkfontsel.c
        gtkframe.c
        gtkgc.c
        gtkhandlebox.c
        gtkhbbox.c
        gtkhbox.c
        gtkhpaned.c
        gtkhruler.c
        gtkhscale.c
        gtkhscrollbar.c
        gtkhseparator.c
        gtkhsv.c
        gtkiconcache.c
        gtkiconcachevalidator.c
        gtkiconfactory.c
        gtkicontheme.c
        gtkiconview.c
        gtkimage.c
        gtkimagemenuitem.c
        gtkimcontext.c
        gtkimcontextsimple.c
        gtkimmodule.c
        gtkimmulticontext.c
        gtkinfobar.c
        gtkinvisible.c
        gtkitem.c
        gtkkeyhash.c
        gtklabel.c
        gtklayout.c
        gtklinkbutton.c
        gtkliststore.c
        gtkmain.c
        gtkmarshal.c
        gtkmarshalers.c
        gtkmenu.c
        gtkmenubar.c
        gtkmenuitem.c
        gtkmenushell.c
        gtkmenutoolbutton.c
        gtkmessagedialog.c
        gtkmisc.c
        gtkmnemonichash.c
        gtkmodules.c
        gtkmountoperation.c
        gtknotebook.c
        gtkobject.c
        gtkoffscreenwindow.c
        gtkoptionmenu.c
        gtkorientable.c
        gtkpaned.c
        gtkpango.c
        gtkpathbar.c
        gtkplug.c
        gtkprogress.c
        gtkprogressbar.c
        gtkquery.c
        gtkradioaction.c
        gtkradiobutton.c
        gtkradiomenuitem.c
        gtkradiotoolbutton.c
        gtkrange.c
        gtkrbtree.c
        gtkrc.c
        gtkrecentaction.c
        gtkrecentchooser.c
        gtkrecentchooserdefault.c
        gtkrecentchooserdialog.c
        gtkrecentchoosermenu.c
        gtkrecentchooserutils.c
        gtkrecentchooserwidget.c
        gtkrecentfilter.c
        gtkrecentmanager.c
        gtkruler.c
        gtkscale.c
        gtkscalebutton.c
        gtkscrollbar.c
        gtkscrolledwindow.c
        gtksearchengine.c
        gtksearchenginesimple.c
        gtkselection.c
        gtkseparator.c
        gtkseparatormenuitem.c
        gtkseparatortoolitem.c
        gtksettings.c
        gtkshow.c
        gtksizegroup.c
        gtksocket.c
        gtkspinbutton.c
        gtkspinner.c
        gtkstatusbar.c
        gtkstock.c
        gtkstyle.c
        gtktable.c
        gtktearoffmenuitem.c
        gtktextbtree.c
        gtktextbuffer.c
        gtktextbufferrichtext.c
        gtktextbufferserialize.c
        gtktextchild.c
        gtktextdisplay.c
        gtktextiter.c
        gtktextlayout.c
        gtktextmark.c
        gtktextsegment.c
        gtktexttag.c
        gtktexttagtable.c
        gtktexttypes.c
        gtktextutil.c
        gtktextview.c
        gtkthemes.c
        gtktoggleaction.c
        gtktogglebutton.c
        gtktoggletoolbutton.c
        gtktoolbar.c
        gtktoolbutton.c
        gtktoolitem.c
        gtktoolitemgroup.c
        gtktoolpalette.c
        gtktoolshell.c
        gtktooltip.c
        gtktooltips.c
        gtktreedatalist.c
        gtktreednd.c
        gtktreemodel.c
        gtktreemodelfilter.c
        gtktreemodelsort.c
        gtktreeselection.c
        gtktreesortable.c
        gtktreestore.c
        gtktreeview.c
        gtktreeviewcolumn.c
        gtktypebuiltins.c
        gtktypeutils.c
        gtkuimanager.c
        gtkvbbox.c
        gtkvbox.c
        gtkviewport.c
        gtkvpaned.c
        gtkvruler.c
        gtkvscale.c
        gtkvscrollbar.c
        gtkvseparator.c
        gtkwidget.c
        gtkwindow-decorate.c
        gtkwindow.c)

ardour_includes(ytk PUBLIC . PRIVATE ytk)
ardour_use(ytk ztk ydk-pixbuf ydk)
ardour_uselib(ytk GLIB GIO PANGO CAIRO PANGOCAIRO GMODULE)
target_compile_options(ytk PRIVATE -w)
# 'DATK_DISABLE_SINGLE_INCLUDES' (sic) is what the wscript defines.
target_compile_definitions(ytk PRIVATE
        HAVE_CONFIG_H
        _LARGEFILE64_SOURCE
        _REENTRANT
        "G_LOG_DOMAIN=\"Gtk\""
        GTK_COMPILATION
        _FILE_OFFSET_BITS=64
        GTK_DISABLE_DEPRECATED
        G_DISABLE_CAST_CHECKS
        G_DISABLE_SINGLE_INCLUDES
        DATK_DISABLE_SINGLE_INCLUDES
        GDK_PIXBUF_DISABLE_SINGLE_INCLUDES
        GTK_DISABLE_SINGLE_INCLUDES
        GDK_PIXBUF_DISABLE_DEPRECATED
        "GTK_PRINT_BACKENDS=\"file,lpr\""
        GTK_PRINT_BACKEND_ENABLE_UNSUPPORTED
        "GTK_PRINT_PREVIEW_COMMAND=\"\""
        _POSIX_C_SOURCE=200809L
        "GTK_VERSION=\"2.24.23\""
        "GTK_BINARY_VERSION=\"2.10.0\""
        "GTK_HOST=\"ardour\""
        "PACKAGE=\"ytk${ARDOUR_VERSION_MAJOR}\""
        "GETTEXT_PACKAGE=\"ytk${ARDOUR_VERSION_MAJOR}\""
        "GTK_DATA_PREFIX=\"${CMAKE_INSTALL_PREFIX}\""
        "GTK_SYSCONFDIR=\"${CMAKE_INSTALL_FULL_SYSCONFDIR}\""
        "GTK_DATA_DIR=\"${ARDOUR_DATADIR}\""
        "GTK_LIBDIR=\"${ARDOUR_DLLDIR}\""
        "GTK_LOCALEDIR=\"${ARDOUR_LOCALEDIR}\"")

if (APPLE)
    target_sources(ytk PRIVATE
                gtkclipboard-quartz.c
                gtkdnd-quartz.c
                gtkmountoperation-stub.c
                gtkplug-stub.c
                gtkquartz.c
                gtksearchenginequartz.c
                gtksocket-stub.c)
    target_compile_options(ytk PRIVATE -xobjective-c)
    ardour_uselib(ytk OSX)
    # Deviation, same reason as libs/tk/ydk: keep gtkaliasdef.c from emitting
    # ELF aliases on Mach-O when glib defines G_HAVE_GNUC_VISIBILITY.
    target_compile_definitions(ytk PRIVATE DISABLE_VISIBILITY)
elseif (WIN32)
    target_sources(ytk PRIVATE
                gtkclipboard.c
                gtkdnd.c
                gtkplug-win32.c
                gtksocket-win32.c
                gtkwin32embed.c
                gtkwin32embedwidget.c
                gtkmountoperation-stub.c)
    target_compile_definitions(ytk PRIVATE INSIDE_GTK_WIN32 DLL_EXPORT PIC)
    target_link_libraries(ytk PRIVATE imm32 ole32 gdi32 comdlg32 winspool comctl32 uuid)
else ()
    target_sources(ytk PRIVATE
                gtkclipboard.c
                gtkdnd.c
                gtkmountoperation-x11.c
                gtkplug-x11.c
                gtksocket-x11.c
                gtkxembed.c)
    ardour_uselib(ytk X11 XEXT)
endif ()
