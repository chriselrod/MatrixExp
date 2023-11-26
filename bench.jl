
using Base.Threads, ForwardDiff, ExponentialUtilities

# utilities for dealing with nested tuples
# we use nested instead of flat tuples to avoid heuristics
# that avoid specializing on long tuples
rmap(f, ::Tuple{}) = ()
rmap(f::F, x::Tuple) where {F} = map(f, x)
rmap(f::F, x::Tuple{Vararg{Tuple,K}}) where {F,K} = map(Base.Fix1(rmap, f), x)
rmap(f, ::Tuple{}, ::Tuple{}) = ()
rmap(f::F, x::Tuple, y::Tuple) where {F} = map(f, x, y)
rmap(f::F, x::Tuple{Vararg{Tuple,K}}, y::Tuple{Vararg{Tuple,K}}) where {F,K} =
  map((a, b) -> rmap(f, a, b), x, y)

# rmaptnum applies `f` to a tuple of non-tuples
rmaptnum(f, ::Tuple{}) = ()
rmaptnum(f::F, x::Tuple{Vararg{Tuple{Vararg}}}) where {F} = map(f, x)
rmaptnum(f::F, x::Tuple{Vararg{Tuple{Vararg{Tuple}}}}) where {F} =
  map(Base.Fix1(rmaptnum, f), x)

struct SumScaleMatrixExponential{F}
  f!::F
  s::Float64
end
function (sme::SumScaleMatrixExponential)(B, A)
  for i in eachindex(B, A)
    B[i] = sme.s * A[i]
  end
  sme.f!(B)
  return sum(B)
end

function do_singlethreaded_work!(f!::F, Bs, As, r) where {F}
  ret = rmaptnum(zero ∘ eltype ∘ eltype, Bs)
  for s in r
    incr = rmap(SumScaleMatrixExponential(f!, s), Bs, As)
    ret = rmap(+, ret, rmaptnum(sum, incr))
  end
  return ret
end

function do_multithreaded_work!(f!::F, Bs, As, r) where {F}
  nt = Threads.nthreads(:default)
  nt > 1 || return do_singlethreaded_work!(f!, Bs, As, r)
  tasks = Vector{Task}(undef, nt)
  for n = 1:nt
    subrange = r[n:nt:end] # stride to balance opnorms across threads
    Bsc = n == nt ? Bs : rmap(copy, Bs)
    tasks[n] = Threads.@spawn do_singlethreaded_work!($f!, $Bsc, $As, $subrange)
  end
  _ret = rmaptnum(zero ∘ eltype ∘ eltype, Bs)
  ret::typeof(_ret) = Threads.fetch(tasks[1])
  for n = 2:nt
    ret = rmap(+, ret, Threads.fetch(tasks[n]))
  end
  return ret
end

max_size = 5
d(x, n) = ForwardDiff.Dual(x, ntuple(_ -> randn(), n))
function dualify(A, n, j)
  n == 0 && return A
  j == 0 ? d.(A, n) : d.(d.(A, n), j)
end
randdual(n, dinner, douter) = dualify(rand(n, n), dinner, douter)
As = map((0, 1, 2)) do dout # outer dual
  map(ntuple(identity, Val(9)) .- 1) do din # inner dual
    map(ntuple(identity, Val(max_size - 1)) .+ 1) do n # matrix size
      randdual(n, din, dout)
    end
  end
end;
Bs = rmap(similar, As);

testrange = range(0.001; stop = 6.0, length = 1_000)
# res = @time @eval do_multithreaded_work!(exponential!, Bs, As, testrange);
# @time do_multithreaded_work!(exponential!, Bs, As, testrange);

