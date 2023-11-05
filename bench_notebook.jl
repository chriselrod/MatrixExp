### A Pluto.jl notebook ###
# v0.19.32

using Markdown
using InteractiveUtils

# ╔═╡ 76bafa79-bdd3-487c-b056-d74f02ce48f1
begin
	using Base.Threads
    
    # utilities for dealing with nested tuples
	# we use nested instead of flat tuples to avoid heuristics
	# that avoid specializing on long tuples
	rmap(f, ::Tuple{}) = ()
	rmap(f::F, x::Tuple) where {F} = map(f, x)
	rmap(f::F, x::Tuple{Vararg{Tuple,K}}) where {F,K} = map(Base.Fix1(rmap, f), x)
	rmap(f, ::Tuple{}, ::Tuple{}) = ()
	rmap(f::F, x::Tuple, y::Tuple) where {F} = map(f, x, y)
	rmap(f::F, x::Tuple{Vararg{Tuple,K}}, y::Tuple{Vararg{Tuple,K}}) where {F,K} = map((a,b)->rmap(f,a,b), x, y)

	# rmaptnum applies `f` to a tuple of non-tuples
	rmaptnum(f, ::Tuple{}) = ()
	rmaptnum(f::F, x::Tuple{Vararg{Tuple{Vararg}}}) where {F} = map(f, x)
	rmaptnum(f::F, x::Tuple{Vararg{Tuple{Vararg{Tuple}}}}) where {F} = map(Base.Fix1(rmaptnum,f), x)
	
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
	        ret = rmap(+, ret, rmaptnum(sum,incr))
	    end
	    return ret
	end
	
	function do_multithreaded_work!(f!::F, Bs, As, r) where {F}
	    nt = Threads.nthreads(:default)
	    nt > 1 || return do_singlethreaded_work!(f!, Bs, As, r)
	    tasks = Vector{Task}(undef, nt)
	    for n in 1:nt        
	        subrange = r[n:nt:end] # stride to balance opnorms across threads
	        Bsc = n == nt ? Bs : rmap(copy, Bs)
	        tasks[n] = Threads.@spawn do_singlethreaded_work!($f!, $Bsc, $As, $subrange)
	    end
		_ret = rmaptnum(zero ∘ eltype ∘ eltype, Bs)
	    ret::typeof(_ret) = Threads.fetch(tasks[1])
	    for n in 2:nt
	        ret = rmap(+, ret, Threads.fetch(tasks[n]))
	    end
	    return ret
	end
end

# ╔═╡ 1958441e-329b-4f6d-803a-49e83fb9c155
begin
	using ForwardDiff
	A = rand(4, 4)
	ForwardDiff.gradient(sum∘exp, A)
end

# ╔═╡ 48bc4a98-7d22-41ea-b548-26163b6d6796
begin
	using ExponentialUtilities
	ForwardDiff.gradient(sum∘exponential!∘copy, A)
end

# ╔═╡ aaaebfb6-f5bd-46f2-9e70-453816bec321
md"""
## Matching `C++` Performance with `Julia` on Forward-Mode AD of the MatrixExponential

Our benchmark test case will be applying ForwardMode AD (using `ForwardDiff.jl`) for (dynamically sized) square matrices of size 2x2...8x8, with dual sizes `0:8` for single derivatives, and `1:8` by `1:2` for second derivatives.

We'll iterate over a range of scale factors, to hit different code-paths based on the op-norm of the matrices. For each scale factor, we'll iterate over all tested matrices to increase the working set of memory, to simulate more realistic workloads that may (for example) be solving a large number of affine differential equations as part of an optimization problem.

The function we're benchmarking:
"""

