#   CMake toolchain script
#
#   Targets Android 8, ARM
#   Called from build.sh via cmake

set (CMAKE_SYSTEM_NAME Linux)  # Tell CMake we're cross-compiling
set (ANDROID True)
set (BUILD_ANDROID True)

include (CMakeForceCompiler)

# where is the target environment
set (ANDROID_NDK_ROOT $ENV{ANDROID_NDK_ROOT})
set (ANDROID_SYS_ROOT $ENV{ANDROID_SYS_ROOT})
set (ANDROID_API_LEVEL $ENV{ANDROID_API_LEVEL})
set (TOOLCHAIN_PATH $ENV{TOOLCHAIN_PATH})
set (TOOLCHAIN_HOST $ENV{TOOLCHAIN_HOST})
set (TOOLCHAIN_ARCH $ENV{TOOLCHAIN_ARCH})

# api level see doc https://github.com/taka-no-me/android-cmake
set (CMAKE_INSTALL_PREFIX /tmp)
set (CMAKE_FIND_ROOT_PATH
    "${TOOLCHAIN_PATH}"
    "${CMAKE_INSTALL_PREFIX}"
    "${CMAKE_INSTALL_PREFIX}/share")

# Prefix detection only works with compiler id "GNU"
# CMake will look for prefixed g++, cpp, ld, etc. automatically
CMAKE_FORCE_C_COMPILER (${TOOLCHAIN_PATH}/arm-linux-androideabi-gcc GNU)

#   Find location of ZeroMQ header file
include (FindPkgConfig)
pkg_check_modules (PC_ZEROMQ "libzmq")
if (NOT PC_ZEROMQ_FOUND)
    pkg_check_modules(PC_ZEROMQ "zmq")
endif (NOT PC_ZEROMQ_FOUND)

if (PC_ZEROMQ_FOUND)
    set (PC_ZEROMQ_INCLUDE_HINTS ${PC_ZEROMQ_INCLUDE_DIRS} ${PC_ZEROMQ_INCLUDE_DIRS}/*)
endif (PC_ZEROMQ_FOUND)
find_path (ZEROMQ_INCLUDE_DIR NAMES zmq.h HINTS ${PC_ZEROMQ_INCLUDE_HINTS})

cmake_policy (SET CMP0015 NEW)   #  Use relative paths in link_directories

include_directories (
    ${ZEROMQ_INCLUDE_DIR}
    ../../../include
    ../../../bindings/jni/src/native/include
    ../../../builds/android/prefix/arm-linux-androideabi-4.9/include
    ${ANDROID_SYS_ROOT}/usr/include
)
link_directories (
    ../../../builds/android/prefix/arm-linux-androideabi-4.9/lib
    ${ANDROID_SYS_ROOT}/usr/lib
)
