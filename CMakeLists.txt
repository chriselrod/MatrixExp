cmake_minimum_required(VERSION 3.23)

project(MatrixExp LANGUAGES CXX)

option(ENABLE_NATIVE_COMPILATION "Compile with -march=native" ON)
option(ENABLE_LTO "Compile with link time optimizations" OFF)
option(USE_WIDE_VECTORS "Set wide vectors even though compilers are bad at optimizing" OFF)

include(FetchContent)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

FetchContent_Declare(
  Math
  GIT_REPOSITORY git@github.com:LoopModels/Math.git
  GIT_TAG origin/main)

FetchContent_MakeAvailable(Math)

file(GLOB_RECURSE headers CONFIGURE_DEPENDS
     ${CMAKE_CURRENT_SOURCE_DIR}/include/*.hpp)
file(GLOB_RECURSE sources CONFIGURE_DEPENDS
     ${CMAKE_CURRENT_SOURCE_DIR}/lib/*.cpp)
add_library(${PROJECT_NAME} SHARED ${headers} ${sources})
target_link_libraries(MatrixExp Math)
target_include_directories( 
  ${PROJECT_NAME}
  PRIVATE $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include>
          $<INSTALL_INTERFACE:include/${PROJECT_NAME}-${PROJECT_VERSION}>)
set_target_properties(${PROJECT_NAME} PROPERTIES LINKER_LANGUAGE CXX)

if((CMAKE_CXX_COMPILER_ID MATCHES "Clang") OR (CMAKE_CXX_COMPILER_ID MATCHES
                                               "IntelLLVM"))
  target_compile_options(${PROJECT_NAME} PRIVATE -ferror-limit=2
                                                 -fcolor-diagnostics)
  # -mllvm -enable-vplan-native-path)
elseif(CMAKE_CXX_COMPILER_ID MATCHES "GNU")
  target_compile_options(
    ${PROJECT_NAME}
    PRIVATE -fmax-errors=2
            -fconcepts-diagnostics-depth=4
            -fno-semantic-interposition
            -fdiagnostics-color=always
            -fverbose-asm
            -fweb
            -frename-registers)
endif()

if(ENABLE_NATIVE_COMPILATION)
  if(CMAKE_CXX_COMPILER_ID MATCHES "IntelLLVM")
    target_compile_options(${PROJECT_NAME} PRIVATE -xhost -qopt-zmm-usage=high)
  else()
    target_compile_options(${PROJECT_NAME} PRIVATE -march=native) 
    if (USE_WIDE_VECTORS)
      include(CheckCXXCompilerFlag)
      check_cxx_compiler_flag("-mprefer-vector-width=512" VEC512)
      if(VEC512)
        target_compile_options(${PROJECT_NAME} PRIVATE -mprefer-vector-width=512)
      endif()
    endif()
  endif()
endif()

include(ProcessorCount)
ProcessorCount(N)
if(NOT N EQUAL 0)
  # 50 tasks
  math(EXPR N "(${N} + 49) / ${N}")
  message(STATUS "Using ${N} batch size")
set_target_properties(${PROJECT_NAME} PROPERTIES
                      UNITY_BUILD_MODE BATCH
                      UNITY_BUILD_BATCH_SIZE ${N}
)
else()
set_target_properties(${PROJECT_NAME} PROPERTIES
                      UNITY_BUILD_MODE BATCH
                      UNITY_BUILD_BATCH_SIZE 0)  
endif()

set_target_properties(
  ${PROJECT_NAME}
  PROPERTIES CXX_STANDARD 23
             CXX_VISIBILITY_PRESET hidden
             VISIBILITY_INLINES_HIDDEN ON)
target_compile_options(
  ${PROJECT_NAME}
  PRIVATE -funsafe-math-optimizations # who wouldn't want fun and safe math optimizations?
          -fno-exceptions
          -fno-rtti
          -fstrict-aliasing
          -fno-plt
          -fstrict-overflow
          -fomit-frame-pointer
          -fno-signed-zeros
          -fassociative-math
          -ffinite-math-only
          -fno-trapping-math
          -Wall
          -Wshadow
          -Wextra
          -Werror
          -fno-unwind-tables
          -fno-asynchronous-unwind-tables)

if(ENABLE_LTO)
  include(CheckIPOSupported)
  check_ipo_supported(RESULT supported OUTPUT error)
  if(supported)
    message(STATUS "IPO / LTO enabled")
    set_target_properties(${PROJECT_NAME}
                          PROPERTIES INTERPROCEDURAL_OPTIMIZATION TRUE)
  else()
    message(STATUS "IPO / LTO not supported: <${error}>")
  endif()
else() # temps aren't interesting with LTO
  target_compile_options(${PROJECT_NAME} PRIVATE -save-temps)
endif()

# target_precompile_headers(${PROJECT_NAME} PRIVATE <algorithm>)

