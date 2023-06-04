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
Out of place Julia:   1.304 μs (18 allocations: 1.12 KiB)
In place     Julia:   645.636 ns (5 allocations: 320 bytes)
Out of place GCC:     126.535 ns (0 allocations: 0 bytes)
Out of place Clang:   129.270 ns (0 allocations: 0 bytes)
Size 1 x 1, duals (n,j) = (1,0), T = ForwardDiff.Dual{Nothing, Float64, 1}:
Out of place Julia:   4.568 μs (46 allocations: 160.84 KiB)
In place     Julia:   1.279 μs (11 allocations: 40.16 KiB)
Out of place GCC:     174.189 ns (0 allocations: 0 bytes)
Out of place Clang:   149.201 ns (0 allocations: 0 bytes)
Size 1 x 1, duals (n,j) = (2,0), T = ForwardDiff.Dual{Nothing, Float64, 2}:
Out of place Julia:   4.725 μs (46 allocations: 169.84 KiB)
In place     Julia:   1.320 μs (11 allocations: 42.41 KiB)
Out of place GCC:     166.804 ns (0 allocations: 0 bytes)
Out of place Clang:   154.072 ns (0 allocations: 0 bytes)
Size 1 x 1, duals (n,j) = (3,0), T = ForwardDiff.Dual{Nothing, Float64, 3}:
Out of place Julia:   3.643 μs (36 allocations: 124.78 KiB)
In place     Julia:   1.285 μs (11 allocations: 41.47 KiB)
Out of place GCC:     152.156 ns (0 allocations: 0 bytes)
Out of place Clang:   139.542 ns (0 allocations: 0 bytes)
Size 1 x 1, duals (n,j) = (4,0), T = ForwardDiff.Dual{Nothing, Float64, 4}:
Out of place Julia:   3.587 μs (36 allocations: 123.28 KiB)
In place     Julia:   1.343 μs (11 allocations: 40.97 KiB)
Out of place GCC:     103.102 ns (0 allocations: 0 bytes)
Out of place Clang:   142.963 ns (0 allocations: 0 bytes)
Size 1 x 1, duals (n,j) = (5,0), T = ForwardDiff.Dual{Nothing, Float64, 5}:
Out of place Julia:   2.513 μs (26 allocations: 87.09 KiB)
In place     Julia:   1.288 μs (10 allocations: 43.17 KiB)
Out of place GCC:     84.409 ns (0 allocations: 0 bytes)
Out of place Clang:   136.407 ns (0 allocations: 0 bytes)
Size 1 x 1, duals (n,j) = (6,0), T = ForwardDiff.Dual{Nothing, Float64, 6}:
Out of place Julia:   2.501 μs (26 allocations: 76.59 KiB)
In place     Julia:   1.286 μs (10 allocations: 37.92 KiB)
Out of place GCC:     104.969 ns (0 allocations: 0 bytes)
Out of place Clang:   170.975 ns (0 allocations: 0 bytes)
Size 1 x 1, duals (n,j) = (7,0), T = ForwardDiff.Dual{Nothing, Float64, 7}:
Out of place Julia:   3.547 μs (36 allocations: 111.84 KiB)
In place     Julia:   1.329 μs (11 allocations: 37.09 KiB)
Out of place GCC:     194.749 ns (0 allocations: 0 bytes)
Out of place Clang:   155.365 ns (0 allocations: 0 bytes)
Size 1 x 1, duals (n,j) = (8,0), T = ForwardDiff.Dual{Nothing, Float64, 8}:
Out of place Julia:   2.543 μs (26 allocations: 83.81 KiB)
In place     Julia:   1.270 μs (10 allocations: 41.47 KiB)
Out of place GCC:     108.120 ns (0 allocations: 0 bytes)
Out of place Clang:   138.240 ns (0 allocations: 0 bytes)
Size 1 x 1, duals (n,j) = (1,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 1}, 1}:
Out of place Julia:   3.643 μs (36 allocations: 124.78 KiB)
In place     Julia:   1.292 μs (11 allocations: 41.47 KiB)
Out of place GCC:     189.582 ns (0 allocations: 0 bytes)
Out of place Clang:   145.704 ns (0 allocations: 0 bytes)
Size 1 x 1, duals (n,j) = (2,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 2}, 1}:
Out of place Julia:   2.540 μs (26 allocations: 87.09 KiB)
In place     Julia:   1.268 μs (10 allocations: 43.17 KiB)
Out of place GCC:     170.890 ns (0 allocations: 0 bytes)
Out of place Clang:   162.260 ns (0 allocations: 0 bytes)
Size 1 x 1, duals (n,j) = (3,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 3}, 1}:
Out of place Julia:   4.647 μs (46 allocations: 148.88 KiB)
In place     Julia:   1.366 μs (11 allocations: 37.09 KiB)
Out of place GCC:     252.373 ns (0 allocations: 0 bytes)
Out of place Clang:   185.009 ns (0 allocations: 0 bytes)
Size 1 x 1, duals (n,j) = (4,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 4}, 1}:
Out of place Julia:   3.701 μs (36 allocations: 118.12 KiB)
In place     Julia:   1.385 μs (11 allocations: 39.16 KiB)
Out of place GCC:     245.943 ns (0 allocations: 0 bytes)
Out of place Clang:   214.585 ns (0 allocations: 0 bytes)
Size 1 x 1, duals (n,j) = (5,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 5}, 1}:
Out of place Julia:   3.924 μs (36 allocations: 116.91 KiB)
In place     Julia:   1.447 μs (11 allocations: 38.72 KiB)
Out of place GCC:     268.997 ns (0 allocations: 0 bytes)
Out of place Clang:   230.930 ns (0 allocations: 0 bytes)
Size 1 x 1, duals (n,j) = (6,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 6}, 1}:
Out of place Julia:   2.675 μs (26 allocations: 74.47 KiB)
In place     Julia:   1.379 μs (10 allocations: 36.61 KiB)
Out of place GCC:     259.767 ns (0 allocations: 0 bytes)
Out of place Clang:   180.708 ns (0 allocations: 0 bytes)
Size 1 x 1, duals (n,j) = (7,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 7}, 1}:
Out of place Julia:   4.992 μs (46 allocations: 168.25 KiB)
In place     Julia:   1.431 μs (11 allocations: 41.84 KiB)
Out of place GCC:     321.612 ns (0 allocations: 0 bytes)
Out of place Clang:   225.352 ns (0 allocations: 0 bytes)
Size 1 x 1, duals (n,j) = (8,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 8}, 1}:
Out of place Julia:   5.081 μs (46 allocations: 150.59 KiB)
In place     Julia:   1.518 μs (11 allocations: 37.41 KiB)
Out of place GCC:     339.164 ns (0 allocations: 0 bytes)
Out of place Clang:   273.973 ns (0 allocations: 0 bytes)
Size 1 x 1, duals (n,j) = (1,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 1}, 2}:
Out of place Julia:   3.604 μs (36 allocations: 130.31 KiB)
In place     Julia:   1.412 μs (11 allocations: 43.28 KiB)
Out of place GCC:     181.601 ns (0 allocations: 0 bytes)
Out of place Clang:   206.742 ns (0 allocations: 0 bytes)
Size 1 x 1, duals (n,j) = (2,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 2}, 2}:
Out of place Julia:   3.775 μs (36 allocations: 125.34 KiB)
In place     Julia:   1.381 μs (11 allocations: 41.59 KiB)
Out of place GCC:     230.954 ns (0 allocations: 0 bytes)
Out of place Clang:   211.016 ns (0 allocations: 0 bytes)
Size 1 x 1, duals (n,j) = (3,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 3}, 2}:
Out of place Julia:   2.670 μs (26 allocations: 78.25 KiB)
In place     Julia:   1.345 μs (10 allocations: 38.56 KiB)
Out of place GCC:     215.237 ns (0 allocations: 0 bytes)
Out of place Clang:   158.745 ns (0 allocations: 0 bytes)
Size 1 x 1, duals (n,j) = (4,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 4}, 2}:
Out of place Julia:   4.915 μs (46 allocations: 157.91 KiB)
In place     Julia:   1.521 μs (11 allocations: 39.28 KiB)
Out of place GCC:     373.737 ns (0 allocations: 0 bytes)
Out of place Clang:   295.449 ns (0 allocations: 0 bytes)
Size 1 x 1, duals (n,j) = (5,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 5}, 2}:
Out of place Julia:   5.135 μs (46 allocations: 150.59 KiB)
In place     Julia:   1.759 μs (11 allocations: 37.41 KiB)
Out of place GCC:     382.946 ns (0 allocations: 0 bytes)
Out of place Clang:   320.648 ns (0 allocations: 0 bytes)
Size 1 x 1, duals (n,j) = (6,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 6}, 2}:
Out of place Julia:   4.517 μs (36 allocations: 131.53 KiB)
In place     Julia:   1.827 μs (11 allocations: 43.47 KiB)
Out of place GCC:     336.161 ns (0 allocations: 0 bytes)
Out of place Clang:   308.927 ns (0 allocations: 0 bytes)
Size 1 x 1, duals (n,j) = (7,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 7}, 2}:
Out of place Julia:   4.685 μs (36 allocations: 116.34 KiB)
In place     Julia:   1.806 μs (11 allocations: 38.34 KiB)
Out of place GCC:     438.889 ns (0 allocations: 0 bytes)
Out of place Clang:   254.814 ns (0 allocations: 0 bytes)
Size 1 x 1, duals (n,j) = (8,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 8}, 2}:
Out of place Julia:   5.108 μs (46 allocations: 173.97 KiB)
In place     Julia:   1.663 μs (11 allocations: 43.16 KiB)
Out of place GCC:     959.306 ns (0 allocations: 0 bytes)
Out of place Clang:   673.726 ns (0 allocations: 0 bytes)
Size 2 x 2:
Size 2 x 2, duals (n,j) = (0,0), T = Float64:
Out of place Julia:   1.237 μs (23 allocations: 2.14 KiB)
In place     Julia:   536.812 ns (5 allocations: 464 bytes)
Out of place GCC:     281.138 ns (0 allocations: 0 bytes)
Out of place Clang:   288.359 ns (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (1,0), T = ForwardDiff.Dual{Nothing, Float64, 1}:
Out of place Julia:   1.474 μs (23 allocations: 2.83 KiB)
In place     Julia:   671.136 ns (5 allocations: 592 bytes)
Out of place GCC:     410.535 ns (0 allocations: 0 bytes)
Out of place Clang:   344.102 ns (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (2,0), T = ForwardDiff.Dual{Nothing, Float64, 2}:
Out of place Julia:   1.535 μs (23 allocations: 3.52 KiB)
In place     Julia:   765.420 ns (5 allocations: 720 bytes)
Out of place GCC:     316.525 ns (0 allocations: 0 bytes)
Out of place Clang:   346.474 ns (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (3,0), T = ForwardDiff.Dual{Nothing, Float64, 3}:
Out of place Julia:   1.806 μs (23 allocations: 4.20 KiB)
In place     Julia:   883.283 ns (5 allocations: 848 bytes)
Out of place GCC:     503.909 ns (0 allocations: 0 bytes)
Out of place Clang:   475.515 ns (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (4,0), T = ForwardDiff.Dual{Nothing, Float64, 4}:
Out of place Julia:   1.961 μs (23 allocations: 4.89 KiB)
In place     Julia:   935.333 ns (5 allocations: 976 bytes)
Out of place GCC:     366.077 ns (0 allocations: 0 bytes)
Out of place Clang:   536.914 ns (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (5,0), T = ForwardDiff.Dual{Nothing, Float64, 5}:
Out of place Julia:   2.005 μs (23 allocations: 5.58 KiB)
In place     Julia:   1.016 μs (5 allocations: 1.08 KiB)
Out of place GCC:     368.350 ns (0 allocations: 0 bytes)
Out of place Clang:   522.785 ns (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (6,0), T = ForwardDiff.Dual{Nothing, Float64, 6}:
Out of place Julia:   2.143 μs (23 allocations: 6.27 KiB)
In place     Julia:   1.057 μs (5 allocations: 1.20 KiB)
Out of place GCC:     409.123 ns (0 allocations: 0 bytes)
Out of place Clang:   496.280 ns (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (7,0), T = ForwardDiff.Dual{Nothing, Float64, 7}:
Out of place Julia:   1.873 μs (23 allocations: 7.30 KiB)
In place     Julia:   1.003 μs (5 allocations: 1.39 KiB)
Out of place GCC:     874.325 ns (0 allocations: 0 bytes)
Out of place Clang:   522.907 ns (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (8,0), T = ForwardDiff.Dual{Nothing, Float64, 8}:
Out of place Julia:   3.054 μs (31 allocations: 10.86 KiB)
In place     Julia:   930.900 ns (6 allocations: 1.88 KiB)
Out of place GCC:     576.544 ns (0 allocations: 0 bytes)
Out of place Clang:   596.949 ns (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (1,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 1}, 1}:
Out of place Julia:   1.506 μs (19 allocations: 3.45 KiB)
In place     Julia:   955.125 ns (5 allocations: 848 bytes)
Out of place GCC:     484.403 ns (0 allocations: 0 bytes)
Out of place Clang:   402.144 ns (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (2,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 2}, 1}:
Out of place Julia:   1.976 μs (23 allocations: 5.58 KiB)
In place     Julia:   1.095 μs (5 allocations: 1.08 KiB)
Out of place GCC:     683.145 ns (0 allocations: 0 bytes)
Out of place Clang:   578.354 ns (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (3,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 3}, 1}:
Out of place Julia:   2.062 μs (23 allocations: 7.30 KiB)
In place     Julia:   1.174 μs (5 allocations: 1.39 KiB)
Out of place GCC:     893.822 ns (0 allocations: 0 bytes)
Out of place Clang:   693.473 ns (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (4,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 4}, 1}:
Out of place Julia:   3.939 μs (31 allocations: 11.80 KiB)
In place     Julia:   1.375 μs (6 allocations: 2.03 KiB)
Out of place GCC:     850.727 ns (0 allocations: 0 bytes)
Out of place Clang:   964.947 ns (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (5,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 5}, 1}:
Out of place Julia:   3.526 μs (23 allocations: 9.70 KiB)
In place     Julia:   1.801 μs (5 allocations: 1.83 KiB)
Out of place GCC:     1.367 μs (0 allocations: 0 bytes)
Out of place Clang:   849.127 ns (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (6,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 6}, 1}:
Out of place Julia:   5.633 μs (31 allocations: 16.02 KiB)
In place     Julia:   2.300 μs (6 allocations: 2.73 KiB)
Out of place GCC:     1.139 μs (0 allocations: 0 bytes)
Out of place Clang:   1.175 μs (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (7,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 7}, 1}:
Out of place Julia:   5.382 μs (31 allocations: 16.95 KiB)
In place     Julia:   2.161 μs (6 allocations: 2.89 KiB)
Out of place GCC:     1.374 μs (0 allocations: 0 bytes)
Out of place Clang:   972.412 ns (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (8,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 8}, 1}:
Out of place Julia:   4.836 μs (23 allocations: 14.52 KiB)
In place     Julia:   2.327 μs (5 allocations: 2.70 KiB)
Out of place GCC:     1.870 μs (0 allocations: 0 bytes)
Out of place Clang:   1.205 μs (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (1,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 1}, 2}:
Out of place Julia:   2.096 μs (23 allocations: 5.58 KiB)
In place     Julia:   1.199 μs (5 allocations: 1.08 KiB)
Out of place GCC:     576.253 ns (0 allocations: 0 bytes)
Out of place Clang:   727.085 ns (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (2,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 2}, 2}:
Out of place Julia:   2.378 μs (23 allocations: 7.98 KiB)
In place     Julia:   1.410 μs (5 allocations: 1.52 KiB)
Out of place GCC:     912.385 ns (0 allocations: 0 bytes)
Out of place Clang:   886.203 ns (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (3,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 3}, 2}:
Out of place Julia:   4.401 μs (31 allocations: 13.20 KiB)
In place     Julia:   1.829 μs (6 allocations: 2.27 KiB)
Out of place GCC:     867.035 ns (0 allocations: 0 bytes)
Out of place Clang:   981.833 ns (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (4,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 4}, 2}:
Out of place Julia:   3.193 μs (19 allocations: 9.64 KiB)
In place     Julia:   1.774 μs (5 allocations: 2.20 KiB)
Out of place GCC:     1.902 μs (0 allocations: 0 bytes)
Out of place Clang:   1.264 μs (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (5,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 5}, 2}:
Out of place Julia:   6.675 μs (31 allocations: 19.77 KiB)
In place     Julia:   2.448 μs (6 allocations: 3.36 KiB)
Out of place GCC:     1.976 μs (0 allocations: 0 bytes)
Out of place Clang:   1.331 μs (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (6,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 6}, 2}:
Out of place Julia:   5.463 μs (23 allocations: 15.89 KiB)
In place     Julia:   2.514 μs (5 allocations: 2.95 KiB)
Out of place GCC:     1.824 μs (0 allocations: 0 bytes)
Out of place Clang:   1.236 μs (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (7,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 7}, 2}:
Out of place Julia:   4.894 μs (19 allocations: 15.83 KiB)
In place     Julia:   2.341 μs (5 allocations: 3.58 KiB)
Out of place GCC:     2.255 μs (0 allocations: 0 bytes)
Out of place Clang:   1.414 μs (0 allocations: 0 bytes)
Size 2 x 2, duals (n,j) = (8,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 8}, 2}:
Out of place Julia:   5.982 μs (23 allocations: 21.73 KiB)
In place     Julia:   3.483 μs (5 allocations: 4.02 KiB)
Out of place GCC:     5.482 μs (0 allocations: 0 bytes)
Out of place Clang:   3.811 μs (0 allocations: 0 bytes)
Size 3 x 3:
Size 3 x 3, duals (n,j) = (0,0), T = Float64:
Out of place Julia:   1.679 μs (31 allocations: 3.83 KiB)
In place     Julia:   569.036 ns (6 allocations: 720 bytes)
Out of place GCC:     387.206 ns (0 allocations: 0 bytes)
Out of place Clang:   418.920 ns (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (1,0), T = ForwardDiff.Dual{Nothing, Float64, 1}:
Out of place Julia:   2.636 μs (31 allocations: 6.17 KiB)
In place     Julia:   1.216 μs (6 allocations: 1.09 KiB)
Out of place GCC:     611.589 ns (0 allocations: 0 bytes)
Out of place Clang:   641.883 ns (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (2,0), T = ForwardDiff.Dual{Nothing, Float64, 2}:
Out of place Julia:   2.673 μs (31 allocations: 8.05 KiB)
In place     Julia:   1.305 μs (6 allocations: 1.41 KiB)
Out of place GCC:     689.484 ns (0 allocations: 0 bytes)
Out of place Clang:   748.966 ns (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (3,0), T = ForwardDiff.Dual{Nothing, Float64, 3}:
Out of place Julia:   2.995 μs (31 allocations: 10.86 KiB)
In place     Julia:   1.459 μs (6 allocations: 1.88 KiB)
Out of place GCC:     847.471 ns (0 allocations: 0 bytes)
Out of place Clang:   1.062 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (4,0), T = ForwardDiff.Dual{Nothing, Float64, 4}:
Out of place Julia:   3.335 μs (31 allocations: 13.20 KiB)
In place     Julia:   1.586 μs (6 allocations: 2.27 KiB)
Out of place GCC:     802.923 ns (0 allocations: 0 bytes)
Out of place Clang:   1.056 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (5,0), T = ForwardDiff.Dual{Nothing, Float64, 5}:
Out of place Julia:   4.345 μs (31 allocations: 14.61 KiB)
In place     Julia:   2.104 μs (6 allocations: 2.50 KiB)
Out of place GCC:     873.370 ns (0 allocations: 0 bytes)
Out of place Clang:   1.285 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (6,0), T = ForwardDiff.Dual{Nothing, Float64, 6}:
Out of place Julia:   4.798 μs (31 allocations: 16.95 KiB)
In place     Julia:   2.338 μs (6 allocations: 2.89 KiB)
Out of place GCC:     976.053 ns (0 allocations: 0 bytes)
Out of place Clang:   1.445 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (7,0), T = ForwardDiff.Dual{Nothing, Float64, 7}:
Out of place Julia:   4.809 μs (31 allocations: 19.77 KiB)
In place     Julia:   2.161 μs (6 allocations: 3.36 KiB)
Out of place GCC:     1.929 μs (0 allocations: 0 bytes)
Out of place Clang:   1.799 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (8,0), T = ForwardDiff.Dual{Nothing, Float64, 8}:
Out of place Julia:   5.574 μs (31 allocations: 21.64 KiB)
In place     Julia:   2.278 μs (6 allocations: 3.67 KiB)
Out of place GCC:     1.462 μs (0 allocations: 0 bytes)
Out of place Clang:   1.557 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (1,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 1}, 1}:
Out of place Julia:   3.465 μs (31 allocations: 10.86 KiB)
In place     Julia:   1.753 μs (6 allocations: 1.88 KiB)
Out of place GCC:     1.096 μs (0 allocations: 0 bytes)
Out of place Clang:   1.200 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (2,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 2}, 1}:
Out of place Julia:   4.855 μs (31 allocations: 14.61 KiB)
In place     Julia:   2.614 μs (6 allocations: 2.50 KiB)
Out of place GCC:     1.233 μs (0 allocations: 0 bytes)
Out of place Clang:   1.449 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (3,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 3}, 1}:
Out of place Julia:   5.429 μs (31 allocations: 19.77 KiB)
In place     Julia:   2.864 μs (6 allocations: 3.36 KiB)
Out of place GCC:     2.213 μs (0 allocations: 0 bytes)
Out of place Clang:   1.857 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (4,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 4}, 1}:
Out of place Julia:   6.645 μs (31 allocations: 23.98 KiB)
In place     Julia:   3.927 μs (6 allocations: 4.06 KiB)
Out of place GCC:     1.916 μs (0 allocations: 0 bytes)
Out of place Clang:   2.510 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (5,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 5}, 1}:
Out of place Julia:   9.649 μs (31 allocations: 29.61 KiB)
In place     Julia:   5.563 μs (6 allocations: 5.00 KiB)
Out of place GCC:     2.280 μs (0 allocations: 0 bytes)
Out of place Clang:   2.648 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (6,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 6}, 1}:
Out of place Julia:   11.080 μs (31 allocations: 31.95 KiB)
In place     Julia:   6.343 μs (6 allocations: 5.39 KiB)
Out of place GCC:     3.136 μs (0 allocations: 0 bytes)
Out of place Clang:   3.523 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (7,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 7}, 1}:
Out of place Julia:   10.686 μs (31 allocations: 36.64 KiB)
In place     Julia:   6.452 μs (6 allocations: 6.17 KiB)
Out of place GCC:     3.793 μs (0 allocations: 0 bytes)
Out of place Clang:   2.936 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (8,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 8}, 1}:
Out of place Julia:   10.118 μs (23 allocations: 29.30 KiB)
In place     Julia:   6.827 μs (5 allocations: 5.39 KiB)
Out of place GCC:     5.107 μs (0 allocations: 0 bytes)
Out of place Clang:   4.167 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (1,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 1}, 2}:
Out of place Julia:   5.042 μs (31 allocations: 14.61 KiB)
In place     Julia:   2.488 μs (6 allocations: 2.50 KiB)
Out of place GCC:     1.089 μs (0 allocations: 0 bytes)
Out of place Clang:   1.990 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (2,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 2}, 2}:
Out of place Julia:   6.110 μs (31 allocations: 21.64 KiB)
In place     Julia:   4.002 μs (6 allocations: 3.67 KiB)
Out of place GCC:     2.306 μs (0 allocations: 0 bytes)
Out of place Clang:   2.536 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (3,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 3}, 2}:
Out of place Julia:   9.039 μs (31 allocations: 29.61 KiB)
In place     Julia:   5.321 μs (6 allocations: 5.00 KiB)
Out of place GCC:     2.811 μs (0 allocations: 0 bytes)
Out of place Clang:   3.667 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (4,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 4}, 2}:
Out of place Julia:   10.231 μs (31 allocations: 34.30 KiB)
In place     Julia:   5.753 μs (6 allocations: 5.78 KiB)
Out of place GCC:     4.159 μs (0 allocations: 0 bytes)
Out of place Clang:   3.541 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (5,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 5}, 2}:
Out of place Julia:   12.040 μs (31 allocations: 39.92 KiB)
In place     Julia:   7.131 μs (6 allocations: 6.72 KiB)
Out of place GCC:     5.087 μs (0 allocations: 0 bytes)
Out of place Clang:   3.561 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (6,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 6}, 2}:
Out of place Julia:   13.872 μs (31 allocations: 47.89 KiB)
In place     Julia:   8.818 μs (6 allocations: 8.05 KiB)
Out of place GCC:     6.153 μs (0 allocations: 0 bytes)
Out of place Clang:   4.489 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (7,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 7}, 2}:
Out of place Julia:   14.698 μs (31 allocations: 53.05 KiB)
In place     Julia:   8.480 μs (6 allocations: 8.91 KiB)
Out of place GCC:     8.852 μs (0 allocations: 0 bytes)
Out of place Clang:   5.231 μs (0 allocations: 0 bytes)
Size 3 x 3, duals (n,j) = (8,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 8}, 2}:
Out of place Julia:   18.794 μs (31 allocations: 59.61 KiB)
In place     Julia:   11.215 μs (6 allocations: 10.00 KiB)
Out of place GCC:     18.737 μs (0 allocations: 0 bytes)
Out of place Clang:   7.655 μs (0 allocations: 0 bytes)
Size 4 x 4:
Size 4 x 4, duals (n,j) = (0,0), T = Float64:
Out of place Julia:   3.908 μs (31 allocations: 5.72 KiB)
In place     Julia:   2.185 μs (6 allocations: 1.03 KiB)
Out of place GCC:     701.653 ns (0 allocations: 0 bytes)
Out of place Clang:   813.314 ns (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (1,0), T = ForwardDiff.Dual{Nothing, Float64, 1}:
Out of place Julia:   6.170 μs (49 allocations: 129.28 KiB)
In place     Julia:   4.455 μs (24 allocations: 121.11 KiB)
Out of place GCC:     1.052 μs (0 allocations: 0 bytes)
Out of place Clang:   1.181 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (2,0), T = ForwardDiff.Dual{Nothing, Float64, 2}:
Out of place Julia:   7.498 μs (49 allocations: 139.31 KiB)
In place     Julia:   5.532 μs (24 allocations: 128.41 KiB)
Out of place GCC:     2.004 μs (0 allocations: 0 bytes)
Out of place Clang:   1.599 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (3,0), T = ForwardDiff.Dual{Nothing, Float64, 3}:
Out of place Julia:   6.786 μs (49 allocations: 140.06 KiB)
In place     Julia:   4.806 μs (24 allocations: 126.03 KiB)
Out of place GCC:     1.676 μs (0 allocations: 0 bytes)
Out of place Clang:   2.275 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (4,0), T = ForwardDiff.Dual{Nothing, Float64, 4}:
Out of place Julia:   8.107 μs (49 allocations: 143.25 KiB)
In place     Julia:   6.066 μs (24 allocations: 125.31 KiB)
Out of place GCC:     2.079 μs (0 allocations: 0 bytes)
Out of place Clang:   2.426 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (5,0), T = ForwardDiff.Dual{Nothing, Float64, 5}:
Out of place Julia:   8.849 μs (49 allocations: 154.69 KiB)
In place     Julia:   6.457 μs (24 allocations: 132.84 KiB)
Out of place GCC:     1.919 μs (0 allocations: 0 bytes)
Out of place Clang:   2.917 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (6,0), T = ForwardDiff.Dual{Nothing, Float64, 6}:
Out of place Julia:   8.456 μs (49 allocations: 142.22 KiB)
In place     Julia:   6.434 μs (24 allocations: 117.64 KiB)
Out of place GCC:     2.150 μs (0 allocations: 0 bytes)
Out of place Clang:   2.900 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (7,0), T = ForwardDiff.Dual{Nothing, Float64, 7}:
Out of place Julia:   8.607 μs (49 allocations: 141.56 KiB)
In place     Julia:   6.221 μs (24 allocations: 115.03 KiB)
Out of place GCC:     3.688 μs (0 allocations: 0 bytes)
Out of place Clang:   3.319 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (8,0), T = ForwardDiff.Dual{Nothing, Float64, 8}:
Out of place Julia:   10.395 μs (49 allocations: 159.75 KiB)
In place     Julia:   7.358 μs (24 allocations: 129.31 KiB)
Out of place GCC:     3.566 μs (0 allocations: 0 bytes)
Out of place Clang:   3.775 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (1,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 1}, 1}:
Out of place Julia:   7.799 μs (49 allocations: 140.06 KiB)
In place     Julia:   5.581 μs (24 allocations: 126.03 KiB)
Out of place GCC:     2.037 μs (0 allocations: 0 bytes)
Out of place Clang:   2.504 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (2,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 2}, 1}:
Out of place Julia:   10.340 μs (54 allocations: 177.83 KiB)
In place     Julia:   8.228 μs (27 allocations: 154.23 KiB)
Out of place GCC:     3.039 μs (0 allocations: 0 bytes)
Out of place Clang:   3.924 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (3,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 3}, 1}:
Out of place Julia:   10.140 μs (49 allocations: 141.56 KiB)
In place     Julia:   7.501 μs (24 allocations: 115.03 KiB)
Out of place GCC:     4.584 μs (0 allocations: 0 bytes)
Out of place Clang:   5.223 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (4,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 4}, 1}:
Out of place Julia:   13.489 μs (49 allocations: 155.53 KiB)
In place     Julia:   10.604 μs (24 allocations: 122.36 KiB)
Out of place GCC:     5.289 μs (0 allocations: 0 bytes)
Out of place Clang:   5.906 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (5,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 5}, 1}:
Out of place Julia:   24.785 μs (49 allocations: 162.00 KiB)
In place     Julia:   18.249 μs (24 allocations: 122.19 KiB)
Out of place GCC:     5.232 μs (0 allocations: 0 bytes)
Out of place Clang:   6.464 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (6,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 6}, 1}:
Out of place Julia:   29.147 μs (49 allocations: 167.72 KiB)
In place     Julia:   20.891 μs (24 allocations: 118.14 KiB)
Out of place GCC:     5.768 μs (0 allocations: 0 bytes)
Out of place Clang:   6.625 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (7,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 7}, 1}:
Out of place Julia:   32.911 μs (49 allocations: 186.94 KiB)
In place     Julia:   21.071 μs (24 allocations: 133.84 KiB)
Out of place GCC:     9.084 μs (0 allocations: 0 bytes)
Out of place Clang:   5.371 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (8,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 8}, 1}:
Out of place Julia:   36.359 μs (49 allocations: 180.94 KiB)
In place     Julia:   24.190 μs (24 allocations: 121.59 KiB)
Out of place GCC:     10.462 μs (0 allocations: 0 bytes)
Out of place Clang:   6.355 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (1,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 1}, 2}:
Out of place Julia:   11.241 μs (49 allocations: 154.69 KiB)
In place     Julia:   8.441 μs (24 allocations: 132.84 KiB)
Out of place GCC:     2.053 μs (0 allocations: 0 bytes)
Out of place Clang:   3.941 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (2,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 2}, 2}:
Out of place Julia:   12.270 μs (49 allocations: 159.75 KiB)
In place     Julia:   10.049 μs (24 allocations: 129.31 KiB)
Out of place GCC:     3.843 μs (0 allocations: 0 bytes)
Out of place Clang:   5.161 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (3,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 3}, 2}:
Out of place Julia:   24.985 μs (49 allocations: 162.00 KiB)
In place     Julia:   18.297 μs (24 allocations: 122.19 KiB)
Out of place GCC:     5.987 μs (0 allocations: 0 bytes)
Out of place Clang:   7.429 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (4,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 4}, 2}:
Out of place Julia:   32.740 μs (54 allocations: 198.45 KiB)
In place     Julia:   23.524 μs (27 allocations: 144.91 KiB)
Out of place GCC:     8.997 μs (0 allocations: 0 bytes)
Out of place Clang:   8.652 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (5,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 5}, 2}:
Out of place Julia:   39.668 μs (54 allocations: 203.95 KiB)
In place     Julia:   26.400 μs (27 allocations: 139.86 KiB)
Out of place GCC:     12.305 μs (0 allocations: 0 bytes)
Out of place Clang:   8.491 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (6,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 6}, 2}:
Out of place Julia:   42.949 μs (49 allocations: 210.19 KiB)
In place     Julia:   29.622 μs (24 allocations: 141.47 KiB)
Out of place GCC:     12.202 μs (0 allocations: 0 bytes)
Out of place Clang:   9.462 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (7,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 7}, 2}:
Out of place Julia:   40.717 μs (49 allocations: 205.69 KiB)
In place     Julia:   28.130 μs (24 allocations: 127.59 KiB)
Out of place GCC:     19.718 μs (0 allocations: 0 bytes)
Out of place Clang:   15.489 μs (0 allocations: 0 bytes)
Size 4 x 4, duals (n,j) = (8,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 8}, 2}:
Out of place Julia:   55.432 μs (49 allocations: 231.19 KiB)
In place     Julia:   35.517 μs (24 allocations: 143.72 KiB)
Out of place GCC:     42.086 μs (0 allocations: 0 bytes)
Out of place Clang:   15.685 μs (0 allocations: 0 bytes)
Size 5 x 5:
Size 5 x 5, duals (n,j) = (0,0), T = Float64:
Out of place Julia:   4.661 μs (33 allocations: 8.09 KiB)
In place     Julia:   2.660 μs (6 allocations: 1.34 KiB)
Out of place GCC:     1.334 μs (0 allocations: 0 bytes)
Out of place Clang:   1.636 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (1,0), T = ForwardDiff.Dual{Nothing, Float64, 1}:
Out of place Julia:   7.224 μs (49 allocations: 133.97 KiB)
In place     Julia:   5.575 μs (24 allocations: 121.89 KiB)
Out of place GCC:     2.154 μs (0 allocations: 0 bytes)
Out of place Clang:   2.021 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (2,0), T = ForwardDiff.Dual{Nothing, Float64, 2}:
Out of place Julia:   10.045 μs (54 allocations: 168.20 KiB)
In place     Julia:   8.476 μs (27 allocations: 150.52 KiB)
Out of place GCC:     3.438 μs (0 allocations: 0 bytes)
Out of place Clang:   2.447 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (3,0), T = ForwardDiff.Dual{Nothing, Float64, 3}:
Out of place Julia:   8.483 μs (49 allocations: 149.44 KiB)
In place     Julia:   6.465 μs (24 allocations: 127.59 KiB)
Out of place GCC:     3.247 μs (0 allocations: 0 bytes)
Out of place Clang:   4.187 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (4,0), T = ForwardDiff.Dual{Nothing, Float64, 4}:
Out of place Julia:   11.029 μs (49 allocations: 153.56 KiB)
In place     Julia:   8.302 μs (24 allocations: 127.03 KiB)
Out of place GCC:     2.857 μs (0 allocations: 0 bytes)
Out of place Clang:   3.742 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (5,0), T = ForwardDiff.Dual{Nothing, Float64, 5}:
Out of place Julia:   11.338 μs (49 allocations: 168.28 KiB)
In place     Julia:   8.955 μs (24 allocations: 135.11 KiB)
Out of place GCC:     3.597 μs (0 allocations: 0 bytes)
Out of place Clang:   5.231 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (6,0), T = ForwardDiff.Dual{Nothing, Float64, 6}:
Out of place Julia:   12.400 μs (49 allocations: 156.28 KiB)
In place     Julia:   9.708 μs (24 allocations: 119.98 KiB)
Out of place GCC:     4.066 μs (0 allocations: 0 bytes)
Out of place Clang:   6.289 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (7,0), T = ForwardDiff.Dual{Nothing, Float64, 7}:
Out of place Julia:   13.972 μs (54 allocations: 184.45 KiB)
In place     Julia:   10.360 μs (27 allocations: 136.81 KiB)
Out of place GCC:     8.914 μs (0 allocations: 0 bytes)
Out of place Clang:   10.110 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (8,0), T = ForwardDiff.Dual{Nothing, Float64, 8}:
Out of place Julia:   17.811 μs (54 allocations: 207.20 KiB)
In place     Julia:   13.230 μs (27 allocations: 153.66 KiB)
Out of place GCC:     5.307 μs (0 allocations: 0 bytes)
Out of place Clang:   8.181 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (1,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 1}, 1}:
Out of place Julia:   12.013 μs (49 allocations: 149.44 KiB)
In place     Julia:   8.332 μs (24 allocations: 127.59 KiB)
Out of place GCC:     3.985 μs (0 allocations: 0 bytes)
Out of place Clang:   4.698 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (2,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 2}, 1}:
Out of place Julia:   12.997 μs (49 allocations: 168.28 KiB)
In place     Julia:   10.657 μs (24 allocations: 135.11 KiB)
Out of place GCC:     4.833 μs (0 allocations: 0 bytes)
Out of place Clang:   5.092 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (3,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 3}, 1}:
Out of place Julia:   15.733 μs (49 allocations: 162.66 KiB)
In place     Julia:   11.989 μs (24 allocations: 118.55 KiB)
Out of place GCC:     8.027 μs (0 allocations: 0 bytes)
Out of place Clang:   10.125 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (4,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 4}, 1}:
Out of place Julia:   24.937 μs (49 allocations: 177.56 KiB)
In place     Julia:   17.294 μs (24 allocations: 126.03 KiB)
Out of place GCC:     11.251 μs (0 allocations: 0 bytes)
Out of place Clang:   14.287 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (5,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 5}, 1}:
Out of place Julia:   45.464 μs (49 allocations: 189.19 KiB)
In place     Julia:   31.954 μs (24 allocations: 126.72 KiB)
Out of place GCC:     10.017 μs (0 allocations: 0 bytes)
Out of place Clang:   14.021 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (6,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 6}, 1}:
Out of place Julia:   61.628 μs (54 allocations: 218.20 KiB)
In place     Julia:   43.070 μs (27 allocations: 140.61 KiB)
Out of place GCC:     13.213 μs (0 allocations: 0 bytes)
Out of place Clang:   16.624 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (7,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 7}, 1}:
Out of place Julia:   64.659 μs (54 allocations: 247.70 KiB)
In place     Julia:   41.288 μs (27 allocations: 159.98 KiB)
Out of place GCC:     18.889 μs (0 allocations: 0 bytes)
Out of place Clang:   12.790 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (8,1), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 8}, 1}:
Out of place Julia:   71.958 μs (54 allocations: 245.95 KiB)
In place     Julia:   47.445 μs (27 allocations: 146.42 KiB)
Out of place GCC:     18.153 μs (0 allocations: 0 bytes)
Out of place Clang:   13.455 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (1,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 1}, 2}:
Out of place Julia:   17.828 μs (54 allocations: 192.33 KiB)
In place     Julia:   12.698 μs (27 allocations: 156.50 KiB)
Out of place GCC:     4.239 μs (0 allocations: 0 bytes)
Out of place Clang:   7.982 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (2,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 2}, 2}:
Out of place Julia:   24.390 μs (54 allocations: 207.20 KiB)
In place     Julia:   20.341 μs (27 allocations: 153.66 KiB)
Out of place GCC:     10.394 μs (0 allocations: 0 bytes)
Out of place Clang:   12.492 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (3,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 3}, 2}:
Out of place Julia:   50.532 μs (49 allocations: 189.19 KiB)
In place     Julia:   34.037 μs (24 allocations: 126.72 KiB)
Out of place GCC:     9.486 μs (0 allocations: 0 bytes)
Out of place Clang:   12.016 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (4,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 4}, 2}:
Out of place Julia:   57.563 μs (54 allocations: 232.95 KiB)
In place     Julia:   42.820 μs (27 allocations: 150.30 KiB)
Out of place GCC:     18.795 μs (0 allocations: 0 bytes)
Out of place Clang:   18.334 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (5,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 5}, 2}:
Out of place Julia:   62.935 μs (54 allocations: 245.95 KiB)
In place     Julia:   45.514 μs (27 allocations: 146.42 KiB)
Out of place GCC:     25.645 μs (0 allocations: 0 bytes)
Out of place Clang:   19.533 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (6,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 6}, 2}:
Out of place Julia:   72.061 μs (54 allocations: 284.95 KiB)
In place     Julia:   55.123 μs (27 allocations: 170.23 KiB)
Out of place GCC:     27.572 μs (0 allocations: 0 bytes)
Out of place Clang:   20.254 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (7,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 7}, 2}:
Out of place Julia:   66.114 μs (49 allocations: 256.31 KiB)
In place     Julia:   50.023 μs (24 allocations: 136.03 KiB)
Out of place GCC:     37.676 μs (0 allocations: 0 bytes)
Out of place Clang:   30.046 μs (0 allocations: 0 bytes)
Size 5 x 5, duals (n,j) = (8,2), T = ForwardDiff.Dual{Nothing, ForwardDiff.Dual{Nothing, Float64, 8}, 2}:
Out of place Julia:   89.425 μs (49 allocations: 289.31 KiB)
In place     Julia:   61.827 μs (24 allocations: 153.41 KiB)
Out of place GCC:     68.325 μs (0 allocations: 0 bytes)
Out of place Clang:   26.657 μs (0 allocations: 0 bytes)
```
Especially when the array sizes are smaller (dimensions and dual sizes), the C++ implementions perform much better than Julia.
Clang -- which is powered by LLVM like Julia -- continues to outperform it into the larger sizes we care about/benchmark here. This is despite the much more naive C++ implementation.
