### MatrixExp example

This is a library meant to 
1. provide an example of using the LoopModels-support math library (note: it is not currently optimized via LoopModels or any SIMD tricks; the implementation is incredibly naive compared to a library like Eigen).
2. provide a benchmark showcasing the ergonomics of C++ for implementing allocating mathematical functons. To this effect, we have two Julia matrix exponential implementations in `bench.jl`, as well as a `C++` implemention in `src/MatrixExp.cpp`. The C++ implemention is much shorter and more readable than the in-place Julia version. The in-place Julia version goes considerably out of its way with manual memory management to try and reduce memory allocations, while the C++ code isn't really using any, and focuses on brevity. 

As the matrix exponential is also of interest coupled with automatic differentiation, the C++ code contains a `Dual` number implementation for forward-mode automatic differentiation, so that we can compare both dual numbers and `Float64` between Julia and C++.

To run the benchmarks, simply
```
git clone git@github.com:chriselrod/MatrixExp.git
cd MatrixExp/
./build.sh
julia bench.jl
```

Note that these benchmarks are single threaded, so they aren't stressing Julia's GC-woes. Example results:
```julia
Size 2 x 2:
Size 2 x 2, duals (n,j) = (0,0), T = Float64:
Out of place Julia:   17.600 μs (272 allocations: 25.34 KiB)
In place     Julia:   4.813 μs (53 allocations: 4.81 KiB)
Using `mul!`-Julia:   4.796 μs (53 allocations: 4.81 KiB)
Out of place GCC:     2.063 μs (0 allocations: 0 bytes)
Out of place Clang:   1.990 μs (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (1,0), T = ForwardDiff.Dual{Nothing, Float64, 1}:
Out of place Julia:   17.457 μs (272 allocations: 33.53 KiB)
In place     Julia:   6.058 μs (53 allocations: 6.16 KiB)
Using `mul!`-Julia:   6.156 μs (53 allocations: 6.16 KiB)
Out of place GCC:     2.745 μs (0 allocations: 0 bytes)
Out of place Clang:   2.788 μs (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (2,0), T = ForwardDiff.Dual{Nothing, Float64, 2}:
Out of place Julia:   19.036 μs (272 allocations: 41.72 KiB)
In place     Julia:   7.074 μs (53 allocations: 7.50 KiB)
Using `mul!`-Julia:   7.985 μs (53 allocations: 7.50 KiB)
Out of place GCC:     3.422 μs (0 allocations: 0 bytes)
Out of place Clang:   3.179 μs (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (3,0), T = ForwardDiff.Dual{Nothing, Float64, 3}:
Out of place Julia:   35.409 μs (272 allocations: 49.91 KiB)
In place     Julia:   8.268 μs (53 allocations: 8.84 KiB)
Using `mul!`-Julia:   8.973 μs (53 allocations: 8.84 KiB)
Out of place GCC:     3.626 μs (0 allocations: 0 bytes)
Out of place Clang:   3.886 μs (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (4,0), T = ForwardDiff.Dual{Nothing, Float64, 4}:
Out of place Julia:   22.620 μs (272 allocations: 58.09 KiB)
In place     Julia:   7.824 μs (53 allocations: 10.19 KiB)
Using `mul!`-Julia:   8.560 μs (53 allocations: 10.19 KiB)
Out of place GCC:     3.626 μs (0 allocations: 0 bytes)
Out of place Clang:   4.558 μs (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (5,0), T = ForwardDiff.Dual{Nothing, Float64, 5}:
Out of place Julia:   32.916 μs (272 allocations: 66.28 KiB)
In place     Julia:   10.073 μs (53 allocations: 11.53 KiB)
Using `mul!`-Julia:   10.943 μs (53 allocations: 11.53 KiB)
Out of place GCC:     3.899 μs (0 allocations: 0 bytes)
Out of place Clang:   5.600 μs (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (6,0), T = ForwardDiff.Dual{Nothing, Float64, 6}:
Out of place Julia:   35.225 μs (272 allocations: 74.47 KiB)
In place     Julia:   10.771 μs (53 allocations: 12.88 KiB)
Using `mul!`-Julia:   13.692 μs (53 allocations: 12.88 KiB)
Out of place GCC:     4.220 μs (0 allocations: 0 bytes)
Out of place Clang:   4.989 μs (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (7,0), T = ForwardDiff.Dual{Nothing, Float64, 7}:
Out of place Julia:   29.026 μs (272 allocations: 86.75 KiB)
In place     Julia:   8.929 μs (53 allocations: 14.89 KiB)
Using `mul!`-Julia:   10.444 μs (53 allocations: 14.89 KiB)
Out of place GCC:     6.730 μs (0 allocations: 0 bytes)
Out of place Clang:   4.989 μs (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (8,0), T = ForwardDiff.Dual{Nothing, Float64, 8}:
Out of place Julia:   37.281 μs (272 allocations: 94.94 KiB)
In place     Julia:   10.297 μs (53 allocations: 16.23 KiB)
Using `mul!`-Julia:   11.968 μs (53 allocations: 16.23 KiB)
Out of place GCC:     5.384 μs (0 allocations: 0 bytes)
Out of place Clang:   5.277 μs (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (1,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 1}, 1}:
Out of place Julia:   30.449 μs (272 allocations: 49.91 KiB)
In place     Julia:   9.146 μs (53 allocations: 8.84 KiB)
Using `mul!`-Julia:   9.845 μs (53 allocations: 8.84 KiB)
Out of place GCC:     4.078 μs (0 allocations: 0 bytes)
Out of place Clang:   4.255 μs (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (2,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 2}, 1}:
Out of place Julia:   28.909 μs (272 allocations: 66.28 KiB)
In place     Julia:   10.332 μs (53 allocations: 11.53 KiB)
Using `mul!`-Julia:   11.683 μs (53 allocations: 11.53 KiB)
Out of place GCC:     4.774 μs (0 allocations: 0 bytes)
Out of place Clang:   5.636 μs (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (3,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 3}, 1}:
Out of place Julia:   31.520 μs (272 allocations: 86.75 KiB)
In place     Julia:   10.413 μs (53 allocations: 14.89 KiB)
Using `mul!`-Julia:   11.772 μs (53 allocations: 14.89 KiB)
Out of place GCC:     6.849 μs (0 allocations: 0 bytes)
Out of place Clang:   6.037 μs (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (4,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 4}, 1}:
Out of place Julia:   47.808 μs (272 allocations: 103.12 KiB)
In place     Julia:   13.683 μs (53 allocations: 17.58 KiB)
Using `mul!`-Julia:   17.290 μs (53 allocations: 17.58 KiB)
Out of place GCC:     8.037 μs (0 allocations: 0 bytes)
Out of place Clang:   8.953 μs (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (5,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 5}, 1}:
Out of place Julia:   44.853 μs (272 allocations: 115.41 KiB)
In place     Julia:   13.606 μs (53 allocations: 19.59 KiB)
Using `mul!`-Julia:   17.429 μs (53 allocations: 19.59 KiB)
Out of place GCC:     8.144 μs (0 allocations: 0 bytes)
Out of place Clang:   7.937 μs (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (6,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 6}, 1}:
Out of place Julia:   50.856 μs (272 allocations: 139.97 KiB)
In place     Julia:   14.354 μs (53 allocations: 23.62 KiB)
Using `mul!`-Julia:   17.945 μs (53 allocations: 23.62 KiB)
Out of place GCC:     9.272 μs (0 allocations: 0 bytes)
Out of place Clang:   12.112 μs (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (7,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 7}, 1}:
Out of place Julia:   65.406 μs (272 allocations: 148.16 KiB)
In place     Julia:   17.494 μs (53 allocations: 24.97 KiB)
Using `mul!`-Julia:   20.754 μs (53 allocations: 24.97 KiB)
Out of place GCC:     11.553 μs (0 allocations: 0 bytes)
Out of place Clang:   8.246 μs (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (8,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 8}, 1}:
Out of place Julia:   65.298 μs (272 allocations: 172.72 KiB)
In place     Julia:   20.446 μs (53 allocations: 29.00 KiB)
Using `mul!`-Julia:   27.056 μs (53 allocations: 29.00 KiB)
Out of place GCC:     14.198 μs (0 allocations: 0 bytes)
Out of place Clang:   8.248 μs (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (1,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 1}, 2}:
Out of place Julia:   30.303 μs (272 allocations: 66.28 KiB)
In place     Julia:   10.592 μs (53 allocations: 11.53 KiB)
Using `mul!`-Julia:   11.720 μs (53 allocations: 11.53 KiB)
Out of place GCC:     5.447 μs (0 allocations: 0 bytes)
Out of place Clang:   6.539 μs (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (2,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 2}, 2}:
Out of place Julia:   46.536 μs (272 allocations: 94.94 KiB)
In place     Julia:   14.775 μs (53 allocations: 16.23 KiB)
Using `mul!`-Julia:   16.331 μs (53 allocations: 16.23 KiB)
Out of place GCC:     7.921 μs (0 allocations: 0 bytes)
Out of place Clang:   8.057 μs (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (3,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 3}, 2}:
Out of place Julia:   48.788 μs (272 allocations: 115.41 KiB)
In place     Julia:   16.511 μs (53 allocations: 19.59 KiB)
Using `mul!`-Julia:   17.796 μs (53 allocations: 19.59 KiB)
Out of place GCC:     9.395 μs (0 allocations: 0 bytes)
Out of place Clang:   9.645 μs (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (4,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 4}, 2}:
Out of place Julia:   67.537 μs (272 allocations: 139.97 KiB)
In place     Julia:   20.501 μs (53 allocations: 23.62 KiB)
Using `mul!`-Julia:   22.347 μs (53 allocations: 23.62 KiB)
Out of place GCC:     15.064 μs (0 allocations: 0 bytes)
Out of place Clang:   12.850 μs (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (5,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 5}, 2}:
Out of place Julia:   67.288 μs (272 allocations: 172.72 KiB)
In place     Julia:   19.769 μs (53 allocations: 29.00 KiB)
Using `mul!`-Julia:   24.385 μs (53 allocations: 29.00 KiB)
Out of place GCC:     16.823 μs (0 allocations: 0 bytes)
Out of place Clang:   11.739 μs (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (6,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 6}, 2}:
Out of place Julia:   73.663 μs (272 allocations: 189.09 KiB)
In place     Julia:   21.774 μs (53 allocations: 31.69 KiB)
Using `mul!`-Julia:   27.861 μs (53 allocations: 31.69 KiB)
Out of place GCC:     19.123 μs (0 allocations: 0 bytes)
Out of place Clang:   14.112 μs (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (7,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 7}, 2}:
Out of place Julia:   103.356 μs (272 allocations: 230.03 KiB)
In place     Julia:   25.344 μs (53 allocations: 38.41 KiB)
Using `mul!`-Julia:   34.258 μs (53 allocations: 38.41 KiB)
Out of place GCC:     28.287 μs (0 allocations: 0 bytes)
Out of place Clang:   16.025 μs (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (8,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 8}, 2}:
Out of place Julia:   115.840 μs (272 allocations: 258.69 KiB)
In place     Julia:   31.306 μs (53 allocations: 43.11 KiB)
Using `mul!`-Julia:   41.134 μs (53 allocations: 43.11 KiB)
Out of place GCC:     27.942 μs (0 allocations: 0 bytes)
Out of place Clang:   19.553 μs (0 allocations: 0 bytes)
Size 3 x 3:
Size 3 x 3, duals (n,j) = (0,0), T = Float64:
Out of place Julia:   25.378 μs (272 allocations: 33.53 KiB)
In place     Julia:   8.274 μs (53 allocations: 6.16 KiB)
Using `mul!`-Julia:   7.547 μs (53 allocations: 6.16 KiB)
Out of place GCC:     4.192 μs (0 allocations: 0 bytes)
Out of place Clang:   4.036 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (1,0), T = ForwardDiff.Dual{Nothing, Float64, 1}:
Out of place Julia:   39.767 μs (272 allocations: 54.00 KiB)
In place     Julia:   12.971 μs (53 allocations: 9.52 KiB)
Using `mul!`-Julia:   14.489 μs (53 allocations: 9.52 KiB)
Out of place GCC:     6.153 μs (0 allocations: 0 bytes)
Out of place Clang:   5.943 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (2,0), T = ForwardDiff.Dual{Nothing, Float64, 2}:
Out of place Julia:   43.781 μs (272 allocations: 70.38 KiB)
In place     Julia:   15.207 μs (53 allocations: 12.20 KiB)
Using `mul!`-Julia:   16.342 μs (53 allocations: 12.20 KiB)
Out of place GCC:     7.546 μs (0 allocations: 0 bytes)
Out of place Clang:   7.317 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (3,0), T = ForwardDiff.Dual{Nothing, Float64, 3}:
Out of place Julia:   53.955 μs (272 allocations: 94.94 KiB)
In place     Julia:   17.216 μs (53 allocations: 16.23 KiB)
Using `mul!`-Julia:   18.350 μs (53 allocations: 16.23 KiB)
Out of place GCC:     8.638 μs (0 allocations: 0 bytes)
Out of place Clang:   9.967 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (4,0), T = ForwardDiff.Dual{Nothing, Float64, 4}:
Out of place Julia:   58.586 μs (272 allocations: 115.41 KiB)
In place     Julia:   18.805 μs (53 allocations: 19.59 KiB)
Using `mul!`-Julia:   21.393 μs (53 allocations: 19.59 KiB)
Out of place GCC:     8.611 μs (0 allocations: 0 bytes)
Out of place Clang:   10.836 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (5,0), T = ForwardDiff.Dual{Nothing, Float64, 5}:
Out of place Julia:   64.693 μs (272 allocations: 127.69 KiB)
In place     Julia:   21.816 μs (53 allocations: 21.61 KiB)
Using `mul!`-Julia:   23.732 μs (53 allocations: 21.61 KiB)
Out of place GCC:     9.726 μs (0 allocations: 0 bytes)
Out of place Clang:   13.069 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (6,0), T = ForwardDiff.Dual{Nothing, Float64, 6}:
Out of place Julia:   70.855 μs (272 allocations: 148.16 KiB)
In place     Julia:   25.057 μs (53 allocations: 24.97 KiB)
Using `mul!`-Julia:   29.761 μs (53 allocations: 24.97 KiB)
Out of place GCC:     10.508 μs (0 allocations: 0 bytes)
Out of place Clang:   14.415 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (7,0), T = ForwardDiff.Dual{Nothing, Float64, 7}:
Out of place Julia:   78.975 μs (272 allocations: 172.72 KiB)
In place     Julia:   24.927 μs (53 allocations: 29.00 KiB)
Using `mul!`-Julia:   28.236 μs (53 allocations: 29.00 KiB)
Out of place GCC:     17.478 μs (0 allocations: 0 bytes)
Out of place Clang:   16.584 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (8,0), T = ForwardDiff.Dual{Nothing, Float64, 8}:
Out of place Julia:   85.493 μs (272 allocations: 189.09 KiB)
In place     Julia:   29.071 μs (53 allocations: 31.69 KiB)
Using `mul!`-Julia:   33.918 μs (53 allocations: 31.69 KiB)
Out of place GCC:     14.986 μs (0 allocations: 0 bytes)
Out of place Clang:   16.112 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (1,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 1}, 1}:
Out of place Julia:   53.587 μs (272 allocations: 94.94 KiB)
In place     Julia:   21.092 μs (53 allocations: 16.23 KiB)
Using `mul!`-Julia:   21.655 μs (53 allocations: 16.23 KiB)
Out of place GCC:     9.925 μs (0 allocations: 0 bytes)
Out of place Clang:   11.604 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (2,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 2}, 1}:
Out of place Julia:   71.821 μs (272 allocations: 127.69 KiB)
In place     Julia:   27.756 μs (53 allocations: 21.61 KiB)
Using `mul!`-Julia:   28.798 μs (53 allocations: 21.61 KiB)
Out of place GCC:     12.957 μs (0 allocations: 0 bytes)
Out of place Clang:   16.999 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (3,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 3}, 1}:
Out of place Julia:   90.070 μs (272 allocations: 172.72 KiB)
In place     Julia:   33.636 μs (53 allocations: 29.00 KiB)
Using `mul!`-Julia:   35.568 μs (53 allocations: 29.00 KiB)
Out of place GCC:     21.194 μs (0 allocations: 0 bytes)
Out of place Clang:   21.767 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (4,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 4}, 1}:
Out of place Julia:   111.141 μs (272 allocations: 209.56 KiB)
In place     Julia:   37.936 μs (53 allocations: 35.05 KiB)
Using `mul!`-Julia:   46.497 μs (53 allocations: 35.05 KiB)
Out of place GCC:     22.522 μs (0 allocations: 0 bytes)
Out of place Clang:   29.297 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (5,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 5}, 1}:
Out of place Julia:   111.459 μs (272 allocations: 258.69 KiB)
In place     Julia:   40.864 μs (53 allocations: 43.11 KiB)
Using `mul!`-Julia:   49.539 μs (53 allocations: 43.11 KiB)
Out of place GCC:     23.620 μs (0 allocations: 0 bytes)
Out of place Clang:   28.367 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (6,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 6}, 1}:
Out of place Julia:   153.647 μs (272 allocations: 279.16 KiB)
In place     Julia:   50.679 μs (53 allocations: 46.47 KiB)
Using `mul!`-Julia:   59.515 μs (53 allocations: 46.47 KiB)
Out of place GCC:     27.775 μs (0 allocations: 0 bytes)
Out of place Clang:   36.877 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (7,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 7}, 1}:
Out of place Julia:   159.867 μs (272 allocations: 320.09 KiB)
In place     Julia:   47.354 μs (53 allocations: 53.19 KiB)
Using `mul!`-Julia:   61.612 μs (53 allocations: 53.19 KiB)
Out of place GCC:     35.705 μs (0 allocations: 0 bytes)
Out of place Clang:   27.554 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (8,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 8}, 1}:
Out of place Julia:   207.557 μs (272 allocations: 348.75 KiB)
In place     Julia:   62.875 μs (53 allocations: 57.89 KiB)
Using `mul!`-Julia:   86.452 μs (53 allocations: 57.89 KiB)
Out of place GCC:     43.384 μs (0 allocations: 0 bytes)
Out of place Clang:   33.382 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (1,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 1}, 2}:
Out of place Julia:   71.899 μs (272 allocations: 127.69 KiB)
In place     Julia:   29.008 μs (53 allocations: 21.61 KiB)
Using `mul!`-Julia:   29.836 μs (53 allocations: 21.61 KiB)
Out of place GCC:     15.164 μs (0 allocations: 0 bytes)
Out of place Clang:   20.978 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (2,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 2}, 2}:
Out of place Julia:   105.164 μs (272 allocations: 189.09 KiB)
In place     Julia:   40.507 μs (53 allocations: 31.69 KiB)
Using `mul!`-Julia:   45.822 μs (53 allocations: 31.69 KiB)
Out of place GCC:     21.940 μs (0 allocations: 0 bytes)
Out of place Clang:   23.982 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (3,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 3}, 2}:
Out of place Julia:   112.722 μs (272 allocations: 258.69 KiB)
In place     Julia:   45.887 μs (53 allocations: 43.11 KiB)
Using `mul!`-Julia:   50.241 μs (53 allocations: 43.11 KiB)
Out of place GCC:     27.786 μs (0 allocations: 0 bytes)
Out of place Clang:   33.680 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (4,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 4}, 2}:
Out of place Julia:   165.148 μs (272 allocations: 299.62 KiB)
In place     Julia:   57.925 μs (53 allocations: 49.83 KiB)
Using `mul!`-Julia:   63.621 μs (53 allocations: 49.83 KiB)
Out of place GCC:     42.525 μs (0 allocations: 0 bytes)
Out of place Clang:   36.319 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (5,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 5}, 2}:
Out of place Julia:   186.386 μs (272 allocations: 348.75 KiB)
In place     Julia:   60.745 μs (53 allocations: 57.89 KiB)
Using `mul!`-Julia:   73.204 μs (53 allocations: 57.89 KiB)
Out of place GCC:     47.832 μs (0 allocations: 0 bytes)
Out of place Clang:   38.891 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (6,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 6}, 2}:
Out of place Julia:   212.584 μs (272 allocations: 418.34 KiB)
In place     Julia:   71.688 μs (53 allocations: 69.31 KiB)
Using `mul!`-Julia:   88.590 μs (53 allocations: 69.31 KiB)
Out of place GCC:     58.090 μs (0 allocations: 0 bytes)
Out of place Clang:   44.883 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (7,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 7}, 2}:
Out of place Julia:   227.191 μs (272 allocations: 463.38 KiB)
In place     Julia:   64.698 μs (53 allocations: 76.70 KiB)
Using `mul!`-Julia:   87.310 μs (53 allocations: 76.70 KiB)
Out of place GCC:     83.311 μs (0 allocations: 0 bytes)
Out of place Clang:   52.147 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (8,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 8}, 2}:
Out of place Julia:   299.189 μs (272 allocations: 520.69 KiB)
In place     Julia:   89.752 μs (53 allocations: 86.11 KiB)
Using `mul!`-Julia:   128.125 μs (53 allocations: 86.11 KiB)
Out of place GCC:     86.597 μs (0 allocations: 0 bytes)
Out of place Clang:   61.000 μs (0 allocations: 0 bytes)
Size 4 x 4:
Size 4 x 4, duals (n,j) = (0,0), T = Float64:
Out of place Julia:   50.170 μs (272 allocations: 50.06 KiB)
In place     Julia:   11.415 μs (53 allocations: 9.00 KiB)
Using `mul!`-Julia:   22.959 μs (53 allocations: 9.00 KiB)
Out of place GCC:     7.198 μs (0 allocations: 0 bytes)
Out of place Clang:   7.503 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (1,0), T = ForwardDiff.Dual{Nothing, Float64, 1}:
Out of place Julia:   205.583 μs (410 allocations: 1.42 MiB)
In place     Julia:   19.008 μs (53 allocations: 15.05 KiB)
Using `mul!`-Julia:   131.860 μs (167 allocations: 1.12 MiB)
Out of place GCC:     11.267 μs (0 allocations: 0 bytes)
Out of place Clang:   12.664 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (2,0), T = ForwardDiff.Dual{Nothing, Float64, 2}:
Out of place Julia:   204.335 μs (410 allocations: 1.53 MiB)
In place     Julia:   24.062 μs (53 allocations: 19.75 KiB)
Using `mul!`-Julia:   146.034 μs (167 allocations: 1.19 MiB)
Out of place GCC:     14.467 μs (0 allocations: 0 bytes)
Out of place Clang:   13.243 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (3,0), T = ForwardDiff.Dual{Nothing, Float64, 3}:
Out of place Julia:   235.003 μs (410 allocations: 1.53 MiB)
In place     Julia:   33.324 μs (53 allocations: 25.12 KiB)
Using `mul!`-Julia:   156.846 μs (167 allocations: 1.17 MiB)
Out of place GCC:     18.653 μs (0 allocations: 0 bytes)
Out of place Clang:   23.048 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (4,0), T = ForwardDiff.Dual{Nothing, Float64, 4}:
Out of place Julia:   257.376 μs (410 allocations: 1.55 MiB)
In place     Julia:   37.846 μs (53 allocations: 31.84 KiB)
Using `mul!`-Julia:   154.537 μs (167 allocations: 1.16 MiB)
Out of place GCC:     19.082 μs (0 allocations: 0 bytes)
Out of place Clang:   28.215 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (5,0), T = ForwardDiff.Dual{Nothing, Float64, 5}:
Out of place Julia:   281.416 μs (410 allocations: 1.67 MiB)
In place     Julia:   43.450 μs (53 allocations: 38.56 KiB)
Using `mul!`-Julia:   162.852 μs (167 allocations: 1.23 MiB)
Out of place GCC:     20.117 μs (0 allocations: 0 bytes)
Out of place Clang:   30.659 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (6,0), T = ForwardDiff.Dual{Nothing, Float64, 6}:
Out of place Julia:   244.161 μs (410 allocations: 1.52 MiB)
In place     Julia:   38.655 μs (53 allocations: 43.27 KiB)
Using `mul!`-Julia:   161.525 μs (167 allocations: 1.09 MiB)
Out of place GCC:     23.792 μs (0 allocations: 0 bytes)
Out of place Clang:   32.168 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (7,0), T = ForwardDiff.Dual{Nothing, Float64, 7}:
Out of place Julia:   273.487 μs (410 allocations: 1.50 MiB)
In place     Julia:   46.518 μs (53 allocations: 46.62 KiB)
Using `mul!`-Julia:   153.776 μs (167 allocations: 1.06 MiB)
Out of place GCC:     38.567 μs (0 allocations: 0 bytes)
Out of place Clang:   38.982 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (8,0), T = ForwardDiff.Dual{Nothing, Float64, 8}:
Out of place Julia:   310.480 μs (410 allocations: 1.69 MiB)
In place     Julia:   51.377 μs (53 allocations: 53.34 KiB)
Using `mul!`-Julia:   176.976 μs (167 allocations: 1.19 MiB)
Out of place GCC:     34.489 μs (0 allocations: 0 bytes)
Out of place Clang:   37.903 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (1,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 1}, 1}:
Out of place Julia:   228.342 μs (410 allocations: 1.53 MiB)
In place     Julia:   39.304 μs (53 allocations: 25.12 KiB)
Using `mul!`-Julia:   142.829 μs (167 allocations: 1.17 MiB)
Out of place GCC:     20.447 μs (0 allocations: 0 bytes)
Out of place Clang:   24.606 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (2,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 2}, 1}:
Out of place Julia:   260.137 μs (410 allocations: 1.67 MiB)
In place     Julia:   51.181 μs (53 allocations: 38.56 KiB)
Using `mul!`-Julia:   159.416 μs (167 allocations: 1.23 MiB)
Out of place GCC:     26.264 μs (0 allocations: 0 bytes)
Out of place Clang:   32.901 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (3,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 3}, 1}:
Out of place Julia:   293.108 μs (410 allocations: 1.50 MiB)
In place     Julia:   62.442 μs (53 allocations: 46.62 KiB)
Using `mul!`-Julia:   174.840 μs (167 allocations: 1.06 MiB)
Out of place GCC:     42.507 μs (0 allocations: 0 bytes)
Out of place Clang:   45.963 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (4,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 4}, 1}:
Out of place Julia:   357.549 μs (410 allocations: 1.64 MiB)
In place     Julia:   72.109 μs (53 allocations: 58.05 KiB)
Using `mul!`-Julia:   205.825 μs (167 allocations: 1.13 MiB)
Out of place GCC:     50.261 μs (0 allocations: 0 bytes)
Out of place Clang:   66.591 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (5,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 5}, 1}:
Out of place Julia:   481.129 μs (410 allocations: 1.69 MiB)
In place     Julia:   86.914 μs (53 allocations: 69.47 KiB)
Using `mul!`-Julia:   285.156 μs (167 allocations: 1.13 MiB)
Out of place GCC:     44.549 μs (0 allocations: 0 bytes)
Out of place Clang:   56.455 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (6,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 6}, 1}:
Out of place Julia:   564.101 μs (410 allocations: 1.72 MiB)
In place     Julia:   93.885 μs (53 allocations: 86.27 KiB)
Using `mul!`-Julia:   315.477 μs (167 allocations: 1.09 MiB)
Out of place GCC:     52.357 μs (0 allocations: 0 bytes)
Out of place Clang:   86.320 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (7,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 7}, 1}:
Out of place Julia:   543.760 μs (410 allocations: 1.93 MiB)
In place     Julia:   93.712 μs (53 allocations: 92.31 KiB)
Using `mul!`-Julia:   310.045 μs (167 allocations: 1.23 MiB)
Out of place GCC:     73.676 μs (0 allocations: 0 bytes)
Out of place Clang:   55.725 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (8,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 8}, 1}:
Out of place Julia:   644.993 μs (410 allocations: 1.84 MiB)
In place     Julia:   123.241 μs (53 allocations: 103.06 KiB)
Using `mul!`-Julia:   375.411 μs (167 allocations: 1.12 MiB)
Out of place GCC:     87.224 μs (0 allocations: 0 bytes)
Out of place Clang:   65.417 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (1,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 1}, 2}:
Out of place Julia:   264.502 μs (410 allocations: 1.67 MiB)
In place     Julia:   54.959 μs (53 allocations: 38.56 KiB)
Using `mul!`-Julia:   166.811 μs (167 allocations: 1.23 MiB)
Out of place GCC:     34.164 μs (0 allocations: 0 bytes)
Out of place Clang:   47.472 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (2,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 2}, 2}:
Out of place Julia:   333.668 μs (410 allocations: 1.69 MiB)
In place     Julia:   77.712 μs (53 allocations: 53.34 KiB)
Using `mul!`-Julia:   202.197 μs (167 allocations: 1.19 MiB)
Out of place GCC:     47.140 μs (0 allocations: 0 bytes)
Out of place Clang:   52.567 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (3,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 3}, 2}:
Out of place Julia:   509.461 μs (410 allocations: 1.69 MiB)
In place     Julia:   95.023 μs (53 allocations: 69.47 KiB)
Using `mul!`-Julia:   296.233 μs (167 allocations: 1.13 MiB)
Out of place GCC:     57.881 μs (0 allocations: 0 bytes)
Out of place Clang:   69.406 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (4,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 4}, 2}:
Out of place Julia:   552.488 μs (410 allocations: 1.81 MiB)
In place     Julia:   106.502 μs (53 allocations: 86.27 KiB)
Using `mul!`-Julia:   327.267 μs (167 allocations: 1.16 MiB)
Out of place GCC:     86.215 μs (0 allocations: 0 bytes)
Out of place Clang:   80.295 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (5,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 5}, 2}:
Out of place Julia:   629.316 μs (410 allocations: 1.84 MiB)
In place     Julia:   121.440 μs (53 allocations: 103.06 KiB)
Using `mul!`-Julia:   368.415 μs (167 allocations: 1.12 MiB)
Out of place GCC:     108.664 μs (0 allocations: 0 bytes)
Out of place Clang:   83.459 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (6,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 6}, 2}:
Out of place Julia:   699.577 μs (410 allocations: 2.14 MiB)
In place     Julia:   127.416 μs (53 allocations: 119.19 KiB)
Using `mul!`-Julia:   402.153 μs (167 allocations: 1.30 MiB)
Out of place GCC:     122.064 μs (0 allocations: 0 bytes)
Out of place Clang:   106.061 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (7,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 7}, 2}:
Out of place Julia:   704.038 μs (410 allocations: 2.06 MiB)
In place     Julia:   125.749 μs (53 allocations: 135.31 KiB)
Using `mul!`-Julia:   408.197 μs (167 allocations: 1.17 MiB)
Out of place GCC:     184.190 μs (0 allocations: 0 bytes)
Out of place Clang:   111.969 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (8,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 8}, 2}:
Out of place Julia:   873.650 μs (410 allocations: 2.31 MiB)
In place     Julia:   180.892 μs (53 allocations: 151.44 KiB)
Using `mul!`-Julia:   521.264 μs (167 allocations: 1.32 MiB)
Out of place GCC:     191.511 μs (0 allocations: 0 bytes)
Out of place Clang:   131.082 μs (0 allocations: 0 bytes)
Size 5 x 5:
Size 5 x 5, duals (n,j) = (0,0), T = Float64:
Out of place Julia:   66.506 μs (272 allocations: 66.44 KiB)
In place     Julia:   18.208 μs (53 allocations: 11.69 KiB)
Using `mul!`-Julia:   31.958 μs (53 allocations: 11.69 KiB)
Out of place GCC:     12.688 μs (0 allocations: 0 bytes)
Out of place Clang:   13.549 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (1,0), T = ForwardDiff.Dual{Nothing, Float64, 1}:
Out of place Julia:   225.184 μs (410 allocations: 1.46 MiB)
In place     Julia:   31.825 μs (53 allocations: 21.77 KiB)
Using `mul!`-Julia:   154.067 μs (167 allocations: 1.13 MiB)
Out of place GCC:     19.335 μs (0 allocations: 0 bytes)
Out of place Clang:   19.993 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (2,0), T = ForwardDiff.Dual{Nothing, Float64, 2}:
Out of place Julia:   237.141 μs (410 allocations: 1.58 MiB)
In place     Julia:   38.677 μs (53 allocations: 29.16 KiB)
Using `mul!`-Julia:   160.737 μs (167 allocations: 1.20 MiB)
Out of place GCC:     25.932 μs (0 allocations: 0 bytes)
Out of place Clang:   24.033 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (3,0), T = ForwardDiff.Dual{Nothing, Float64, 3}:
Out of place Julia:   276.343 μs (410 allocations: 1.61 MiB)
In place     Julia:   53.824 μs (53 allocations: 38.56 KiB)
Using `mul!`-Julia:   172.312 μs (167 allocations: 1.18 MiB)
Out of place GCC:     37.246 μs (0 allocations: 0 bytes)
Out of place Clang:   52.658 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (4,0), T = ForwardDiff.Dual{Nothing, Float64, 4}:
Out of place Julia:   325.531 μs (410 allocations: 1.64 MiB)
In place     Julia:   60.358 μs (53 allocations: 46.62 KiB)
Using `mul!`-Julia:   194.819 μs (167 allocations: 1.17 MiB)
Out of place GCC:     34.788 μs (0 allocations: 0 bytes)
Out of place Clang:   51.172 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (5,0), T = ForwardDiff.Dual{Nothing, Float64, 5}:
Out of place Julia:   343.425 μs (410 allocations: 1.78 MiB)
In place     Julia:   70.691 μs (53 allocations: 58.05 KiB)
Using `mul!`-Julia:   198.773 μs (167 allocations: 1.25 MiB)
Out of place GCC:     37.714 μs (0 allocations: 0 bytes)
Out of place Clang:   61.484 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (6,0), T = ForwardDiff.Dual{Nothing, Float64, 6}:
Out of place Julia:   382.154 μs (410 allocations: 1.64 MiB)
In place     Julia:   72.913 μs (53 allocations: 63.42 KiB)
Using `mul!`-Julia:   215.168 μs (167 allocations: 1.11 MiB)
Out of place GCC:     41.889 μs (0 allocations: 0 bytes)
Out of place Clang:   58.138 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (7,0), T = ForwardDiff.Dual{Nothing, Float64, 7}:
Out of place Julia:   371.731 μs (410 allocations: 1.68 MiB)
In place     Julia:   75.329 μs (53 allocations: 76.86 KiB)
Using `mul!`-Julia:   206.516 μs (167 allocations: 1.09 MiB)
Out of place GCC:     69.994 μs (0 allocations: 0 bytes)
Out of place Clang:   74.452 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (8,0), T = ForwardDiff.Dual{Nothing, Float64, 8}:
Out of place Julia:   419.627 μs (410 allocations: 1.89 MiB)
In place     Julia:   87.545 μs (53 allocations: 86.27 KiB)
Using `mul!`-Julia:   229.106 μs (167 allocations: 1.23 MiB)
Out of place GCC:     61.299 μs (0 allocations: 0 bytes)
Out of place Clang:   74.712 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (1,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 1}, 1}:
Out of place Julia:   290.816 μs (410 allocations: 1.61 MiB)
In place     Julia:   73.942 μs (53 allocations: 38.56 KiB)
Using `mul!`-Julia:   192.835 μs (167 allocations: 1.18 MiB)
Out of place GCC:     44.610 μs (0 allocations: 0 bytes)
Out of place Clang:   50.214 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (2,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 2}, 1}:
Out of place Julia:   355.345 μs (410 allocations: 1.78 MiB)
In place     Julia:   84.644 μs (53 allocations: 58.05 KiB)
Using `mul!`-Julia:   212.760 μs (167 allocations: 1.25 MiB)
Out of place GCC:     52.904 μs (0 allocations: 0 bytes)
Out of place Clang:   65.210 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (3,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 3}, 1}:
Out of place Julia:   420.783 μs (410 allocations: 1.68 MiB)
In place     Julia:   110.365 μs (53 allocations: 76.86 KiB)
Using `mul!`-Julia:   240.053 μs (167 allocations: 1.09 MiB)
Out of place GCC:     84.424 μs (0 allocations: 0 bytes)
Out of place Clang:   99.211 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (4,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 4}, 1}:
Out of place Julia:   519.154 μs (410 allocations: 1.83 MiB)
In place     Julia:   122.001 μs (53 allocations: 89.62 KiB)
Using `mul!`-Julia:   299.948 μs (167 allocations: 1.16 MiB)
Out of place GCC:     93.640 μs (0 allocations: 0 bytes)
Out of place Clang:   123.302 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (5,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 5}, 1}:
Out of place Julia:   735.630 μs (410 allocations: 1.92 MiB)
In place     Julia:   147.322 μs (53 allocations: 108.44 KiB)
Using `mul!`-Julia:   448.966 μs (167 allocations: 1.16 MiB)
Out of place GCC:     89.576 μs (0 allocations: 0 bytes)
Out of place Clang:   118.244 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (6,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 6}, 1}:
Out of place Julia:   787.213 μs (410 allocations: 1.95 MiB)
In place     Julia:   159.153 μs (53 allocations: 124.56 KiB)
Using `mul!`-Julia:   520.705 μs (167 allocations: 1.12 MiB)
Out of place GCC:     100.226 μs (0 allocations: 0 bytes)
Out of place Clang:   158.575 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (7,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 7}, 1}:
Out of place Julia:   842.753 μs (410 allocations: 2.21 MiB)
In place     Julia:   164.439 μs (53 allocations: 140.69 KiB)
Using `mul!`-Julia:   501.425 μs (167 allocations: 1.28 MiB)
Out of place GCC:     143.869 μs (0 allocations: 0 bytes)
Out of place Clang:   103.923 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (8,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 8}, 1}:
Out of place Julia:   976.292 μs (410 allocations: 2.17 MiB)
In place     Julia:   221.989 μs (53 allocations: 159.50 KiB)
Using `mul!`-Julia:   585.168 μs (167 allocations: 1.17 MiB)
Out of place GCC:     175.238 μs (0 allocations: 0 bytes)
Out of place Clang:   138.527 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (1,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 1}, 2}:
Out of place Julia:   371.197 μs (410 allocations: 1.78 MiB)
In place     Julia:   94.217 μs (53 allocations: 58.05 KiB)
Using `mul!`-Julia:   221.838 μs (167 allocations: 1.25 MiB)
Out of place GCC:     64.527 μs (0 allocations: 0 bytes)
Out of place Clang:   84.059 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (2,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 2}, 2}:
Out of place Julia:   526.393 μs (410 allocations: 1.89 MiB)
In place     Julia:   135.307 μs (53 allocations: 86.27 KiB)
Using `mul!`-Julia:   288.993 μs (167 allocations: 1.23 MiB)
Out of place GCC:     82.584 μs (0 allocations: 0 bytes)
Out of place Clang:   103.284 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (3,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 3}, 2}:
Out of place Julia:   738.858 μs (410 allocations: 1.92 MiB)
In place     Julia:   166.233 μs (53 allocations: 108.44 KiB)
Using `mul!`-Julia:   448.738 μs (167 allocations: 1.16 MiB)
Out of place GCC:     114.111 μs (0 allocations: 0 bytes)
Out of place Clang:   135.064 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (4,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 4}, 2}:
Out of place Julia:   806.208 μs (410 allocations: 2.08 MiB)
In place     Julia:   182.008 μs (53 allocations: 132.62 KiB)
Using `mul!`-Julia:   490.725 μs (167 allocations: 1.20 MiB)
Out of place GCC:     160.517 μs (0 allocations: 0 bytes)
Out of place Clang:   157.441 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (5,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 5}, 2}:
Out of place Julia:   900.336 μs (410 allocations: 2.17 MiB)
In place     Julia:   211.169 μs (53 allocations: 159.50 KiB)
Using `mul!`-Julia:   554.619 μs (167 allocations: 1.17 MiB)
Out of place GCC:     205.169 μs (0 allocations: 0 bytes)
Out of place Clang:   172.488 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (6,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 6}, 2}:
Out of place Julia:   1.003 ms (410 allocations: 2.52 MiB)
In place     Julia:   232.097 μs (53 allocations: 183.69 KiB)
Using `mul!`-Julia:   645.673 μs (167 allocations: 1.36 MiB)
Out of place GCC:     225.848 μs (0 allocations: 0 bytes)
Out of place Clang:   184.070 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (7,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 7}, 2}:
Out of place Julia:   995.325 μs (410 allocations: 2.49 MiB)
In place     Julia:   205.942 μs (53 allocations: 207.88 KiB)
Using `mul!`-Julia:   590.079 μs (167 allocations: 1.24 MiB)
Out of place GCC:     338.537 μs (0 allocations: 0 bytes)
Out of place Clang:   217.819 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (8,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 8}, 2}:
Out of place Julia:   1.304 ms (410 allocations: 2.81 MiB)
In place     Julia:   309.060 μs (53 allocations: 234.75 KiB)
Using `mul!`-Julia:   798.978 μs (167 allocations: 1.40 MiB)
Out of place GCC:     352.386 μs (0 allocations: 0 bytes)
Out of place Clang:   257.139 μs (0 allocations: 0 bytes)
Total compile times: 
Out of place Julia: 50.229 s
In place     Julia: 17.816 s
Using `mul!` Julia: 36.261 s
Out of place GCC:   79.720 ms
Out of place Clang: 72.812 ms
```
Especially when the array sizes are smaller (dimensions and dual sizes), the C++ implementions perform much better than Julia.
Clang -- which is powered by LLVM like Julia -- continues to outperform it into the larger sizes we care about/benchmark here. This is despite the much more naive C++ implementation.
In terms of compile times, the build step for Clang and GCC took
```
[100%] Linking CXX shared library libMatrixExp.so
[100%] Built target MatrixExp # Clang; comp in parallel with GCC

real    0m5.242s
user    0m45.405s
sys     0m1.662s
[100%] Linking CXX shared library libMatrixExp.so
[100%] Built target MatrixExp # GCC; comp in parallel with Clang

real    0m7.354s
user    1m6.521s
sys     0m1.904s
```
So their overall compile times were much smaller.
