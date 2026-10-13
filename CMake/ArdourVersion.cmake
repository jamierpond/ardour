# The program version, derived from git exactly the way the root wscript's
# set_version() does it, so a CMake and a waf build of the same commit report
# the same VERSION / PROGRAM_VERSION. The parsing lives in
# scripts/ardour-version.py; this only reads its answer.
#
#   git describe HEAD  ->  9.8-207-g488c059492
#   ARDOUR_VERSION_MAJOR 9, _MINOR 8, _MICRO 207, ARDOUR_VERSION 9.8.207,
#   ARDOUR_PROGRAM_VERSION 9, ARDOUR_REVISION, ARDOUR_REVISION_DATE

# Python is a build requirement anyway: gtk2_ardour runs tools/fmt-bindings.py.
find_package(Python3 REQUIRED COMPONENTS Interpreter)

function(ardour_detect_version)
    execute_process(
            COMMAND "${Python3_EXECUTABLE}" "${PROJECT_SOURCE_DIR}/scripts/ardour-version.py" --json
            OUTPUT_VARIABLE json
            COMMAND_ERROR_IS_FATAL ANY)

    foreach (key major minor micro version revision date)
        string(JSON value GET "${json}" ${key})
        set(v_${key} "${value}")
    endforeach ()

    set(ARDOUR_VERSION_MAJOR "${v_major}" PARENT_SCOPE)
    set(ARDOUR_VERSION_MINOR "${v_minor}" PARENT_SCOPE)
    set(ARDOUR_VERSION_MICRO "${v_micro}" PARENT_SCOPE)
    set(ARDOUR_VERSION "${v_version}" PARENT_SCOPE)
    set(ARDOUR_PROGRAM_VERSION "${v_major}" PARENT_SCOPE)
    set(ARDOUR_REVISION "${v_revision}" PARENT_SCOPE)
    set(ARDOUR_REVISION_DATE "${v_date}" PARENT_SCOPE)

    # Re-run configure when HEAD moves, so the version macros follow it.
    if (EXISTS "${PROJECT_SOURCE_DIR}/.git/HEAD")
        set_property(DIRECTORY "${PROJECT_SOURCE_DIR}" APPEND PROPERTY
                CMAKE_CONFIGURE_DEPENDS
                "${PROJECT_SOURCE_DIR}/.git/HEAD"
                "${PROJECT_SOURCE_DIR}/scripts/ardour-version.py")
    endif ()
endfunction()