const libExpMatGCC = joinpath(@__DIR__, "buildgcc/libMatrixExp.so")
const libExpMatClang = joinpath(@__DIR__, "buildclang/libMatrixExp.so")
for (lib, cc) in ((:libExpMatGCC, :gcc), (:libExpMatClang, :clang))
  j = Symbol(cc, :expm!)

  @eval $j(A::Matrix{Float64}) =
    @ccall $lib.expmf64(A::Ptr{Float64}, size(A, 1)::Clong)::Nothing
  for n = 1:8
    sym = Symbol(:expmf64d, n)
    @eval $j(A::Matrix{ForwardDiff.Dual{T,Float64,$n}}) where {T} =
      @ccall $lib.$sym(A::Ptr{Float64}, size(A, 1)::Clong)::Nothing
    for i = 1:2
      sym = Symbol(:expmf64d, n, :d, i)
      @eval $j(
        A::Matrix{ForwardDiff.Dual{T1,ForwardDiff.Dual{T0,Float64,$n},$i}}
      ) where {T0,T1} =
        @ccall $lib.$sym(A::Ptr{Float64}, size(A, 1)::Clong)::Nothing
    end
  end
end

A4_7 = randdual(4, 7, 0);
B4_7 = similar(A4_7);
C4_7 = similar(A4_7);

clangexpm!(copyto!(C4_7, A4_7));
C4_7;
exponential!(copyto!(B4_7, A4_7))
reinterpret(Float64, B4_7) ≈ reinterpret(Float64, C4_7)

@testset begin
  for o = 0:2, i = 1:8
    @show i, o
    A = randdual(4, i, o)
    B = similar(A)
    C = similar(A)
    clangexpm!(copyto!(C, A))
    exponential!(copyto!(B, A))
    @test reinterpret(Float64, B) ≈ reinterpret(Float64, C)
  end
end

rescpp = @time @eval do_multithreaded_work!(clangexpm!, Bs, As, testrange);
approxd(x, y) = isapprox(x, y)
function approxd(x::ForwardDiff.Dual, y::ForwardDiff.Dual)
  approxd(x.value, y.value) && approxd(Tuple(x.partials), Tuple(y.partials))
end
approxd(x::Tuple, y::Tuple) = all(map(approxd, x, y))
@assert approxd(res, rescpp)

@time do_multithreaded_work!(clangexpm!, Bs, As, testrange);

using LinearAlgebra
# My C++ `opnorm` implementation only looks at Dual's values
# so lets just go ahead and copy that optimization here.
_deval(x) = x
_deval(x::ForwardDiff.Dual) = _deval(ForwardDiff.value(x))
function opnorm1(A)
  n = _deval(zero(eltype(A)))
  @inbounds for j in axes(A, 2)
    s = _deval(zero(eltype(A)))
    @simd for i in axes(A, 1)
      s += abs(_deval(A[i, j]))
    end
    n = max(n, s)
  end
  return n
end

# Let's also immediately implement our own `evalpoly` to cut down
# allocations. `B` contains the result, `A` is a temporary
# that we reuse (following the same approach as in C++)
function matevalpoly!(B, A, C, t::NTuple, N)
  @assert N > 1
  if isodd(N)
    A, B = B, A
  end
  B .= t[1] .* C
  @view(B[diagind(B)]) .+= t[2]
  for n = 3:N
    A, B = B, A
    mul!(B, A, C)
    @view(B[diagind(B)]) .+= t[n]
  end
end

log2ceil(x::Float64) =
  (reinterpret(Int, x) - 1) >> Base.significand_bits(Float64) - 1022

