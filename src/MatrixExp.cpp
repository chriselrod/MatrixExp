

#include "Containers/TinyVector.hpp"
#include "Math/Array.hpp"
#include "Math/LinearAlgebra.hpp"
#include "Math/Matrix.hpp"
#include "Math/StaticArrays.hpp"
#include "Utilities/Invariant.hpp"
#include <algorithm>
#include <array>
#include <concepts>
#include <cstdint>
#include <random>

namespace poly::math {

template <class T, size_t N> class Dual {
  T val{};
  SVector<T, N> partials{};

public:
  using val_type = T;
  static constexpr size_t num_partials = N;
  constexpr Dual() = default;
  constexpr Dual(T v) : val(v) {}
  constexpr Dual(T v, size_t n) : val(v) { partials[n] = T{1}; }
  constexpr Dual(T v, SVector<T, N> g) : val(v), partials(g) {}
  constexpr Dual(std::integral auto v) : val(v) {}
  constexpr Dual(std::floating_point auto v) : val(v) {}
  constexpr auto value() -> T & { return val; }
  constexpr auto gradient() -> SVector<T, N> & { return partials; }
  [[nodiscard]] constexpr auto value() const -> const T & { return val; }
  [[nodiscard]] constexpr auto gradient() const -> const SVector<T, N> & {
    return partials;
  }
  // constexpr auto operator[](size_t i) const -> T { return grad[i]; }
  // constexpr auto operator[](size_t i) -> T & { return grad[i]; }
  constexpr auto operator-() const -> Dual { return Dual(-val, -partials); }
  constexpr auto operator+(const Dual &other) const -> Dual {
    return {val + other.val, partials + other.partials};
  }
  constexpr auto operator-(const Dual &other) const -> Dual {
    return {val - other.val, partials - other.partials};
  }
  constexpr auto operator*(const Dual &other) const -> Dual {
    return {val * other.val, val * other.partials + other.val * partials};
  }
  constexpr auto operator/(const Dual &other) const -> Dual {
    return {val / other.val, (other.val * partials - val * other.partials) /
                               (other.val * other.val)};
  }
  constexpr auto operator+=(const Dual &other) -> Dual & {
    val += other.val;
    partials += other.partials;
    return *this;
  }
  constexpr auto operator-=(const Dual &other) -> Dual & {
    val -= other.val;
    partials -= other.partials;
    return *this;
  }
  constexpr auto operator*=(const Dual &other) -> Dual & {
    val *= other.val;
    partials = val * other.partials + other.val * partials;
    return *this;
  }
  constexpr auto operator/=(const Dual &other) -> Dual & {
    val /= other.val;
    partials =
      (other.val * partials - val * other.partials) / (other.val * other.val);
    return *this;
  }
  constexpr auto operator+(double other) const -> Dual {
    return {val + other, partials};
  }
  constexpr auto operator-(double other) const -> Dual {
    return {val - other, partials};
  }
  constexpr auto operator*(double other) const -> Dual {
    return {val * other, other * partials};
  }
  constexpr auto operator/(double other) const -> Dual {
    return {val / other, partials / other};
  }
  constexpr auto operator+=(double other) -> Dual & {
    val += other;
    return *this;
  }
  constexpr auto operator-=(double other) -> Dual & {
    val -= other;
    return *this;
  }
  constexpr auto operator*=(double other) -> Dual & {
    val *= other;
    partials *= other;
    return *this;
  }
  constexpr auto operator/=(double other) -> Dual & {
    val /= other;
    partials /= other;
    return *this;
  }
  constexpr auto operator==(const Dual &other) const -> bool {
    return val == other.val; // && grad == other.grad;
  }
  constexpr auto operator!=(const Dual &other) const -> bool {
    return val != other.val; // || grad != other.grad;
  }
  constexpr auto operator==(double other) const -> bool { return val == other; }
  constexpr auto operator!=(double other) const -> bool { return val != other; }
  constexpr auto operator<(double other) const -> bool { return val < other; }
  constexpr auto operator>(double other) const -> bool { return val > other; }
  constexpr auto operator<=(double other) const -> bool { return val <= other; }
  constexpr auto operator>=(double other) const -> bool { return val >= other; }
  constexpr auto operator<(const Dual &other) const -> bool {
    return val < other.val;
  }
  constexpr auto operator>(const Dual &other) const -> bool {
    return val > other.val;
  }
  constexpr auto operator<=(const Dual &other) const -> bool {
    return val <= other.val;
  }
  constexpr auto operator>=(const Dual &other) const -> bool {
    return val >= other.val;
  }
};
template <class T, size_t N> Dual(T, SVector<T, N>) -> Dual<T, N>;

template <class T, size_t N>
constexpr auto operator+(double other, Dual<T, N> x) -> Dual<T, N> {
  return {x.value() + other, x.gradient()};
}
template <class T, size_t N>
constexpr auto operator-(double other, Dual<T, N> x) -> Dual<T, N> {
  return {x.value() - other, -x.gradient()};
}
template <class T, size_t N>
constexpr auto operator*(double other, Dual<T, N> x) -> Dual<T, N> {
  return {x.value() * other, other * x.gradient()};
}
template <class T, size_t N>
constexpr auto operator/(double other, Dual<T, N> x) -> Dual<T, N> {
  return {other / x.value(), -other * x.gradient() / (x.value() * x.value())};
}
constexpr size_t L = 16;
static_assert(
  utils::ElementOf<double, SquareMatrix<Dual<Dual<double, 4>, 2>, L>>);
// auto x = Dual<Dual<double, 4>, 2>{1.0};
// auto y = x * 3.4;

static_assert(std::convertible_to<int, Dual<double, 4>>);
static_assert(std::convertible_to<int, Dual<Dual<double, 4>, 2>>);

template <class D> struct URand {
  using T = typename D::val_type;
  static constexpr size_t N = D::num_partials;
  auto operator()(std::mt19937_64 &mt) -> D {
    Dual<T, N> x{URand<T>{}(mt)};
    for (size_t i = 0; i < N; ++i) x.gradient()[i] = URand<T>{}(mt);
    return x;
  }
};
template <> struct URand<double> {
  auto operator()(std::mt19937_64 &mt) -> double {
    return std::uniform_real_distribution<double>(-2, 2)(mt);
  }
};

constexpr auto extractDualValRecurse(const auto &x) { return x; }
template <class T, size_t N>
constexpr auto extractDualValRecurse(const Dual<T, N> &x) {
  return extractDualValRecurse(x.value());
  // return x.value();
}
template <AbstractMatrix T> constexpr auto evalpoly(const T &C, const auto &p) {
  using U = utils::eltype_t<T>;
  using S = SquareMatrix<U, L>;
  assert(C.numRow() == C.numCol());
  S A{SquareDims{C.numRow()}}, B{SquareDims{C.numRow()}};
  B << p[0] * C + I * p[1];
  for (size_t i = 2; i < p.size(); ++i) {
    std::swap(A, B);
    B << A * C + p[i] * I;
  }
  return B;
}
template <AbstractMatrix T>
constexpr void evalpoly(T &B, const T &C, const auto &p) {
  using U = utils::eltype_t<T>;
  using S = SquareMatrix<U, L>;
  size_t N = p.size();
  invariant(N > 0);
  invariant(size_t(C.numRow()), size_t(C.numCol()));
  invariant(size_t(B.numRow()), size_t(B.numCol()));
  invariant(size_t(B.numRow()), size_t(C.numRow()));
  S A{SquareDims{B.numRow()}};
  B << p[0] * C + p[1] * I;
  for (size_t i = 2; i < N; ++i) {
    std::swap(A, B);
    B << A * C + p[i] * I;
  }
}

template <AbstractMatrix T> constexpr auto opnorm1(const T &A) {
  using S = decltype(extractDualValRecurse(std::declval<utils::eltype_t<T>>()));
  size_t n = size_t(A.numRow());
  invariant(n > 0);
  Vector<S> v;
  v.resizeForOverwrite(n);
  invariant(A.numRow() > 0);
  for (size_t j = 0; j < n; ++j)
    v[j] = std::abs(extractDualValRecurse(A(0, j)));
  for (size_t i = 1; i < n; ++i)
    for (size_t j = 0; j < n; ++j)
      v[j] += std::abs(extractDualValRecurse(A(i, j)));
  return *std::max_element(v.begin(), v.end());
}

template <AbstractMatrix T> constexpr auto expm(const T &A) {
  using S = utils::eltype_t<T>;
  unsigned n = unsigned(A.numRow());
  auto nA = opnorm1(A);
  SquareMatrix<S, L> A2{A * A}, U{SquareDims{n}}, V{SquareDims{n}};
  SquareMatrix<S, L> *Up = &U, *Vp = &V;
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
    evalpoly(V, A2, p0);
    U << A * V;
    evalpoly(V, A2, p1);
  } else {
    s = std::max(int(std::ceil(std::log2(nA / 5.4))), 0);
    double t = 1.0;
    if (s > 0) {
      t = 1.0 / std::exp2(s);
      A2 *= (t * t);
      if (s & 1) std::swap(Up, Vp);
    }
    SquareMatrix<S, L> A4{A2 * A2}, A6{A2 * A4};

    *Vp << A6 * (A6 + 16380 * A4 + 40840800 * A2) +
             (33522128640 * A6 + 10559470521600 * A4 + 1187353796428800 * A2) +
             32382376266240000 * I;
    *Up << A * (*Vp);
    if (s > 0) (*Up) *= t;
    *Vp << A6 * (182 * A6 + 960960 * A4 + 1323241920 * A2) +
             (670442572800 * A6 + 129060195264000 * A4 +
              7771770303897600 * A2) +

             64764752532480000 * I;
  }
  for (auto v = Vp->begin(), u = Up->begin(), e = Vp->end(); v != e; ++v, ++u) {
    auto &&d = *v - *u;
    *v += *u;
    *u = d;
  }
  // return (V - U) \ (V + U);
  // LU::fact(std::move(U)).ldiv(MutPtrMatrix<S>(V));
  LU::ldiv(*Up, MutPtrMatrix<S>(*Vp));
  for (; s--;) {
    *Up = (*Vp) * (*Vp);
    std::swap(Up, Vp);
  }
  return V;
}

