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
Size 1 x 1:
Size 1 x 1, duals (n,j) = (0,0), T = Float64:
Out of place Julia:   23.564 μs (262 allocations: 16.38 KiB)
In place     Julia:   10.182 μs (53 allocations: 3.31 KiB)
Out of place GCC:     1.028 μs (0 allocations: 0 bytes)
Out of place Clang:   1.085 μs (0 allocations: 0 bytes)
Size 1 x 1, duals (n,j) = (1,0), T = ForwardDiff.Dual{Nothing, Float64, 1}:
Out of place Julia:   106.147 μs (469 allocations: 1.36 MiB)
In place     Julia:   55.962 μs (224 allocations: 1.11 MiB)
Out of place GCC:     1.169 μs (0 allocations: 0 bytes)
Out of place Clang:   1.070 μs (0 allocations: 0 bytes)
Size 1 x 1, duals (n,j) = (2,0), T = ForwardDiff.Dual{Nothing, Float64, 2}:
Out of place Julia:   101.239 μs (469 allocations: 1.44 MiB)
In place     Julia:   63.333 μs (224 allocations: 1.17 MiB)
Out of place GCC:     1.192 μs (0 allocations: 0 bytes)
Out of place Clang:   1.231 μs (0 allocations: 0 bytes)
Size 1 x 1, duals (n,j) = (3,0), T = ForwardDiff.Dual{Nothing, Float64, 3}:
Out of place Julia:   123.981 μs (469 allocations: 1.41 MiB)
In place     Julia:   66.653 μs (224 allocations: 1.15 MiB)
Out of place GCC:     1.165 μs (0 allocations: 0 bytes)
Out of place Clang:   1.309 μs (0 allocations: 0 bytes)
Size 1 x 1, duals (n,j) = (4,0), T = ForwardDiff.Dual{Nothing, Float64, 4}:
Out of place Julia:   109.312 μs (469 allocations: 1.39 MiB)
In place     Julia:   63.677 μs (224 allocations: 1.13 MiB)
Out of place GCC:     919.083 ns (0 allocations: 0 bytes)
Out of place Clang:   1.700 μs (0 allocations: 0 bytes)
Size 1 x 1, duals (n,j) = (5,0), T = ForwardDiff.Dual{Nothing, Float64, 5}:
Out of place Julia:   99.677 μs (469 allocations: 1.47 MiB)
In place     Julia:   59.533 μs (224 allocations: 1.20 MiB)
Out of place GCC:     1.062 μs (0 allocations: 0 bytes)
Out of place Clang:   2.055 μs (0 allocations: 0 bytes)
Size 1 x 1, duals (n,j) = (6,0), T = ForwardDiff.Dual{Nothing, Float64, 6}:
Out of place Julia:   98.583 μs (469 allocations: 1.29 MiB)
In place     Julia:   58.457 μs (224 allocations: 1.05 MiB)
Out of place GCC:     1.213 μs (0 allocations: 0 bytes)
Out of place Clang:   1.580 μs (0 allocations: 0 bytes)
Size 1 x 1, duals (n,j) = (7,0), T = ForwardDiff.Dual{Nothing, Float64, 7}:
Out of place Julia:   97.953 μs (469 allocations: 1.26 MiB)
In place     Julia:   62.194 μs (224 allocations: 1.02 MiB)
Out of place GCC:     1.446 μs (0 allocations: 0 bytes)
Out of place Clang:   1.589 μs (0 allocations: 0 bytes)
Size 1 x 1, duals (n,j) = (8,0), T = ForwardDiff.Dual{Nothing, Float64, 8}:
Out of place Julia:   87.359 μs (469 allocations: 1.41 MiB)
In place     Julia:   59.000 μs (224 allocations: 1.15 MiB)
Out of place GCC:     1.629 μs (0 allocations: 0 bytes)
Out of place Clang:   1.577 μs (0 allocations: 0 bytes)
Size 1 x 1, duals (n,j) = (1,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 1}, 1}:
Out of place Julia:   139.857 μs (469 allocations: 1.41 MiB)
In place     Julia:   71.016 μs (224 allocations: 1.15 MiB)
Out of place GCC:     1.536 μs (0 allocations: 0 bytes)
Out of place Clang:   1.309 μs (0 allocations: 0 bytes)
Size 1 x 1, duals (n,j) = (2,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 2}, 1}:
Out of place Julia:   92.681 μs (469 allocations: 1.47 MiB)
In place     Julia:   59.898 μs (224 allocations: 1.20 MiB)
Out of place GCC:     1.614 μs (0 allocations: 0 bytes)
Out of place Clang:   1.899 μs (0 allocations: 0 bytes)
Size 1 x 1, duals (n,j) = (3,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 3}, 1}:
Out of place Julia:   118.476 μs (469 allocations: 1.26 MiB)
In place     Julia:   57.853 μs (224 allocations: 1.02 MiB)
Out of place GCC:     1.862 μs (0 allocations: 0 bytes)
Out of place Clang:   1.660 μs (0 allocations: 0 bytes)
Size 1 x 1, duals (n,j) = (4,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 4}, 1}:
Out of place Julia:   89.582 μs (469 allocations: 1.33 MiB)
In place     Julia:   59.346 μs (224 allocations: 1.08 MiB)
Out of place GCC:     2.095 μs (0 allocations: 0 bytes)
Out of place Clang:   1.817 μs (0 allocations: 0 bytes)
Size 1 x 1, duals (n,j) = (5,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 5}, 1}:
Out of place Julia:   88.942 μs (469 allocations: 1.32 MiB)
In place     Julia:   62.796 μs (224 allocations: 1.07 MiB)
Out of place GCC:     2.650 μs (0 allocations: 0 bytes)
Out of place Clang:   2.015 μs (0 allocations: 0 bytes)
Size 1 x 1, duals (n,j) = (6,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 6}, 1}:
Out of place Julia:   93.893 μs (469 allocations: 1.26 MiB)
In place     Julia:   60.965 μs (224 allocations: 1.01 MiB)
Out of place GCC:     2.637 μs (0 allocations: 0 bytes)
Out of place Clang:   2.094 μs (0 allocations: 0 bytes)
Size 1 x 1, duals (n,j) = (7,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 7}, 1}:
Out of place Julia:   93.147 μs (469 allocations: 1.43 MiB)
In place     Julia:   65.238 μs (224 allocations: 1.15 MiB)
Out of place GCC:     2.973 μs (0 allocations: 0 bytes)
Out of place Clang:   1.737 μs (0 allocations: 0 bytes)
Size 1 x 1, duals (n,j) = (8,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 8}, 1}:
Out of place Julia:   90.594 μs (469 allocations: 1.28 MiB)
In place     Julia:   63.177 μs (224 allocations: 1.03 MiB)
Out of place GCC:     3.529 μs (0 allocations: 0 bytes)
Out of place Clang:   1.952 μs (0 allocations: 0 bytes)
Size 1 x 1, duals (n,j) = (1,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 1}, 2}:
Out of place Julia:   94.548 μs (469 allocations: 1.47 MiB)
In place     Julia:   63.334 μs (224 allocations: 1.20 MiB)
Out of place GCC:     1.326 μs (0 allocations: 0 bytes)
Out of place Clang:   1.823 μs (0 allocations: 0 bytes)
Size 1 x 1, duals (n,j) = (2,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 2}, 2}:
Out of place Julia:   89.000 μs (469 allocations: 1.41 MiB)
In place     Julia:   63.318 μs (224 allocations: 1.15 MiB)
Out of place GCC:     1.970 μs (0 allocations: 0 bytes)
Out of place Clang:   1.713 μs (0 allocations: 0 bytes)
Size 1 x 1, duals (n,j) = (3,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 3}, 2}:
Out of place Julia:   104.234 μs (469 allocations: 1.32 MiB)
In place     Julia:   65.533 μs (224 allocations: 1.07 MiB)
Out of place GCC:     2.213 μs (0 allocations: 0 bytes)
Out of place Clang:   1.745 μs (0 allocations: 0 bytes)
Size 1 x 1, duals (n,j) = (4,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 4}, 2}:
Out of place Julia:   151.701 μs (469 allocations: 1.34 MiB)
In place     Julia:   75.012 μs (224 allocations: 1.08 MiB)
Out of place GCC:     3.555 μs (0 allocations: 0 bytes)
Out of place Clang:   2.217 μs (0 allocations: 0 bytes)
Size 1 x 1, duals (n,j) = (5,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 5}, 2}:
Out of place Julia:   99.684 μs (469 allocations: 1.28 MiB)
In place     Julia:   70.929 μs (224 allocations: 1.03 MiB)
Out of place GCC:     4.128 μs (0 allocations: 0 bytes)
Out of place Clang:   2.328 μs (0 allocations: 0 bytes)
Size 1 x 1, duals (n,j) = (6,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 6}, 2}:
Out of place Julia:   133.258 μs (469 allocations: 1.49 MiB)
In place     Julia:   79.308 μs (224 allocations: 1.19 MiB)
Out of place GCC:     4.241 μs (0 allocations: 0 bytes)
Out of place Clang:   2.783 μs (0 allocations: 0 bytes)
Size 1 x 1, duals (n,j) = (7,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 7}, 2}:
Out of place Julia:   103.577 μs (469 allocations: 1.32 MiB)
In place     Julia:   74.587 μs (224 allocations: 1.05 MiB)
Out of place GCC:     4.579 μs (0 allocations: 0 bytes)
Out of place Clang:   3.090 μs (0 allocations: 0 bytes)
Size 1 x 1, duals (n,j) = (8,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 8}, 2}:
Out of place Julia:   103.841 μs (469 allocations: 1.48 MiB)
In place     Julia:   74.207 μs (224 allocations: 1.18 MiB)
Out of place GCC:     9.624 μs (0 allocations: 0 bytes)
Out of place Clang:   3.873 μs (0 allocations: 0 bytes)
Size 2 x 2:
Size 2 x 2, duals (n,j) = (0,0), T = Float64:
Out of place Julia:   18.485 μs (272 allocations: 25.34 KiB)
In place     Julia:   5.686 μs (53 allocations: 4.81 KiB)
Out of place GCC:     2.107 μs (0 allocations: 0 bytes)
Out of place Clang:   2.057 μs (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (1,0), T = ForwardDiff.Dual{Nothing, Float64, 1}:
Out of place Julia:   25.461 μs (272 allocations: 33.53 KiB)
In place     Julia:   7.896 μs (53 allocations: 6.16 KiB)
Out of place GCC:     2.863 μs (0 allocations: 0 bytes)
Out of place Clang:   2.490 μs (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (2,0), T = ForwardDiff.Dual{Nothing, Float64, 2}:
Out of place Julia:   26.623 μs (272 allocations: 41.72 KiB)
In place     Julia:   9.772 μs (53 allocations: 7.50 KiB)
Out of place GCC:     3.008 μs (0 allocations: 0 bytes)
Out of place Clang:   2.712 μs (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (3,0), T = ForwardDiff.Dual{Nothing, Float64, 3}:
Out of place Julia:   33.395 μs (272 allocations: 49.91 KiB)
In place     Julia:   10.738 μs (53 allocations: 8.84 KiB)
Out of place GCC:     3.392 μs (0 allocations: 0 bytes)
Out of place Clang:   3.532 μs (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (4,0), T = ForwardDiff.Dual{Nothing, Float64, 4}:
Out of place Julia:   32.078 μs (272 allocations: 58.09 KiB)
In place     Julia:   12.272 μs (53 allocations: 10.19 KiB)
Out of place GCC:     3.629 μs (0 allocations: 0 bytes)
Out of place Clang:   4.751 μs (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (5,0), T = ForwardDiff.Dual{Nothing, Float64, 5}:
Out of place Julia:   37.670 μs (272 allocations: 66.28 KiB)
In place     Julia:   12.727 μs (53 allocations: 11.53 KiB)
Out of place GCC:     3.951 μs (0 allocations: 0 bytes)
Out of place Clang:   4.786 μs (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (6,0), T = ForwardDiff.Dual{Nothing, Float64, 6}:
Out of place Julia:   40.465 μs (272 allocations: 74.47 KiB)
In place     Julia:   13.283 μs (53 allocations: 12.88 KiB)
Out of place GCC:     4.066 μs (0 allocations: 0 bytes)
Out of place Clang:   4.947 μs (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (7,0), T = ForwardDiff.Dual{Nothing, Float64, 7}:
Out of place Julia:   41.506 μs (272 allocations: 86.75 KiB)
In place     Julia:   13.375 μs (53 allocations: 14.89 KiB)
Out of place GCC:     6.535 μs (0 allocations: 0 bytes)
Out of place Clang:   4.972 μs (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (8,0), T = ForwardDiff.Dual{Nothing, Float64, 8}:
Out of place Julia:   44.053 μs (272 allocations: 94.94 KiB)
In place     Julia:   13.605 μs (53 allocations: 16.23 KiB)
Out of place GCC:     4.992 μs (0 allocations: 0 bytes)
Out of place Clang:   5.189 μs (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (1,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 1}, 1}:
Out of place Julia:   34.414 μs (272 allocations: 49.91 KiB)
In place     Julia:   11.565 μs (53 allocations: 8.84 KiB)
Out of place GCC:     4.319 μs (0 allocations: 0 bytes)
Out of place Clang:   3.517 μs (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (2,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 2}, 1}:
Out of place Julia:   40.272 μs (272 allocations: 66.28 KiB)
In place     Julia:   14.635 μs (53 allocations: 11.53 KiB)
Out of place GCC:     5.273 μs (0 allocations: 0 bytes)
Out of place Clang:   5.327 μs (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (3,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 3}, 1}:
Out of place Julia:   44.258 μs (272 allocations: 86.75 KiB)
In place     Julia:   15.298 μs (53 allocations: 14.89 KiB)
Out of place GCC:     8.092 μs (0 allocations: 0 bytes)
Out of place Clang:   5.768 μs (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (4,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 4}, 1}:
Out of place Julia:   51.147 μs (272 allocations: 103.12 KiB)
In place     Julia:   18.788 μs (53 allocations: 17.58 KiB)
Out of place GCC:     9.569 μs (0 allocations: 0 bytes)
Out of place Clang:   8.031 μs (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (5,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 5}, 1}:
Out of place Julia:   61.778 μs (272 allocations: 115.41 KiB)
In place     Julia:   28.137 μs (53 allocations: 19.59 KiB)
Out of place GCC:     9.134 μs (0 allocations: 0 bytes)
Out of place Clang:   7.168 μs (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (6,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 6}, 1}:
Out of place Julia:   78.156 μs (272 allocations: 139.97 KiB)
In place     Julia:   30.341 μs (53 allocations: 23.62 KiB)
Out of place GCC:     9.939 μs (0 allocations: 0 bytes)
Out of place Clang:   10.650 μs (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (7,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 7}, 1}:
Out of place Julia:   80.346 μs (272 allocations: 148.16 KiB)
In place     Julia:   32.586 μs (53 allocations: 24.97 KiB)
Out of place GCC:     13.828 μs (0 allocations: 0 bytes)
Out of place Clang:   7.772 μs (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (8,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 8}, 1}:
Out of place Julia:   89.322 μs (272 allocations: 172.72 KiB)
In place     Julia:   33.787 μs (53 allocations: 29.00 KiB)
Out of place GCC:     16.109 μs (0 allocations: 0 bytes)
Out of place Clang:   8.046 μs (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (1,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 1}, 2}:
Out of place Julia:   41.914 μs (272 allocations: 66.28 KiB)
In place     Julia:   15.698 μs (53 allocations: 11.53 KiB)
Out of place GCC:     4.933 μs (0 allocations: 0 bytes)
Out of place Clang:   5.472 μs (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (2,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 2}, 2}:
Out of place Julia:   48.728 μs (272 allocations: 94.94 KiB)
In place     Julia:   17.986 μs (53 allocations: 16.23 KiB)
Out of place GCC:     8.146 μs (0 allocations: 0 bytes)
Out of place Clang:   7.882 μs (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (3,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 3}, 2}:
Out of place Julia:   65.062 μs (272 allocations: 115.41 KiB)
In place     Julia:   24.324 μs (53 allocations: 19.59 KiB)
Out of place GCC:     8.548 μs (0 allocations: 0 bytes)
Out of place Clang:   8.035 μs (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (4,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 4}, 2}:
Out of place Julia:   72.872 μs (272 allocations: 139.97 KiB)
In place     Julia:   27.933 μs (53 allocations: 23.62 KiB)
Out of place GCC:     15.908 μs (0 allocations: 0 bytes)
Out of place Clang:   13.534 μs (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (5,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 5}, 2}:
Out of place Julia:   82.747 μs (272 allocations: 172.72 KiB)
In place     Julia:   31.201 μs (53 allocations: 29.00 KiB)
Out of place GCC:     18.617 μs (0 allocations: 0 bytes)
Out of place Clang:   13.594 μs (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (6,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 6}, 2}:
Out of place Julia:   93.288 μs (272 allocations: 189.09 KiB)
In place     Julia:   37.393 μs (53 allocations: 31.69 KiB)
Out of place GCC:     21.873 μs (0 allocations: 0 bytes)
Out of place Clang:   15.859 μs (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (7,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 7}, 2}:
Out of place Julia:   103.871 μs (272 allocations: 230.03 KiB)
In place     Julia:   39.273 μs (53 allocations: 38.41 KiB)
Out of place GCC:     29.006 μs (0 allocations: 0 bytes)
Out of place Clang:   19.880 μs (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (8,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 8}, 2}:
Out of place Julia:   126.291 μs (272 allocations: 258.69 KiB)
In place     Julia:   51.698 μs (53 allocations: 43.11 KiB)
Out of place GCC:     61.404 μs (0 allocations: 0 bytes)
Out of place Clang:   19.328 μs (0 allocations: 0 bytes)
Size 3 x 3:
Size 3 x 3, duals (n,j) = (0,0), T = Float64:
Out of place Julia:   23.431 μs (272 allocations: 33.53 KiB)
In place     Julia:   7.319 μs (53 allocations: 6.16 KiB)
Out of place GCC:     4.265 μs (0 allocations: 0 bytes)
Out of place Clang:   4.100 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (1,0), T = ForwardDiff.Dual{Nothing, Float64, 1}:
Out of place Julia:   37.284 μs (272 allocations: 54.00 KiB)
In place     Julia:   14.399 μs (53 allocations: 9.52 KiB)
Out of place GCC:     6.209 μs (0 allocations: 0 bytes)
Out of place Clang:   5.295 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (2,0), T = ForwardDiff.Dual{Nothing, Float64, 2}:
Out of place Julia:   42.970 μs (272 allocations: 70.38 KiB)
In place     Julia:   17.265 μs (53 allocations: 12.20 KiB)
Out of place GCC:     6.854 μs (0 allocations: 0 bytes)
Out of place Clang:   6.107 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (3,0), T = ForwardDiff.Dual{Nothing, Float64, 3}:
Out of place Julia:   50.017 μs (272 allocations: 94.94 KiB)
In place     Julia:   18.989 μs (53 allocations: 16.23 KiB)
Out of place GCC:     9.593 μs (0 allocations: 0 bytes)
Out of place Clang:   9.499 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (4,0), T = ForwardDiff.Dual{Nothing, Float64, 4}:
Out of place Julia:   55.817 μs (272 allocations: 115.41 KiB)
In place     Julia:   23.079 μs (53 allocations: 19.59 KiB)
Out of place GCC:     8.669 μs (0 allocations: 0 bytes)
Out of place Clang:   11.788 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (5,0), T = ForwardDiff.Dual{Nothing, Float64, 5}:
Out of place Julia:   61.776 μs (272 allocations: 127.69 KiB)
In place     Julia:   25.772 μs (53 allocations: 21.61 KiB)
Out of place GCC:     9.499 μs (0 allocations: 0 bytes)
Out of place Clang:   11.934 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (6,0), T = ForwardDiff.Dual{Nothing, Float64, 6}:
Out of place Julia:   70.446 μs (272 allocations: 148.16 KiB)
In place     Julia:   29.596 μs (53 allocations: 24.97 KiB)
Out of place GCC:     11.042 μs (0 allocations: 0 bytes)
Out of place Clang:   14.693 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (7,0), T = ForwardDiff.Dual{Nothing, Float64, 7}:
Out of place Julia:   74.918 μs (272 allocations: 172.72 KiB)
In place     Julia:   30.525 μs (53 allocations: 29.00 KiB)
Out of place GCC:     17.710 μs (0 allocations: 0 bytes)
Out of place Clang:   15.100 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (8,0), T = ForwardDiff.Dual{Nothing, Float64, 8}:
Out of place Julia:   79.931 μs (272 allocations: 189.09 KiB)
In place     Julia:   29.685 μs (53 allocations: 31.69 KiB)
Out of place GCC:     14.935 μs (0 allocations: 0 bytes)
Out of place Clang:   14.911 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (1,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 1}, 1}:
Out of place Julia:   53.965 μs (272 allocations: 94.94 KiB)
In place     Julia:   23.076 μs (53 allocations: 16.23 KiB)
Out of place GCC:     12.269 μs (0 allocations: 0 bytes)
Out of place Clang:   10.499 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (2,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 2}, 1}:
Out of place Julia:   66.080 μs (272 allocations: 127.69 KiB)
In place     Julia:   29.380 μs (53 allocations: 21.61 KiB)
Out of place GCC:     13.099 μs (0 allocations: 0 bytes)
Out of place Clang:   13.666 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (3,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 3}, 1}:
Out of place Julia:   85.519 μs (272 allocations: 172.72 KiB)
In place     Julia:   37.884 μs (53 allocations: 29.00 KiB)
Out of place GCC:     19.367 μs (0 allocations: 0 bytes)
Out of place Clang:   18.518 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (4,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 4}, 1}:
Out of place Julia:   96.131 μs (272 allocations: 209.56 KiB)
In place     Julia:   44.340 μs (53 allocations: 35.05 KiB)
Out of place GCC:     23.842 μs (0 allocations: 0 bytes)
Out of place Clang:   25.903 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (5,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 5}, 1}:
Out of place Julia:   150.882 μs (272 allocations: 258.69 KiB)
In place     Julia:   74.911 μs (53 allocations: 43.11 KiB)
Out of place GCC:     23.660 μs (0 allocations: 0 bytes)
Out of place Clang:   26.014 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (6,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 6}, 1}:
Out of place Julia:   162.961 μs (272 allocations: 279.16 KiB)
In place     Julia:   79.227 μs (53 allocations: 46.47 KiB)
Out of place GCC:     27.226 μs (0 allocations: 0 bytes)
Out of place Clang:   32.182 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (7,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 7}, 1}:
Out of place Julia:   177.000 μs (272 allocations: 320.09 KiB)
In place     Julia:   84.768 μs (53 allocations: 53.19 KiB)
Out of place GCC:     41.977 μs (0 allocations: 0 bytes)
Out of place Clang:   21.179 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (8,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 8}, 1}:
Out of place Julia:   196.001 μs (272 allocations: 348.75 KiB)
In place     Julia:   84.701 μs (53 allocations: 57.89 KiB)
Out of place GCC:     48.373 μs (0 allocations: 0 bytes)
Out of place Clang:   28.673 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (1,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 1}, 2}:
Out of place Julia:   69.965 μs (272 allocations: 127.69 KiB)
In place     Julia:   31.590 μs (53 allocations: 21.61 KiB)
Out of place GCC:     14.716 μs (0 allocations: 0 bytes)
Out of place Clang:   15.598 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (2,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 2}, 2}:
Out of place Julia:   94.681 μs (272 allocations: 189.09 KiB)
In place     Julia:   46.721 μs (53 allocations: 31.69 KiB)
Out of place GCC:     23.046 μs (0 allocations: 0 bytes)
Out of place Clang:   23.082 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (3,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 3}, 2}:
Out of place Julia:   139.954 μs (272 allocations: 258.69 KiB)
In place     Julia:   63.453 μs (53 allocations: 43.11 KiB)
Out of place GCC:     29.065 μs (0 allocations: 0 bytes)
Out of place Clang:   29.262 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (4,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 4}, 2}:
Out of place Julia:   153.935 μs (272 allocations: 299.62 KiB)
In place     Julia:   70.602 μs (53 allocations: 49.83 KiB)
Out of place GCC:     37.846 μs (0 allocations: 0 bytes)
Out of place Clang:   34.803 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (5,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 5}, 2}:
Out of place Julia:   178.102 μs (272 allocations: 348.75 KiB)
In place     Julia:   84.106 μs (53 allocations: 57.89 KiB)
Out of place GCC:     55.390 μs (0 allocations: 0 bytes)
Out of place Clang:   38.682 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (6,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 6}, 2}:
Out of place Julia:   207.868 μs (272 allocations: 418.34 KiB)
In place     Julia:   102.888 μs (53 allocations: 69.31 KiB)
Out of place GCC:     58.257 μs (0 allocations: 0 bytes)
Out of place Clang:   47.319 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (7,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 7}, 2}:
Out of place Julia:   226.804 μs (272 allocations: 463.38 KiB)
In place     Julia:   103.788 μs (53 allocations: 76.70 KiB)
Out of place GCC:     77.990 μs (0 allocations: 0 bytes)
Out of place Clang:   56.749 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (8,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 8}, 2}:
Out of place Julia:   290.543 μs (272 allocations: 520.69 KiB)
In place     Julia:   144.604 μs (53 allocations: 86.11 KiB)
Out of place GCC:     195.017 μs (0 allocations: 0 bytes)
Out of place Clang:   62.831 μs (0 allocations: 0 bytes)
Size 4 x 4:
Size 4 x 4, duals (n,j) = (0,0), T = Float64:
Out of place Julia:   44.517 μs (272 allocations: 50.06 KiB)
In place     Julia:   22.108 μs (53 allocations: 9.00 KiB)
Out of place GCC:     7.168 μs (0 allocations: 0 bytes)
Out of place Clang:   7.541 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (1,0), T = ForwardDiff.Dual{Nothing, Float64, 1}:
Out of place Julia:   130.776 μs (479 allocations: 1.43 MiB)
In place     Julia:   91.067 μs (224 allocations: 1.12 MiB)
Out of place GCC:     10.655 μs (0 allocations: 0 bytes)
Out of place Clang:   10.809 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (2,0), T = ForwardDiff.Dual{Nothing, Float64, 2}:
Out of place Julia:   145.735 μs (479 allocations: 1.53 MiB)
In place     Julia:   99.605 μs (224 allocations: 1.19 MiB)
Out of place GCC:     18.251 μs (0 allocations: 0 bytes)
Out of place Clang:   15.139 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (3,0), T = ForwardDiff.Dual{Nothing, Float64, 3}:
Out of place Julia:   158.298 μs (479 allocations: 1.53 MiB)
In place     Julia:   102.161 μs (224 allocations: 1.17 MiB)
Out of place GCC:     20.776 μs (0 allocations: 0 bytes)
Out of place Clang:   24.083 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (4,0), T = ForwardDiff.Dual{Nothing, Float64, 4}:
Out of place Julia:   177.094 μs (479 allocations: 1.55 MiB)
In place     Julia:   112.964 μs (224 allocations: 1.16 MiB)
Out of place GCC:     17.640 μs (0 allocations: 0 bytes)
Out of place Clang:   26.042 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (5,0), T = ForwardDiff.Dual{Nothing, Float64, 5}:
Out of place Julia:   189.116 μs (479 allocations: 1.67 MiB)
In place     Julia:   115.788 μs (224 allocations: 1.23 MiB)
Out of place GCC:     19.235 μs (0 allocations: 0 bytes)
Out of place Clang:   27.701 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (6,0), T = ForwardDiff.Dual{Nothing, Float64, 6}:
Out of place Julia:   203.715 μs (479 allocations: 1.52 MiB)
In place     Julia:   123.449 μs (224 allocations: 1.09 MiB)
Out of place GCC:     23.088 μs (0 allocations: 0 bytes)
Out of place Clang:   31.891 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (7,0), T = ForwardDiff.Dual{Nothing, Float64, 7}:
Out of place Julia:   195.287 μs (479 allocations: 1.50 MiB)
In place     Julia:   114.335 μs (224 allocations: 1.06 MiB)
Out of place GCC:     36.141 μs (0 allocations: 0 bytes)
Out of place Clang:   36.109 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (8,0), T = ForwardDiff.Dual{Nothing, Float64, 8}:
Out of place Julia:   230.574 μs (479 allocations: 1.70 MiB)
In place     Julia:   127.388 μs (224 allocations: 1.19 MiB)
Out of place GCC:     27.015 μs (0 allocations: 0 bytes)
Out of place Clang:   40.694 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (1,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 1}, 1}:
Out of place Julia:   167.128 μs (479 allocations: 1.53 MiB)
In place     Julia:   100.847 μs (224 allocations: 1.17 MiB)
Out of place GCC:     21.485 μs (0 allocations: 0 bytes)
Out of place Clang:   23.464 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (2,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 2}, 1}:
Out of place Julia:   195.909 μs (479 allocations: 1.67 MiB)
In place     Julia:   121.300 μs (224 allocations: 1.23 MiB)
Out of place GCC:     30.639 μs (0 allocations: 0 bytes)
Out of place Clang:   32.972 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (3,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 3}, 1}:
Out of place Julia:   214.618 μs (479 allocations: 1.50 MiB)
In place     Julia:   131.621 μs (224 allocations: 1.06 MiB)
Out of place GCC:     44.432 μs (0 allocations: 0 bytes)
Out of place Clang:   44.778 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (4,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 4}, 1}:
Out of place Julia:   263.541 μs (479 allocations: 1.64 MiB)
In place     Julia:   164.500 μs (224 allocations: 1.13 MiB)
Out of place GCC:     46.191 μs (0 allocations: 0 bytes)
Out of place Clang:   59.119 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (5,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 5}, 1}:
Out of place Julia:   426.249 μs (479 allocations: 1.69 MiB)
In place     Julia:   269.380 μs (224 allocations: 1.13 MiB)
Out of place GCC:     53.141 μs (0 allocations: 0 bytes)
Out of place Clang:   57.099 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (6,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 6}, 1}:
Out of place Julia:   492.408 μs (479 allocations: 1.72 MiB)
In place     Julia:   300.012 μs (224 allocations: 1.09 MiB)
Out of place GCC:     55.560 μs (0 allocations: 0 bytes)
Out of place Clang:   68.077 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (7,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 7}, 1}:
Out of place Julia:   496.385 μs (479 allocations: 1.93 MiB)
In place     Julia:   276.871 μs (224 allocations: 1.23 MiB)
Out of place GCC:     90.790 μs (0 allocations: 0 bytes)
Out of place Clang:   45.003 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (8,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 8}, 1}:
Out of place Julia:   562.418 μs (479 allocations: 1.84 MiB)
In place     Julia:   304.150 μs (224 allocations: 1.12 MiB)
Out of place GCC:     100.190 μs (0 allocations: 0 bytes)
Out of place Clang:   67.441 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (1,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 1}, 2}:
Out of place Julia:   216.007 μs (479 allocations: 1.67 MiB)
In place     Julia:   139.226 μs (224 allocations: 1.23 MiB)
Out of place GCC:     24.484 μs (0 allocations: 0 bytes)
Out of place Clang:   35.757 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (2,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 2}, 2}:
Out of place Julia:   267.870 μs (479 allocations: 1.70 MiB)
In place     Julia:   173.569 μs (224 allocations: 1.19 MiB)
Out of place GCC:     43.860 μs (0 allocations: 0 bytes)
Out of place Clang:   57.305 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (3,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 3}, 2}:
Out of place Julia:   418.087 μs (479 allocations: 1.69 MiB)
In place     Julia:   262.164 μs (224 allocations: 1.13 MiB)
Out of place GCC:     68.304 μs (0 allocations: 0 bytes)
Out of place Clang:   56.760 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (4,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 4}, 2}:
Out of place Julia:   457.813 μs (479 allocations: 1.81 MiB)
In place     Julia:   287.930 μs (224 allocations: 1.16 MiB)
Out of place GCC:     87.042 μs (0 allocations: 0 bytes)
Out of place Clang:   85.742 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (5,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 5}, 2}:
Out of place Julia:   500.143 μs (479 allocations: 1.84 MiB)
In place     Julia:   305.687 μs (224 allocations: 1.12 MiB)
Out of place GCC:     114.274 μs (0 allocations: 0 bytes)
Out of place Clang:   82.852 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (6,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 6}, 2}:
Out of place Julia:   574.673 μs (479 allocations: 2.14 MiB)
In place     Julia:   355.753 μs (224 allocations: 1.30 MiB)
Out of place GCC:     115.145 μs (0 allocations: 0 bytes)
Out of place Clang:   100.024 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (7,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 7}, 2}:
Out of place Julia:   575.125 μs (479 allocations: 2.06 MiB)
In place     Julia:   364.755 μs (224 allocations: 1.17 MiB)
Out of place GCC:     196.924 μs (0 allocations: 0 bytes)
Out of place Clang:   119.405 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (8,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 8}, 2}:
Out of place Julia:   729.714 μs (479 allocations: 2.31 MiB)
In place     Julia:   473.067 μs (224 allocations: 1.32 MiB)
Out of place GCC:     472.428 μs (0 allocations: 0 bytes)
Out of place Clang:   141.152 μs (0 allocations: 0 bytes)
Size 5 x 5:
Size 5 x 5, duals (n,j) = (0,0), T = Float64:
Out of place Julia:   62.838 μs (272 allocations: 66.44 KiB)
In place     Julia:   38.433 μs (53 allocations: 11.69 KiB)
Out of place GCC:     12.320 μs (0 allocations: 0 bytes)
Out of place Clang:   13.511 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (1,0), T = ForwardDiff.Dual{Nothing, Float64, 1}:
Out of place Julia:   157.557 μs (479 allocations: 1.47 MiB)
In place     Julia:   109.862 μs (224 allocations: 1.13 MiB)
Out of place GCC:     20.702 μs (0 allocations: 0 bytes)
Out of place Clang:   25.014 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (2,0), T = ForwardDiff.Dual{Nothing, Float64, 2}:
Out of place Julia:   188.383 μs (479 allocations: 1.58 MiB)
In place     Julia:   125.552 μs (224 allocations: 1.20 MiB)
Out of place GCC:     28.993 μs (0 allocations: 0 bytes)
Out of place Clang:   25.547 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (3,0), T = ForwardDiff.Dual{Nothing, Float64, 3}:
Out of place Julia:   204.344 μs (479 allocations: 1.61 MiB)
In place     Julia:   127.461 μs (224 allocations: 1.18 MiB)
Out of place GCC:     32.139 μs (0 allocations: 0 bytes)
Out of place Clang:   39.066 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (4,0), T = ForwardDiff.Dual{Nothing, Float64, 4}:
Out of place Julia:   240.552 μs (479 allocations: 1.64 MiB)
In place     Julia:   149.368 μs (224 allocations: 1.17 MiB)
Out of place GCC:     30.285 μs (0 allocations: 0 bytes)
Out of place Clang:   50.276 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (5,0), T = ForwardDiff.Dual{Nothing, Float64, 5}:
Out of place Julia:   264.157 μs (479 allocations: 1.78 MiB)
In place     Julia:   152.845 μs (224 allocations: 1.25 MiB)
Out of place GCC:     36.630 μs (0 allocations: 0 bytes)
Out of place Clang:   48.490 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (6,0), T = ForwardDiff.Dual{Nothing, Float64, 6}:
Out of place Julia:   268.342 μs (479 allocations: 1.64 MiB)
In place     Julia:   163.364 μs (224 allocations: 1.11 MiB)
Out of place GCC:     41.332 μs (0 allocations: 0 bytes)
Out of place Clang:   57.197 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (7,0), T = ForwardDiff.Dual{Nothing, Float64, 7}:
Out of place Julia:   275.032 μs (479 allocations: 1.68 MiB)
In place     Julia:   152.345 μs (224 allocations: 1.09 MiB)
Out of place GCC:     65.770 μs (0 allocations: 0 bytes)
Out of place Clang:   80.980 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (8,0), T = ForwardDiff.Dual{Nothing, Float64, 8}:
Out of place Julia:   336.296 μs (479 allocations: 1.89 MiB)
In place     Julia:   181.340 μs (224 allocations: 1.23 MiB)
Out of place GCC:     55.113 μs (0 allocations: 0 bytes)
Out of place Clang:   77.409 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (1,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 1}, 1}:
Out of place Julia:   223.943 μs (479 allocations: 1.61 MiB)
In place     Julia:   127.834 μs (224 allocations: 1.18 MiB)
Out of place GCC:     46.111 μs (0 allocations: 0 bytes)
Out of place Clang:   52.998 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (2,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 2}, 1}:
Out of place Julia:   263.293 μs (479 allocations: 1.78 MiB)
In place     Julia:   162.111 μs (224 allocations: 1.25 MiB)
Out of place GCC:     52.806 μs (0 allocations: 0 bytes)
Out of place Clang:   57.464 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (3,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 3}, 1}:
Out of place Julia:   313.319 μs (479 allocations: 1.68 MiB)
In place     Julia:   188.362 μs (224 allocations: 1.09 MiB)
Out of place GCC:     81.623 μs (0 allocations: 0 bytes)
Out of place Clang:   89.346 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (4,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 4}, 1}:
Out of place Julia:   406.604 μs (479 allocations: 1.83 MiB)
In place     Julia:   243.644 μs (224 allocations: 1.16 MiB)
Out of place GCC:     90.074 μs (0 allocations: 0 bytes)
Out of place Clang:   109.649 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (5,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 5}, 1}:
Out of place Julia:   691.141 μs (479 allocations: 1.92 MiB)
In place     Julia:   447.837 μs (224 allocations: 1.16 MiB)
Out of place GCC:     94.915 μs (0 allocations: 0 bytes)
Out of place Clang:   108.170 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (6,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 6}, 1}:
Out of place Julia:   751.144 μs (479 allocations: 1.95 MiB)
In place     Julia:   495.766 μs (224 allocations: 1.12 MiB)
Out of place GCC:     124.171 μs (0 allocations: 0 bytes)
Out of place Clang:   147.120 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (7,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 7}, 1}:
Out of place Julia:   759.689 μs (479 allocations: 2.21 MiB)
In place     Julia:   461.360 μs (224 allocations: 1.28 MiB)
Out of place GCC:     191.505 μs (0 allocations: 0 bytes)
Out of place Clang:   90.545 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (8,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 8}, 1}:
Out of place Julia:   855.500 μs (479 allocations: 2.18 MiB)
In place     Julia:   499.251 μs (224 allocations: 1.17 MiB)
Out of place GCC:     188.842 μs (0 allocations: 0 bytes)
Out of place Clang:   132.906 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (1,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 1}, 2}:
Out of place Julia:   303.527 μs (479 allocations: 1.78 MiB)
In place     Julia:   193.204 μs (224 allocations: 1.25 MiB)
Out of place GCC:     57.690 μs (0 allocations: 0 bytes)
Out of place Clang:   70.246 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (2,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 2}, 2}:
Out of place Julia:   406.333 μs (479 allocations: 1.89 MiB)
In place     Julia:   259.625 μs (224 allocations: 1.23 MiB)
Out of place GCC:     91.482 μs (0 allocations: 0 bytes)
Out of place Clang:   103.511 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (3,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 3}, 2}:
Out of place Julia:   680.101 μs (479 allocations: 1.92 MiB)
In place     Julia:   437.101 μs (224 allocations: 1.16 MiB)
Out of place GCC:     117.702 μs (0 allocations: 0 bytes)
Out of place Clang:   129.169 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (4,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 4}, 2}:
Out of place Julia:   697.647 μs (479 allocations: 2.08 MiB)
In place     Julia:   471.602 μs (224 allocations: 1.20 MiB)
Out of place GCC:     150.479 μs (0 allocations: 0 bytes)
Out of place Clang:   158.316 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (5,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 5}, 2}:
Out of place Julia:   751.198 μs (479 allocations: 2.18 MiB)
In place     Julia:   494.614 μs (224 allocations: 1.17 MiB)
Out of place GCC:     218.887 μs (0 allocations: 0 bytes)
Out of place Clang:   176.941 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (6,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 6}, 2}:
Out of place Julia:   829.906 μs (479 allocations: 2.52 MiB)
In place     Julia:   568.025 μs (224 allocations: 1.36 MiB)
Out of place GCC:     219.567 μs (0 allocations: 0 bytes)
Out of place Clang:   191.433 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (7,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 7}, 2}:
Out of place Julia:   845.503 μs (479 allocations: 2.49 MiB)
In place     Julia:   589.463 μs (224 allocations: 1.24 MiB)
Out of place GCC:     352.881 μs (0 allocations: 0 bytes)
Out of place Clang:   247.349 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (8,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 8}, 2}:
Out of place Julia:   1.144 ms (479 allocations: 2.81 MiB)
In place     Julia:   849.239 μs (224 allocations: 1.40 MiB)
Out of place GCC:     839.055 μs (0 allocations: 0 bytes)
Out of place Clang:   264.537 μs (0 allocations: 0 bytes)
Total compile times: 
Out of place Julia: 71.719 s
In place     Julia: 77.512 s
Out of place GCC:   87.314 ms
Out of place Clang: 80.804 ms
```
Especially when the array sizes are smaller (dimensions and dual sizes), the C++ implementions perform much better than Julia.
Clang -- which is powered by LLVM like Julia -- continues to outperform it into the larger sizes we care about/benchmark here. This is despite the much more naive C++ implementation.
In terms of compile times, building with GCC and Clang took about 30s and 20s, respectively. So their overall compile times were much smaller.