# ╔═╡ 2ddbf2c2-7bbc-11ee-3a66-af10ce78ff33
md"""For our matrix exponential implementations, we use
1. `ExponentialUtilities.exponential!`
2. Implementations based on [StaticArrays.exp](https://github.com/JuliaArrays/StaticArrays.jl/blob/72d2bd3538235c9162f630a5130112b83eaa0af7/src/expm.jl#L75-L129).

The `StaticArays.jl` implementation is 55 lines of code, making it an easy starting point, even though all our arrays we're testing here are dynamically sized.
Our `C++` implementation follows a similar style, and is similarly terse:
```c++
template <typename T> constexpr void expm(MutSquarePtrMatrix<T> A) {
  ptrdiff_t n = ptrdiff_t(A.numRow()), s = 0;
  SquareMatrix<T, L> A2{A * A}, U_{SquareDims<>{{n}}};
  MutSquarePtrMatrix<T> U{U_};
  if (double nA = opnorm1(A); nA <= 0.015) {
    U << A * (A2 + 60.0 * I);
    A << 12.0 * A2 + 120.0 * I;
  } else {
    SquareMatrix<T, L> B{SquareDims<>{{n}}};
    if (nA <= 2.1) {
      containers::TinyVector<double, 5> p0, p1;
      if (nA > 0.95) {
        p0 = {1.0, 3960.0, 2162160.0, 302702400.0, 8821612800.0};
        p1 = {90.0, 110880.0, 3.027024e7, 2.0756736e9, 1.76432256e10};
      } else if (nA > 0.25) {
        p0 = {1.0, 1512.0, 277200.0, 8.64864e6};
        p1 = {56.0, 25200.0, 1.99584e6, 1.729728e7};
      } else {
        p0 = {1.0, 420.0, 15120.0};
        p1 = {30.0, 3360.0, 30240.0};
      }
      evalpoly(B, U, A2, p0);
      U << A * B;
      evalpoly(A, B, A2, p1);
    } else {
      // s = std::max(unsigned(std::ceil(std::log2(nA / 5.4))), 0);
      s = nA > 5.4 ? log2ceil(nA / 5.4) : 0;
      double t = (s > 0) ? 1.0 / exp2(s) : 0.0;
      if (s > 0) A2 *= (t * t);
      // here we take an estrin (instead of horner) approach to cut down flops
      SquareMatrix<T, L> A4{A2 * A2}, A6{A2 * A4};
      B << A6 * (A6 + 16380 * A4 + 40840800 * A2) +
             (33522128640 * A6 + 10559470521600 * A4 + 1187353796428800 * A2) +
             32382376266240000 * I;
      U << A * B;
      if (s & 1) {  // we have an odd number of swaps at the end
        A << U * t; // copy data to `A`, so we can swap and make it even
        std::swap(A, U);
      } else if (s > 0) U *= t;
      A << A6 * (182 * A6 + 960960 * A4 + 1323241920 * A2) +
             (670442572800 * A6 + 129060195264000 * A4 +
              7771770303897600 * A2) +
             64764752532480000 * I;
    }
  }
  for (auto &&[a, u] : std::ranges::zip_view(A, U))
    std::tie(a, u) = std::make_pair(a + u, a - u);
  LU::ldiv(U, MutPtrMatrix<T>(A));
  for (; s--; std::swap(A, U)) U << A * A;
}
```
Note that matrix multiplications are much more expensive than additions. Thus, while an estrin-like approach to evaluating the polynomials increases the number of temporary matrices needed, it greatly cuts down how many flops we actually need. These details were copied from the `StaticArrays.jl` implementation. `StaticArrays.SArray`s are typically stack allocated, making this tradeoff favorable.

`ExponentialUtilities.jl` is more involved with a lot more options. I haven't looked into these, nor have I compared accurcacy of the approaches. I'm simply using it as a baseline, as it's likely what most people would reach for as soon as they notice"""

# ╔═╡ c0aa3102-bbe5-48f2-b110-292c94b178d6
md"""
That is, the base method is not generic, but `ExponentialUtilities.jl` is.

Now, lets create the test arrays and time:
"""

