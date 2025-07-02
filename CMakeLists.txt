cmake_minimum_required(VERSION 4.0)
project(BMWSecureCam CXX)

set(CMAKE_CXX_COMPILER clang++)
set(CMAKE_C_COMPILER clang)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Find OpenCV
find_package(OpenCV REQUIRED)

# Find libcamera via pkg-config
find_package(PkgConfig REQUIRED)
find_package(OpenCV REQUIRED)
pkg_check_modules(libcamera REQUIRED IMPORTED_TARGET libcamera)

# Find FFmpeg manually via pkg-config
pkg_check_modules(FFMPEG REQUIRED IMPORTED_TARGET libavcodec libavformat libavutil libswscale)

# Add the executable
add_executable(BMSecureCam src/main.cpp)

# Link libraries
target_link_libraries(BMSecureCam
    PRIVATE
        PkgConfig::libcamera
        PkgConfig::FFMPEG
        OpenCV::OpenCV
)
