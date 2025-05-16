cmake_minimum_required(VERSION 3.20)
project(SDL3TestApp VERSION 1.0 LANGUAGES C CXX)

# Load environment variables directly from .env
set(ENV_FILE_PATH "${CMAKE_SOURCE_DIR}/.env")
if(EXISTS "${ENV_FILE_PATH}")
    file(READ "${ENV_FILE_PATH}" _env_content)
    string(REGEX MATCH "APPLE_TEAM_ID=([A-Za-z0-9]+)" _ ${_env_content})
    if(NOT CMAKE_MATCH_1)
        message(FATAL_ERROR "APPLE_TEAM_ID not found in ${ENV_FILE_PATH}")
    endif()
    set(APPLE_TEAM_ID "${CMAKE_MATCH_1}")
else()
    message(FATAL_ERROR ".env file not found at ${ENV_FILE_PATH}")
endif()

# Set C and C++ standards
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Add custom CMake modules for FindSDL3.cmake
list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake")

# Locate SDL3 using FindSDL3.cmake
find_package(SDL3 REQUIRED)

# Collect source files
file(GLOB_RECURSE SOURCES
    "${CMAKE_SOURCE_DIR}/src/*.c"
    "${CMAKE_SOURCE_DIR}/src/*.cpp"
)

# Create executable (bundle on macOS)
if(APPLE)
    set(CMAKE_OSX_DEPLOYMENT_TARGET "10.13" CACHE STRING "Minimum macOS deployment version")
    add_executable(MyApp MACOSX_BUNDLE ${SOURCES})
else()
    add_executable(MyApp ${SOURCES})
endif()

# Include and link SDL3
target_include_directories(MyApp PRIVATE ${SDL3_INCLUDE_DIRS})
target_link_libraries(MyApp PRIVATE ${SDL3_LIBRARIES})

# Platform-specific post-build and rpath settings
if(WIN32 AND NOT SDL3_FRAMEWORK)
    # Copy SDL3.dll next to executable
    get_filename_component(SDL3_LIB_DIR ${SDL3_LIBRARIES} DIRECTORY)
    add_custom_command(TARGET MyApp POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
            "${SDL3_LIB_DIR}/SDL3.dll"
            $<TARGET_FILE_DIR:MyApp>
    )
endif()

if(APPLE)
    # Embed and sign framework
    set_target_properties(MyApp PROPERTIES
        XCODE_EMBED_FRAMEWORKS "${CMAKE_SOURCE_DIR}/libs/macos/SDL3.framework"
        XCODE_EMBED_FRAMEWORKS_CODE_SIGN_ON_COPY TRUE
        XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY "Apple Development"
        XCODE_ATTRIBUTE_DEVELOPMENT_TEAM "${APPLE_TEAM_ID}"
        XCODE_ATTRIBUTE_CODE_SIGN_STYLE "Automatic"
        XCODE_ATTRIBUTE_ENABLE_HARDENED_RUNTIME TRUE
        XCODE_ATTRIBUTE_RUNTIME_SEARCH_PATHS "@executable_path/../Frameworks"
        # Ensure runtime load path includes bundled frameworks
        INSTALL_RPATH "@executable_path/../Frameworks"
        BUILD_WITH_INSTALL_RPATH TRUE
    )
endif()
