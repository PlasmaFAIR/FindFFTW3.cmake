

find_package(PkgConfig)

if (PKG_CONFIG_FOUND AND NOT FFTW_ROOT)
  pkg_check_modules(PKG_FFTW QUIET "fftw3")
endif()

if (PKG_FFTW_LIBRARY_DIRS)
  set(_fftw_library_hint_dir "${PKG_FFTW_LIBRARY_DIRS}")
  set(_fftw_include_hint_dir "${PKG_FFTW_INCLUDE_DIRS}")
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

  get_filename_component(_fftw_wisdom_tmp "${FFTW_WISDOM}" DIRECTORY)
  get_filename_component(_fftw_hint_dir "${_fftw_wisdom_tmp}" DIRECTORY)

  set(_fftw_library_hint_dir "${_fftw_hint_dir}")
  set(_fftw_include_hint_dir "${_fftw_hint_dir}")
endif()

if (FFTW_DEBUG)
  message(STATUS "FFTW library hint dir: ${_fftw_library_hint_dir}")
  message(STATUS "FFTW include hint dir: ${_fftw_include_hint_dir}")
endif()

set(_fftw_library_names "")
foreach(_fftw_type IN ITEMS "" "f" "l")
  list(APPEND _fftw_library_names "fftw3${_fftw_type}")
  foreach(_fftw_parallel IN ITEMS "threads" "omp" "mpi")
    list(APPEND _fftw_library_names "fftw3${_fftw_type}_${_fftw_parallel}")
  endforeach()
endforeach()

if (FFTW_DEBUG)
  message(STATUS "FFTW libraries: ${_fftw_library_names}")
endif()

foreach(_fftw_library_name IN LISTS _fftw_library_names)
  find_library(_fftw_${_fftw_library_name}_lib
      NAMES "${_fftw_library_name}"
      PATH_SUFFIXES "lib" "lib64"
      HINTS "${_fftw_library_hint_dir}"
      )
  if (FFTW_DEBUG)
    message(STATUS "Looking for ${_fftw_library_name}: _fftw_${_fftw_library_name}_lib = ${_fftw_${_fftw_library_name}_lib}")
  endif()
endforeach()

find_path(FFTW_INCLUDE_DIRS
  NAMES "fftw3.h"
  PATH_SUFFIXES "include"
  HINTS "${_fftw_include_hint_dir}"
  )

set(FFTW_DOUBLE_LIB_FOUND ${_fftw_fftw_lib})

include(FindPackageHandleStandardArgs)

find_package_handle_standard_args(FFTW
  REQUIRED_VARS FFTW_INCLUDE_DIRS
  HANDLE_COMPONENTS
  )

if (NOT FFTW_FOUND)
  return()
endif()

function(_fftw_add_target TARGET_NAME LIB_NAME)
  if (LIB_NAME AND NOT TARGET FFTW::${TARGET_NAME})
    message(STATUS "Making FFTW target ${TARGET_NAME}")
    add_library(FFTW::${TARGET_NAME} INTERFACE IMPORTED)
    set_target_properties(FFTW::${TARGET_NAME} PROPERTIES
      INTERFACE_INCLUDE_DIRECTORIES "${FFTW_INCLUDE_DIRS}"
      INTERFACE_LINK_LIBRARIES "${LIB_NAME}"
      )
  endif()
endfunction()

_fftw_add_target(Double "${_fftw_fftw3_lib}")
_fftw_add_target(DoubleThreads "${_fftw_fftw3_threads_lib}")
_fftw_add_target(DoubleOpenMP "${_fftw_fftw3_omp_lib}")
_fftw_add_target(DoubleMPI "${_fftw_fftw3_mpi_lib}")
_fftw_add_target(Float "${_fftw_fftw3f_lib}")
_fftw_add_target(FloatThreads "${_fftw_fftw3f_threads_lib}")
_fftw_add_target(FloatOpenMP "${_fftw_fftw3f_omp_lib}")
_fftw_add_target(FloatMPI "${_fftw_fftw3f_mpi_lib}")
_fftw_add_target(Long "${_fftw_fftw3l_lib}")
_fftw_add_target(LongThreads "${_fftw_fftw3l_threads_lib}")
_fftw_add_target(LongOpenMP "${_fftw_fftw3l_omp_lib}")
_fftw_add_target(LongMPI "${_fftw_fftw3l_mpi_lib}")