# ╔═╡ 0441be8c-9dcc-49fa-9ff8-de99957caecc
begin
	d(x, n) = ForwardDiff.Dual(x, ntuple(_ -> randn(), n))
	function dualify(A, n, j)
		n == 0 && return A
		j == 0 ? d.(A, n) : d.(d.(A, n), j)
  	end
	randdual(n, dinner, douter) = dualify(rand(n,n), dinner, douter)
    As = map((0,1,2)) do dout # outer dual
		map(ntuple(identity,Val(9)).-1) do din # inner dual
			map(ntuple(identity,Val(7)).+1) do n # matrix size
				randdual(n,din,dout)
			end
		end
	end
	Bs = rmap(similar, As)
end; # setup

# ╔═╡ 600e1024-8fd9-494c-9564-f7c885929c2f
@time do_multithreaded_work!(exponential!, Bs, As, 0.01:0.01:10.0)

# ╔═╡ 0baa8849-c8b4-4bad-b386-87dbce39a81d
@time do_multithreaded_work!(exponential!, Bs, As, 0.01:0.01:10.0)

# ╔═╡ f7730067-9e96-439f-930d-be984d359879
begin
	const libExpMatGCC = joinpath(@__DIR__, "buildgcc/libMatrixExp.so")
	const libExpMatClang = joinpath(@__DIR__, "buildclang/libMatrixExp.so")
	for (lib, cc) in ((:libExpMatGCC, :gcc), (:libExpMatClang, :clang))
	  j = Symbol(cc, :expm!)
	
	  @eval $j(A::Matrix{Float64}) = @ccall $lib.expmf64(
	    A::Ptr{Float64},
	    size(A, 1)::Clong
	  )::Nothing
	  for n = 1:8
	    sym = Symbol(:expmf64d, n)
	    @eval $j(
	      A::Matrix{ForwardDiff.Dual{T,Float64,$n}}
	    ) where {T} = @ccall $lib.$sym(
	      A::Ptr{Float64},
	      size(A, 1)::Clong
	    )::Nothing
	    for i = 1:2
	      sym = Symbol(:expmf64d, n, :d, i)
	      @eval $j(
	        A::Matrix{ForwardDiff.Dual{T1,ForwardDiff.Dual{T0,Float64,$n},$i}}
	      ) where {T0,T1} = @ccall $lib.$sym(
	        A::Ptr{Float64},
	        size(A, 1)::Clong
	      )::Nothing
	    end
	  end
	end
end

# ╔═╡ 55268c5e-7ea6-48ca-a32b-6c16e827bd53
@time do_multithreaded_work!(clangexpm!, Bs, As, 0.01:0.01:10.0)

# ╔═╡ c9ce96c7-8caa-4613-ad70-1f0ff299e816
@time do_multithreaded_work!(clangexpm!, Bs, As, 0.01:0.01:10.0)

# ╔═╡ ddc76605-60f5-4757-b55a-d47523379862
joinpath(@__DIR__, "buildgcc/libMatrixExp.so")

# ╔═╡ 7892fb44-a4e8-410a-beca-7c4b68e8e3e2


# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
ExponentialUtilities = "d4d017d3-3776-5f7e-afef-a10c40355c18"
ForwardDiff = "f6369f11-7733-5829-9624-2563aa707210"

[compat]
ExponentialUtilities = "~1.25.0"
ForwardDiff = "~0.10.36"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.11.0-DEV"
manifest_format = "2.0"
project_hash = "f2926d19ee373d7368ac90907840670be6be4ad0"

[[deps.Adapt]]
deps = ["LinearAlgebra", "Requires"]
git-tree-sha1 = "02f731463748db57cc2ebfbd9fbc9ce8280d3433"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.7.1"

    [deps.Adapt.extensions]
    AdaptStaticArraysExt = "StaticArrays"

    [deps.Adapt.weakdeps]
    StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.ArrayInterface]]
