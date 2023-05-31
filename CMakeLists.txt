cmake_minimum_required(VERSION 3.23)

project(MatrixExp LANGUAGES C CXX)

option(ENABLE_NATIVE_COMPILATION "Compile with -march=native" ON)

include(FetchContent)

FetchContent_Declare(
  LoopModels
  GIT_REPOSITORY https://github.com/JuliaSIMD/LoopModels.git
  GIT_TAG        8ec207aa5d7dc4acc73802beaa64a75d604e9378
  CONFIGURE_COMMAND ""
  BUILD_COMMAND     ""
)

FetchContent_GetProperties(LoopModels)
if(NOT LoopModels_POPULATED)
  FetchContent_Populate(LoopModels)
endif()

# add_library(LoopModels INTERFACE)
# target_include_directories(LoopModels INTERFACE ${LoopModels_SOURCE_DIR}/include)

add_library(MatrixExp SHARED src/MatrixExp.cpp)


# message(STATUS "LoopModels_INCLUDE_DIR: ${LoopModels_SOURCE_DIR}/include")
message(STATUS "LoopModels include dir: ${MatrixExp_BINARY_DIR}/_deps/loopmodels-src/include")
# include only LoopModel's headers
target_include_directories(MatrixExp PUBLIC ${MatrixExp_BINARY_DIR}/_deps/loopmodels-src/include)
# target_link_libraries(MatrixExp LoopModels)

# target_include_directories(MatrixExp PUBLIC ${LoopModels_SOURCE_DIR}/include)

# we need LLVM...
find_package(LLVM 16 REQUIRED CONFIG)
list(APPEND CMAKE_MODULE_PATH ${LLVM_CMAKE_DIR})
include(${LLVM_DIR}/AddLLVM.cmake)
target_include_directories(${PROJECT_NAME} SYSTEM PRIVATE ${LLVM_INCLUDE_DIRS})
target_link_libraries(${PROJECT_NAME} PRIVATE LLVM)


if((CMAKE_CXX_COMPILER_ID MATCHES "Clang") OR (CMAKE_CXX_COMPILER_ID MATCHES "IntelLLVM"))
  target_compile_options(${PROJECT_NAME} PRIVATE -ferror-limit=2 -fcolor-diagnostics)
elseif(CMAKE_CXX_COMPILER_ID MATCHES "GNU")
  target_compile_options(
    ${PROJECT_NAME} PRIVATE -fmax-errors=2 -fconcepts-diagnostics-depth=4
                            -fno-semantic-interposition -fdiagnostics-color=always -fverbose-asm
  )
endif()

if(ENABLE_NATIVE_COMPILATION)
  if(CMAKE_CXX_COMPILER_ID MATCHES "IntelLLVM")
    target_compile_options(${PROJECT_NAME} PRIVATE -xhost -qopt-zmm-usage=high)
  else()
    target_compile_options(${PROJECT_NAME} PRIVATE -march=native) # -fno-unroll-loops)
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
             VISIBILITY_INLINES_HIDDEN ON
)
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
          -save-temps
)

