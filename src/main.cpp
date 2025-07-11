#include "main.hpp"
#include <spdlog/spdlog.h>

int main(int argc, char *argv[]) {
    try {
        pi_security_cam::pi_camera::CameraDeviceManager cam;
        spdlog::info("Camera initialized and configured successfully.");
    } catch (const std::exception &e) {
        spdlog::error("Camera initialization failed: {}",  e.what());
        return 1;
    }

    return 0;
}