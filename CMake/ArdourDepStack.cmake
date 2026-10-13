# Where the third-party dependency stack comes from.
#
# waf finds everything through pkg-config and the environment: PKG_CONFIG_PATH,
# --depstack-root (~/gtk/inst, ~/a3/inst for Ardour's private stack), and
# --boost-include / --also-include / --also-libdir for whatever has no .pc file.
# Here the same roots go on CMAKE_PREFIX_PATH, which pkg_check_modules (via
# <prefix>/lib/pkgconfig) and every find_package/find_library both search, so
# one list feeds both kinds of lookup.
#
#   ARDOUR_DEPSTACK_ROOT  a private stack prefix (e.g. ~/gtk/inst); searched
#                         first. Empty by default.
#   Homebrew (macOS)      used when present, including the keg-only formulae
#                         Ardour needs (curl, libarchive, libxml2), which do not
#                         link into the Homebrew prefix and so are invisible to
#                         a plain pkg-config search.

set(ARDOUR_DEPSTACK_ROOT "" CACHE PATH
        "Private dependency stack prefix to search first (waf: --depstack-root/PKG_CONFIG_PATH)")

if (ARDOUR_DEPSTACK_ROOT)
    list(PREPEND CMAKE_PREFIX_PATH "${ARDOUR_DEPSTACK_ROOT}")
endif ()

if (APPLE)
    find_program(ARDOUR_BREW brew PATHS /opt/homebrew/bin /usr/local/bin)
    if (ARDOUR_BREW)
        execute_process(COMMAND "${ARDOUR_BREW}" --prefix
                OUTPUT_VARIABLE ARDOUR_BREW_PREFIX
                OUTPUT_STRIP_TRAILING_WHITESPACE
                ERROR_QUIET)
    endif ()

    if (ARDOUR_BREW_PREFIX)
        foreach (keg curl libarchive libxml2)
            if (IS_DIRECTORY "${ARDOUR_BREW_PREFIX}/opt/${keg}")
                list(APPEND CMAKE_PREFIX_PATH "${ARDOUR_BREW_PREFIX}/opt/${keg}")
            endif ()
        endforeach ()
        list(APPEND CMAKE_PREFIX_PATH "${ARDOUR_BREW_PREFIX}")
    endif ()
endif ()
