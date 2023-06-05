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
Out of place Julia:   22.647 μs (262 allocations: 16.38 KiB)
In place     Julia:   9.582 μs (53 allocations: 3.31 KiB)
Out of place GCC:     1.142 μs (0 allocations: 0 bytes)
Out of place Clang:   1.269 μs (0 allocations: 0 bytes)
Size 1 x 1, duals (n,j) = (1,0), T = ForwardDiff.Dual{Nothing, Float64, 1}:
Out of place Julia:   90.686 μs (469 allocations: 1.36 MiB)
In place     Julia:   60.226 μs (224 allocations: 1.11 MiB)
Out of place GCC:     1.325 μs (0 allocations: 0 bytes)
Out of place Clang:   1.586 μs (0 allocations: 0 bytes)
Size 1 x 1, duals (n,j) = (2,0), T = ForwardDiff.Dual{Nothing, Float64, 2}:
Out of place Julia:   106.746 μs (469 allocations: 1.44 MiB)
In place     Julia:   72.019 μs (224 allocations: 1.17 MiB)
Out of place GCC:     1.293 μs (0 allocations: 0 bytes)
Out of place Clang:   1.630 μs (0 allocations: 0 bytes)
Size 1 x 1, duals (n,j) = (3,0), T = ForwardDiff.Dual{Nothing, Float64, 3}:
Out of place Julia:   102.745 μs (469 allocations: 1.41 MiB)
In place     Julia:   57.832 μs (224 allocations: 1.15 MiB)
Out of place GCC:     1.457 μs (0 allocations: 0 bytes)
Out of place Clang:   1.869 μs (0 allocations: 0 bytes)
Size 1 x 1, duals (n,j) = (4,0), T = ForwardDiff.Dual{Nothing, Float64, 4}:
Out of place Julia:   84.058 μs (469 allocations: 1.39 MiB)
In place     Julia:   56.555 μs (224 allocations: 1.13 MiB)
Out of place GCC:     1.015 μs (0 allocations: 0 bytes)
Out of place Clang:   1.874 μs (0 allocations: 0 bytes)
Size 1 x 1, duals (n,j) = (5,0), T = ForwardDiff.Dual{Nothing, Float64, 5}:
Out of place Julia:   92.953 μs (469 allocations: 1.47 MiB)
In place     Julia:   60.927 μs (224 allocations: 1.20 MiB)
Out of place GCC:     1.143 μs (0 allocations: 0 bytes)
Out of place Clang:   2.177 μs (0 allocations: 0 bytes)
Size 1 x 1, duals (n,j) = (6,0), T = ForwardDiff.Dual{Nothing, Float64, 6}:
Out of place Julia:   81.438 μs (469 allocations: 1.29 MiB)
In place     Julia:   55.721 μs (224 allocations: 1.05 MiB)
Out of place GCC:     1.174 μs (0 allocations: 0 bytes)
Out of place Clang:   2.110 μs (0 allocations: 0 bytes)
Size 1 x 1, duals (n,j) = (7,0), T = ForwardDiff.Dual{Nothing, Float64, 7}:
Out of place Julia:   86.279 μs (469 allocations: 1.26 MiB)
In place     Julia:   57.111 μs (224 allocations: 1.02 MiB)
Out of place GCC:     1.697 μs (0 allocations: 0 bytes)
Out of place Clang:   2.328 μs (0 allocations: 0 bytes)
Size 1 x 1, duals (n,j) = (8,0), T = ForwardDiff.Dual{Nothing, Float64, 8}:
Out of place Julia:   98.463 μs (469 allocations: 1.41 MiB)
In place     Julia:   71.961 μs (224 allocations: 1.15 MiB)
Out of place GCC:     1.603 μs (0 allocations: 0 bytes)
Out of place Clang:   2.006 μs (0 allocations: 0 bytes)
Size 1 x 1, duals (n,j) = (1,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 1}, 1}:
Out of place Julia:   108.531 μs (469 allocations: 1.41 MiB)
In place     Julia:   61.255 μs (224 allocations: 1.15 MiB)
Out of place GCC:     1.648 μs (0 allocations: 0 bytes)
Out of place Clang:   1.736 μs (0 allocations: 0 bytes)
Size 1 x 1, duals (n,j) = (2,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 2}, 1}:
Out of place Julia:   91.176 μs (469 allocations: 1.47 MiB)
In place     Julia:   64.124 μs (224 allocations: 1.20 MiB)
Out of place GCC:     1.679 μs (0 allocations: 0 bytes)
Out of place Clang:   2.273 μs (0 allocations: 0 bytes)
Size 1 x 1, duals (n,j) = (3,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 3}, 1}:
Out of place Julia:   144.933 μs (469 allocations: 1.26 MiB)
In place     Julia:   64.393 μs (224 allocations: 1.02 MiB)
Out of place GCC:     2.071 μs (0 allocations: 0 bytes)
Out of place Clang:   2.427 μs (0 allocations: 0 bytes)
Size 1 x 1, duals (n,j) = (4,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 4}, 1}:
Out of place Julia:   109.964 μs (469 allocations: 1.33 MiB)
In place     Julia:   68.128 μs (224 allocations: 1.08 MiB)
Out of place GCC:     2.344 μs (0 allocations: 0 bytes)
Out of place Clang:   2.323 μs (0 allocations: 0 bytes)
Size 1 x 1, duals (n,j) = (5,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 5}, 1}:
Out of place Julia:   90.986 μs (469 allocations: 1.32 MiB)
In place     Julia:   66.818 μs (224 allocations: 1.07 MiB)
Out of place GCC:     2.909 μs (0 allocations: 0 bytes)
Out of place Clang:   2.595 μs (0 allocations: 0 bytes)
Size 1 x 1, duals (n,j) = (6,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 6}, 1}:
Out of place Julia:   96.864 μs (469 allocations: 1.26 MiB)
In place     Julia:   70.791 μs (224 allocations: 1.01 MiB)
Out of place GCC:     2.749 μs (0 allocations: 0 bytes)
Out of place Clang:   2.823 μs (0 allocations: 0 bytes)
Size 1 x 1, duals (n,j) = (7,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 7}, 1}:
Out of place Julia:   112.796 μs (469 allocations: 1.43 MiB)
In place     Julia:   81.433 μs (224 allocations: 1.15 MiB)
Out of place GCC:     3.242 μs (0 allocations: 0 bytes)
Out of place Clang:   2.346 μs (0 allocations: 0 bytes)
Size 1 x 1, duals (n,j) = (8,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 8}, 1}:
Out of place Julia:   109.000 μs (469 allocations: 1.28 MiB)
In place     Julia:   71.313 μs (224 allocations: 1.03 MiB)
Out of place GCC:     3.807 μs (0 allocations: 0 bytes)
Out of place Clang:   2.575 μs (0 allocations: 0 bytes)
Size 1 x 1, duals (n,j) = (1,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 1}, 2}:
Out of place Julia:   110.754 μs (469 allocations: 1.47 MiB)
In place     Julia:   67.302 μs (224 allocations: 1.20 MiB)
Out of place GCC:     1.627 μs (0 allocations: 0 bytes)
Out of place Clang:   2.363 μs (0 allocations: 0 bytes)
Size 1 x 1, duals (n,j) = (2,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 2}, 2}:
Out of place Julia:   91.944 μs (469 allocations: 1.41 MiB)
In place     Julia:   65.991 μs (224 allocations: 1.15 MiB)
Out of place GCC:     2.126 μs (0 allocations: 0 bytes)
Out of place Clang:   2.283 μs (0 allocations: 0 bytes)
Size 1 x 1, duals (n,j) = (3,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 3}, 2}:
Out of place Julia:   100.638 μs (469 allocations: 1.32 MiB)
In place     Julia:   67.968 μs (224 allocations: 1.07 MiB)
Out of place GCC:     3.099 μs (0 allocations: 0 bytes)
Out of place Clang:   2.694 μs (0 allocations: 0 bytes)
Size 1 x 1, duals (n,j) = (4,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 4}, 2}:
Out of place Julia:   100.224 μs (469 allocations: 1.34 MiB)
In place     Julia:   68.576 μs (224 allocations: 1.08 MiB)
Out of place GCC:     3.822 μs (0 allocations: 0 bytes)
Out of place Clang:   2.718 μs (0 allocations: 0 bytes)
Size 1 x 1, duals (n,j) = (5,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 5}, 2}:
Out of place Julia:   109.608 μs (469 allocations: 1.28 MiB)
In place     Julia:   70.428 μs (224 allocations: 1.03 MiB)
Out of place GCC:     4.190 μs (0 allocations: 0 bytes)
Out of place Clang:   2.870 μs (0 allocations: 0 bytes)
Size 1 x 1, duals (n,j) = (6,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 6}, 2}:
Out of place Julia:   104.355 μs (469 allocations: 1.49 MiB)
In place     Julia:   78.097 μs (224 allocations: 1.19 MiB)
Out of place GCC:     3.978 μs (0 allocations: 0 bytes)
Out of place Clang:   3.550 μs (0 allocations: 0 bytes)
Size 1 x 1, duals (n,j) = (7,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 7}, 2}:
Out of place Julia:   104.307 μs (469 allocations: 1.32 MiB)
In place     Julia:   75.046 μs (224 allocations: 1.05 MiB)
Out of place GCC:     5.009 μs (0 allocations: 0 bytes)
Out of place Clang:   3.637 μs (0 allocations: 0 bytes)
Size 1 x 1, duals (n,j) = (8,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 8}, 2}:
Out of place Julia:   102.283 μs (469 allocations: 1.48 MiB)
In place     Julia:   75.090 μs (224 allocations: 1.18 MiB)
Out of place GCC:     10.349 μs (0 allocations: 0 bytes)
Out of place Clang:   4.357 μs (0 allocations: 0 bytes)
Size 2 x 2:
Size 2 x 2, duals (n,j) = (0,0), T = Float64:
Out of place Julia:   19.451 μs (272 allocations: 25.34 KiB)
In place     Julia:   5.782 μs (53 allocations: 4.81 KiB)
Out of place GCC:     2.285 μs (0 allocations: 0 bytes)
Out of place Clang:   2.513 μs (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (1,0), T = ForwardDiff.Dual{Nothing, Float64, 1}:
Out of place Julia:   19.717 μs (272 allocations: 33.53 KiB)
In place     Julia:   7.062 μs (53 allocations: 6.16 KiB)
Out of place GCC:     2.998 μs (0 allocations: 0 bytes)
Out of place Clang:   3.153 μs (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (2,0), T = ForwardDiff.Dual{Nothing, Float64, 2}:
Out of place Julia:   25.595 μs (272 allocations: 41.72 KiB)
In place     Julia:   8.555 μs (53 allocations: 7.50 KiB)
Out of place GCC:     3.276 μs (0 allocations: 0 bytes)
Out of place Clang:   3.709 μs (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (3,0), T = ForwardDiff.Dual{Nothing, Float64, 3}:
Out of place Julia:   28.184 μs (272 allocations: 49.91 KiB)
In place     Julia:   10.743 μs (53 allocations: 8.84 KiB)
Out of place GCC:     3.755 μs (0 allocations: 0 bytes)
Out of place Clang:   4.517 μs (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (4,0), T = ForwardDiff.Dual{Nothing, Float64, 4}:
Out of place Julia:   31.985 μs (272 allocations: 58.09 KiB)
In place     Julia:   11.910 μs (53 allocations: 10.19 KiB)
Out of place GCC:     3.473 μs (0 allocations: 0 bytes)
Out of place Clang:   4.803 μs (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (5,0), T = ForwardDiff.Dual{Nothing, Float64, 5}:
Out of place Julia:   39.083 μs (272 allocations: 66.28 KiB)
In place     Julia:   13.490 μs (53 allocations: 11.53 KiB)
Out of place GCC:     4.219 μs (0 allocations: 0 bytes)
Out of place Clang:   5.358 μs (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (6,0), T = ForwardDiff.Dual{Nothing, Float64, 6}:
Out of place Julia:   40.270 μs (272 allocations: 74.47 KiB)
In place     Julia:   13.915 μs (53 allocations: 12.88 KiB)
Out of place GCC:     4.174 μs (0 allocations: 0 bytes)
Out of place Clang:   5.357 μs (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (7,0), T = ForwardDiff.Dual{Nothing, Float64, 7}:
Out of place Julia:   42.625 μs (272 allocations: 86.75 KiB)
In place     Julia:   14.783 μs (53 allocations: 14.89 KiB)
Out of place GCC:     6.901 μs (0 allocations: 0 bytes)
Out of place Clang:   5.944 μs (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (8,0), T = ForwardDiff.Dual{Nothing, Float64, 8}:
Out of place Julia:   41.971 μs (272 allocations: 94.94 KiB)
In place     Julia:   14.559 μs (53 allocations: 16.23 KiB)
Out of place GCC:     5.677 μs (0 allocations: 0 bytes)
Out of place Clang:   5.857 μs (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (1,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 1}, 1}:
Out of place Julia:   34.002 μs (272 allocations: 49.91 KiB)
In place     Julia:   12.391 μs (53 allocations: 8.84 KiB)
Out of place GCC:     4.576 μs (0 allocations: 0 bytes)
Out of place Clang:   4.885 μs (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (2,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 2}, 1}:
Out of place Julia:   40.407 μs (272 allocations: 66.28 KiB)
In place     Julia:   14.622 μs (53 allocations: 11.53 KiB)
Out of place GCC:     5.909 μs (0 allocations: 0 bytes)
Out of place Clang:   6.343 μs (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (3,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 3}, 1}:
Out of place Julia:   46.463 μs (272 allocations: 86.75 KiB)
In place     Julia:   16.408 μs (53 allocations: 14.89 KiB)
Out of place GCC:     6.931 μs (0 allocations: 0 bytes)
Out of place Clang:   6.722 μs (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (4,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 4}, 1}:
Out of place Julia:   53.837 μs (272 allocations: 103.12 KiB)
In place     Julia:   20.104 μs (53 allocations: 17.58 KiB)
Out of place GCC:     9.647 μs (0 allocations: 0 bytes)
Out of place Clang:   11.219 μs (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (5,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 5}, 1}:
Out of place Julia:   63.948 μs (272 allocations: 115.41 KiB)
In place     Julia:   29.323 μs (53 allocations: 19.59 KiB)
Out of place GCC:     10.625 μs (0 allocations: 0 bytes)
Out of place Clang:   8.988 μs (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (6,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 6}, 1}:
Out of place Julia:   77.862 μs (272 allocations: 139.97 KiB)
In place     Julia:   30.295 μs (53 allocations: 23.62 KiB)
Out of place GCC:     9.746 μs (0 allocations: 0 bytes)
Out of place Clang:   11.930 μs (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (7,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 7}, 1}:
Out of place Julia:   78.620 μs (272 allocations: 148.16 KiB)
In place     Julia:   30.751 μs (53 allocations: 24.97 KiB)
Out of place GCC:     14.859 μs (0 allocations: 0 bytes)
Out of place Clang:   8.837 μs (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (8,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 8}, 1}:
Out of place Julia:   88.920 μs (272 allocations: 172.72 KiB)
In place     Julia:   33.860 μs (53 allocations: 29.00 KiB)
Out of place GCC:     19.012 μs (0 allocations: 0 bytes)
Out of place Clang:   9.654 μs (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (1,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 1}, 2}:
Out of place Julia:   42.943 μs (272 allocations: 66.28 KiB)
In place     Julia:   16.306 μs (53 allocations: 11.53 KiB)
Out of place GCC:     5.059 μs (0 allocations: 0 bytes)
Out of place Clang:   7.206 μs (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (2,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 2}, 2}:
Out of place Julia:   49.229 μs (272 allocations: 94.94 KiB)
In place     Julia:   19.856 μs (53 allocations: 16.23 KiB)
Out of place GCC:     8.642 μs (0 allocations: 0 bytes)
Out of place Clang:   8.218 μs (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (3,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 3}, 2}:
Out of place Julia:   66.032 μs (272 allocations: 115.41 KiB)
In place     Julia:   24.988 μs (53 allocations: 19.59 KiB)
Out of place GCC:     11.060 μs (0 allocations: 0 bytes)
Out of place Clang:   10.194 μs (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (4,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 4}, 2}:
Out of place Julia:   74.395 μs (272 allocations: 139.97 KiB)
In place     Julia:   28.277 μs (53 allocations: 23.62 KiB)
Out of place GCC:     15.281 μs (0 allocations: 0 bytes)
Out of place Clang:   13.637 μs (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (5,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 5}, 2}:
Out of place Julia:   84.036 μs (272 allocations: 172.72 KiB)
In place     Julia:   31.199 μs (53 allocations: 29.00 KiB)
Out of place GCC:     17.984 μs (0 allocations: 0 bytes)
Out of place Clang:   15.106 μs (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (6,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 6}, 2}:
Out of place Julia:   95.299 μs (272 allocations: 189.09 KiB)
In place     Julia:   37.348 μs (53 allocations: 31.69 KiB)
Out of place GCC:     19.461 μs (0 allocations: 0 bytes)
Out of place Clang:   14.419 μs (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (7,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 7}, 2}:
Out of place Julia:   102.962 μs (272 allocations: 230.03 KiB)
In place     Julia:   39.093 μs (53 allocations: 38.41 KiB)
Out of place GCC:     29.426 μs (0 allocations: 0 bytes)
Out of place Clang:   19.785 μs (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (8,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 8}, 2}:
Out of place Julia:   129.646 μs (272 allocations: 258.69 KiB)
In place     Julia:   53.420 μs (53 allocations: 43.11 KiB)
Out of place GCC:     63.585 μs (0 allocations: 0 bytes)
Out of place Clang:   22.367 μs (0 allocations: 0 bytes)
Size 3 x 3:
Size 3 x 3, duals (n,j) = (0,0), T = Float64:
Out of place Julia:   20.265 μs (272 allocations: 33.53 KiB)
In place     Julia:   6.918 μs (53 allocations: 6.16 KiB)
Out of place GCC:     4.946 μs (0 allocations: 0 bytes)
Out of place Clang:   4.571 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (1,0), T = ForwardDiff.Dual{Nothing, Float64, 1}:
Out of place Julia:   36.078 μs (272 allocations: 54.00 KiB)
In place     Julia:   14.599 μs (53 allocations: 9.52 KiB)
Out of place GCC:     6.324 μs (0 allocations: 0 bytes)
Out of place Clang:   6.501 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (2,0), T = ForwardDiff.Dual{Nothing, Float64, 2}:
Out of place Julia:   42.147 μs (272 allocations: 70.38 KiB)
In place     Julia:   17.237 μs (53 allocations: 12.20 KiB)
Out of place GCC:     8.251 μs (0 allocations: 0 bytes)
Out of place Clang:   7.507 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (3,0), T = ForwardDiff.Dual{Nothing, Float64, 3}:
Out of place Julia:   52.825 μs (272 allocations: 94.94 KiB)
In place     Julia:   21.154 μs (53 allocations: 16.23 KiB)
Out of place GCC:     11.010 μs (0 allocations: 0 bytes)
Out of place Clang:   10.150 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (4,0), T = ForwardDiff.Dual{Nothing, Float64, 4}:
Out of place Julia:   57.009 μs (272 allocations: 115.41 KiB)
In place     Julia:   22.975 μs (53 allocations: 19.59 KiB)
Out of place GCC:     8.457 μs (0 allocations: 0 bytes)
Out of place Clang:   11.948 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (5,0), T = ForwardDiff.Dual{Nothing, Float64, 5}:
Out of place Julia:   62.426 μs (272 allocations: 127.69 KiB)
In place     Julia:   25.971 μs (53 allocations: 21.61 KiB)
Out of place GCC:     10.148 μs (0 allocations: 0 bytes)
Out of place Clang:   13.389 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (6,0), T = ForwardDiff.Dual{Nothing, Float64, 6}:
Out of place Julia:   69.434 μs (272 allocations: 148.16 KiB)
In place     Julia:   29.374 μs (53 allocations: 24.97 KiB)
Out of place GCC:     11.394 μs (0 allocations: 0 bytes)
Out of place Clang:   15.038 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (7,0), T = ForwardDiff.Dual{Nothing, Float64, 7}:
Out of place Julia:   74.437 μs (272 allocations: 172.72 KiB)
In place     Julia:   30.512 μs (53 allocations: 29.00 KiB)
Out of place GCC:     17.793 μs (0 allocations: 0 bytes)
Out of place Clang:   19.252 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (8,0), T = ForwardDiff.Dual{Nothing, Float64, 8}:
Out of place Julia:   83.143 μs (272 allocations: 189.09 KiB)
In place     Julia:   31.757 μs (53 allocations: 31.69 KiB)
Out of place GCC:     15.451 μs (0 allocations: 0 bytes)
Out of place Clang:   17.724 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (1,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 1}, 1}:
Out of place Julia:   54.733 μs (272 allocations: 94.94 KiB)
In place     Julia:   24.287 μs (53 allocations: 16.23 KiB)
Out of place GCC:     11.017 μs (0 allocations: 0 bytes)
Out of place Clang:   12.498 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (2,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 2}, 1}:
Out of place Julia:   68.877 μs (272 allocations: 127.69 KiB)
In place     Julia:   30.364 μs (53 allocations: 21.61 KiB)
Out of place GCC:     14.239 μs (0 allocations: 0 bytes)
Out of place Clang:   15.886 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (3,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 3}, 1}:
Out of place Julia:   83.635 μs (272 allocations: 172.72 KiB)
In place     Julia:   37.259 μs (53 allocations: 29.00 KiB)
Out of place GCC:     20.157 μs (0 allocations: 0 bytes)
Out of place Clang:   23.754 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (4,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 4}, 1}:
Out of place Julia:   101.397 μs (272 allocations: 209.56 KiB)
In place     Julia:   47.986 μs (53 allocations: 35.05 KiB)
Out of place GCC:     25.288 μs (0 allocations: 0 bytes)
Out of place Clang:   30.586 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (5,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 5}, 1}:
Out of place Julia:   154.427 μs (272 allocations: 258.69 KiB)
In place     Julia:   77.036 μs (53 allocations: 43.11 KiB)
Out of place GCC:     27.420 μs (0 allocations: 0 bytes)
Out of place Clang:   32.148 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (6,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 6}, 1}:
Out of place Julia:   166.894 μs (272 allocations: 279.16 KiB)
In place     Julia:   79.732 μs (53 allocations: 46.47 KiB)
Out of place GCC:     33.334 μs (0 allocations: 0 bytes)
Out of place Clang:   45.442 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (7,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 7}, 1}:
Out of place Julia:   171.955 μs (272 allocations: 320.09 KiB)
In place     Julia:   83.535 μs (53 allocations: 53.19 KiB)
Out of place GCC:     43.384 μs (0 allocations: 0 bytes)
Out of place Clang:   28.716 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (8,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 8}, 1}:
Out of place Julia:   199.192 μs (272 allocations: 348.75 KiB)
In place     Julia:   85.552 μs (53 allocations: 57.89 KiB)
Out of place GCC:     46.455 μs (0 allocations: 0 bytes)
Out of place Clang:   36.863 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (1,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 1}, 2}:
Out of place Julia:   73.636 μs (272 allocations: 127.69 KiB)
In place     Julia:   35.319 μs (53 allocations: 21.61 KiB)
Out of place GCC:     14.874 μs (0 allocations: 0 bytes)
Out of place Clang:   21.024 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (2,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 2}, 2}:
Out of place Julia:   96.371 μs (272 allocations: 189.09 KiB)
In place     Julia:   48.714 μs (53 allocations: 31.69 KiB)
Out of place GCC:     24.281 μs (0 allocations: 0 bytes)
Out of place Clang:   23.477 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (3,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 3}, 2}:
Out of place Julia:   141.636 μs (272 allocations: 258.69 KiB)
In place     Julia:   63.117 μs (53 allocations: 43.11 KiB)
Out of place GCC:     29.754 μs (0 allocations: 0 bytes)
Out of place Clang:   32.153 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (4,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 4}, 2}:
Out of place Julia:   157.912 μs (272 allocations: 299.62 KiB)
In place     Julia:   73.664 μs (53 allocations: 49.83 KiB)
Out of place GCC:     43.446 μs (0 allocations: 0 bytes)
Out of place Clang:   41.660 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (5,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 5}, 2}:
Out of place Julia:   181.664 μs (272 allocations: 348.75 KiB)
In place     Julia:   83.945 μs (53 allocations: 57.89 KiB)
Out of place GCC:     47.200 μs (0 allocations: 0 bytes)
Out of place Clang:   42.056 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (6,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 6}, 2}:
Out of place Julia:   216.432 μs (272 allocations: 418.34 KiB)
In place     Julia:   105.434 μs (53 allocations: 69.31 KiB)
Out of place GCC:     59.830 μs (0 allocations: 0 bytes)
Out of place Clang:   42.503 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (7,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 7}, 2}:
Out of place Julia:   226.792 μs (272 allocations: 463.38 KiB)
In place     Julia:   101.554 μs (53 allocations: 76.70 KiB)
Out of place GCC:     95.283 μs (0 allocations: 0 bytes)
Out of place Clang:   63.069 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (8,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 8}, 2}:
Out of place Julia:   294.828 μs (272 allocations: 520.69 KiB)
In place     Julia:   144.694 μs (53 allocations: 86.11 KiB)
Out of place GCC:     196.450 μs (0 allocations: 0 bytes)
Out of place Clang:   67.980 μs (0 allocations: 0 bytes)
Size 4 x 4:
Size 4 x 4, duals (n,j) = (0,0), T = Float64:
Out of place Julia:   47.291 μs (272 allocations: 50.06 KiB)
In place     Julia:   23.879 μs (53 allocations: 9.00 KiB)
Out of place GCC:     7.788 μs (0 allocations: 0 bytes)
Out of place Clang:   8.270 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (1,0), T = ForwardDiff.Dual{Nothing, Float64, 1}:
Out of place Julia:   153.542 μs (479 allocations: 1.43 MiB)
In place     Julia:   95.214 μs (224 allocations: 1.12 MiB)
Out of place GCC:     12.030 μs (0 allocations: 0 bytes)
Out of place Clang:   11.008 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (2,0), T = ForwardDiff.Dual{Nothing, Float64, 2}:
Out of place Julia:   149.306 μs (479 allocations: 1.53 MiB)
In place     Julia:   100.296 μs (224 allocations: 1.19 MiB)
Out of place GCC:     16.743 μs (0 allocations: 0 bytes)
Out of place Clang:   14.037 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (3,0), T = ForwardDiff.Dual{Nothing, Float64, 3}:
Out of place Julia:   160.575 μs (479 allocations: 1.53 MiB)
In place     Julia:   104.306 μs (224 allocations: 1.17 MiB)
Out of place GCC:     19.645 μs (0 allocations: 0 bytes)
Out of place Clang:   22.891 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (4,0), T = ForwardDiff.Dual{Nothing, Float64, 4}:
Out of place Julia:   181.509 μs (479 allocations: 1.55 MiB)
In place     Julia:   116.274 μs (224 allocations: 1.16 MiB)
Out of place GCC:     18.460 μs (0 allocations: 0 bytes)
Out of place Clang:   27.266 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (5,0), T = ForwardDiff.Dual{Nothing, Float64, 5}:
Out of place Julia:   197.116 μs (479 allocations: 1.67 MiB)
In place     Julia:   121.072 μs (224 allocations: 1.23 MiB)
Out of place GCC:     18.821 μs (0 allocations: 0 bytes)
Out of place Clang:   29.111 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (6,0), T = ForwardDiff.Dual{Nothing, Float64, 6}:
Out of place Julia:   204.943 μs (479 allocations: 1.52 MiB)
In place     Julia:   122.037 μs (224 allocations: 1.09 MiB)
Out of place GCC:     23.758 μs (0 allocations: 0 bytes)
Out of place Clang:   26.093 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (7,0), T = ForwardDiff.Dual{Nothing, Float64, 7}:
Out of place Julia:   197.098 μs (479 allocations: 1.50 MiB)
In place     Julia:   115.905 μs (224 allocations: 1.06 MiB)
Out of place GCC:     39.293 μs (0 allocations: 0 bytes)
Out of place Clang:   43.041 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (8,0), T = ForwardDiff.Dual{Nothing, Float64, 8}:
Out of place Julia:   232.522 μs (479 allocations: 1.70 MiB)
In place     Julia:   133.656 μs (224 allocations: 1.19 MiB)
Out of place GCC:     34.214 μs (0 allocations: 0 bytes)
Out of place Clang:   38.551 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (1,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 1}, 1}:
Out of place Julia:   173.374 μs (479 allocations: 1.53 MiB)
In place     Julia:   103.780 μs (224 allocations: 1.17 MiB)
Out of place GCC:     22.663 μs (0 allocations: 0 bytes)
Out of place Clang:   27.036 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (2,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 2}, 1}:
Out of place Julia:   207.995 μs (479 allocations: 1.67 MiB)
In place     Julia:   125.982 μs (224 allocations: 1.23 MiB)
Out of place GCC:     28.796 μs (0 allocations: 0 bytes)
Out of place Clang:   33.133 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (3,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 3}, 1}:
Out of place Julia:   218.887 μs (479 allocations: 1.50 MiB)
In place     Julia:   135.521 μs (224 allocations: 1.06 MiB)
Out of place GCC:     39.719 μs (0 allocations: 0 bytes)
Out of place Clang:   48.112 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (4,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 4}, 1}:
Out of place Julia:   272.842 μs (479 allocations: 1.64 MiB)
In place     Julia:   167.338 μs (224 allocations: 1.13 MiB)
Out of place GCC:     56.149 μs (0 allocations: 0 bytes)
Out of place Clang:   71.744 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (5,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 5}, 1}:
Out of place Julia:   432.265 μs (479 allocations: 1.69 MiB)
In place     Julia:   269.094 μs (224 allocations: 1.13 MiB)
Out of place GCC:     45.218 μs (0 allocations: 0 bytes)
Out of place Clang:   59.216 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (6,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 6}, 1}:
Out of place Julia:   484.352 μs (479 allocations: 1.72 MiB)
In place     Julia:   301.263 μs (224 allocations: 1.09 MiB)
Out of place GCC:     57.685 μs (0 allocations: 0 bytes)
Out of place Clang:   84.604 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (7,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 7}, 1}:
Out of place Julia:   510.210 μs (479 allocations: 1.93 MiB)
In place     Julia:   276.594 μs (224 allocations: 1.23 MiB)
Out of place GCC:     93.442 μs (0 allocations: 0 bytes)
Out of place Clang:   48.223 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (8,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 8}, 1}:
Out of place Julia:   555.264 μs (479 allocations: 1.84 MiB)
In place     Julia:   309.717 μs (224 allocations: 1.12 MiB)
Out of place GCC:     99.131 μs (0 allocations: 0 bytes)
Out of place Clang:   73.465 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (1,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 1}, 2}:
Out of place Julia:   222.298 μs (479 allocations: 1.67 MiB)
In place     Julia:   138.586 μs (224 allocations: 1.23 MiB)
Out of place GCC:     28.320 μs (0 allocations: 0 bytes)
Out of place Clang:   45.618 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (2,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 2}, 2}:
Out of place Julia:   268.994 μs (479 allocations: 1.70 MiB)
In place     Julia:   170.024 μs (224 allocations: 1.19 MiB)
Out of place GCC:     47.408 μs (0 allocations: 0 bytes)
Out of place Clang:   52.890 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (3,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 3}, 2}:
Out of place Julia:   427.076 μs (479 allocations: 1.69 MiB)
In place     Julia:   270.404 μs (224 allocations: 1.13 MiB)
Out of place GCC:     69.829 μs (0 allocations: 0 bytes)
Out of place Clang:   81.174 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (4,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 4}, 2}:
Out of place Julia:   474.039 μs (479 allocations: 1.81 MiB)
In place     Julia:   287.848 μs (224 allocations: 1.16 MiB)
Out of place GCC:     98.566 μs (0 allocations: 0 bytes)
Out of place Clang:   93.758 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (5,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 5}, 2}:
Out of place Julia:   506.764 μs (479 allocations: 1.84 MiB)
In place     Julia:   309.705 μs (224 allocations: 1.12 MiB)
Out of place GCC:     115.064 μs (0 allocations: 0 bytes)
Out of place Clang:   98.004 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (6,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 6}, 2}:
Out of place Julia:   562.063 μs (479 allocations: 2.14 MiB)
In place     Julia:   355.238 μs (224 allocations: 1.30 MiB)
Out of place GCC:     115.697 μs (0 allocations: 0 bytes)
Out of place Clang:   97.450 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (7,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 7}, 2}:
Out of place Julia:   581.977 μs (479 allocations: 2.06 MiB)
In place     Julia:   365.816 μs (224 allocations: 1.17 MiB)
Out of place GCC:     200.535 μs (0 allocations: 0 bytes)
Out of place Clang:   120.117 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (8,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 8}, 2}:
Out of place Julia:   739.855 μs (479 allocations: 2.31 MiB)
In place     Julia:   462.461 μs (224 allocations: 1.32 MiB)
Out of place GCC:     496.138 μs (0 allocations: 0 bytes)
Out of place Clang:   139.765 μs (0 allocations: 0 bytes)
Size 5 x 5:
Size 5 x 5, duals (n,j) = (0,0), T = Float64:
Out of place Julia:   64.506 μs (272 allocations: 66.44 KiB)
In place     Julia:   39.423 μs (53 allocations: 11.69 KiB)
Out of place GCC:     14.251 μs (0 allocations: 0 bytes)
Out of place Clang:   14.565 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (1,0), T = ForwardDiff.Dual{Nothing, Float64, 1}:
Out of place Julia:   167.860 μs (479 allocations: 1.47 MiB)
In place     Julia:   112.871 μs (224 allocations: 1.13 MiB)
Out of place GCC:     19.604 μs (0 allocations: 0 bytes)
Out of place Clang:   21.065 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (2,0), T = ForwardDiff.Dual{Nothing, Float64, 2}:
Out of place Julia:   192.787 μs (479 allocations: 1.58 MiB)
In place     Julia:   125.698 μs (224 allocations: 1.20 MiB)
Out of place GCC:     32.126 μs (0 allocations: 0 bytes)
Out of place Clang:   26.622 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (3,0), T = ForwardDiff.Dual{Nothing, Float64, 3}:
Out of place Julia:   207.645 μs (479 allocations: 1.61 MiB)
In place     Julia:   130.188 μs (224 allocations: 1.18 MiB)
Out of place GCC:     36.594 μs (0 allocations: 0 bytes)
Out of place Clang:   43.826 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (4,0), T = ForwardDiff.Dual{Nothing, Float64, 4}:
Out of place Julia:   240.483 μs (479 allocations: 1.64 MiB)
In place     Julia:   150.362 μs (224 allocations: 1.17 MiB)
Out of place GCC:     36.270 μs (0 allocations: 0 bytes)
Out of place Clang:   48.387 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (5,0), T = ForwardDiff.Dual{Nothing, Float64, 5}:
Out of place Julia:   260.393 μs (479 allocations: 1.78 MiB)
In place     Julia:   155.027 μs (224 allocations: 1.25 MiB)
Out of place GCC:     35.654 μs (0 allocations: 0 bytes)
Out of place Clang:   55.753 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (6,0), T = ForwardDiff.Dual{Nothing, Float64, 6}:
Out of place Julia:   277.209 μs (479 allocations: 1.64 MiB)
In place     Julia:   165.868 μs (224 allocations: 1.11 MiB)
Out of place GCC:     44.059 μs (0 allocations: 0 bytes)
Out of place Clang:   64.026 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (7,0), T = ForwardDiff.Dual{Nothing, Float64, 7}:
Out of place Julia:   278.882 μs (479 allocations: 1.68 MiB)
In place     Julia:   153.773 μs (224 allocations: 1.09 MiB)
Out of place GCC:     78.184 μs (0 allocations: 0 bytes)
Out of place Clang:   81.553 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (8,0), T = ForwardDiff.Dual{Nothing, Float64, 8}:
Out of place Julia:   335.794 μs (479 allocations: 1.89 MiB)
In place     Julia:   182.972 μs (224 allocations: 1.23 MiB)
Out of place GCC:     69.443 μs (0 allocations: 0 bytes)
Out of place Clang:   79.015 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (1,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 1}, 1}:
Out of place Julia:   228.278 μs (479 allocations: 1.61 MiB)
In place     Julia:   135.320 μs (224 allocations: 1.18 MiB)
Out of place GCC:     48.523 μs (0 allocations: 0 bytes)
Out of place Clang:   46.806 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (2,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 2}, 1}:
Out of place Julia:   269.390 μs (479 allocations: 1.78 MiB)
In place     Julia:   164.363 μs (224 allocations: 1.25 MiB)
Out of place GCC:     56.483 μs (0 allocations: 0 bytes)
Out of place Clang:   66.575 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (3,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 3}, 1}:
Out of place Julia:   318.138 μs (479 allocations: 1.68 MiB)
In place     Julia:   190.910 μs (224 allocations: 1.09 MiB)
Out of place GCC:     92.035 μs (0 allocations: 0 bytes)
Out of place Clang:   104.472 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (4,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 4}, 1}:
Out of place Julia:   395.331 μs (479 allocations: 1.83 MiB)
In place     Julia:   252.094 μs (224 allocations: 1.16 MiB)
Out of place GCC:     104.484 μs (0 allocations: 0 bytes)
Out of place Clang:   121.685 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (5,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 5}, 1}:
Out of place Julia:   663.633 μs (479 allocations: 1.92 MiB)
In place     Julia:   436.734 μs (224 allocations: 1.16 MiB)
Out of place GCC:     87.655 μs (0 allocations: 0 bytes)
Out of place Clang:   123.451 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (6,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 6}, 1}:
Out of place Julia:   763.889 μs (479 allocations: 1.95 MiB)
In place     Julia:   492.078 μs (224 allocations: 1.12 MiB)
Out of place GCC:     106.368 μs (0 allocations: 0 bytes)
Out of place Clang:   152.013 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (7,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 7}, 1}:
Out of place Julia:   759.848 μs (479 allocations: 2.21 MiB)
In place     Julia:   455.199 μs (224 allocations: 1.28 MiB)
Out of place GCC:     181.649 μs (0 allocations: 0 bytes)
Out of place Clang:   114.357 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (8,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 8}, 1}:
Out of place Julia:   839.583 μs (479 allocations: 2.18 MiB)
In place     Julia:   501.465 μs (224 allocations: 1.17 MiB)
Out of place GCC:     176.522 μs (0 allocations: 0 bytes)
Out of place Clang:   132.668 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (1,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 1}, 2}:
Out of place Julia:   296.524 μs (479 allocations: 1.78 MiB)
In place     Julia:   188.874 μs (224 allocations: 1.25 MiB)
Out of place GCC:     53.885 μs (0 allocations: 0 bytes)
Out of place Clang:   88.802 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (2,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 2}, 2}:
Out of place Julia:   398.654 μs (479 allocations: 1.89 MiB)
In place     Julia:   261.632 μs (224 allocations: 1.23 MiB)
Out of place GCC:     90.811 μs (0 allocations: 0 bytes)
Out of place Clang:   108.016 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (3,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 3}, 2}:
Out of place Julia:   668.043 μs (479 allocations: 1.92 MiB)
In place     Julia:   446.609 μs (224 allocations: 1.16 MiB)
Out of place GCC:     120.276 μs (0 allocations: 0 bytes)
Out of place Clang:   137.719 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (4,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 4}, 2}:
Out of place Julia:   704.848 μs (479 allocations: 2.08 MiB)
In place     Julia:   458.736 μs (224 allocations: 1.20 MiB)
Out of place GCC:     161.214 μs (0 allocations: 0 bytes)
Out of place Clang:   155.338 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (5,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 5}, 2}:
Out of place Julia:   763.418 μs (479 allocations: 2.18 MiB)
In place     Julia:   495.028 μs (224 allocations: 1.17 MiB)
Out of place GCC:     202.092 μs (0 allocations: 0 bytes)
Out of place Clang:   175.730 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (6,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 6}, 2}:
Out of place Julia:   843.755 μs (479 allocations: 2.52 MiB)
In place     Julia:   585.755 μs (224 allocations: 1.36 MiB)
Out of place GCC:     211.305 μs (0 allocations: 0 bytes)
Out of place Clang:   174.514 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (7,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 7}, 2}:
Out of place Julia:   859.380 μs (479 allocations: 2.49 MiB)
In place     Julia:   589.541 μs (224 allocations: 1.24 MiB)
Out of place GCC:     405.265 μs (0 allocations: 0 bytes)
Out of place Clang:   266.848 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (8,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 8}, 2}:
Out of place Julia:   1.135 ms (479 allocations: 2.81 MiB)
In place     Julia:   732.921 μs (224 allocations: 1.40 MiB)
Out of place GCC:     883.974 μs (0 allocations: 0 bytes)
Out of place Clang:   264.656 μs (0 allocations: 0 bytes)
```
Especially when the array sizes are smaller (dimensions and dual sizes), the C++ implementions perform much better than Julia.
Clang -- which is powered by LLVM like Julia -- continues to outperform it into the larger sizes we care about/benchmark here. This is despite the much more naive C++ implementation.