deps = ["Adapt", "LinearAlgebra", "Requires", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "16267cf279190ca7c1b30d020758ced95db89cd0"
uuid = "4fba245c-0d91-5ea0-9b3e-6abc04ee57a9"
version = "7.5.1"

    [deps.ArrayInterface.extensions]
    ArrayInterfaceBandedMatricesExt = "BandedMatrices"
    ArrayInterfaceBlockBandedMatricesExt = "BlockBandedMatrices"
    ArrayInterfaceCUDAExt = "CUDA"
    ArrayInterfaceGPUArraysCoreExt = "GPUArraysCore"
    ArrayInterfaceStaticArraysCoreExt = "StaticArraysCore"
    ArrayInterfaceTrackerExt = "Tracker"

    [deps.ArrayInterface.weakdeps]
    BandedMatrices = "aae01518-5342-5314-be14-df237901396f"
    BlockBandedMatrices = "ffab5731-97b5-5995-9138-79e8c1846df0"
    CUDA = "052768ef-5323-5732-b1bb-66c8b64840ba"
    GPUArraysCore = "46192b85-c4d5-4398-a991-12ede77f4527"
    StaticArraysCore = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
    Tracker = "9f7883ad-71c0-57eb-9f7f-b5c9e6d3789c"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"
version = "1.11.0"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"
version = "1.11.0"

[[deps.CommonSubexpressions]]
deps = ["MacroTools", "Test"]
git-tree-sha1 = "7b8a93dba8af7e3b42fecabf646260105ac373f7"
uuid = "bbf7d656-a473-5ed7-a52c-81e309532950"
version = "0.3.0"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.1.0+0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"
version = "1.11.0"

[[deps.DiffResults]]
deps = ["StaticArraysCore"]
git-tree-sha1 = "782dd5f4561f5d267313f23853baaaa4c52ea621"
uuid = "163ba53b-c6d8-5494-b064-1a9d43ac40c5"
version = "1.1.0"

[[deps.DiffRules]]
deps = ["IrrationalConstants", "LogExpFunctions", "NaNMath", "Random", "SpecialFunctions"]
git-tree-sha1 = "23163d55f885173722d1e4cf0f6110cdbaf7e272"
uuid = "b552c78f-8df3-52c6-915a-8e097449b14b"
version = "1.15.1"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "2fb1e02f2b635d0845df5d7c167fec4dd739b00d"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.3"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.ExponentialUtilities]]
deps = ["Adapt", "ArrayInterface", "GPUArraysCore", "GenericSchur", "LinearAlgebra", "PrecompileTools", "Printf", "SparseArrays", "libblastrampoline_jll"]
git-tree-sha1 = "602e4585bcbd5a25bc06f514724593d13ff9e862"
uuid = "d4d017d3-3776-5f7e-afef-a10c40355c18"
version = "1.25.0"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"
version = "1.11.0"

[[deps.ForwardDiff]]
deps = ["CommonSubexpressions", "DiffResults", "DiffRules", "LinearAlgebra", "LogExpFunctions", "NaNMath", "Preferences", "Printf", "Random", "SpecialFunctions"]
git-tree-sha1 = "cf0fe81336da9fb90944683b8c41984b08793dad"
uuid = "f6369f11-7733-5829-9624-2563aa707210"
version = "0.10.36"

    [deps.ForwardDiff.extensions]
    ForwardDiffStaticArraysExt = "StaticArrays"

    [deps.ForwardDiff.weakdeps]
    StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"

[[deps.GPUArraysCore]]
deps = ["Adapt"]
git-tree-sha1 = "2d6ca471a6c7b536127afccfa7564b5b39227fe0"
uuid = "46192b85-c4d5-4398-a991-12ede77f4527"
version = "0.1.5"

[[deps.GenericSchur]]
deps = ["LinearAlgebra", "Printf"]
git-tree-sha1 = "fb69b2a645fa69ba5f474af09221b9308b160ce6"
uuid = "c145ed77-6b09-5dd9-b285-bf645a82121e"
version = "0.5.3"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"
version = "1.11.0"

[[deps.IrrationalConstants]]
git-tree-sha1 = "630b497eafcc20001bba38a4651b327dcfc491d2"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.2.2"

[[deps.JLLWrappers]]
deps = ["Artifacts", "Preferences"]
git-tree-sha1 = "7e5d6779a1e09a36db2a7b6cff50942a0a7d0fca"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.5.0"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.4"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "8.4.0+0"

[[deps.LibGit2]]
deps = ["Base64", "LibGit2_jll", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"
version = "1.11.0"

[[deps.LibGit2_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll"]
uuid = "e37daf67-58a4-590a-8e99-b0245dd2ffc5"
version = "1.7.1+0"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.11.0+1"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"
version = "1.11.0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
version = "1.11.0"

[[deps.LogExpFunctions]]
deps = ["DocStringExtensions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "7d6dd4e9212aebaeed356de34ccf262a3cd415aa"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.26"

    [deps.LogExpFunctions.extensions]
    LogExpFunctionsChainRulesCoreExt = "ChainRulesCore"
    LogExpFunctionsChangesOfVariablesExt = "ChangesOfVariables"
    LogExpFunctionsInverseFunctionsExt = "InverseFunctions"

    [deps.LogExpFunctions.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    ChangesOfVariables = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
    InverseFunctions = "3587e190-3f89-42d0-90ee-14403ec27112"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"
version = "1.11.0"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "9ee1618cbf5240e6d4e0371d6f24065083f60c48"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.11"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"
version = "1.11.0"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.2+1"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2023.1.10"

[[deps.NaNMath]]
deps = ["OpenLibm_jll"]
git-tree-sha1 = "0877504529a3e5c3343c6f8b4c0381e57e4387e4"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.0.2"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.24+0"

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"
version = "0.8.1+2"

[[deps.OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.11.0"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "03b4c25b43cb84cee5c90aa9b5ea0a78fd848d2f"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.2.0"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "00805cd429dcb4870060ff49ef443486c262e38e"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.4.1"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"
version = "1.11.0"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"
version = "1.11.0"

[[deps.Random]]
deps = ["SHA"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
version = "1.11.0"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"
version = "1.11.0"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"
version = "1.11.0"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
version = "1.11.0"

[[deps.SpecialFunctions]]
deps = ["IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "e2cfc4012a19088254b3950b85c3c1d8882d864d"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.3.1"

    [deps.SpecialFunctions.extensions]
    SpecialFunctionsChainRulesCoreExt = "ChainRulesCore"

    [deps.SpecialFunctions.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"

[[deps.StaticArraysCore]]
git-tree-sha1 = "36b3d696ce6366023a0ea192b4cd442268995a0d"
uuid = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
version = "1.4.2"

[[deps.SuiteSparse]]
deps = ["Libdl", "LinearAlgebra", "Serialization", "SparseArrays"]
uuid = "4607b0f0-06f3-5cda-b6b1-a6196a1729e9"

[[deps.SuiteSparse_jll]]
deps = ["Artifacts", "Libdl", "Pkg", "libblastrampoline_jll"]
uuid = "bea87d4a-7f5b-5778-9afe-8cc45184846c"
version = "7.2.1+1"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"
version = "1.11.0"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"
version = "1.11.0"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"
version = "1.11.0"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.13+1"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.8.0+1"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.52.0+1"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+2"
"""

# ╔═╡ Cell order:
# ╟─aaaebfb6-f5bd-46f2-9e70-453816bec321
# ╠═76bafa79-bdd3-487c-b056-d74f02ce48f1
# ╟─2ddbf2c2-7bbc-11ee-3a66-af10ce78ff33
# ╠═1958441e-329b-4f6d-803a-49e83fb9c155
# ╠═48bc4a98-7d22-41ea-b548-26163b6d6796
# ╠═c0aa3102-bbe5-48f2-b110-292c94b178d6
# ╠═0441be8c-9dcc-49fa-9ff8-de99957caecc
# ╠═600e1024-8fd9-494c-9564-f7c885929c2f
# ╠═0baa8849-c8b4-4bad-b386-87dbce39a81d
# ╠═f7730067-9e96-439f-930d-be984d359879
# ╠═55268c5e-7ea6-48ca-a32b-6c16e827bd53
# ╠═c9ce96c7-8caa-4613-ad70-1f0ff299e816
# ╠═ddc76605-60f5-4757-b55a-d47523379862
# ╠═7892fb44-a4e8-410a-beca-7c4b68e8e3e2
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