function expm!(A::AbstractMatrix)
  N = size(A, 1)
  s = 0
  N == size(A, 2) || error("Matrix is not square.")
  A2 = A * A
  U = similar(A)
  if (nA = opnorm1(A); nA <= 0.015)
    mul!(U, A, A2 + 60.0I)
    # broadcasting doesn't work with `I`
    A .= 12.0 .* A2
    @view(A[diagind(A)]) .+= 120.0
  else
    B = similar(A)
    if nA <= 2.1
      # No need to specialize on different tuple sizes
      if nA > 0.95
        p0 = (1.0, 3960.0, 2162160.0, 302702400.0, 8821612800.0)
        p1 = (90.0, 110880.0, 3.027024e7, 2.0756736e9, 1.76432256e10)
        N = 5
      elseif nA > 0.25
        p0 = (1.0, 1512.0, 277200.0, 8.64864e6, 0.0)
        p1 = (56.0, 25200.0, 1.99584e6, 1.729728e7, 0.0)
        N = 4
      else
        p0 = (1.0, 420.0, 15120.0, 0.0, 0.0)
        p1 = (30.0, 3360.0, 30240.0, 0.0, 0.0)
        N = 3
      end
      matevalpoly!(B, U, A2, p0, N)
      mul!(U, A, B)
      matevalpoly!(A, B, A2, p1, N)
    else
      s = nA > 5.4 ? log2ceil(nA / 5.4) : 0
      t = (s > 0) ? exp2(-s) : 0.0
      (s > 0) && (A2 .*= t * t)
      A4 = A2 * A2
      A6 = A2 * A4
      # we use `U` as a temporary here that we didn't
      # need in the C++ code for the estrin-style polynomial
      # evaluation. Thankfully we don't need another allocation!
      @. U = A6 + 16380 * A4 + 40840800 * A2
      mul!(B, A6, U)
      @. B += 33522128640 * A6 + 10559470521600 * A4 + 1187353796428800 * A2
      @view(B[diagind(B)]) .+= 32382376266240000
      mul!(U, A, B)
      # Like in the C++ code, we swap A and U `s` times at the end
      # so if `s` is odd, we pre-swap to end with the original
      # `A` being filled by the answer
      if isodd(s)
        A .= U .* t
        A, U = U, A
      elseif s > 0
        U .*= t
      end
      # we use `B` as a temporary here we didn't
      # need in the C++ code
      @. B = 182 * A6 + 960960 * A4 + 1323241920 * A2
      mul!(A, A6, B)
      @. A += 670442572800 * A6 + 129060195264000 * A4 + 7771770303897600 * A2
      @view(A[diagind(A)]) .+= 64764752532480000
    end
  end
  @inbounds for i in eachindex(A, U)
    A[i], U[i] = A[i] + U[i], A[i] - U[i]
  end
  ldiv!(lu!(U), A)
  for _ = 1:s
    mul!(U, A, A)
    A, U = U, A
  end
end

resexpm = @time @eval do_multithreaded_work!(expm!, Bs, As, testrange);
@assert approxd(res, resexpm)

@time do_multithreaded_work!(expm!, Bs, As, testrange);

function mulreduceinnerloop!(C, A, B)
  AxM = axes(A, 1)
  AxK = axes(A, 2) # we use two `axes` calls in case of `AbstractVector`
  BxK = axes(B, 1)
  BxN = axes(B, 2)
  CxM = axes(C, 1)
  CxN = axes(C, 2)
  if AxM != CxM
    throw(
      DimensionMismatch(
        lazy"matrix A has axes ($AxM,$AxK), matrix C has axes ($CxM,$CxN)"
      )
    )
  end
  if AxK != BxK
    throw(
      DimensionMismatch(
        lazy"matrix A has axes ($AxM,$AxK), matrix B has axes ($BxK,$CxN)"
      )
    )
  end
  if BxN != CxN
    throw(
      DimensionMismatch(
        lazy"matrix B has axes ($BxK,$BxN), matrix C has axes ($CxM,$CxN)"
      )
    )
  end
  @inbounds for n in BxN, m in AxM
    Cmn = zero(eltype(C))
    for k in BxK
      Cmn = muladd(A[m, k], B[k, n], Cmn)
    end
    C[m, n] = Cmn
  end
  return C
