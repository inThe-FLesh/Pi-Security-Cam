cmake_minimum_required(VERSION 3.16)
project(PiSecurityCam CXX)

# Use Clang explicitly
set(CMAKE_CXX_COMPILER clang++)
set(CMAKE_C_COMPILER clang)

# Enable compile_commands.json
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Find required packages
find_package(spdlog REQUIRED)
find_package(OpenCV REQUIRED COMPONENTS core imgproc)

# Find libcamera libs and headers
find_path(LIBCAMERA_INCLUDE_DIR
  NAMES libcamera/camera_manager.h
  PATHS /usr/include/libcamera /usr/local/include/libcamera
)

find_library(LIBCAMERA_LIB
  NAMES camera
  PATHS /usr/lib /usr/lib/aarch64-linux-gnu
)

find_library(LIBCAMERA_BASE_LIB
  NAMES camera-base
  PATHS /usr/lib /usr/lib/aarch64-linux-gnu
)

message(STATUS "libcamera include: ${LIBCAMERA_INCLUDE_DIR}")
message(STATUS "libcamera lib: ${LIBCAMERA_LIB}")
message(STATUS "libcamera base lib: ${LIBCAMERA_BASE_LIB}")

if(NOT LIBCAMERA_INCLUDE_DIR OR NOT LIBCAMERA_LIB OR NOT LIBCAMERA_BASE_LIB)
  message(FATAL_ERROR "❌ libcamera not found. Cannot build this project.")
endif()

# Define system include paths
set(OPENCV_INCLUDE_DIR "/usr/include/opencv4")
set(FFMPEG_INCLUDE_DIR "/usr/include")  # FFmpeg headers are usually directly in here

# Set the C++ standard
set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Add your executable
add_executable(PiSecurityCam 
    src/main.cpp
    src/pi_camera/pi_device_camera_manager.cpp
)

# Manually specify include directories
target_include_directories(PiSecurityCam PRIVATE
    ${LIBCAMERA_INCLUDE_DIR}
    ${OPENCV_INCLUDE_DIR}
    ${FFMPEG_INCLUDE_DIR}
    ${PROJECT_SOURCE_DIR}/include
)

# Manually link required libraries
target_link_libraries(PiSecurityCam PRIVATE
    ${OpenCV_LIBS}
    ${LIBCAMERA_LIB}
    ${LIBCAMERA_BASE_LIB}
    spdlog::spdlog         # logging library
    fmt::fmt
)