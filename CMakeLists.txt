cmake_minimum_required (VERSION 3.16)
project ($ENV{PROJECT_NAME} VERSION $ENV{PROJECT_VERSION} LANGUAGES CXX)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

file (GLOB CPP_FILES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} src/*.cpp)

# ADD SHARED OBJECT

add_library ($ENV{PROJECT_NAME} SHARED ${CPP_FILES})

target_include_directories ($ENV{PROJECT_NAME} PUBLIC include PRIVATE src/include)
target_precompile_headers ($ENV{PROJECT_NAME} PRIVATE src/include/private-pch.h)
set_property(TARGET $ENV{PROJECT_NAME} PROPERTY CXX_STANDARD 20)

include (GNUInstallDirs)

install (
    TARGETS $ENV{PROJECT_NAME}
    LIBRARY DESTINATION ${CMAKE_INSTALL_FULL_LIBDIR}
    COMPONENT bin
)

install (
    DIRECTORY ${PROJECT_SOURCE_DIR}/include/
    DESTINATION ${CMAKE_INSTALL_FULL_INCLUDEDIR}
    COMPONENT dev
)

# ADD SAMPLE APP

add_executable (main src/main.cpp)
add_dependencies (main $ENV{PROJECT_NAME})

target_include_directories (main PUBLIC include PRIVATE src/include)
target_precompile_headers (main PRIVATE src/include/private-pch.h)
target_link_libraries (main $ENV{PROJECT_NAME})
set_property(TARGET main PROPERTY CXX_STANDARD 20)

# ADD UNIT TESTS

enable_testing ()
include (GoogleTest)

file (GLOB files "tests/test*.cpp")
add_executable (tests ${files})
add_dependencies (tests $ENV{PROJECT_NAME})
target_include_directories (tests PUBLIC include)
target_precompile_headers (tests PRIVATE include/pch.h)
target_link_libraries (tests gtest_main gtest pthread $ENV{PROJECT_NAME})
set_property(TARGET tests PROPERTY CXX_STANDARD 20)
gtest_discover_tests (tests)

# Create Debian Package

set (CPACK_GENERATOR             DEB)
set (CPACK_PACKAGE_NAME          $ENV{PROJECT_NAME})
set (CPACK_PACKAGE_CONTACT       "Michael H.")
set (CPACK_PACKAGE_VERSION_MAJOR ${PROJECT_VERSION_MAJOR})
set (CPACK_PACKAGE_VERSION_MINOR ${PROJECT_VERSION_MINOR})
set (CPACK_PACKAGE_VERSION_PATCH ${PROJECT_VERSION_PATCH})
set (CPACK_RESOURCE_FILE_LICENSE ${PROJECT_SOURCE_DIR}/LICENSE)
set (CPACK_PACKAGE_DESCRIPTION_SUMMARY "Simple test object")
set (CPACK_DEB_COMPONENT_INSTALL ON)

set (CPACK_DEBIAN_BIN_DEBUGINFO_PACKAGE ON)
set (CPACK_DEBIAN_BIN_PACKAGE_NAME $ENV{PROJECT_NAME})
set (CPACK_DEBIAN_BIN_FILE_NAME $ENV{PROJECT_NAME}-$ENV{PROJECT_VERSION}-Linux.deb)

string (CONCAT CPACK_DEBIAN_DEV_PACKAGE_DEPENDS "$ENV{PROJECT_NAME} (=$ENV{PROJECT_VERSION})")

include (CPack)