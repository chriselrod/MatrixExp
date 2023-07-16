#!/bin/sh
if [ ! -d "buildgcc" ]; then
    CXX=g++ cmake -S . -B buildgcc -DCMAKE_BUILD_TYPE=Release -DUNITY_BUILD=ON
fi
if [ ! -d "buildclang" ]; then
    CXX=clang++ cmake -S . -B buildclang -DCMAKE_BUILD_TYPE=Release -DUNITY_BUILD=ON
fi
time cmake --build buildgcc &
time cmake --build buildclang &
wait