end
function matevalpoly_custommul!(B, A, C, t::NTuple, N)
  @assert N > 1
  if isodd(N)
    A, B = B, A
  end
  B .= t[1] .* C
  @view(B[diagind(B)]) .+= t[2]
  for n = 3:N
    A, B = B, A
    mulreduceinnerloop!(B, A, C)
    @view(B[diagind(B)]) .+= t[n]
  end
end

function expm_custommul!(A::AbstractMatrix)
  N = size(A, 1)
  s = 0
  N == size(A, 2) || error("Matrix is not square.")
  A2 = mulreduceinnerloop!(similar(A), A, A)
  U = similar(A)
  if (nA = opnorm1(A); nA <= 0.015)
    mulreduceinnerloop!(U, A, A2 + 60.0I)
    # broadcasting doesn't work with `I`
    A .= 12.0 .* A2
    @view(A[diagind(A)]) .+= 120.0
  else
    B = similar(A)
    if nA <= 2.1
      # No need to specialize on different tuple sizes
      if nA > 0.95
        p0 = (1.0, 3960.0, 2162160.0, 302702400.0, 8821612800.0)
        p1 = (90.0, 110880.0, 3.027024e7, 2.0756736e9, 1.76432256e10)
        N = 5
      elseif nA > 0.25
        p0 = (1.0, 1512.0, 277200.0, 8.64864e6, 0.0)
        p1 = (56.0, 25200.0, 1.99584e6, 1.729728e7, 0.0)
        N = 4
      else
        p0 = (1.0, 420.0, 15120.0, 0.0, 0.0)
        p1 = (30.0, 3360.0, 30240.0, 0.0, 0.0)
        N = 3
      end
      matevalpoly_custommul!(B, U, A2, p0, N)
      mulreduceinnerloop!(U, A, B)
      matevalpoly_custommul!(A, B, A2, p1, N)
    else
      s = nA > 5.4 ? log2ceil(nA / 5.4) : 0
      t = (s > 0) ? exp2(-s) : 0.0
      (s > 0) && (A2 .*= t * t)
      A4 = mulreduceinnerloop!(similar(A), A2, A2)
      A6 = mulreduceinnerloop!(similar(A), A2, A4)
      # we use `U` as a temporary here that we didn't
      # need in the C++ code for the estrin-style polynomial
      # evaluation. Thankfully we don't need another allocation!
      @. U = A6 + 16380 * A4 + 40840800 * A2
      mulreduceinnerloop!(B, A6, U)
      @. B += 33522128640 * A6 + 10559470521600 * A4 + 1187353796428800 * A2
      @view(B[diagind(B)]) .+= 32382376266240000
      mulreduceinnerloop!(U, A, B)
      # Like in the C++ code, we swap A and U `s` times at the end
      # so if `s` is odd, we pre-swap to end with the original
      # `A` being filled by the answer
      if isodd(s)
        A .= U .* t
        A, U = U, A
      elseif s > 0
        U .*= t
      end
      # we use `B` as a temporary here we didn't
      # need in the C++ code
      @. B = 182 * A6 + 960960 * A4 + 1323241920 * A2
      mulreduceinnerloop!(A, A6, B)
      @. A += 670442572800 * A6 + 129060195264000 * A4 + 7771770303897600 * A2
      @view(A[diagind(A)]) .+= 64764752532480000
    end
  end
  @inbounds for i in eachindex(A, U)
    A[i], U[i] = A[i] + U[i], A[i] - U[i]
  end
  ldiv!(lu!(U), A)
  for _ = 1:s
    mulreduceinnerloop!(U, A, A)
    A, U = U, A
  end
end

resexpmcm =
  @time @eval do_multithreaded_work!(expm_custommul!, Bs, As, testrange);
@assert approxd(res, resexpmcm)

t_expm_custommul =
  @elapsed do_multithreaded_work!(expm_custommul!, Bs, As, testrange)

