# SPDX-License-Identifier: BSD-3
# Copyright (c) 2022, Peter Hill
#
# FindFFTW
# --------
#
# Finds the FFTW3 library for Fourier transforms.
# http://fftw.org
#
# Components
# ^^^^^^^^^^
#
# The following components can be specified:
#
# - ``fftw3``: ``double`` version
# - ``fftw3f``: ``float`` version
# - ``fftw3l``: ``long double`` version
#
# along with the following suffixes:
#
# - ``_threads``: pthreads version
# - ``_omp``: OpenMP version
# - ``_mpi``: MPI version
#
# So, for example to get the OpenMP ``float`` version, would be ``fftw3f_omp``.

# Variables
# ^^^^^^^^^
#
# ``FFTW_FOUND``
# ``FFTW_INCLUDE_DIRS``
# ``FFTW_<component>_LIBRARY``
# ``FFTW_VERSION``
# ``FFTW_DEBUG``: output some debug information
#
# Plus a target for each found component, in the ``FFTW3::`` namespace, for
# example ``FFTW3::fftw3_omp``

find_package(PkgConfig)

if (PKG_CONFIG_FOUND AND NOT FFTW_ROOT)
  pkg_check_modules(PKG_FFTW QUIET "fftw3")
endif()

if (PKG_FFTW_LIBRARY_DIRS)
  set(_fftw_library_hint_dir "${PKG_FFTW_LIBRARY_DIRS}")
  set(_fftw_include_hint_dir "${PKG_FFTW_INCLUDE_DIRS}")
  set(FFTW_VERSION ${PKG_FFTW_VERSION})
else()
  find_program(FFTW_WISDOM "fftw-wisdom"
    PATH_SUFFIXES bin
    DOC "Path to fftw-wisdom executable"
    )
  if (FFTW_DEBUG)
    message(STATUS "[ ${CMAKE_CURRENT_LIST_FILE}:${CMAKE_CURRENT_LIST_LINE} ] "
      " FFTW_WISDOM = ${FFTW_WISDOM}"
      )
  endif()

  execute_process(
    COMMAND "${FFTW_WISDOM} --version"
    OUTPUT_VARIABLE _fftw_wisdom_version
    )

  string(REGEX REPLACE ".*FFTW version \([0-9]+\.[0-9]+\.[0-9]+\).*" "\\1" FFTW_VERSION "${_fftw_wisdom_version}")

  get_filename_component(_fftw_wisdom_tmp "${FFTW_WISDOM}" DIRECTORY)
  get_filename_component(_fftw_hint_dir "${_fftw_wisdom_tmp}" DIRECTORY)

  set(_fftw_library_hint_dir "${_fftw_hint_dir}")
  set(_fftw_include_hint_dir "${_fftw_hint_dir}")
endif()

if (FFTW_DEBUG)
  message(STATUS "FFTW library hint dir: ${_fftw_library_hint_dir}")
  message(STATUS "FFTW include hint dir: ${_fftw_include_hint_dir}")
endif()

set(_fftw_components "")
set(_fftw_parallel_types "")
foreach(_fftw_type IN ITEMS "" "f" "l")
  list(APPEND _fftw_components "fftw3${_fftw_type}")
  foreach(_fftw_parallel IN ITEMS "threads" "omp" "mpi")
    set(_fftw_lib_name "fftw3${_fftw_type}_${_fftw_parallel}")
    list(APPEND _fftw_components "${_fftw_lib_name}")
    list(APPEND _fftw_parallel_types "${_fftw_lib_name}")
    set(${_fftw_lib_name}_base_lib "FFTW3::fftw3${_fftw_type}")
  endforeach()
endforeach()

foreach(_fftw_component IN LISTS _fftw_components)
  find_library(FFTW_${_fftw_component}_LIBRARY
    NAMES "${_fftw_component}"
    PATH_SUFFIXES "lib" "lib64"
    HINTS "${_fftw_library_hint_dir}"
    )
endforeach()

find_path(FFTW_INCLUDE_DIRS
  NAMES "fftw3.h"
  PATH_SUFFIXES "include"
  HINTS "${_fftw_include_hint_dir}"
  )

foreach(_fftw_component IN LISTS _fftw_components)
  if (FFTW_DEBUG)
    message(STATUS "FFTW_${_fftw_component}_LIBRARY: ${FFTW_${_fftw_component}_LIBRARY}")
  endif()
  set(FFTW_${_fftw_component}_FOUND ${FFTW_${_fftw_component}_LIBRARY})
endforeach()

include(FindPackageHandleStandardArgs)

find_package_handle_standard_args(FFTW
  REQUIRED_VARS FFTW_INCLUDE_DIRS
  VERSION_VAR FFTW_VERSION
  HANDLE_COMPONENTS
  )

if (NOT FFTW_FOUND)
  return()
endif()

foreach(_fftw_component IN LISTS _fftw_components)
  if (FFTW_${_fftw_component}_LIBRARY AND NOT TARGET FFTW::${_fftw_component})
    add_library(FFTW3::${_fftw_component} INTERFACE IMPORTED)
    set_target_properties(FFTW3::${_fftw_component} PROPERTIES
      INTERFACE_INCLUDE_DIRECTORIES "${FFTW_INCLUDE_DIRS}"
      INTERFACE_LINK_LIBRARIES "${FFTW_${_fftw_component}_LIBRARY};${${_fftw_component}_base_lib}"
      )
  endif()
endforeach()
