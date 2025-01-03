################################################################################
# Common Library Configuration
#
# This script provides common configurations and options for all libraries,
# including paths, build options, package management, and compiler settings.
#
# Definitions:
# - INSTALL_LIBDIR: Directory for installed library files.
# - INSTALL_INCLUDEDIR: Directory for installed header files.
# - INSTALL_BINDIR: Directory for installed binaries.
# - INSTALL_DOCDIR: Directory for installed documentation.
#
# Options:
# - DEBUG: Enable debugging features (default OFF).
# - ADDRESS_SANITIZER: Enable Address Sanitizer (default OFF).
# - SHARED_BUILD: Build shared libraries (default OFF).
# - STATIC_BUILD: Build static libraries (default ON).
# - DEBUG_BUILD: Build debug libraries (default ON).
# - BUILD_TESTING: Enable building tests (default OFF).
# - ENABLE_CODE_COVERAGE: Enable code coverage reporting (default OFF).
# - ENABLE_CLANG_TIDY: Enable Clang-Tidy analysis (default OFF).
#
# Compiler Settings:
# - CMAKE_C_STANDARD: Set the C standard (default 23).
# - ADDRESS_SANITIZER: Adds `-fsanitize=address` if enabled.
# - ENABLE_CLANG_TIDY: Sets Clang-Tidy as the CMake analysis tool if enabled.
#
# Code Coverage:
# - Includes the CodeCoverage.cmake file for managing code coverage options.
#
# Package Management:
# - Dynamically finds and manages custom and third-party packages.
# - Constructs package groups for static, debug, and shared libraries.
# - Unsets variables if no packages are defined to prevent configuration errors.
#
# Example Usage:
#
# cmake_minimum_required(VERSION 3.10)
#
# # Project Configuration
# project(amemorylibrary VERSION 0.1.1)
#
# # Variables
# set(INCLUDE_DIR_NAME "a-memory-library")
# set(EXTRA_FILES README.md AUTHORS NEWS.md CHANGELOG.md LICENSE NOTICE)
# set(CUSTOM_PACKAGES themacrolibrary)
#
# # Source files
# file(GLOB SOURCE_FILES src/*.c)
#
# # Locate and include the CMake library
# find_package(a-cmake-library REQUIRED)
#
# include(LibraryConfig)  # Load common configuration
# include(LibraryBuild)   # Configure the library build process
#
# # Testing
# if(BUILD_TESTING)
#     enable_testing()
#     add_subdirectory(tests)
# endif()
################################################################################

# Common to all libraries
set(INSTALL_LIBDIR lib)
set(INSTALL_INCLUDEDIR include)
set(INSTALL_BINDIR bin)
set(INSTALL_DOCDIR share/doc/${PROJECT_NAME})

# Options
option(DEBUG "Enable debugging" OFF)
option(ADDRESS_SANITIZER "Enable Address Sanitizer" OFF)
option(SHARED_BUILD "Build shared libraries" OFF)
option(STATIC_BUILD "Build static libraries" ON)
option(DEBUG_BUILD "Build debug libraries" ON)
option(BUILD_TESTING "Build tests" OFF)
option(ENABLE_CODE_COVERAGE "Enable code coverage reporting" OFF)
option(ENABLE_CLANG_TIDY "Enable Clang-Tidy analysis" OFF)

# C version
set(CMAKE_C_STANDARD 23)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS OFF)

# Compiler options
if(ADDRESS_SANITIZER)
    add_compile_options(-fsanitize=address)
endif()

if(ENABLE_CLANG_TIDY)
    set(CMAKE_C_CLANG_TIDY clang-tidy)
endif()

include(${CMAKE_CURRENT_LIST_DIR}/BinaryLibraryFunctions.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/CodeCoverage.cmake)

# Undefine empty variables
if(NOT DEFINED CUSTOM_PACKAGES OR CUSTOM_PACKAGES STREQUAL "")
    unset(CUSTOM_PACKAGES)
endif()

if(NOT DEFINED THIRD_PARTY_PACKAGES OR THIRD_PARTY_PACKAGES STREQUAL "")
    unset(THIRD_PARTY_PACKAGES)
endif()

# Find all custom packages
if(DEFINED CUSTOM_PACKAGES)
    foreach(PACKAGE ${CUSTOM_PACKAGES})
        message(STATUS "find_package ${PACKAGE}")
        find_package(${PACKAGE} REQUIRED)
    endforeach()
endif()

# Find all third-party packages
if(DEFINED THIRD_PARTY_PACKAGES)
    foreach(PACKAGE ${THIRD_PARTY_PACKAGES})
        find_package(${PACKAGE} REQUIRED)
    endforeach()
endif()

# Construct package groups
set(STATIC_PACKAGES "")
set(DEBUG_PACKAGES "")
set(SHARED_PACKAGES "")
set(HEADER_PACKAGES "")

if(DEFINED CUSTOM_PACKAGES)
    foreach(PACKAGE ${CUSTOM_PACKAGES})
        is_header_only_library(${PACKAGE} IS_HEADER_ONLY)
        if(IS_HEADER_ONLY)
            list(APPEND HEADER_PACKAGES ${PACKAGE}::${PACKAGE})
        else()
            list(APPEND STATIC_PACKAGES ${PACKAGE}::static)
            list(APPEND DEBUG_PACKAGES ${PACKAGE}::debug)
            list(APPEND SHARED_PACKAGES ${PACKAGE}::shared)
        endif()
    endforeach()
endif()

if(DEFINED THIRD_PARTY_PACKAGES)
    foreach(PACKAGE ${THIRD_PARTY_PACKAGES})
        list(APPEND STATIC_PACKAGES ${PACKAGE}::${PACKAGE})
        list(APPEND DEBUG_PACKAGES ${PACKAGE}::${PACKAGE})
        list(APPEND SHARED_PACKAGES ${PACKAGE}::${PACKAGE})
    endforeach()
endif()

message(STATUS "Linking against static: ${STATIC_PACKAGES}")
message(STATUS "Linking against debug: ${DEBUG_PACKAGES}")
message(STATUS "Linking against shared: ${SHARED_PACKAGES}")
message(STATUS "Linking against header: ${HEADER_PACKAGES}")