

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

# TODO: go back to loop and name targets same as official targets
set(Double fftw3)
set(DoubleThreads fftw3_threads)
set(DoubleOpenMP fftw3_omp)
set(DoubleMPI fftw3_mpi)
set(Float fftw3f)
set(FloatThreads fftw3f_threads)
set(FloatOpenMP fftw3f_omp)
set(FloatMPI fftw3f_mpi)
set(Long fftw3l)
set(LongThreads fftw3l_threads)
set(LongOpenMP fftw3l_omp)
set(LongMPI fftw3l_mpi)

set(_fftw_components
  Double
  DoubleThreads
  DoubleOpenMP
  DoubleMPI
  Float
  FloatThreads
  FloatOpenMP
  FloatMPI
  Long
  LongThreads
  LongOpenMP
  LongMPI
  )

foreach(_fftw_library_name IN LISTS _fftw_components)
  # TODO: if FFTW_ROOT set we should _insist_ on using it
  find_library(_fftw_${_fftw_library_name}_lib
      NAMES "${${_fftw_library_name}}"
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
  set(FFTW_${_fftw_component}_FOUND ${_fftw_${_fftw_component}_lib})
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
  if (_fftw_${_fftw_component}_lib AND NOT TARGET FFTW::${_fftw_component})
    add_library(FFTW::${_fftw_component} INTERFACE IMPORTED)
    set_target_properties(FFTW::${_fftw_component} PROPERTIES
      INTERFACE_INCLUDE_DIRECTORIES "${FFTW_INCLUDE_DIRS}"
      INTERFACE_LINK_LIBRARIES "${_fftw_${_fftw_component}_lib}"
      )
  endif()
endforeach()
