cmake_minimum_required(VERSION 3.1)

find_package(LLVM REQUIRED CONFIG)
add_definitions(${LLVM_DEFINITIONS})
include_directories(${LLVM_INCLUDE_DIRS})
link_directories(${LLVM_LIBRARY_DIRS})

add_library(LLVMCDFG MODULE
    # List your source files here.
    src/pass.cpp
    src/graph.h
)

SET(CMAKE_CXX_FLAGS "-Wall")
