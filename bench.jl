using LinearAlgebra, Statistics, ForwardDiff, StaticArrays, BenchmarkTools, Test, ExponentialUtilities

const BENCH_OPNORMS = (66.0, 33.0, 22.0, 11.0, 6.0, 3.0, 2.0, 0.5, 0.03, 0.001)

"""
Generates one random matrix per opnorm.
All generated matrices are scale multiples of one another.
This is meant to exercise all code paths in the `expm` function.
"""
function randmatrices(n)
  A = randn(n, n)
  op = opnorm(A, 1)
  map(BENCH_OPNORMS) do x
    (x / op) .* A
  end
end

function expm(A::AbstractMatrix{S}) where {S}
  # omitted: matrix balancing, i.e., LAPACK.gebal!
  nA = opnorm(A, 1)
  ## For sufficiently small nA, use lower order Padé-Approximations
  if (nA <= 2.1)
    A2 = A * A
    if nA > 0.95
      U = @evalpoly(
        A2,
        S(8821612800) * I,
        S(302702400) * I,
        S(2162160) * I,
        S(3960) * I,
        S(1) * I
      )
      U = A * U
      V = @evalpoly(
        A2,
        S(17643225600) * I,
        S(2075673600) * I,
        S(30270240) * I,
        S(110880) * I,
        S(90) * I
      )
    elseif nA > 0.25
      U = @evalpoly(A2, S(8648640) * I, S(277200) * I, S(1512) * I, S(1) * I)
      U = A * U
      V =
        @evalpoly(A2, S(17297280) * I, S(1995840) * I, S(25200) * I, S(56) * I)
    elseif nA > 0.015
      U = @evalpoly(A2, S(15120) * I, S(420) * I, S(1) * I)
      U = A * U
      V = @evalpoly(A2, S(30240) * I, S(3360) * I, S(30) * I)
    else
      U = @evalpoly(A2, S(60) * I, S(1) * I)
      U = A * U
      V = @evalpoly(A2, S(120) * I, S(12) * I)
    end
    expA = (V - U) \ (V + U)
  else
    s = log2(nA / 5.4)               # power of 2 later reversed by squaring
    if s > 0
      si = ceil(Int, s)
      A = A / S(exp2(si))
    end

    A2 = A * A
    A4 = A2 * A2
    A6 = A2 * A4

    U =
      A6 * (A6 .+ S(16380) .* A4 .+ S(40840800) .* A2) .+ (
        S(33522128640) .* A6 .+ S(10559470521600) .* A4 .+
        S(1187353796428800) .* A2
      ) + S(32382376266240000) * I
    U = A * U
    V =
      A6 * (S(182) .* A6 .+ S(960960) .* A4 .+ S(1323241920) .* A2) .+ (
        S(670442572800) .* A6 .+ S(129060195264000) .* A4 +
        S(7771770303897600) .* A2
      ) + S(64764752532480000) * I
    expA = (V - U) \ (V + U)
    if s > 0            # squaring to reverse dividing by power of 2
      for _ = 1:si
        expA = expA * expA
      end
    end
  end
  expA
end

function _matevalpoly!(B, C, D, A::AbstractMatrix{T}, t::NTuple{1}) where {T}
  M = size(A, 1)
  te = T(last(t))
  @inbounds for n = 1:M, m = 1:M
    B[m, n] = ifelse(m == n, te, zero(te))
  end
  @inbounds for n = 1:M, k = 1:M, m = 1:M
    B[m, n] = muladd(A[m, k], D[k, n], B[m, n])
  end
  return B
end
function _matevalpoly!(B, C, D, A::AbstractMatrix{T}, t::NTuple) where {T}
  M = size(A, 1)
  te = T(last(t))
  @inbounds for n = 1:M, m = 1:M
    C[m, n] = ifelse(m == n, te, zero(te))
  end
  @inbounds for n = 1:M, k = 1:M, m = 1:M
    C[m, n] = muladd(A[m, k], D[k, n], C[m, n])
  end
  _matevalpoly!(B, D, C, A, Base.front(t))
end
function matevalpoly!(B, C, D, A::AbstractMatrix{T}, t::NTuple) where {T}
  t1 = Base.front(t)
  te = T(last(t))
  tp = T(last(t1))
  @inbounds for j in axes(A, 2), i in axes(A, 1)
    D[i, j] = muladd(A[i, j], te, ifelse(i == j, tp, zero(tp)))
  end
  _matevalpoly!(B, C, D, A, Base.front(t1))
end
function matevalpoly!(B, C, D, A::AbstractMatrix{T}, t::NTuple{2}) where {T}
  t1 = Base.front(t)
  te = T(last(t))
  tp = T(last(t1))
  @inbounds for j in axes(A, 2), i in axes(A, 1)
    B[i, j] = muladd(A[i, j], te, ifelse(i == j, tp, zero(tp)))
  end
  return B
