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
Out of place Julia:   18.384 μs (272 allocations: 25.34 KiB)
In place     Julia:   5.510 μs (53 allocations: 4.81 KiB)
Out of place GCC:     1.962 μs (0 allocations: 0 bytes)
Out of place Clang:   1.891 μs (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (1,0), T = ForwardDiff.Dual{Nothing, Float64, 1}:
Out of place Julia:   19.316 μs (272 allocations: 33.53 KiB)
In place     Julia:   7.149 μs (53 allocations: 6.16 KiB)
Out of place GCC:     2.876 μs (0 allocations: 0 bytes)
Out of place Clang:   2.567 μs (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (2,0), T = ForwardDiff.Dual{Nothing, Float64, 2}:
Out of place Julia:   25.291 μs (272 allocations: 41.72 KiB)
In place     Julia:   9.222 μs (53 allocations: 7.50 KiB)
Out of place GCC:     3.102 μs (0 allocations: 0 bytes)
Out of place Clang:   2.810 μs (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (3,0), T = ForwardDiff.Dual{Nothing, Float64, 3}:
Out of place Julia:   27.102 μs (272 allocations: 49.91 KiB)
In place     Julia:   9.675 μs (53 allocations: 8.84 KiB)
Out of place GCC:     3.717 μs (0 allocations: 0 bytes)
Out of place Clang:   3.378 μs (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (4,0), T = ForwardDiff.Dual{Nothing, Float64, 4}:
Out of place Julia:   28.567 μs (272 allocations: 58.09 KiB)
In place     Julia:   11.171 μs (53 allocations: 10.19 KiB)
Out of place GCC:     3.881 μs (0 allocations: 0 bytes)
Out of place Clang:   3.993 μs (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (5,0), T = ForwardDiff.Dual{Nothing, Float64, 5}:
Out of place Julia:   28.308 μs (272 allocations: 66.28 KiB)
In place     Julia:   10.640 μs (53 allocations: 11.53 KiB)
Out of place GCC:     4.331 μs (0 allocations: 0 bytes)
Out of place Clang:   4.769 μs (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (6,0), T = ForwardDiff.Dual{Nothing, Float64, 6}:
Out of place Julia:   37.887 μs (272 allocations: 74.47 KiB)
In place     Julia:   12.678 μs (53 allocations: 12.88 KiB)
Out of place GCC:     4.595 μs (0 allocations: 0 bytes)
Out of place Clang:   5.220 μs (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (7,0), T = ForwardDiff.Dual{Nothing, Float64, 7}:
Out of place Julia:   29.107 μs (272 allocations: 86.75 KiB)
In place     Julia:   11.734 μs (53 allocations: 14.89 KiB)
Out of place GCC:     6.846 μs (0 allocations: 0 bytes)
Out of place Clang:   4.779 μs (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (8,0), T = ForwardDiff.Dual{Nothing, Float64, 8}:
Out of place Julia:   43.310 μs (272 allocations: 94.94 KiB)
In place     Julia:   12.778 μs (53 allocations: 16.23 KiB)
Out of place GCC:     5.349 μs (0 allocations: 0 bytes)
Out of place Clang:   4.940 μs (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (1,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 1}, 1}:
Out of place Julia:   26.731 μs (272 allocations: 49.91 KiB)
In place     Julia:   10.731 μs (53 allocations: 8.84 KiB)
Out of place GCC:     4.431 μs (0 allocations: 0 bytes)
Out of place Clang:   4.124 μs (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (2,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 2}, 1}:
Out of place Julia:   30.836 μs (272 allocations: 66.28 KiB)
In place     Julia:   12.133 μs (53 allocations: 11.53 KiB)
Out of place GCC:     5.372 μs (0 allocations: 0 bytes)
Out of place Clang:   6.263 μs (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (3,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 3}, 1}:
Out of place Julia:   32.314 μs (272 allocations: 86.75 KiB)
In place     Julia:   13.377 μs (53 allocations: 14.89 KiB)
Out of place GCC:     7.178 μs (0 allocations: 0 bytes)
Out of place Clang:   5.666 μs (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (4,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 4}, 1}:
Out of place Julia:   35.549 μs (272 allocations: 103.12 KiB)
In place     Julia:   16.110 μs (53 allocations: 17.58 KiB)
Out of place GCC:     7.646 μs (0 allocations: 0 bytes)
Out of place Clang:   7.970 μs (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (5,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 5}, 1}:
Out of place Julia:   59.947 μs (272 allocations: 115.41 KiB)
In place     Julia:   27.227 μs (53 allocations: 19.59 KiB)
Out of place GCC:     9.447 μs (0 allocations: 0 bytes)
Out of place Clang:   7.427 μs (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (6,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 6}, 1}:
Out of place Julia:   57.792 μs (272 allocations: 139.97 KiB)
In place     Julia:   26.830 μs (53 allocations: 23.62 KiB)
Out of place GCC:     10.735 μs (0 allocations: 0 bytes)
Out of place Clang:   10.283 μs (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (7,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 7}, 1}:
Out of place Julia:   59.976 μs (272 allocations: 148.16 KiB)
In place     Julia:   28.028 μs (53 allocations: 24.97 KiB)
Out of place GCC:     12.679 μs (0 allocations: 0 bytes)
Out of place Clang:   6.980 μs (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (8,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 8}, 1}:
Out of place Julia:   83.286 μs (272 allocations: 172.72 KiB)
In place     Julia:   33.883 μs (53 allocations: 29.00 KiB)
Out of place GCC:     17.001 μs (0 allocations: 0 bytes)
Out of place Clang:   8.740 μs (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (1,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 1}, 2}:
Out of place Julia:   31.673 μs (272 allocations: 66.28 KiB)
In place     Julia:   13.534 μs (53 allocations: 11.53 KiB)
Out of place GCC:     4.984 μs (0 allocations: 0 bytes)
Out of place Clang:   6.015 μs (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (2,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 2}, 2}:
Out of place Julia:   35.489 μs (272 allocations: 94.94 KiB)
In place     Julia:   15.694 μs (53 allocations: 16.23 KiB)
Out of place GCC:     7.965 μs (0 allocations: 0 bytes)
Out of place Clang:   8.010 μs (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (3,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 3}, 2}:
Out of place Julia:   63.025 μs (272 allocations: 115.41 KiB)
In place     Julia:   24.466 μs (53 allocations: 19.59 KiB)
Out of place GCC:     10.970 μs (0 allocations: 0 bytes)
Out of place Clang:   8.416 μs (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (4,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 4}, 2}:
Out of place Julia:   53.746 μs (272 allocations: 139.97 KiB)
In place     Julia:   25.585 μs (53 allocations: 23.62 KiB)
Out of place GCC:     16.206 μs (0 allocations: 0 bytes)
Out of place Clang:   12.069 μs (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (5,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 5}, 2}:
Out of place Julia:   60.411 μs (272 allocations: 172.72 KiB)
In place     Julia:   27.457 μs (53 allocations: 29.00 KiB)
Out of place GCC:     19.643 μs (0 allocations: 0 bytes)
Out of place Clang:   13.070 μs (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (6,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 6}, 2}:
Out of place Julia:   92.587 μs (272 allocations: 189.09 KiB)
In place     Julia:   36.849 μs (53 allocations: 31.69 KiB)
Out of place GCC:     18.214 μs (0 allocations: 0 bytes)
Out of place Clang:   14.279 μs (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (7,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 7}, 2}:
Out of place Julia:   75.373 μs (272 allocations: 230.03 KiB)
In place     Julia:   33.709 μs (53 allocations: 38.41 KiB)
Out of place GCC:     25.780 μs (0 allocations: 0 bytes)
Out of place Clang:   9.986 μs (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (8,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 8}, 2}:
Out of place Julia:   91.830 μs (272 allocations: 258.69 KiB)
In place     Julia:   45.680 μs (53 allocations: 43.11 KiB)
Out of place GCC:     28.645 μs (0 allocations: 0 bytes)
Out of place Clang:   15.238 μs (0 allocations: 0 bytes)
Size 3 x 3:
Size 3 x 3, duals (n,j) = (0,0), T = Float64:
Out of place Julia:   24.573 μs (272 allocations: 33.53 KiB)
In place     Julia:   7.467 μs (53 allocations: 6.16 KiB)
Out of place GCC:     3.994 μs (0 allocations: 0 bytes)
Out of place Clang:   3.979 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (1,0), T = ForwardDiff.Dual{Nothing, Float64, 1}:
Out of place Julia:   36.510 μs (272 allocations: 54.00 KiB)
In place     Julia:   14.420 μs (53 allocations: 9.52 KiB)
Out of place GCC:     6.283 μs (0 allocations: 0 bytes)
Out of place Clang:   5.694 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (2,0), T = ForwardDiff.Dual{Nothing, Float64, 2}:
Out of place Julia:   45.474 μs (272 allocations: 70.38 KiB)
In place     Julia:   17.728 μs (53 allocations: 12.20 KiB)
Out of place GCC:     7.424 μs (0 allocations: 0 bytes)
Out of place Clang:   6.747 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (3,0), T = ForwardDiff.Dual{Nothing, Float64, 3}:
Out of place Julia:   47.975 μs (272 allocations: 94.94 KiB)
In place     Julia:   19.290 μs (53 allocations: 16.23 KiB)
Out of place GCC:     10.381 μs (0 allocations: 0 bytes)
Out of place Clang:   10.701 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (4,0), T = ForwardDiff.Dual{Nothing, Float64, 4}:
Out of place Julia:   55.108 μs (272 allocations: 115.41 KiB)
In place     Julia:   22.404 μs (53 allocations: 19.59 KiB)
Out of place GCC:     8.313 μs (0 allocations: 0 bytes)
Out of place Clang:   11.228 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (5,0), T = ForwardDiff.Dual{Nothing, Float64, 5}:
Out of place Julia:   61.055 μs (272 allocations: 127.69 KiB)
In place     Julia:   25.782 μs (53 allocations: 21.61 KiB)
Out of place GCC:     10.114 μs (0 allocations: 0 bytes)
Out of place Clang:   12.768 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (6,0), T = ForwardDiff.Dual{Nothing, Float64, 6}:
Out of place Julia:   67.457 μs (272 allocations: 148.16 KiB)
In place     Julia:   29.336 μs (53 allocations: 24.97 KiB)
Out of place GCC:     11.109 μs (0 allocations: 0 bytes)
Out of place Clang:   13.733 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (7,0), T = ForwardDiff.Dual{Nothing, Float64, 7}:
Out of place Julia:   73.241 μs (272 allocations: 172.72 KiB)
In place     Julia:   30.780 μs (53 allocations: 29.00 KiB)
Out of place GCC:     18.544 μs (0 allocations: 0 bytes)
Out of place Clang:   17.780 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (8,0), T = ForwardDiff.Dual{Nothing, Float64, 8}:
Out of place Julia:   77.762 μs (272 allocations: 189.09 KiB)
In place     Julia:   28.299 μs (53 allocations: 31.69 KiB)
Out of place GCC:     15.844 μs (0 allocations: 0 bytes)
Out of place Clang:   16.487 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (1,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 1}, 1}:
Out of place Julia:   53.318 μs (272 allocations: 94.94 KiB)
In place     Julia:   22.920 μs (53 allocations: 16.23 KiB)
Out of place GCC:     11.224 μs (0 allocations: 0 bytes)
Out of place Clang:   10.378 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (2,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 2}, 1}:
Out of place Julia:   65.086 μs (272 allocations: 127.69 KiB)
In place     Julia:   29.382 μs (53 allocations: 21.61 KiB)
Out of place GCC:     13.343 μs (0 allocations: 0 bytes)
Out of place Clang:   13.455 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (3,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 3}, 1}:
Out of place Julia:   82.446 μs (272 allocations: 172.72 KiB)
In place     Julia:   37.241 μs (53 allocations: 29.00 KiB)
Out of place GCC:     21.920 μs (0 allocations: 0 bytes)
Out of place Clang:   23.004 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (4,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 4}, 1}:
Out of place Julia:   94.491 μs (272 allocations: 209.56 KiB)
In place     Julia:   43.816 μs (53 allocations: 35.05 KiB)
Out of place GCC:     20.984 μs (0 allocations: 0 bytes)
Out of place Clang:   24.421 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (5,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 5}, 1}:
Out of place Julia:   118.708 μs (272 allocations: 258.69 KiB)
In place     Julia:   68.713 μs (53 allocations: 43.11 KiB)
Out of place GCC:     23.244 μs (0 allocations: 0 bytes)
Out of place Clang:   25.970 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (6,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 6}, 1}:
Out of place Julia:   160.261 μs (272 allocations: 279.16 KiB)
In place     Julia:   78.367 μs (53 allocations: 46.47 KiB)
Out of place GCC:     27.173 μs (0 allocations: 0 bytes)
Out of place Clang:   32.122 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (7,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 7}, 1}:
Out of place Julia:   175.251 μs (272 allocations: 320.09 KiB)
In place     Julia:   84.232 μs (53 allocations: 53.19 KiB)
Out of place GCC:     37.442 μs (0 allocations: 0 bytes)
Out of place Clang:   21.291 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (8,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 8}, 1}:
Out of place Julia:   192.253 μs (272 allocations: 348.75 KiB)
In place     Julia:   86.958 μs (53 allocations: 57.89 KiB)
Out of place GCC:     48.793 μs (0 allocations: 0 bytes)
Out of place Clang:   33.644 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (1,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 1}, 2}:
Out of place Julia:   69.448 μs (272 allocations: 127.69 KiB)
In place     Julia:   31.656 μs (53 allocations: 21.61 KiB)
Out of place GCC:     12.113 μs (0 allocations: 0 bytes)
Out of place Clang:   17.212 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (2,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 2}, 2}:
Out of place Julia:   93.769 μs (272 allocations: 189.09 KiB)
In place     Julia:   45.976 μs (53 allocations: 31.69 KiB)
Out of place GCC:     24.069 μs (0 allocations: 0 bytes)
Out of place Clang:   26.058 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (3,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 3}, 2}:
Out of place Julia:   107.835 μs (272 allocations: 258.69 KiB)
In place     Julia:   58.587 μs (53 allocations: 43.11 KiB)
Out of place GCC:     28.651 μs (0 allocations: 0 bytes)
Out of place Clang:   30.885 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (4,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 4}, 2}:
Out of place Julia:   152.223 μs (272 allocations: 299.62 KiB)
In place     Julia:   71.619 μs (53 allocations: 49.83 KiB)
Out of place GCC:     38.968 μs (0 allocations: 0 bytes)
Out of place Clang:   33.144 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (5,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 5}, 2}:
Out of place Julia:   175.590 μs (272 allocations: 348.75 KiB)
In place     Julia:   82.083 μs (53 allocations: 57.89 KiB)
Out of place GCC:     50.449 μs (0 allocations: 0 bytes)
Out of place Clang:   33.311 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (6,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 6}, 2}:
Out of place Julia:   201.887 μs (272 allocations: 418.34 KiB)
In place     Julia:   100.115 μs (53 allocations: 69.31 KiB)
Out of place GCC:     52.315 μs (0 allocations: 0 bytes)
Out of place Clang:   48.958 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (7,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 7}, 2}:
Out of place Julia:   220.309 μs (272 allocations: 463.38 KiB)
In place     Julia:   102.284 μs (53 allocations: 76.70 KiB)
Out of place GCC:     84.305 μs (0 allocations: 0 bytes)
Out of place Clang:   36.508 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (8,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 8}, 2}:
Out of place Julia:   287.607 μs (272 allocations: 520.69 KiB)
In place     Julia:   145.928 μs (53 allocations: 86.11 KiB)
Out of place GCC:     76.437 μs (0 allocations: 0 bytes)
Out of place Clang:   44.624 μs (0 allocations: 0 bytes)
Size 4 x 4:
Size 4 x 4, duals (n,j) = (0,0), T = Float64:
Out of place Julia:   43.761 μs (272 allocations: 50.06 KiB)
In place     Julia:   22.520 μs (53 allocations: 9.00 KiB)
Out of place GCC:     6.729 μs (0 allocations: 0 bytes)
Out of place Clang:   7.250 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (1,0), T = ForwardDiff.Dual{Nothing, Float64, 1}:
Out of place Julia:   126.008 μs (479 allocations: 1.43 MiB)
In place     Julia:   88.101 μs (224 allocations: 1.12 MiB)
Out of place GCC:     11.288 μs (0 allocations: 0 bytes)
Out of place Clang:   11.193 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (2,0), T = ForwardDiff.Dual{Nothing, Float64, 2}:
Out of place Julia:   142.666 μs (479 allocations: 1.53 MiB)
In place     Julia:   96.880 μs (224 allocations: 1.19 MiB)
Out of place GCC:     14.728 μs (0 allocations: 0 bytes)
Out of place Clang:   14.258 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (3,0), T = ForwardDiff.Dual{Nothing, Float64, 3}:
Out of place Julia:   147.985 μs (479 allocations: 1.53 MiB)
In place     Julia:   100.969 μs (224 allocations: 1.17 MiB)
Out of place GCC:     19.340 μs (0 allocations: 0 bytes)
Out of place Clang:   24.181 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (4,0), T = ForwardDiff.Dual{Nothing, Float64, 4}:
Out of place Julia:   169.228 μs (479 allocations: 1.55 MiB)
In place     Julia:   109.626 μs (224 allocations: 1.16 MiB)
Out of place GCC:     19.648 μs (0 allocations: 0 bytes)
Out of place Clang:   26.949 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (5,0), T = ForwardDiff.Dual{Nothing, Float64, 5}:
Out of place Julia:   180.868 μs (479 allocations: 1.67 MiB)
In place     Julia:   114.768 μs (224 allocations: 1.23 MiB)
Out of place GCC:     21.812 μs (0 allocations: 0 bytes)
Out of place Clang:   25.776 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (6,0), T = ForwardDiff.Dual{Nothing, Float64, 6}:
Out of place Julia:   163.565 μs (479 allocations: 1.52 MiB)
In place     Julia:   118.392 μs (224 allocations: 1.09 MiB)
Out of place GCC:     22.954 μs (0 allocations: 0 bytes)
Out of place Clang:   29.299 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (7,0), T = ForwardDiff.Dual{Nothing, Float64, 7}:
Out of place Julia:   187.375 μs (479 allocations: 1.50 MiB)
In place     Julia:   111.724 μs (224 allocations: 1.06 MiB)
Out of place GCC:     41.342 μs (0 allocations: 0 bytes)
Out of place Clang:   39.118 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (8,0), T = ForwardDiff.Dual{Nothing, Float64, 8}:
Out of place Julia:   216.829 μs (479 allocations: 1.70 MiB)
In place     Julia:   128.585 μs (224 allocations: 1.19 MiB)
Out of place GCC:     35.957 μs (0 allocations: 0 bytes)
Out of place Clang:   34.607 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (1,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 1}, 1}:
Out of place Julia:   165.966 μs (479 allocations: 1.53 MiB)
In place     Julia:   98.668 μs (224 allocations: 1.17 MiB)
Out of place GCC:     22.607 μs (0 allocations: 0 bytes)
Out of place Clang:   25.089 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (2,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 2}, 1}:
Out of place Julia:   183.967 μs (479 allocations: 1.67 MiB)
In place     Julia:   120.461 μs (224 allocations: 1.23 MiB)
Out of place GCC:     24.843 μs (0 allocations: 0 bytes)
Out of place Clang:   28.292 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (3,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 3}, 1}:
Out of place Julia:   202.520 μs (479 allocations: 1.50 MiB)
In place     Julia:   129.414 μs (224 allocations: 1.06 MiB)
Out of place GCC:     50.947 μs (0 allocations: 0 bytes)
Out of place Clang:   47.336 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (4,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 4}, 1}:
Out of place Julia:   255.105 μs (479 allocations: 1.64 MiB)
In place     Julia:   159.990 μs (224 allocations: 1.13 MiB)
Out of place GCC:     44.079 μs (0 allocations: 0 bytes)
Out of place Clang:   53.859 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (5,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 5}, 1}:
Out of place Julia:   414.020 μs (479 allocations: 1.69 MiB)
In place     Julia:   262.895 μs (224 allocations: 1.13 MiB)
Out of place GCC:     50.067 μs (0 allocations: 0 bytes)
Out of place Clang:   56.523 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (6,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 6}, 1}:
Out of place Julia:   477.002 μs (479 allocations: 1.72 MiB)
In place     Julia:   295.235 μs (224 allocations: 1.09 MiB)
Out of place GCC:     51.213 μs (0 allocations: 0 bytes)
Out of place Clang:   69.092 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (7,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 7}, 1}:
Out of place Julia:   496.255 μs (479 allocations: 1.93 MiB)
In place     Julia:   274.720 μs (224 allocations: 1.23 MiB)
Out of place GCC:     82.735 μs (0 allocations: 0 bytes)
Out of place Clang:   52.233 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (8,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 8}, 1}:
Out of place Julia:   540.428 μs (479 allocations: 1.84 MiB)
In place     Julia:   299.618 μs (224 allocations: 1.12 MiB)
Out of place GCC:     101.625 μs (0 allocations: 0 bytes)
Out of place Clang:   70.783 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (1,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 1}, 2}:
Out of place Julia:   198.103 μs (479 allocations: 1.67 MiB)
In place     Julia:   134.255 μs (224 allocations: 1.23 MiB)
Out of place GCC:     27.703 μs (0 allocations: 0 bytes)
Out of place Clang:   38.007 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (2,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 2}, 2}:
Out of place Julia:   251.380 μs (479 allocations: 1.70 MiB)
In place     Julia:   163.334 μs (224 allocations: 1.19 MiB)
Out of place GCC:     52.582 μs (0 allocations: 0 bytes)
Out of place Clang:   53.899 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (3,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 3}, 2}:
Out of place Julia:   404.405 μs (479 allocations: 1.69 MiB)
In place     Julia:   257.871 μs (224 allocations: 1.13 MiB)
Out of place GCC:     69.235 μs (0 allocations: 0 bytes)
Out of place Clang:   74.456 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (4,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 4}, 2}:
Out of place Julia:   445.695 μs (479 allocations: 1.81 MiB)
In place     Julia:   283.948 μs (224 allocations: 1.16 MiB)
Out of place GCC:     87.642 μs (0 allocations: 0 bytes)
Out of place Clang:   81.705 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (5,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 5}, 2}:
Out of place Julia:   491.132 μs (479 allocations: 1.84 MiB)
In place     Julia:   299.527 μs (224 allocations: 1.12 MiB)
Out of place GCC:     104.439 μs (0 allocations: 0 bytes)
Out of place Clang:   84.150 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (6,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 6}, 2}:
Out of place Julia:   557.294 μs (479 allocations: 2.14 MiB)
In place     Julia:   351.273 μs (224 allocations: 1.30 MiB)
Out of place GCC:     120.614 μs (0 allocations: 0 bytes)
Out of place Clang:   111.604 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (7,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 7}, 2}:
Out of place Julia:   566.150 μs (479 allocations: 2.06 MiB)
In place     Julia:   351.132 μs (224 allocations: 1.17 MiB)
Out of place GCC:     180.909 μs (0 allocations: 0 bytes)
Out of place Clang:   66.617 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (8,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 8}, 2}:
Out of place Julia:   724.293 μs (479 allocations: 2.31 MiB)
In place     Julia:   467.161 μs (224 allocations: 1.32 MiB)
Out of place GCC:     186.400 μs (0 allocations: 0 bytes)
Out of place Clang:   111.741 μs (0 allocations: 0 bytes)
Size 5 x 5:
Size 5 x 5, duals (n,j) = (0,0), T = Float64:
Out of place Julia:   59.537 μs (272 allocations: 66.44 KiB)
In place     Julia:   36.342 μs (53 allocations: 11.69 KiB)
Out of place GCC:     11.253 μs (0 allocations: 0 bytes)
Out of place Clang:   12.127 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (1,0), T = ForwardDiff.Dual{Nothing, Float64, 1}:
Out of place Julia:   152.820 μs (479 allocations: 1.47 MiB)
In place     Julia:   107.775 μs (224 allocations: 1.13 MiB)
Out of place GCC:     19.751 μs (0 allocations: 0 bytes)
Out of place Clang:   23.094 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (2,0), T = ForwardDiff.Dual{Nothing, Float64, 2}:
Out of place Julia:   180.399 μs (479 allocations: 1.58 MiB)
In place     Julia:   121.162 μs (224 allocations: 1.20 MiB)
Out of place GCC:     26.120 μs (0 allocations: 0 bytes)
Out of place Clang:   28.974 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (3,0), T = ForwardDiff.Dual{Nothing, Float64, 3}:
Out of place Julia:   191.649 μs (479 allocations: 1.61 MiB)
In place     Julia:   122.774 μs (224 allocations: 1.18 MiB)
Out of place GCC:     36.670 μs (0 allocations: 0 bytes)
Out of place Clang:   42.796 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (4,0), T = ForwardDiff.Dual{Nothing, Float64, 4}:
Out of place Julia:   220.644 μs (479 allocations: 1.64 MiB)
In place     Julia:   144.426 μs (224 allocations: 1.17 MiB)
Out of place GCC:     34.550 μs (0 allocations: 0 bytes)
Out of place Clang:   54.045 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (5,0), T = ForwardDiff.Dual{Nothing, Float64, 5}:
Out of place Julia:   245.610 μs (479 allocations: 1.78 MiB)
In place     Julia:   152.253 μs (224 allocations: 1.25 MiB)
Out of place GCC:     40.074 μs (0 allocations: 0 bytes)
Out of place Clang:   59.768 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (6,0), T = ForwardDiff.Dual{Nothing, Float64, 6}:
Out of place Julia:   252.756 μs (479 allocations: 1.64 MiB)
In place     Julia:   157.778 μs (224 allocations: 1.11 MiB)
Out of place GCC:     42.598 μs (0 allocations: 0 bytes)
Out of place Clang:   62.531 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (7,0), T = ForwardDiff.Dual{Nothing, Float64, 7}:
Out of place Julia:   257.207 μs (479 allocations: 1.68 MiB)
In place     Julia:   149.289 μs (224 allocations: 1.09 MiB)
Out of place GCC:     71.769 μs (0 allocations: 0 bytes)
Out of place Clang:   64.962 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (8,0), T = ForwardDiff.Dual{Nothing, Float64, 8}:
Out of place Julia:   309.815 μs (479 allocations: 1.89 MiB)
In place     Julia:   176.261 μs (224 allocations: 1.23 MiB)
Out of place GCC:     68.780 μs (0 allocations: 0 bytes)
Out of place Clang:   88.182 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (1,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 1}, 1}:
Out of place Julia:   214.516 μs (479 allocations: 1.61 MiB)
In place     Julia:   129.170 μs (224 allocations: 1.18 MiB)
Out of place GCC:     41.714 μs (0 allocations: 0 bytes)
Out of place Clang:   54.236 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (2,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 2}, 1}:
Out of place Julia:   247.953 μs (479 allocations: 1.78 MiB)
In place     Julia:   156.251 μs (224 allocations: 1.25 MiB)
Out of place GCC:     52.469 μs (0 allocations: 0 bytes)
Out of place Clang:   58.640 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (3,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 3}, 1}:
Out of place Julia:   299.211 μs (479 allocations: 1.68 MiB)
In place     Julia:   179.123 μs (224 allocations: 1.09 MiB)
Out of place GCC:     87.761 μs (0 allocations: 0 bytes)
Out of place Clang:   92.435 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (4,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 4}, 1}:
Out of place Julia:   375.190 μs (479 allocations: 1.83 MiB)
In place     Julia:   235.171 μs (224 allocations: 1.16 MiB)
Out of place GCC:     97.510 μs (0 allocations: 0 bytes)
Out of place Clang:   106.440 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (5,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 5}, 1}:
Out of place Julia:   676.141 μs (479 allocations: 1.92 MiB)
In place     Julia:   431.194 μs (224 allocations: 1.16 MiB)
Out of place GCC:     88.538 μs (0 allocations: 0 bytes)
Out of place Clang:   106.302 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (6,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 6}, 1}:
Out of place Julia:   725.513 μs (479 allocations: 1.95 MiB)
In place     Julia:   482.363 μs (224 allocations: 1.12 MiB)
Out of place GCC:     113.478 μs (0 allocations: 0 bytes)
Out of place Clang:   145.585 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (7,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 7}, 1}:
Out of place Julia:   756.538 μs (479 allocations: 2.21 MiB)
In place     Julia:   442.829 μs (224 allocations: 1.28 MiB)
Out of place GCC:     143.561 μs (0 allocations: 0 bytes)
Out of place Clang:   86.807 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (8,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 8}, 1}:
Out of place Julia:   828.681 μs (479 allocations: 2.18 MiB)
In place     Julia:   508.596 μs (224 allocations: 1.17 MiB)
Out of place GCC:     207.721 μs (0 allocations: 0 bytes)
Out of place Clang:   139.428 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (1,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 1}, 2}:
Out of place Julia:   288.597 μs (479 allocations: 1.78 MiB)
In place     Julia:   189.145 μs (224 allocations: 1.25 MiB)
Out of place GCC:     59.752 μs (0 allocations: 0 bytes)
Out of place Clang:   80.768 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (2,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 2}, 2}:
Out of place Julia:   380.931 μs (479 allocations: 1.89 MiB)
In place     Julia:   253.794 μs (224 allocations: 1.23 MiB)
Out of place GCC:     89.762 μs (0 allocations: 0 bytes)
Out of place Clang:   113.143 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (3,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 3}, 2}:
Out of place Julia:   654.645 μs (479 allocations: 1.92 MiB)
In place     Julia:   424.904 μs (224 allocations: 1.16 MiB)
Out of place GCC:     109.685 μs (0 allocations: 0 bytes)
Out of place Clang:   122.183 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (4,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 4}, 2}:
Out of place Julia:   686.288 μs (479 allocations: 2.08 MiB)
In place     Julia:   449.576 μs (224 allocations: 1.20 MiB)
Out of place GCC:     155.900 μs (0 allocations: 0 bytes)
Out of place Clang:   180.689 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (5,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 5}, 2}:
Out of place Julia:   744.760 μs (479 allocations: 2.18 MiB)
In place     Julia:   491.265 μs (224 allocations: 1.17 MiB)
Out of place GCC:     209.946 μs (0 allocations: 0 bytes)
Out of place Clang:   150.967 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (6,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 6}, 2}:
Out of place Julia:   842.995 μs (479 allocations: 2.52 MiB)
In place     Julia:   578.857 μs (224 allocations: 1.36 MiB)
Out of place GCC:     239.043 μs (0 allocations: 0 bytes)
Out of place Clang:   215.708 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (7,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 7}, 2}:
Out of place Julia:   845.772 μs (479 allocations: 2.49 MiB)
In place     Julia:   563.533 μs (224 allocations: 1.24 MiB)
Out of place GCC:     318.920 μs (0 allocations: 0 bytes)
Out of place Clang:   133.386 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (8,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 8}, 2}:
Out of place Julia:   1.094 ms (479 allocations: 2.81 MiB)
In place     Julia:   776.375 μs (224 allocations: 1.40 MiB)
Out of place GCC:     348.467 μs (0 allocations: 0 bytes)
Out of place Clang:   213.581 μs (0 allocations: 0 bytes)
Total compile times: 
Out of place Julia: 68.716 s
In place     Julia: 72.749 s
Out of place GCC:   82.687 ms
Out of place Clang: 75.403 ms
```
Especially when the array sizes are smaller (dimensions and dual sizes), the C++ implementions perform much better than Julia.
Clang -- which is powered by LLVM like Julia -- continues to outperform it into the larger sizes we care about/benchmark here. This is despite the much more naive C++ implementation.
In terms of compile times, the build step for Clang and GCC took
```
[100%] Built target MatrixExp # Clang

real    0m6.800s
user    1m26.761s
sys     0m2.560s
[100%] Built target MatrixExp # GCC

real    0m8.935s
user    1m39.679s
sys     0m3.515s
```
So their overall compile times were much smaller.
