#pragma once
#include <Containers/TinyVector.hpp>
#include <Math/Array.hpp>
#include <Math/Dual.hpp>
#include <Math/LinearAlgebra.hpp>
#include <Math/Matrix.hpp>
#include <Math/StaticArrays.hpp>
#include <Utilities/Invariant.hpp>
#include <algorithm>
#include <bit>
#include <cstdint>
#include <random>
#include <utility>

namespace poly::math {

constexpr size_t L = 16;
static_assert(
  utils::ElementOf<double, SquareMatrix<Dual<Dual<double, 4>, 2>, L>>);
// auto x = Dual<Dual<double, 4>, 2>{1.0};
// auto y = x * 3.4;
// static_assert(Scalar<Dual<double, 4>>);
static_assert(std::convertible_to<int, Dual<double, 4>>);
static_assert(std::convertible_to<int, Dual<Dual<double, 4>, 2>>);

template <class D> struct URand {
  using T = typename D::val_type;
  static constexpr size_t N = D::num_partials;
  auto operator()(std::mt19937_64 &mt) -> D {
    Dual<T, N> x{URand<T>{}(mt)};
    for (ptrdiff_t i = 0; i < N; ++i) x.gradient()[i] = URand<T>{}(mt);
    return x;
  }
};
template <> struct URand<double> {
  auto operator()(std::mt19937_64 &mt) -> double {
    return std::uniform_real_distribution<double>(-2, 2)(mt);
  }
};

template <typename T>
constexpr auto evalpoly(MutSquarePtrMatrix<T> C, const auto &p) {
  using U = utils::eltype_t<T>;
  using S = SquareMatrix<U, L>;
  assert(C.numRow() == C.numCol());
  S B{SquareDims{C.numRow()}};
  evalpoly(B, C, p);
  return B;
}
template <typename T>
constexpr void evalpoly(MutSquarePtrMatrix<T> B, SquarePtrMatrix<T> C,
                        const auto &p) {
  using S = SquareMatrix<T, L>;
  ptrdiff_t N = p.size();
  invariant(N > 0);
  invariant(ptrdiff_t(C.numRow()), ptrdiff_t(C.numCol()));
  invariant(ptrdiff_t(B.numRow()), ptrdiff_t(B.numCol()));
  invariant(ptrdiff_t(B.numRow()), ptrdiff_t(C.numRow()));
  S D{SquareDims{N == 2 ? Row{0} : B.numRow()}};
  MutSquarePtrMatrix<T> A{D};
  if (N & 1) std::swap(A, B);
  B << p[0] * C + p[1] * I;
  for (ptrdiff_t i = 2; i < N; ++i) {
    std::swap(A, B);
    B << A * C + p[i] * I;
  }
}

template <AbstractMatrix T> constexpr auto opnorm1(const T &A) {
  using S = decltype(extractDualValRecurse(std::declval<utils::eltype_t<T>>()));
  ptrdiff_t n = ptrdiff_t(A.numRow());
  invariant(n > 0);
  Vector<S> v;
  v.resizeForOverwrite(n);
  invariant(A.numRow() > 0);
  for (ptrdiff_t j = 0; j < n; ++j)
    v[j] = std::abs(extractDualValRecurse(A[0, j]));
  for (ptrdiff_t i = 1; i < n; ++i)
    for (ptrdiff_t j = 0; j < n; ++j)
      v[j] += std::abs(extractDualValRecurse(A[i, j]));
  return *std::max_element(v.begin(), v.end());
}

/// computes ceil(log2(x)) for x >= 1
constexpr auto log2ceil(double x) -> unsigned {
  invariant(x >= 1);
  uint64_t u = std::bit_cast<uint64_t>(x) - 1;
  return (u >> 52) - 1022;
}

template <typename T>
constexpr void expm(MutSquarePtrMatrix<T> V, SquarePtrMatrix<T> A) {
  invariant(ptrdiff_t(V.numRow()), ptrdiff_t(A.numRow()));
  unsigned n = unsigned(A.numRow());
  auto nA = opnorm1(A);
  SquareMatrix<T, L> squaredA{A * A}, Utp{SquareDims{n}};
  MutSquarePtrMatrix<T> AA{squaredA}, U{Utp};
  unsigned int s = 0;
  if (nA <= 2.1) {
    containers::TinyVector<double, 5> p0, p1;
    if (nA > 0.95) {
      p0 = {1.0, 3960.0, 2162160.0, 302702400.0, 8821612800.0};
      p1 = {90.0, 110880.0, 3.027024e7, 2.0756736e9, 1.76432256e10};
    } else if (nA > 0.25) {
      p0 = {1.0, 1512.0, 277200.0, 8.64864e6};
      p1 = {56.0, 25200.0, 1.99584e6, 1.729728e7};
    } else if (nA > 0.015) {
      p0 = {1.0, 420.0, 15120.0};
      p1 = {30.0, 3360.0, 30240.0};
    } else {
      p0 = {1.0, 60.0};
      p1 = {12.0, 120.0};
    }
    evalpoly(V, AA, p0);
    U << A * V;
    evalpoly(V, AA, p1);
  } else {
    // s = std::max(unsigned(std::ceil(std::log2(nA / 5.4))), unsigned(0));
    s = nA > 5.4 ? log2ceil(nA / 5.4) : unsigned(0);
    double t = 1.0;
    if (s > 0) {
      t = 1.0 / exp2(s);
      AA *= (t * t);
      if (s & 1) std::swap(U, V);
    }
    SquareMatrix<T, L> A4{AA * AA}, A6{AA * A4};

    V << A6 * (A6 + 16380 * A4 + 40840800 * AA) +
           (33522128640 * A6 + 10559470521600 * A4 + 1187353796428800 * AA) +
           32382376266240000 * I;
    U << A * V;
    if (s > 0) U *= t;
    V << A6 * (182 * A6 + 960960 * A4 + 1323241920 * AA) +
           (670442572800 * A6 + 129060195264000 * A4 + 7771770303897600 * AA) +
           64764752532480000 * I;
  }
  for (auto v = V.begin(), u = U.begin(), e = V.end(); v != e; ++v, ++u) {
    auto &&d = *v - *u;
    *v += *u;
    *u = d;
  }
  LU::ldiv(U, MutPtrMatrix<T>(V));
  for (; s--;) {
    U << V * V;
    std::swap(U, V);
  }
}
template <typename T> constexpr auto expm(SquarePtrMatrix<T> A) {
  SquareMatrix<T, L> V{SquareDims{A.numRow()}};
  expm(V, A);
  return V;
}
template <typename T> void expm(T *A, T *B, ptrdiff_t N) {
  expm(MutSquarePtrMatrix<T>(A, N), SquarePtrMatrix<T>(B, N));
}

} // namespace poly::math

using poly::math::expm, poly::math::Dual;
template <size_t N, size_t M> using DDual = Dual<Dual<double, N>, M>;

static_assert(
  std::same_as<
    double, decltype(poly::math::opnorm1(
              std::declval<poly::math::MutSquarePtrMatrix<DDual<7, 2>>>()))>);