end
ceillog2(x::Float64) =
  (reinterpret(Int, x) - 1) >> Base.significand_bits(Float64) - 1022

naive_matmul!(C, A, B) = @inbounds for n in axes(C, 2), m in axes(C, 1)
  Cmn = zero(eltype(C))
  for k in axes(A, 2)
    Cmn = muladd(A[m, k], B[k, n], Cmn)
  end
  C[m, n] = Cmn
end
naive_matmuladd!(C, A, B) = @inbounds for n in axes(C, 2), m in axes(C, 1)
  Cmn = zero(eltype(C))
  for k in axes(A, 2)
    Cmn = muladd(A[m, k], B[k, n], Cmn)
  end
  C[m, n] += Cmn
end
_deval(x) = x
_deval(x::ForwardDiff.Dual) = _deval(ForwardDiff.value(x))

function opnorm1(A)
  n = _deval(zero(eltype(A)))
  @inbounds for j in axes(A, 2)
    s = _deval(zero(eltype(A)))
    @fastmath for i in axes(A, 1)
      s += abs(_deval(A[i, j]))
    end
    n = max(n, s)
  end
  return n
end

function expm!(
  Z::AbstractMatrix,
  A::AbstractMatrix,
  matmul! = naive_matmul!,
  matmuladd! = naive_matmuladd!
)
  # omitted: matrix balancing, i.e., LAPACK.gebal!
  # nA = maximum(sum(abs.(A); dims=Val(1)))    # marginally more performant than norm(A, 1)
  nA = opnorm1(A)
  N = LinearAlgebra.checksquare(A)
  # B and C are temporaries
  ## For sufficiently small nA, use lower order Padé-Approximations
  A2 = similar(A)
  if nA <= 2.1
    matmul!(A2, A, A)
    U = Z
    V = similar(A)
    if nA <= 0.015
      matevalpoly!(V, nothing, nothing, A2, (60, 1))
      matmul!(U, A, V)
      matevalpoly!(V, nothing, nothing, A2, (120, 12))
    else
      B = similar(A)
      if nA <= 0.25
        matevalpoly!(V, nothing, U, A2, (15120, 420, 1))
        matmul!(U, A, V)
        matevalpoly!(V, nothing, B, A2, (30240, 3360, 30))
      else
        C = similar(A)
        if nA <= 0.95
          matevalpoly!(V, C, U, A2, (8648640, 277200, 1512, 1))
          matmul!(U, A, V)
          matevalpoly!(V, B, C, A2, (17297280, 1995840, 25200, 56))
        else
          matevalpoly!(V, C, U, A2, (8821612800, 302702400, 2162160, 3960, 1))
          matmul!(U, A, V)
          matevalpoly!(
            V,
            B,
            C,
            A2,
            (17643225600, 2075673600, 30270240, 110880, 90)
          )
        end
      end
    end
    @inbounds for m = 1:N*N
      u = U[m]
      v = V[m]
      U[m] = v + u
      V[m] = v - u
    end
    ldiv!(lu!(V), U)
    expA = U
    # expA = (V - U) \ (V + U)
  else
    si = ceillog2(nA / 5.4)               # power of 2 later reversed by squaring
    if si > 0
      A = A / exp2(si)
    end
    matmul!(A2, A, A)
    A4 = similar(A)
    A6 = similar(A)
    matmul!(A4, A2, A2)
    matmul!(A6, A2, A4)

    U = Z
    B = zero(A)
    @inbounds for m = 1:N
      B[m, m] = 32382376266240000
    end
    @inbounds for m = 1:N*N
      a6 = A6[m]
      a4 = A4[m]
      a2 = A2[m]
      B[m] = muladd(
        33522128640,
        a6,
        muladd(10559470521600, a4, muladd(1187353796428800, a2, B[m]))
      )
      U[m] = muladd(16380, a4, muladd(40840800, a2, a6))
    end
    matmuladd!(B, A6, U)
    matmul!(U, A, B)

    V = si > 0 ? fill!(A, 0) : zero(A)
    @inbounds for m = 1:N
      V[m, m] = 64764752532480000
    end
    @inbounds for m = 1:N*N
      a6 = A6[m]
      a4 = A4[m]
      a2 = A2[m]
      B[m] = muladd(182, a6, muladd(960960, a4, 1323241920 * a2))
      V[m] = muladd(
        670442572800,
        a6,
        muladd(129060195264000, a4, muladd(7771770303897600, a2, V[m]))
      )
    end
    matmuladd!(V, A6, B)

    @inbounds for m = 1:N*N
      u = U[m]
      v = V[m]
      U[m] = v + u
      V[m] = v - u
    end
    ldiv!(lu!(V), U)
    expA = U
    # expA = (V - U) \ (V + U)

    if si > 0            # squaring to reverse dividing by power of 2
      for _ = 1:si
        matmul!(V, expA, expA)
        expA, V = V, expA
      end
      if Z !== expA
        copyto!(Z, expA)
        expA = Z
      end
    end
  end
  expA