function tlssimilar(A)
  ret = get!(task_local_storage(), A) do
    ntuple(_ -> similar(A), Val(5))
  end
  return ret::NTuple{5,typeof(A)}
end

function expm_tls!(A::AbstractMatrix)
  N = size(A, 1)
  s = 0
  N == size(A, 2) || error("Matrix is not square.")
  U, B, A2, A4, A6 = tlssimilar(A)
  mulreduceinnerloop!(A2, A, A)
  if (nA = opnorm1(A); nA <= 0.015)
    B .= A2
    @view(B[diagind(B)]) .+= 60.0
    mulreduceinnerloop!(U, A, B)
    # broadcasting doesn't work with `I`
    A .= 12.0 .* A2
    @view(A[diagind(A)]) .+= 120.0
  else
    if nA <= 2.1
      # No need to specialize on different tuple sizes
      if nA > 0.95
        p0 = (1.0, 3960.0, 2162160.0, 302702400.0, 8821612800.0)
        p1 = (90.0, 110880.0, 3.027024e7, 2.0756736e9, 1.76432256e10)
        N = 5
      elseif nA > 0.25
        p0 = (1.0, 1512.0, 277200.0, 8.64864e6, 0.0)
        p1 = (56.0, 25200.0, 1.99584e6, 1.729728e7, 0.0)
        N = 4
      else
        p0 = (1.0, 420.0, 15120.0, 0.0, 0.0)
        p1 = (30.0, 3360.0, 30240.0, 0.0, 0.0)
        N = 3
      end
      matevalpoly_custommul!(B, U, A2, p0, N)
      mulreduceinnerloop!(U, A, B)
      matevalpoly_custommul!(A, B, A2, p1, N)
    else
      s = nA > 5.4 ? log2ceil(nA / 5.4) : 0
      t = (s > 0) ? exp2(-s) : 0.0
      (s > 0) && (A2 .*= t * t)
      mulreduceinnerloop!(A4, A2, A2)
      mulreduceinnerloop!(A6, A2, A4)
      # we use `U` as a temporary here that we didn't
      # need in the C++ code for the estrin-style polynomial
      # evaluation. Thankfully we don't need another allocation!
      @. U = A6 + 16380 * A4 + 40840800 * A2
      mulreduceinnerloop!(B, A6, U)
      @. B += 33522128640 * A6 + 10559470521600 * A4 + 1187353796428800 * A2
      @view(B[diagind(B)]) .+= 32382376266240000
      mulreduceinnerloop!(U, A, B)
      # Like in the C++ code, we swap A and U `s` times at the end
      # so if `s` is odd, we pre-swap to end with the original
      # `A` being filled by the answer
      if isodd(s)
        A .= U .* t
        A, U = U, A
      elseif s > 0
        U .*= t
      end
      # we use `B` as a temporary here we didn't
      # need in the C++ code
      @. B = 182 * A6 + 960960 * A4 + 1323241920 * A2
      mulreduceinnerloop!(A, A6, B)
      @. A += 670442572800 * A6 + 129060195264000 * A4 + 7771770303897600 * A2
      @view(A[diagind(A)]) .+= 64764752532480000
    end
  end
  @inbounds for i in eachindex(A, U)
    A[i], U[i] = A[i] + U[i], A[i] - U[i]
  end
  ldiv!(lu!(U), A)
  for _ = 1:s
    mulreduceinnerloop!(U, A, A)
    A, U = U, A
  end
end

restls = @time @eval do_multithreaded_work!(expm_tls!, Bs, As, testrange);
@assert approxd(res, restls)
@time do_multithreaded_work!(expm_tls!, Bs, As, testrange);

