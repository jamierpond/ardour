# Port of libs/backends/wscript: one subdirectory per configured backend.

foreach (backend IN LISTS ARDOUR_BACKENDS)
    if (NOT EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${backend}/CMakeLists.txt")
        message(FATAL_ERROR "The '${backend}' backend has no CMake port yet (ARDOUR_BACKENDS)")
    endif ()
    add_subdirectory(${backend})
endforeach ()