template <typename T> static void expm(T *A, T *B, size_t N) {
  MutSquarePtrMatrix<T>(A, N) << expm(SquarePtrMatrix<T>(B, N));
}
} // namespace poly::math

using poly::math::expm, poly::math::Dual;

template <size_t N, size_t M> using DDual = Dual<Dual<double, N>, M>;

extern "C" {
void __attribute__((visibility("default")))
expmf64(double *A, double *B, size_t N) {
  expm(A, B, N);
}

void __attribute__((visibility("default")))
expmf64d1(Dual<double, 1> *A, Dual<double, 1> *B, size_t N) {
  expm(A, B, N);
}
void __attribute__((visibility("default")))
expmf64d2(Dual<double, 2> *A, Dual<double, 2> *B, size_t N) {
  expm(A, B, N);
}
void __attribute__((visibility("default")))
expmf64d3(Dual<double, 3> *A, Dual<double, 3> *B, size_t N) {
  expm(A, B, N);
}
void __attribute__((visibility("default")))
expmf64d4(Dual<double, 4> *A, Dual<double, 4> *B, size_t N) {
  expm(A, B, N);
}
void __attribute__((visibility("default")))
expmf64d5(Dual<double, 5> *A, Dual<double, 5> *B, size_t N) {
  expm(A, B, N);
}
void __attribute__((visibility("default")))
expmf64d6(Dual<double, 6> *A, Dual<double, 6> *B, size_t N) {
  expm(A, B, N);
}
void __attribute__((visibility("default")))
expmf64d7(Dual<double, 7> *A, Dual<double, 7> *B, size_t N) {
  expm(A, B, N);
}
void __attribute__((visibility("default")))
expmf64d8(Dual<double, 8> *A, Dual<double, 8> *B, size_t N) {
  expm(A, B, N);
}
void __attribute__((visibility("default")))
expmf64d1d1(DDual<1, 1> *A, DDual<1, 1> *B, size_t N) {
  expm(A, B, N);
}
void __attribute__((visibility("default")))
expmf64d1d2(DDual<1, 2> *A, DDual<1, 2> *B, size_t N) {
  expm(A, B, N);
}
void __attribute__((visibility("default")))
expmf64d2d1(DDual<2, 1> *A, DDual<2, 1> *B, size_t N) {
  expm(A, B, N);
}
void __attribute__((visibility("default")))
expmf64d2d2(DDual<2, 2> *A, DDual<2, 2> *B, size_t N) {
  expm(A, B, N);
}
void __attribute__((visibility("default")))
expmf64d3d1(DDual<3, 1> *A, DDual<3, 1> *B, size_t N) {
  expm(A, B, N);
}
void __attribute__((visibility("default")))
expmf64d3d2(DDual<3, 2> *A, DDual<3, 2> *B, size_t N) {
  expm(A, B, N);
}
void __attribute__((visibility("default")))
expmf64d4d1(DDual<4, 1> *A, DDual<4, 1> *B, size_t N) {
  expm(A, B, N);
}
void __attribute__((visibility("default")))
expmf64d4d2(DDual<4, 2> *A, DDual<4, 2> *B, size_t N) {
  expm(A, B, N);
}
void __attribute__((visibility("default")))
expmf64d5d1(DDual<5, 1> *A, DDual<5, 1> *B, size_t N) {
  expm(A, B, N);
}
void __attribute__((visibility("default")))
expmf64d5d2(DDual<5, 2> *A, DDual<5, 2> *B, size_t N) {
  expm(A, B, N);
}
void __attribute__((visibility("default")))
expmf64d6d1(DDual<6, 1> *A, DDual<6, 1> *B, size_t N) {
  expm(A, B, N);
}
void __attribute__((visibility("default")))
expmf64d6d2(DDual<6, 2> *A, DDual<6, 2> *B, size_t N) {
  expm(A, B, N);
}
void __attribute__((visibility("default")))
expmf64d7d1(DDual<7, 1> *A, DDual<7, 1> *B, size_t N) {
  expm(A, B, N);
}
void __attribute__((visibility("default")))
expmf64d7d2(DDual<7, 2> *A, DDual<7, 2> *B, size_t N) {
  expm(A, B, N);
}
void __attribute__((visibility("default")))
expmf64d8d1(DDual<8, 1> *A, DDual<8, 1> *B, size_t N) {
  expm(A, B, N);
}
void __attribute__((visibility("default")))
expmf64d8d2(DDual<8, 2> *A, DDual<8, 2> *B, size_t N) {
  expm(A, B, N);
}
}
