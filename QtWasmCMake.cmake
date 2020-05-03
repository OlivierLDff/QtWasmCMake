cmake_minimum_required(VERSION 3.0)

# ┌──────────────────────────────────────────────────────────────────┐
# │                       ENVIRONMENT                                │
# └──────────────────────────────────────────────────────────────────┘

# find the Qt root directory
if(NOT Qt5Core_DIR)
  find_package(Qt5Core REQUIRED)
endif()
get_filename_component(QT_WASM_QT_ROOT "${Qt5Core_DIR}/../../.." ABSOLUTE)
message(STATUS "Found Qt SDK Root: ${QT_WASM_QT_ROOT}")

set(QT_WASM_SOURCE_DIR ${CMAKE_CURRENT_LIST_DIR})

# ┌──────────────────────────────────────────────────────────────────┐
# │                    GENERATE QML PLUGIN                           │
# └──────────────────────────────────────────────────────────────────┘

# We need to parse some arguments
include(CMakeParseArguments)

# Usage: add_qt_wasm_app(MyApp
#         # DISABLE_DEPLOYMENT
#         NAME "index")
function(add_qt_wasm_app TARGET)

  set(QT_WASM_OPTIONS DISABLE_DEPLOYMENT)
  set(QT_WASM_ONE_VALUE_ARG NAME)
  set(QT_WASM_MULTI_VALUE_ARG)

  # parse the macro arguments
  cmake_parse_arguments(ARGWASM "${QT_WASM_OPTIONS}" "${QT_WASM_ONE_VALUE_ARG}" "${QT_WASM_MULTI_VALUE_ARG}" ${ARGN})

  # Configure WebAssembly build settings
  # For some reason, the build settings need to be provided through the linker.
  # Most flags are configured to match Qt qmake
  # See EMCC_COMMON_LFLAGS in https://github.com/qt/qtbase/blob/dev/mkspecs/wasm-emscripten/qmake.conf

  # Activate Embind C/C++ bindings
  # https://emscripten.org/docs/porting/connecting_cpp_and_javascript/embind.html
  target_link_libraries(${TARGET} PUBLIC "--bind")

  # Activate WebGL 2 (in addition to WebGL 1)
  # https://emscripten.org/docs/porting/multimedia_and_graphics/OpenGL-support.html#webgl-friendly-subset-of-opengl-es-2-0-3-0
  target_link_libraries(${TARGET} PUBLIC "-s USE_WEBGL2=1")

  # Emulate missing OpenGL ES2/ES3 features
  # https://emscripten.org/docs/porting/multimedia_and_graphics/OpenGL-support.html#opengl-es-2-0-3-0-emulation
  target_link_libraries(${TARGET} PUBLIC "-s FULL_ES2=1")
  #add_link_options("SHELL:-s FULL_ES3=1")

  # Enable demangling of C++ stack traces
  # https://emscripten.org/docs/porting/Debugging.html
  target_link_libraries(${TARGET} PUBLIC "-s DEMANGLE_SUPPORT=1")

  # Run static dtors at teardown
  # https://emscripten.org/docs/getting_started/FAQ.html#what-does-exiting-the-runtime-mean-why-don-t-atexit-s-run
  target_link_libraries(${TARGET} PUBLIC "-s EXIT_RUNTIME=1")

  # Allows amount of memory used to change
  # https://emscripten.org/docs/optimizing/Optimizing-Code.html#memory-growth
  target_link_libraries(${TARGET} PUBLIC "-s ALLOW_MEMORY_GROWTH=1")
  # target_link_libraries(${TARGET} PUBLIC "-s MAXIMUM_MEMORY=1GB") # required when combining USE_PTHREADS with ALLOW_MEMORY_GROWTH

  # Enable C++ exception catching
  # https://emscripten.org/docs/optimizing/Optimizing-Code.html#c-exceptions
  target_compile_options(${TARGET} PUBLIC -fexceptions)
  target_link_libraries(${TARGET} PUBLIC "-s DISABLE_EXCEPTION_CATCHING=0")

  # Export UTF16ToString,stringToUTF16
  # Required by https://codereview.qt-project.org/c/qt/qtbase/+/286997 (since Qt 5.14)
  target_link_libraries(${TARGET} PUBLIC "-s EXTRA_EXPORTED_RUNTIME_METHODS=[UTF16ToString,stringToUTF16]")

  # Enable Fetch API
  # https://emscripten.org/docs/api_reference/fetch.html
  target_link_libraries(${TARGET} PUBLIC "-s FETCH=1")

  # Deploy default qt html/loader files
  if(NOT ARGWASM_DISABLE_DEPLOYMENT)

    if(NOT ARGWASM_NAME OR ARGWASM_NAME STREQUAL "")
      set(ARGWASM_NAME ${TARGET})
    endif()

    # APPNAME will configure html file
    set(APPNAME ${TARGET})

    configure_file("${QT_WASM_QT_ROOT}/plugins/platforms/wasm_shell.html"
                   "${CMAKE_CURRENT_BINARY_DIR}/${ARGWASM_NAME}.html")
    configure_file("${QT_WASM_QT_ROOT}/plugins/platforms/qtloader.js"
                  ${CMAKE_CURRENT_BINARY_DIR}/qtloader.js COPYONLY)
    configure_file("${QT_WASM_QT_ROOT}/plugins/platforms/qtlogo.svg"
                   ${CMAKE_CURRENT_BINARY_DIR}/qtlogo.svg COPYONLY)
  endif()
endfunction()