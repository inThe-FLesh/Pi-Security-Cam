#pragma once

// std includes
#include <memory>

#include "libcamera/camera.h"

// lib includes
#include <libcamera/libcamera.h>
#include <spdlog/spdlog.h>

namespace pi_security_cam::pi_camera {

/**
 * @class CameraDeviceManager
 * @details This class creates and holds the libcamera CameraManager,
 *          and allows access to, and modification of the camera instances.
 */
class CameraDeviceManager {
   public:
    /**
     * @brief Creates an instance of the global camera manager, and starts it.
     *        Then, gets the available camera and configures it
     * @throws A std::runtime_error if the functions inside fail.
     */
    CameraDeviceManager();
    ~CameraDeviceManager();

    /**
     * @brief Releases the active camera stored in this class.
     * @throws std::runtime_error if release returns a value < 0
     */
    void release_camera();

    inline bool is_camera_active() const noexcept {
        return camera_active_;
    }

    inline bool is_camera_configured() const noexcept {
        return camera_configured_;
    }

    inline std::shared_ptr<libcamera::Camera> get_camera() const noexcept {
        return active_camera_;
    }

    inline std::shared_ptr<const libcamera::CameraConfiguration> get_configuration() const {
        return camera_configuration_;
    }

   private:
    std::unique_ptr<libcamera::CameraManager> manager_;
    std::shared_ptr<libcamera::Camera> active_camera_;
    std::shared_ptr<libcamera::CameraConfiguration> camera_configuration_;
    bool camera_active_ = false;
    bool camera_configured_ = false;

    /**
     * @brief A function to get the available camera, and place it in the
     *        active_camera_ variable.
     * @note I will only be connecting a single camera to the Pi so we just get
     *       whichever one is available
     * @throws A std::runtime_error if there are no cameras, or acquire returns a value < 0
     */
    void get_available_camera();

    /**
     * @brief A function to configure the camera
     * @throws A std::runtime_error if there is no active camera, or configuration fails
     */
    void configure_camera();

    /**
     * @brief A function to log the adjusted configuration of the camera, in the case where validate()
     *        returns Adjusted.
     * @param config The camera configuration to log
     */
    static void log_adjusted_configuration(const libcamera::CameraConfiguration& config);
};
}  // namespace pi_security_cam::pi_camera