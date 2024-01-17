cmake_minimum_required(VERSION 3.8)

project("CDFG Analyzer" VERSION 1.0.0)

find_package(LLVM REQUIRED CONFIG)
add_definitions(${LLVM_DEFINITIONS})
include_directories(${LLVM_INCLUDE_DIRS})
link_directories(${LLVM_LIBRARY_DIRS})

INCLUDE_DIRECTORIES(/usr/lib/x86_64-linux-gnu)
LINK_DIRECTORIES(/usr/include)
add_library(LLVMCDFG MODULE
    src/pass.cpp
)

TARGET_LINK_LIBRARIES(LLVMCDFG /usr/local/lib/libmgclient.so)

SET(CMAKE_CXX_FLAGS "-Wall")
