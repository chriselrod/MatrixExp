using LinearAlgebra, Statistics, ForwardDiff, BenchmarkTools, Test

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
      A6 * (S(1) * A6 + S(16380) * A4 + S(40840800) * A2) +
      (
        S(33522128640) * A6 + S(10559470521600) * A4 + S(1187353796428800) * A2
      ) +
      S(32382376266240000) * I
    U = A * U
    V =
      A6 * (S(182) * A6 + S(960960) * A4 + S(1323241920) * A2) +
      (
        S(670442572800) * A6 +
        S(129060195264000) * A4 +
        S(7771770303897600) * A2
      ) +
      S(64764752532480000) * I
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

#### Copied from StaticArrays and adapted to BorderedLowerTriangular
function expm!(Z::AbstractMatrix, A::AbstractMatrix)
  # omitted: matrix balancing, i.e., LAPACK.gebal!
  # nA = maximum(sum(abs.(A); dims=Val(1)))    # marginally more performant than norm(A, 1)
  nA = opnorm(A, 1)
  N = LinearAlgebra.checksquare(A)
  # B and C are temporaries
  ## For sufficiently small nA, use lower order Padé-Approximations
  if nA <= 2.1
    U = Z
    V = similar(A)
    A2 = A * A
    if nA <= 0.015
      matevalpoly!(V, nothing, nothing, A2, (60, 1))
      mul!(U, A, V)
      matevalpoly!(V, nothing, nothing, A2, (120, 12))
    else
      B = similar(A)
      if nA <= 0.25
        matevalpoly!(V, nothing, U, A2, (15120, 420, 1))
        mul!(U, A, V)
        matevalpoly!(V, nothing, B, A2, (30240, 3360, 30))
      else
        C = similar(A)
        if nA <= 0.95
          matevalpoly!(V, C, U, A2, (8648640, 277200, 1512, 1))
          mul!(U, A, V)
          matevalpoly!(V, B, C, A2, (17297280, 1995840, 25200, 56))
        else
          matevalpoly!(V, C, U, A2, (8821612800, 302702400, 2162160, 3960, 1))
          mul!(U, A, V)
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
    s = log2(nA / 5.4)               # power of 2 later reversed by squaring
    if s > 0
      si = ceil(Int, s)
      A = A / exp2(si)
    end
    A2 = A * A
    A4 = A2 * A2
    A6 = A2 * A4

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
    mul!(B, A6, U, 1.0, 1.0)
    mul!(U, A, B)

    V = s > 0 ? fill!(A, 0) : zero(A)
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
    mul!(V, A6, B, 1.0, 1.0)

    @inbounds for m = 1:N*N
      u = U[m]
      v = V[m]
      U[m] = v + u
      V[m] = v - u
    end
    ldiv!(lu!(V), U)
    expA = U
    # expA = (V - U) \ (V + U)

    if s > 0            # squaring to reverse dividing by power of 2
      for t = 1:si
        mul!(V, expA, expA)
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

const libMatrixExp = joinpath(@__DIR__, "buildgcc/libMatrixExp.so")
const libMatrixExpClang = joinpath(@__DIR__, "buildclang/libMatrixExp.so")
for (lib, cc) in ((:libMatrixExp, :gcc), (:libMatrixExpClang, :clang))
  j = Symbol(cc, :expm!)
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

d(x, n) = ForwardDiff.Dual(x, ntuple(_ -> randn(), n))
for l = 1:5
  println("Size $l x $l:")
  for j = 0:2
    for n = (j!=0):8
      A = randn(l, l)
      if n > 0
        A = d.(A, n)
        if (j > 0)
          A = d.(A, j)
        end
      end
      B = similar(A)
      C = similar(A)
      D = similar(A)
      expm!(C, A)
      gccexpm!(B, A)
      clangexpm!(D, A)
      E = expm(A)
      @test reinterpret(Float64, C) ≈
            reinterpret(Float64, B) ≈
            reinterpret(Float64, D) ≈
            reinterpret(Float64, E)
      println("Size $l x $l, duals (n,j) = ($n,$j), T = $(eltype(A)):")
      print("Out of place Julia: ")
      @btime expm($A)
      print("In place     Julia: ")
      @btime expm!($B, $A)
      print("Out of place GCC:   ")
      @btime gccexpm!($B, $A)
      print("Out of place Clang: ")
      @btime clangexpm!($B, $A)
    end
  end
end
