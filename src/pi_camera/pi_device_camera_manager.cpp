#include "pi_camera/pi_device_camera_manager.hpp"

static constexpr int kDefaultCameraWidth = 2304;
static constexpr int kDefaultCameraHeight = 1296;

namespace pi_security_cam::pi_camera {
CameraDeviceManager::CameraDeviceManager() {
    manager_ = std::make_unique<libcamera::CameraManager>();
    manager_->start();

    get_available_camera();
    configure_camera();
}

CameraDeviceManager::~CameraDeviceManager() {
    if (camera_active_) {
        try {
            release_camera();
        } catch (std::runtime_error &err) {
            spdlog::error("Failed to release the camera during clean up of CameraDeviceManager. Error: {}", err.what());
        }
    }

    if (manager_) {
        manager_->stop();
    }
}

void CameraDeviceManager::release_camera() {
    if (!camera_active_) {
        spdlog::warn("Camera is not active, nothing to release");
        return;
    }

    int result = active_camera_->release();

    if (result < 0) {
        throw std::runtime_error("Failed to release the camera. Result: " + std::to_string(result));
    }

    spdlog::info("Successfully released the active camera.");
}

void CameraDeviceManager::get_available_camera() {
    if (manager_->cameras().empty()) {
        throw std::runtime_error("No cameras found");
    }

    // Get the first available and set it as the active camera
    active_camera_ = manager_->cameras().front();

    // Acquire the camera so that no other applications can use it
    int result = active_camera_->acquire();

    if (result < 0) {
        camera_active_ = false;
        throw std::runtime_error("Failed to acquire camera. Result: " + std::to_string(result));
    }

    camera_active_ = true;
}

void CameraDeviceManager::configure_camera() {
    if (!camera_active_) {
        throw std::runtime_error("Camera is not active, cannot configure");
    }

    // Generate a configuration for the camera
    auto config = active_camera_->generateConfiguration({libcamera::StreamRole::VideoRecording});

    if (!config) {
        throw std::runtime_error("Failed to generate camera configuration");
    }

    libcamera::StreamConfiguration &streamConfig = config->at(0);
    streamConfig.size.width = kDefaultCameraWidth;
    streamConfig.size.height = kDefaultCameraHeight;
    streamConfig.pixelFormat = libcamera::formats::YUV420;  // or NV12, RGB888, etc.
    streamConfig.colorSpace = libcamera::ColorSpace::Rec709;

    const auto validate_result = config->validate();

    if (validate_result == libcamera::CameraConfiguration::Valid) {
        spdlog::info("Camera configuration is valid");
    } else if (validate_result == libcamera::CameraConfiguration::Adjusted) {
        spdlog::warn("Camera configuration was adjusted:");
        log_adjusted_configuration(*config);
    } else {
        throw std::runtime_error("Camera configuration is invalid");
    }

    active_camera_->configure(config.get());

    camera_configured_ = true;

    camera_configuration_ = std::move(config);
}

void CameraDeviceManager::log_adjusted_configuration(const libcamera::CameraConfiguration &config) {
    spdlog::info("Adjusted camera configuration:");

    for (unsigned int i = 0; i < config.size(); ++i) {
        const libcamera::StreamConfiguration &streamConfig = config.at(i);
        spdlog::info("Stream {}: Size: {}x{}, Pixel Format: {}, Color Space: {}", i, streamConfig.size.width, streamConfig.size.height,
                     streamConfig.pixelFormat.toString(), streamConfig.colorSpace->toString());
    }
}
}  // namespace pi_security_cam::pi_camera