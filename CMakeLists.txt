cmake_minimum_required(VERSION 3.16)
project(PiSecurityCam CXX)

# Use Clang explicitly
set(CMAKE_CXX_COMPILER clang++)
set(CMAKE_C_COMPILER clang)

# Enable compile_commands.json
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Find required packages
find_package(spdlog REQUIRED)

# Define system include paths
set(LIBCAMERA_INCLUDE_DIR "/usr/include/libcamera")
set(OPENCV_INCLUDE_DIR "/usr/include/opencv4")
set(FFMPEG_INCLUDE_DIR "/usr/include")  # FFmpeg headers are usually directly in here

# Set the C++ standard
set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Add your executable
add_executable(PiSecurityCam src/main.cpp)

# Manually specify include directories
target_include_directories(PiSecurityCam PRIVATE
    ${LIBCAMERA_INCLUDE_DIR}
    ${OPENCV_INCLUDE_DIR}
    ${FFMPEG_INCLUDE_DIR}
    ${PROJECT_SOURCE_DIR}/include
)

# Manually link required libraries
target_link_libraries(PiSecurityCam PRIVATE
    camera                         # libcamera
    camera-base                    # libcamera-base
    opencv_core                    # OpenCV core module
    opencv_imgproc                 # OpenCV image processing
    opencv_videoio                 # OpenCV video I/O
    avcodec                        # FFmpeg codec
    avformat                       # FFmpeg format handling
    avutil                         # FFmpeg utility functions
    swscale                        # FFmpeg scaling
    spdlog::spdlog                 # spdlog for logging
)