end
expm_bad!(Z, A) = expm!(Z, A, mul!, (C, A, B) -> mul!(C, A, B, 1.0, 1.0))



d(x, n) = ForwardDiff.Dual(x, ntuple(_ -> randn(), n))
function dualify(A, n, j)
  if n > 0
    A = d.(A, n)
    if (j > 0)
      A = d.(A, j)
    end
  end
  A
end
struct ForEach{A,B,F}
  f::F
  a::A
  b::B
end
ForEach(f, b) = ForEach(f, nothing, b)
(f::ForEach)() = foreach(Base.Fix1(f.f, f.a), f.b)
(f::ForEach{Nothing})() = foreach(f.f, f.b)


function localwork!(f::F, acc::Ptr{T}, As::NTuple{<:Any,<:AbstractMatrix{T}}, r, i, nt) where {F,T}
    N = length(r)
    start = div(N * (i - 1), nt) + 1
    stop = div(N * i, nt)
    x::T = zero(T)
    B = similar(first(As))
    C = similar(B)
    for A = As
        for j = start:stop
            B .= r[j] .* A
            f(C, B)
            x += sum(C)
        end
    end
    unsafe_store!(acc, x)
end

function threadedwork!(f::F, As::NTuple{<:Any,<:AbstractMatrix{T}}, r::AbstractArray) where {T,F}
  nt = min(Threads.nthreads(), length(r))
    if nt <= 1
        s = MMatrix{1,1,T}(undef)
        GC.@preserve s localwork!(f, pointer(s), As, r, 1, 1)
        return (s[1,1])::T;
    end
    x = cld(64, sizeof(T))
    acc = Matrix{T}(undef, x, nt)
    GC.@preserve acc begin
        p = pointer(acc)
        xst = sizeof(T)*x
        Threads.@threads for i = 1:nt
            localwork!(f, p + xst*(i-1), As, r, i, nt)
        end
    end
    return sum(@view(acc[1,:]))::T
end
function isoutofplace(f, ::Val{NTuple{N,A}}) where {N,A}
    Base.promote_op(f, A) !== Union{}
end
struct ThreadedForEach{A,F}
  f::F
  a::A
end
ThreadedForEach(f, _, b) = ThreadedForEach(f, b)
function (f::ThreadedForEach{A})() where {A}
    r = 0.1:0.01:10.0
    if isoutofplace(f.f, Val(A))
        threadedwork!((x,y) -> copyto!(x, f.f(y)), f.a, r)
    else
        threadedwork!(f.f, f.a, r)
    end
end



const libMatrixExp = joinpath(@__DIR__, "buildgcc/libMatrixExp.so")
const libMatrixExpClang = joinpath(@__DIR__, "buildclang/libMatrixExp.so")
for (lib, cc) in ((:libMatrixExp, :gcc), (:libMatrixExpClang, :clang))
  j = Symbol(cc, :expm!)
    @eval $j(A::Matrix{Float64}, reps::Int) = @ccall $lib.food(
    A::Ptr{Float64},
      size(A, 1)::Clong,
      reps::Clong
  )::Float64

  @eval $j(B::Matrix{Float64}, A::Matrix{Float64}) = @ccall $lib.expmf64(
    B::Ptr{Float64},
    A::Ptr{Float64},
    size(A, 1)::Clong
  )::Nothing
  for n = 1:8
    sym = Symbol(:expmf64d, n)
    @eval $j(
      B::Matrix{ForwardDiff.Dual{T,Float64,$n}},
      A::Matrix{ForwardDiff.Dual{T,Float64,$n}}
    ) where {T} = @ccall $lib.$sym(
      B::Ptr{Float64},
      A::Ptr{Float64},
      size(A, 1)::Clong
    )::Nothing
    for i = 1:2
      sym = Symbol(:expmf64d, n, :d, i)
      @eval $j(
        B::Matrix{ForwardDiff.Dual{T1,ForwardDiff.Dual{T0,Float64,$n},$i}},
        A::Matrix{ForwardDiff.Dual{T1,ForwardDiff.Dual{T0,Float64,$n},$i}}
      ) where {T0,T1} = @ccall $lib.$sym(
        B::Ptr{Float64},
        A::Ptr{Float64},
        size(A, 1)::Clong
      )::Nothing
    end
  end
end

