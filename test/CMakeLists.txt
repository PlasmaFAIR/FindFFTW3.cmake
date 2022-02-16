cmake_minimum_required(VERSION 3.17)
project(test_find_fftw LANGUAGES CXX)

set(CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/.." ${CMAKE_MODULE_PATH})

find_package(FFTW)

add_executable(test_find_fftw test_find_fftw.cxx)
target_link_libraries(test_find_fftw FFTW::Double)
