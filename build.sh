#!/bin/bash
if [ ! -d "buildgcc" ]; then
    CXX=g++ cmake -S . -B buildgcc -DCMAKE_BUILD_TYPE=Release
fi
if [ ! -d "buildclang" ]; then
    CXX=clang++ cmake -S . -B buildclang -DCMAKE_BUILD_TYPE=Release
fi
time cmake --build buildgcc &
time cmake --build buildclang &
wait