testrange = range(0.001; stop = 6.0, length = 30_000)
@time do_multithreaded_work!(gccexpm!, Bs, As, testrange);
@time do_multithreaded_work!(gccexpm!, Bs, As, testrange);
@time do_multithreaded_work!(clangexpm!, Bs, As, testrange);
@time do_multithreaded_work!(clangexpm!, Bs, As, testrange);
@time do_multithreaded_work!(expm_tls!, Bs, As, testrange);
@time do_multithreaded_work!(expm_tls!, Bs, As, testrange);
testrange = range(0.001; stop = 6.0, length = 100_000)
@time do_multithreaded_work!(gccexpm!, Bs, As, testrange);
@time do_multithreaded_work!(gccexpm!, Bs, As, testrange);
@time do_multithreaded_work!(clangexpm!, Bs, As, testrange);
@time do_multithreaded_work!(clangexpm!, Bs, As, testrange);
@time do_multithreaded_work!(expm_tls!, Bs, As, testrange);
@time do_multithreaded_work!(expm_tls!, Bs, As, testrange);

# compared to current version, the fastest version did not have
# # `[[gnu::always_inline]]` on `Dual` ops and also used 256-bit vectors.
# Still experimenting, may revert to that. Best c++ results:
# julia> testrange = range(0.001; stop = 6.0, length = 100_000)
# 0.001:5.999059990599906e-5:6.0
# julia> @time do_multithreaded_work!(clangexpm!, Bs, As, testrange);
#   2.553349 seconds (603.17 k allocations: 1.394 GiB, 1.72% gc time)
# julia> @time do_multithreaded_work!(clangexpm!, Bs, As, testrange);
#   2.563331 seconds (603.17 k allocations: 1.394 GiB, 1.72% gc time)
# julia> @time do_multithreaded_work!(expm_tls!, Bs, As, testrange);
#   3.511809 seconds (74.71 M allocations: 4.653 GiB, 9.25% gc time)
# julia> @time do_multithreaded_work!(expm_tls!, Bs, As, testrange);
#   3.519219 seconds (74.71 M allocations: 4.653 GiB, 9.64% gc time)

# # Current:
# julia> @time do_multithreaded_work!(clangexpm!, Bs, As, testrange);
#   3.054223 seconds (603.17 k allocations: 1.394 GiB, 1.28% gc time)
# julia> @time do_multithreaded_work!(clangexpm!, Bs, As, testrange);
#   2.994284 seconds (603.17 k allocations: 1.394 GiB, 2.54% gc time)
# julia> @time do_multithreaded_work!(expm_tls!, Bs, As, testrange);
#   3.503206 seconds (73.82 M allocations: 4.620 GiB, 9.28% gc time)
# julia> @time do_multithreaded_work!(expm_tls!, Bs, As, testrange);
#   3.493063 seconds (73.82 M allocations: 4.620 GiB, 9.43% gc time)

# We also added a lot of POLYMATHNOVECTORIZE
# TODO: define `dot`-product? , optimize lu/ldiv
# Define/support a'*B 

#
#
#
#
#
#

using LinearAlgebra,
  Statistics, ForwardDiff, BenchmarkTools, ExponentialUtilities

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
      U = evalpoly(
        A2,
        (
          S(8821612800) * I,
          S(302702400) * I,
          S(2162160) * I,
          S(3960) * I,
          S(1) * I
        )
      )
      U = A * U
      V = evalpoly(
        A2,
        (
          S(17643225600) * I,
          S(2075673600) * I,
          S(30270240) * I,
          S(110880) * I,
          S(90) * I
        )
      )
    elseif nA > 0.25
      U = evalpoly(A2, (S(8648640) * I, S(277200) * I, S(1512) * I, S(1) * I))
      U = A * U
      V =
        evalpoly(A2, (S(17297280) * I, S(1995840) * I, S(25200) * I, S(56) * I))
    elseif nA > 0.015
      U = evalpoly(A2, (S(15120) * I, S(420) * I, S(1) * I))
      U = A * U
      V = evalpoly(A2, (S(30240) * I, S(3360) * I, S(30) * I))
    else
      U = evalpoly(A2, (S(60) * I, S(1) * I))
      U = A * U
      V = evalpoly(A2, (S(120) * I, S(12) * I))
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
expm_oop!(B, A) = copyto!(B, expm(A))
function _matevalpoly!(B, _, D, A::AbstractMatrix{T}, t::NTuple{1}) where {T}
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
function matevalpoly!(B, _, _, A::AbstractMatrix{T}, t::NTuple{2}) where {T}
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
  matmul! = mul!,
  matmuladd! = (C, A, B) -> mul!(C, A, B, 1.0, 1.0)
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
expm_naivematmul!(Z, A) = expm!(Z, A, naive_matmul!, naive_matmuladd!)
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

