cmake_minimum_required(VERSION 3.23)

project(MatrixExp LANGUAGES CXX)

option(ENABLE_NATIVE_COMPILATION "Compile with -march=native" ON)

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
elseif(CMAKE_CXX_COMPILER_ID MATCHES "GNU")
  target_compile_options(
    ${PROJECT_NAME}
    PRIVATE -fmax-errors=2
            -fconcepts-diagnostics-depth=4
            -fno-semantic-interposition
            -fdiagnostics-color=always
            -fverbose-asm
            -fweb
            -frename-registers
            -funroll-loops)
endif()

if(ENABLE_NATIVE_COMPILATION)
  if(CMAKE_CXX_COMPILER_ID MATCHES "IntelLLVM")
    target_compile_options(${PROJECT_NAME} PRIVATE -xhost -qopt-zmm-usage=high)
  else()
    target_compile_options(${PROJECT_NAME} PRIVATE -march=native
    )# -fno-unroll-loops)
    include(CheckCXXCompilerFlag)
    check_cxx_compiler_flag("-mprefer-vector-width=512" VEC512)
    if(VEC512)
      target_compile_options(${PROJECT_NAME} PRIVATE -mprefer-vector-width=512)
    endif()
  endif()
endif()

set_target_properties(
  ${PROJECT_NAME}
  PROPERTIES CXX_STANDARD 20
             CXX_VISIBILITY_PRESET hidden
             VISIBILITY_INLINES_HIDDEN ON)
target_compile_options(
  ${PROJECT_NAME}
  PRIVATE -fno-exceptions
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
          -save-temps)

include(CheckIPOSupported)
check_ipo_supported(RESULT supported OUTPUT error)
if(supported)
  message(STATUS "IPO / LTO enabled")
  set_target_properties(${PROJECT_NAME} PROPERTIES INTERPROCEDURAL_OPTIMIZATION
                                                   TRUE)
else()
  message(STATUS "IPO / LTO not supported: <${error}>")
endif()