# macros are too awkward to work with, so we use a function
# mean times are much better for benchmarking than minimum
# whenever you have a function that allocates
function bmean(f)
  b = @benchmark $f()
  m = BenchmarkTools.mean(b)
  a = BenchmarkTools.allocs(m)
  println(
    "  ",
    (BenchmarkTools).prettytime((BenchmarkTools).time(m)),
    " (",
    a,
    " allocation",
    (a == 1 ? "" : "s"),
    ": ",
    (BenchmarkTools).prettymemory((BenchmarkTools).memory(m)),
    ")"
  )
end
function exputils!(B,A)
  exponential!(copyto!(B,A))
  return B
end

#=
struct Closure{F,A}
  f::F
  a::A
end
Closure(f, a, b...) = Closure(f, (a, b...))
(c::Closure)() = c.f(c.a...)
=#
runbenchmarks=true
const COMPILE_TIMES = zeros(Int, 6)
for l = 2:5 # silly to start with 1x1 matrices (should be special cased in `exp` impl)
  println("Size $l x $l:")
  for j = 0:2
    for n = (j!=0):8
      As = map(x -> dualify(x, n, j), randmatrices(l))
      B = similar(first(As))
      C = similar(B)
      D = similar(B)
      F = similar(B)
      G = similar(B)
      for A in As
        Base.cumulative_compile_timing(true)
        tgcc_start = Base.cumulative_compile_time_ns()
        gccexpm!(B, A)
        Base.cumulative_compile_timing(false)
        tgcc = Base.cumulative_compile_time_ns()[1] - tgcc_start[1]
        Base.cumulative_compile_timing(true)
        tclang_start = Base.cumulative_compile_time_ns()
        clangexpm!(D, A)
        Base.cumulative_compile_timing(false)
        tclang = Base.cumulative_compile_time_ns()[1] - tclang_start[1]
        Base.cumulative_compile_timing(true)
        t_start = Base.cumulative_compile_time_ns()
        expm!(C, A)
        Base.cumulative_compile_timing(false)
        t = Base.cumulative_compile_time_ns()[1] - t_start[1]
        Base.cumulative_compile_timing(true)
        t_start = Base.cumulative_compile_time_ns()
        expm_bad!(F, A)
        Base.cumulative_compile_timing(false)
        tbasemul = Base.cumulative_compile_time_ns()[1] - t_start[1]
        Base.cumulative_compile_timing(true)
        t0_start = Base.cumulative_compile_time_ns()
        E = expm(A)
        Base.cumulative_compile_timing(false)
        t0 = Base.cumulative_compile_time_ns()[1] - t0_start[1]
        Base.cumulative_compile_timing(true)
        t0_start = Base.cumulative_compile_time_ns()
        exputils!(G, A)
        Base.cumulative_compile_timing(false)
        t0_exputils = Base.cumulative_compile_time_ns()[1] - t0_start[1]
        COMPILE_TIMES[1] += t0
        COMPILE_TIMES[2] += t
        COMPILE_TIMES[3] += tgcc
        COMPILE_TIMES[4] += tclang
        COMPILE_TIMES[5] += tbasemul
        COMPILE_TIMES[6] += t0_exputils
        @test reinterpret(Float64, C) ≈
              reinterpret(Float64, B) ≈
              reinterpret(Float64, D) ≈
              reinterpret(Float64, E) ≈
              reinterpret(Float64, F) ≈
              reinterpret(Float64, G)
      end
        if runbenchmarks
            FE = Threads.nthreads() > 1 ? ThreadedForEach : ForEach
      println("Size $l x $l, duals (n,j) = ($n,$j), T = $(eltype(B)):")
      print("Out of place Julia: ")
      bmean(FE(expm, As))
      print("In place     Julia: ")
      bmean(FE(expm!, B, As))
      print("Using `mul!`-Julia: ")
      bmean(FE(expm_bad!, B, As))
      print("In place exp utils: ")
      bmean(FE(exputils!, B, As))
      print("Out of place GCC:   ")
      bmean(FE(gccexpm!, B, As))
      print("Out of place Clang: ")
      bmean(FE(clangexpm!, B, As))
      end
    end
  end
end
println(
  "Total compile times: \nOut of place Julia: ",
  (BenchmarkTools).prettytime(COMPILE_TIMES[1]),
  "\nIn place     Julia: ",
  (BenchmarkTools).prettytime(COMPILE_TIMES[2]),
  "\nUsing `mul!` Julia: ",
  (BenchmarkTools).prettytime(COMPILE_TIMES[5]),
  "\n`ExponentialUtilities.jl`:",
  (BenchmarkTools).prettytime(COMPILE_TIMES[6]),
  "\nOut of place GCC:   ",
  (BenchmarkTools).prettytime(COMPILE_TIMES[3]),
  "\nOut of place Clang: ",
  (BenchmarkTools).prettytime(COMPILE_TIMES[4]),
  "\n"
)