function localwork(
  f::F,
  As::NTuple{<:Any,<:AbstractMatrix{T}},
  r,
  i,
  nt
) where {F,T}
  N = length(r)
  start = div(N * (i - 1), nt) + 1
  stop = div(N * i, nt)
  x::T = zero(T)
  B = similar(first(As))
  C = similar(B)
  for A in As
    for j = start:stop
      B .= r[j] .* A
      f(C, B)
      x += sum(C)
    end
  end
  return x
end
function localwork!(
  f::F,
  acc::Ptr{T},
  As::NTuple{<:Any,<:AbstractMatrix{T}},
  r,
  i,
  nt
) where {F,T}
  x = localwork(f, As, r, i, nt)
  unsafe_store!(acc, x)
end
function threadedwork!(
  f::F,
  As::NTuple{<:Any,<:AbstractMatrix{T}},
  r::AbstractArray
) where {T,F}
  nt = min(Threads.nthreads(), length(r))
  if nt <= 1
    return localwork(f, As, r, 1, 1)
  end
  x = cld(64, sizeof(T))
  acc = Matrix{T}(undef, x, nt)
  GC.@preserve acc begin
    p = pointer(acc)
    xst = sizeof(T) * x
    Threads.@threads for i = 1:nt
      localwork!(f, p + xst * (i - 1), As, r, i, nt)
    end
  end
  return sum(@view(acc[1, :]))::T
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
  r = 0.1:0.005:10.0
  if isoutofplace(f.f, Val(A))
    threadedwork!((x, y) -> copyto!(x, f.f(y)), f.a, r)
  else
    threadedwork!(f.f, f.a, r)
  end
end

const libMatrixExp = joinpath(@__DIR__, "buildgcc/libMatrixExp.so")
const libMatrixExpClang = joinpath(@__DIR__, "buildclang/libMatrixExp.so")
for (lib, cc) in ((:libMatrixExp, :gcc), (:libMatrixExpClang, :clang))
  j = Symbol(cc, :expm!)

  @eval $j(A::Matrix{Float64}) =
    @ccall $lib.expmf64(A::Ptr{Float64}, size(A, 1)::Clong)::Nothing
  for n = 1:8
    sym = Symbol(:expmf64d, n)
    @eval $j(A::Matrix{ForwardDiff.Dual{T,Float64,$n}}) where {T} =
      @ccall $lib.$sym(A::Ptr{Float64}, size(A, 1)::Clong)::Nothing
    for i = 1:2
      sym = Symbol(:expmf64d, n, :d, i)
      @eval $j(
        A::Matrix{ForwardDiff.Dual{T1,ForwardDiff.Dual{T0,Float64,$n},$i}}
      ) where {T0,T1} =
        @ccall $lib.$sym(A::Ptr{Float64}, size(A, 1)::Clong)::Nothing
    end
  end
end

struct BMean
  t::Float64
  m::Float64
  a::Float64
end
BMean() = BMean(0.0, 0.0, 0.0)
Base.zero(::BMean) = BMean()
BMean(b::BenchmarkTools.Trial) = BMean(BenchmarkTools.mean(b))
function BMean(b::BenchmarkTools.TrialEstimate)
  a = BenchmarkTools.allocs(b)
  BMean(BenchmarkTools.time(b), BenchmarkTools.memory(b), a)
