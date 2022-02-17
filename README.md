FindFFTW3
=========

A CMake `find_package` module for the popular [FFTW3](http://fftw.org) library.

Finds and creates targets for the `double`, `float`, and `long double` versions,
as well as the `threads`, `omp`, and `mpi` parallel libraries. All of these
combinations can be searched for explicitly as `COMPONENTS`.

Target names follow the official target/library names, that is:

- ``FFTW3::fftw3``: ``double``, serial version
- ``FFTW3::fftw3f``: ``float``, serial version
- ``FFTW3::fftw3l``: ``long double``, serial version
- ``FFTW3::fftw3_threads``: ``double``, pthreads version
- ``FFTW3::fftw3f_threads``: ``float``, pthreads version
- ``FFTW3::fftw3l_threads``: ``long double``, pthreads version
- ``FFTW3::fftw3_omp``: ``double``, OpenMP version
- ``FFTW3::fftw3f_omp``: ``float``, OpenMP version
- ``FFTW3::fftw3l_omp``: ``long double``, OpenMP version
- ``FFTW3::fftw3_mpi``: ``double``, MPI version
- ``FFTW3::fftw3f_mpi``: ``float``, MPI version
- ``FFTW3::fftw3l_mpi``: ``long double``, MPI version

Example
-------

```cmake
find_package(FFTW3 COMPONENTS fftw3 fftw3_omp)

add_executable(test_find_fftw test_find_fftw.cxx)
target_link_libraries(test_find_fftw FFTW3::fftw3)

add_executable(test_find_fftw_openmp test_find_fftw_openmp.cxx)
find_package(OpenMP)
target_link_libraries(test_find_fftw_openmp FFTW3::fftw3_omp OpenMP::OpenMP_CXX)
```
