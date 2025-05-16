# - FindSDL3.cmake
#   Locate SDL3 for use with CMake
#   Sets SDL3_FOUND, SDL3_INCLUDE_DIRS, SDL3_LIBRARIES, SDL3_FRAMEWORK

if (NOT SDL3_FIND_ALREADY_CALLED)
    set(SDL3_FIND_ALREADY_CALLED TRUE)

    include(FindPackageHandleStandardArgs)

    # Default values
    set(SDL3_FOUND FALSE)
    set(SDL3_INCLUDE_DIRS "")
    set(SDL3_LIBRARIES "")
    set(SDL3_FRAMEWORK FALSE)

    # Source root for bundled libs
    set(_SDL3_ROOT "${CMAKE_SOURCE_DIR}/libs")

    # === macOS: look for SDL3.framework ===
    if (APPLE)
        # Framework path
        set(_framework_dir "${_SDL3_ROOT}/macos/SDL3.framework")
        if (EXISTS "${_framework_dir}" AND IS_DIRECTORY "${_framework_dir}")
            # Headers and library
            set(SDL3_FRAMEWORK TRUE)
            set(SDL3_FOUND TRUE)
            set(SDL3_INCLUDE_DIRS "${_framework_dir}/Headers")
            # The actual dylib is at SDL3.framework/SDL3
            find_library(SDL3_FRAMEWORK_PATH
                NAMES SDL3
                HINTS "${_framework_dir}"
            )
            if (SDL3_FRAMEWORK_PATH)
                set(SDL3_LIBRARIES "${SDL3_FRAMEWORK_PATH}")
            endif()
        endif()
    endif()

    # === Other platforms or fallback ===
    if (NOT SDL3_FOUND)
        # Look for headers: expecting include style <SDL3/SDL.h>
        find_path(SDL3_INCLUDE_DIR
            NAMES SDL3/SDL.h
            HINTS
                "${_SDL3_ROOT}/macos/SDL3.framework/Headers"
                "${_SDL3_ROOT}/linux/include"
                "${_SDL3_ROOT}/windows/include"
                "${CMAKE_SOURCE_DIR}/include"
            PATH_SUFFIXES include
        )

        # Look for library files
        find_library(SDL3_LIBRARY
            NAMES SDL3
            HINTS
                "${_SDL3_ROOT}/linux/lib"
                "${_SDL3_ROOT}/windows/lib"
        )

        if (SDL3_INCLUDE_DIR AND SDL3_LIBRARY)
            set(SDL3_FOUND TRUE)
            set(SDL3_INCLUDE_DIRS "${SDL3_INCLUDE_DIR}")
            set(SDL3_LIBRARIES "${SDL3_LIBRARY}")
        endif()
    endif()

    # Standard args handling
    find_package_handle_standard_args(SDL3 DEFAULT_MSG SDL3_FOUND SDL3_LIBRARIES SDL3_INCLUDE_DIRS)

    mark_as_advanced(SDL3_INCLUDE_DIRS SDL3_LIBRARIES SDL3_FRAMEWORK_PATH)
endif()
