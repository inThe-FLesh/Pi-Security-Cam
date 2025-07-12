#pragma once

#include <libcamera/libcamera.h>

namespace pi_security_cam::pi_camera {
class CameraSession {
   public:
    CameraSession();

    void configure();
    void start();
    void stop();

   private:
    std::unique_ptr<libcamera::CameraManager> camera_manager_;
    std::shared_ptr<libcamera::Camera> camera_;

    void setup_camera();
};

}  // namespace pi_security_cam::pi_camera