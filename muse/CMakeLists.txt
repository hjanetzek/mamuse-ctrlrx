# ctrlrLib: CtrlrX as a static library, to run panels inside another plugin. CtrlrProcessor is then an AudioProcessor
# owned by that plugin instead of being the plugin itself (CTRLR_EMBEDDED).
#
# The parent project provides JUCE 7 and a static library with the code of the JUCE modules, passed as
# CTRLR_JUCE_MODULES_TARGET. It needs juce_audio_utils, juce_cryptography, juce_gui_extra and juce_product_unlocking,
# and JUCE_MODAL_LOOPS_PERMITTED=1. boost (headers), LuaJIT and libusb are the system's.

cmake_minimum_required(VERSION 3.15)

set(CTRLR_ROOT ${CMAKE_CURRENT_LIST_DIR}/..)
set(CTRLR_SOURCE ${CTRLR_ROOT}/Source)

if(NOT CTRLR_JUCE_MODULES_TARGET)
	message(FATAL_ERROR "ctrlrLib: set CTRLR_JUCE_MODULES_TARGET to the library with the JUCE modules")
endif()

find_package(PkgConfig REQUIRED)
pkg_check_modules(CTRLR_LUAJIT REQUIRED IMPORTED_TARGET luajit)
pkg_check_modules(CTRLR_LIBUSB REQUIRED IMPORTED_TARGET libusb-1.0)
find_package(Boost REQUIRED)

file(GLOB_RECURSE CTRLR_SOURCES CONFIGURE_DEPENDS
	"${CTRLR_SOURCE}/Misc/luabind/*.cpp"
	"${CTRLR_SOURCE}/Misc/*.c*"
	"${CTRLR_SOURCE}/Core/*.cpp"
	"${CTRLR_SOURCE}/Lua/*.cpp"
	"${CTRLR_SOURCE}/MIDI/*.cpp"
	"${CTRLR_SOURCE}/Native/*.cpp"
	"${CTRLR_SOURCE}/Plugin/*.cpp"
	"${CTRLR_SOURCE}/UIComponents/*.cpp"
)
list(FILTER CTRLR_SOURCES EXCLUDE REGEX "/Source/Misc/luabind/(examples|build[^/]*|test|tests)/")
list(FILTER CTRLR_SOURCES EXCLUDE REGEX "/Source/Lua/Deprecated/CtrlrLuaFile\\.cpp$")
# the application around the plugin
list(FILTER CTRLR_SOURCES EXCLUDE REGEX "/Source/Core/StandaloneWrapper/")
if(NOT (UNIX AND NOT APPLE))
	list(FILTER CTRLR_SOURCES EXCLUDE REGEX "/CtrlrLinux\\.cpp$")
endif()

# the resources (fonts, icons, Lua) as namespace CtrlrBinaryData, muse/include-lib/BinaryData.h makes it BinaryData
file(GLOB_RECURSE CTRLR_RESOURCES CONFIGURE_DEPENDS "${CTRLR_SOURCE}/Resources/*")
list(FILTER CTRLR_RESOURCES EXCLUDE REGEX "/\\.DS_Store$")
juce_add_binary_data(ctrlrBinaryData HEADER_NAME CtrlrBinaryData.h NAMESPACE CtrlrBinaryData SOURCES ${CTRLR_RESOURCES})
set_target_properties(ctrlrBinaryData PROPERTIES POSITION_INDEPENDENT_CODE TRUE)

add_library(ctrlrLib STATIC)
target_sources(ctrlrLib PRIVATE ${CTRLR_SOURCES})

# luabind's object_rep.cpp is miscompiled with optimisation, see the CMakeLists.txt of CtrlrX
set_source_files_properties("${CTRLR_SOURCE}/Misc/luabind/src/object_rep.cpp" PROPERTIES COMPILE_OPTIONS "-O0")

target_include_directories(ctrlrLib PUBLIC
	"${CMAKE_CURRENT_LIST_DIR}/include"
	"${CTRLR_SOURCE}"
	"${CTRLR_SOURCE}/Misc"
	"${CTRLR_SOURCE}/Misc/rapidfuzz"
	"${CTRLR_SOURCE}/Misc/include"
	"${CTRLR_SOURCE}/Misc/luabind"
	"${CTRLR_SOURCE}/MIDI"
	"${CTRLR_SOURCE}/Core"
	"${CTRLR_SOURCE}/Core/CtrlrManager"
	"${CTRLR_SOURCE}/Core/CtrlrModulator"
	"${CTRLR_SOURCE}/Core/CtrlrPanel"
	"${CTRLR_SOURCE}/Native"
	"${CTRLR_SOURCE}/Plugin"
	"${CTRLR_SOURCE}/UIComponents"
	"${CTRLR_SOURCE}/Lua"
)

target_compile_definitions(ctrlrLib PUBLIC
	CTRLR_EMBEDDED=1
	CTRLRX_USE_LUAJIT=1
	BOOST_BIND_GLOBAL_PLACEHOLDERS=1
	JUCE_GLOBAL_MODULE_SETTINGS_INCLUDED=1
	JUCE_MODULE_AVAILABLE_juce_audio_basics=1
	JUCE_MODULE_AVAILABLE_juce_audio_devices=1
	JUCE_MODULE_AVAILABLE_juce_audio_formats=1
	JUCE_MODULE_AVAILABLE_juce_audio_processors=1
	JUCE_MODULE_AVAILABLE_juce_audio_utils=1
	JUCE_MODULE_AVAILABLE_juce_core=1
	JUCE_MODULE_AVAILABLE_juce_cryptography=1
	JUCE_MODULE_AVAILABLE_juce_data_structures=1
	JUCE_MODULE_AVAILABLE_juce_events=1
	JUCE_MODULE_AVAILABLE_juce_graphics=1
	JUCE_MODULE_AVAILABLE_juce_gui_basics=1
	JUCE_MODULE_AVAILABLE_juce_gui_extra=1
	JUCE_MODULE_AVAILABLE_juce_product_unlocking=1
	$<$<PLATFORM_ID:Linux>:_GLIBCXX_USE_DEPRECATED=1>
)

file(READ "${CTRLR_ROOT}/VERSION" CTRLR_VERSION)
string(STRIP "${CTRLR_VERSION}" CTRLR_VERSION)
# for muse/include/JuceHeader.h
target_compile_definitions(ctrlrLib PUBLIC CTRLR_VERSION_STRING="${CTRLR_VERSION}")

if(UNIX)
	# CtrlrX is built with all warnings off
	target_compile_options(ctrlrLib PRIVATE -w -fPIC)
endif()

target_link_libraries(ctrlrLib PRIVATE ctrlrBinaryData)
target_include_directories(ctrlrLib PRIVATE "${CMAKE_CURRENT_LIST_DIR}/include-lib")
target_compile_definitions(ctrlrLib PRIVATE CTRLR_LIB_BUILD=1)
target_link_libraries(ctrlrLib PUBLIC PkgConfig::CTRLR_LUAJIT PkgConfig::CTRLR_LIBUSB Boost::headers)
# the compile definitions of the JUCE modules, and their code after this library on the link line
target_link_libraries(ctrlrLib PRIVATE $<COMPILE_ONLY:${CTRLR_JUCE_MODULES_TARGET}>)
target_link_libraries(ctrlrLib INTERFACE $<LINK_ONLY:${CTRLR_JUCE_MODULES_TARGET}>)
