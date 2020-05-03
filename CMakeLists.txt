cmake_minimum_required(VERSION 3.0.0 FATAL_ERROR)

include(${CMAKE_CURRENT_LIST_DIR}/QtWasmCMake.cmake)

# Keep location for later use
set(QT_WASM_SOURCE_DIR ${QT_WASM_SOURCE_DIR} CACHE STRING "Source directory of QtWasmCMake.cmake" FORCE)
set(QT_WASM_QT_ROOT ${QT_WASM_QT_ROOT} CACHE STRING "Qt sdk root folder" FORCE)
set(QT_WASM_CMAKE_FOUND ON CACHE BOOL "QtWasmCMake have been found" FORCE)
set(QT_WASM_CMAKE_VERSION "1.0.0" CACHE STRING "QtWasmCMake version" FORCE)
