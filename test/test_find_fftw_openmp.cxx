#include <fftw3.h>
#include <cmath>
#include <iostream>
#include <omp.h>

constexpr double pi = std::acos(-1);

int main() {
    fftw_init_threads();
    constexpr int N = 32;
    constexpr double norm = 1. / N;
    constexpr std::size_t nmodes = (N / 2) + 1;

    auto* in = static_cast<double*>(fftw_malloc(sizeof(double) * N));
    auto* out = static_cast<fftw_complex*>(fftw_malloc(sizeof(fftw_complex) * nmodes));
    fftw_plan_with_nthreads(omp_get_num_threads());
    fftw_plan p = fftw_plan_dft_r2c_1d(N, in, out, FFTW_ESTIMATE);

    for (std::size_t i = 0; i < N; ++i) {
      in[i] = std::cos(2. * pi * i / N);
    }

    fftw_execute(p);

    for (std::size_t i = 0; i < nmodes; ++i) {
      if (std::abs(out[i][0] * norm) <= 1.e-15) { out[i][0] = 0.; }
      if (std::abs(out[i][1] * norm) <= 1.e-15) { out[i][1] = 0.; }

      std::cout << "(" << out[i][0] * norm << ", " << out[i][1] * norm << ") ";
    }
    std::cout << "\n";

    fftw_destroy_plan(p);
    fftw_free(in);
    fftw_free(out);
    fftw_cleanup_threads();
}
