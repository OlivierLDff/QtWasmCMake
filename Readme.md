# 🌍 Qt Wasm CMake

## Minimum working example

Try it now with [QQuickStaticHelloWorld](https://github.com/OlivierLDff/QQuickStaticHelloWorld). This is a minimal CMake project for Qt application compatible with Wasm.

## Introduction

This project aim is to provide a CMake function to replicate `qmake` behavior when building a project with [Qt for WebAssembly](https://doc.qt.io/qt-5/wasm.html). The script provide a function `add_qt_wasm_app` that will set linker flags required by Qt to work with Emscripten. It will also deploy Qt template file that can load your application.

This generates the following files:

| Generated file |     Brief Description      |
| :------------: | :------------------------: |
|  YourApp.html  |       HTML container       |
|  qtloader.js   | JS API for loading Qt apps |
|   YourApp.js   | JS API for loading Qt apps |
|  YourApp.wasm  |   emscripten app binary    |

## 🔧 Usage

```bash
add_qt_wasm_app(YourApp
  NAME "index"
  DISABLE_DEPLOYMENT)
```

**NAME**

Specify the name of the HTML container. By default it will be the target name. This option can be useful to automatically generate a `index.html`.

**DISABLE_DEPLOYMENT**

Disable the deployment of Qt file. The compilation will only leave you with a `YourApp.js` and `YourApp.wasm`. You will need to provide your own `qtloader.js` that load the qt application, and an html file to embed the app into a `canvas`.

*NAME doesn't have any effect with this option set.*

## ✏️ CMake Integration

Just calling `add_qt_wasm_app` won't be enough if you are using QML plugins. Since we are linking with a version of qt that is static, you need to add a few extra steps.

Those steps won't be necessary in the future when Qt will have better support of Qt.

### Link to static Qt plugin

The easiest way is to use [QtStaticCMake](https://github.com/OlivierLDff/QtStaticCMake).

```cmake
get_target_property(QT_TARGET_TYPE Qt5::Core TYPE)
if(${QT_TARGET_TYPE} STREQUAL "STATIC_LIBRARY")
  include(QtStaticCMake.cmake)
  qt_generate_plugin_import(YourApp VERBOSE)
  # This function assert that your qml are in qml/
  qt_generate_qml_plugin_import(YourApp
    QML_SRC ${CMAKE_CURRENT_SOURCE_DIR}/qml)
endif()
```

Soon you will be able to replace this with `qt5_import_qml_plugins` and `qt5_import_plugins`.

###Link to Emscripten

Then simply use this script function.

```cmake
if(${CMAKE_SYSTEM_NAME} STREQUAL "Emscripten")
  include(QtWasmCMake.cmake)
  add_qt_wasm_app(YourApp)
endif()
```

## 🚀 Run CMake

Since you are cross compiling, when executing cmake you need to add a cmake toolchain.

```bash
cmake -DCMAKE_TOOLCHAIN_FILE=$EMSDK/upstream/emscripten/cmake/Modules/Platform/Emscripten.cmake -DCMAKE_PREFIX_PATH=$QT_WASM ..
```

`emsdk` also come with `emcmake` command that set the toolchain variable for you.

```bash
emcmake cmake -DCMAKE_PREFIX_PATH=$QT_WASM ..
```

You can also use a docker container that will make your life way easier. Checkout [reivilo1234/qt-webassembly-cmake](https://hub.docker.com/r/reivilo1234/qt-webassembly-cmake). In this container `cmake` is already aliases as `emcmake cmake` and qt sdk is installed so it is immediatly found by cmake. You can just run `cmake ..` in this container.

## Reference

* This whole work is based on [forderud](https://github.com/forderud/QtWasm)
* [Using Docker to test Qt WebAssembly](https://blog.qt.io/blog/2019/03/05/using-docker-test-qt-webassembly/)
* [CMake Toolchain](https://github.com/emscripten-core/emscripten/blob/incoming/cmake/Modules/Platform/Emscripten.cmake)
* [QtStaticMake](https://github.com/OlivierLDff/QtStaticCMake)
* [ManmanFred docker container](https://hub.docker.com/r/madmanfred/qt-webassembly)