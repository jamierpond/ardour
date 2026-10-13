# Port of libs/canvas/wscript.

ardour_add_library(canvas SHARED)

target_sources(canvas PRIVATE
        arc.cc
        arrow.cc
        box.cc
        button.cc
        canvas.cc
        circle.cc
        container.cc
        curve.cc
        debug.cc
        item.cc
        fill.cc
        flag.cc
        framed_curve.cc
        grid.cc
        image.cc
        line.cc
        line_set.cc
        lollipop.cc
        lookup_table.cc
        meter.cc
        note.cc
        outline.cc
        pixbuf.cc
        poly_item.cc
        poly_line.cc
        polygon.cc
        rectangle.cc
        rect_set.cc
        root_group.cc
        ruler.cc
        scroll_group.cc
        stateful_image.cc
        step_button.cc
        table.cc
        text.cc
        tracking_text.cc
        types.cc
        utils.cc
        widget.cc
        xfade_curve.cc)

ardour_includes(canvas PUBLIC .)
ardour_uselib(canvas SIGCPP CAIROMM PANGOMM BOOST XML OSX LIBMM GIOMM PANGOCAIRO)
ardour_use(canvas pbd gtkmm2ext ytkmm)
target_compile_definitions(canvas PRIVATE
        LIBCANVAS_DLL_EXPORTS=1
        "PACKAGE=\"libcanvas\"")