end
Base.:(+)(x::BMean, y::BMean) = BMean(x.t + y.t, x.m + y.m, x.a + y.a)
Base.:(/)(x::BMean, y::Number) = BMean(x.t / y, x.m / y, x.a / y)
get_time(b::BMean) = b.t
function Base.show(io::IO, ::MIME"text/plain", b::BMean)
  (; t, m, a) = b
  println(
    io,
    "  ",
    BenchmarkTools.prettytime(t),
    " (",
    a,
    " allocation",
    (a == 1 ? "" : "s"),
    ": ",
    BenchmarkTools.prettymemory(m),
    ")"
  )
end

# macros are too awkward to work with, so we use a function
# mean times are much better for benchmarking than minimum
# whenever you have a function that allocates
function bmean(f)
  b = @benchmark $f()
  BMean(b)
end
function exputils!(B, A)
  exponential!(copyto!(B, A))
  return B
end

function run_benchmarks(funs, sizes = 2:8, D0 = 0:8, D1 = 0:2)
  num_funs = length(funs)
  compile_times = zeros(Int, num_funs)
  brs = Array{BMean}(undef, num_funs, length(sizes), length(D0), length(D1))
  counter = 0
  max_count = length(sizes) * (length(D0) * length(D1) - (length(D1) - 1))
  for (i, dim) in enumerate(sizes)
    for (j, d1) in enumerate(D1)
      for (k, d0) in enumerate(D0)
        if d0 == 0 && d1 != 0
          fill!(@view(brs[:, i, k, j]), BMean())
          continue
        end
        As = map(x -> dualify(x, d0, d1), randmatrices(dim))
        Bs = [similar(first(As)) for _ in eachindex(funs)]
        for A in As
          for l in eachindex(funs)
            fun! = funs[l]
            B = Bs[l]
            Base.cumulative_compile_timing(true)
            tstart = Base.cumulative_compile_time_ns()
            fun!(B, A)
            Base.cumulative_compile_timing(false)
            compile_times[l] += Base.cumulative_compile_time_ns()[1] - tstart[1]
          end
          for l = 2:num_funs
            if reinterpret(Float64, Bs[1]) ≉ reinterpret(Float64, Bs[l])
              throw("Funs 1 and $l disagree with dim=$dim, d0=$d0, d1=$d1.")
            end
          end
        end
        if Threads.nthreads() > 1
          for (l, fun) in enumerate(funs)
            brs[l, i, k, j] = bmean(ThreadedForEach(fun, As))
          end
        else
          B = similar(first(As))
          for (l, fun) in enumerate(funs)
            brs[l, i, k, j] = bmean(ForEach(fun, B, As))
          end
        end
        if (counter += 1) != max_count
          println(round(100counter / max_count; digits = 2), "% complete")
        end
      end
    end
  end
  return brs, compile_times
end

#=
funs = [expm_oop!, expm!, expm_naivematmul!, exputils!, gccexpm!, clangexpm!];
fun_names = ["Out Of Place", "In Place", "In Place+Naive matmul!", "ExponentialUtilities.exponential!", "GCC", "Clang"]
funs = [expm!, exputils!, clangexpm!];
fun_names = ["In Place", "ExponentialUtilities.exponential!", "Clang"]
brs, cts = run_benchmarks(funs);
println(cts ./ 1e9)

using CairoMakie, Statistics
t_vs_sz = mean(brs, dims = (3,4));
logtime(x) = log10(get_time(x))
f, ax, l1 = lines(2:8, logtime.(t_vs_sz[1,:,1,1]), label = fun_names[1]);
for l = 2:size(t_vs_sz,1)
  lines!(2:8, logtime.(t_vs_sz[l,:,1,1]), label=fun_names[l]);
end
axislegend(position=:rb); f
save("size_vs_log10time.png", f);
=#
