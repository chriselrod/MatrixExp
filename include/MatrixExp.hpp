#pragma once
#include <Containers/TinyVector.hpp>
#include <Math/Array.hpp>
#include <Math/Dual.hpp>
#include <Math/LinearAlgebra.hpp>
#include <Math/Matrix.hpp>
#include <Utilities/Invariant.hpp>
#include <algorithm>
#include <bit>
#include <cstdint>
#include <ranges>
#include <utility>

namespace poly::math {

constexpr size_t L = 16;
static_assert(
  utils::ElementOf<double, SquareMatrix<Dual<Dual<double, 4>, 2>, L>>);
static_assert(std::convertible_to<int, Dual<double, 4>>);
static_assert(std::convertible_to<int, Dual<Dual<double, 4>, 2>>);

template <typename T>
constexpr void evalpoly(MutSquarePtrMatrix<T> B, MutSquarePtrMatrix<T> A,
                        SquarePtrMatrix<T> C, const auto &p) {
  ptrdiff_t N = p.size();
  invariant(N > 0);
  invariant(ptrdiff_t(B.numRow()), ptrdiff_t(C.numRow()));
  if (N & 1) std::swap(A, B);
  B << p[0] * C + p[1] * I;
  for (ptrdiff_t i = 2; i < N; ++i) {
    std::swap(A, B);
    B << A * C + p[i] * I;
  }
}

template <AbstractMatrix T> constexpr auto opnorm1(const T &A) {
  using S = decltype(extractDualValRecurse(std::declval<utils::eltype_t<T>>()));
  auto [M, N] = A.size();
  invariant(M > 0);
  invariant(N > 0);
  S a{};
  for (ptrdiff_t n = 0; n < N; ++n) {
    S s{};
    for (ptrdiff_t m = 0; m < M; ++m)
      s += std::abs(extractDualValRecurse(A[m, n]));
    a = std::max(a, s);
  }
  return a;
  // Vector<S> v{N};
  // for (ptrdiff_t n = 0; n < N; ++n)
  //   v[n] = std::abs(extractDualValRecurse(A[0, n]));
  // for (ptrdiff_t m = 1; m < M; ++m)
  //   for (ptrdiff_t n = 0; n < N; ++n)
  //     v[n] += std::abs(extractDualValRecurse(A[m, n]));
  // return *std::max_element(v.begin(), v.end());
}

/// computes ceil(log2(x)) for x >= 1
constexpr auto log2ceil(double x) -> ptrdiff_t {
  invariant(x >= 1);
  uint64_t u = std::bit_cast<uint64_t>(x) - 1;
  auto y = ptrdiff_t((u >> 52) - 1022);
  invariant(y >= 0);
  return y;
}

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
      double t = (s > 0) ? exp2(-s) : 0.0;
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
template <typename T> void expm(T *A, ptrdiff_t M) {
  expm(MutSquarePtrMatrix<T>(A, SquareDims<>{{M}}));
}

} // namespace poly::math

using poly::math::expm, poly::math::Dual;
template <size_t N, size_t M> using DDual = Dual<Dual<double, N>, M>;

static_assert(
  std::same_as<
    double, decltype(poly::math::opnorm1(
              std::declval<poly::math::MutSquarePtrMatrix<DDual<7, 2>>>()))>);
