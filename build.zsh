#!/bin/zsh
set -e
trap 'echo "❌ Build failed at line $LINENO"; exit 1' ERR

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color


# Global for reuse
pkgman=""

detect_package_manager() {
  if command -v pacman &>/dev/null; then
    pkgman="pacman"
  elif command -v dpkg &>/dev/null; then
    pkgman="dpkg"
  else
    pkgman="unknown"
  fi
}

check_dependencies() {
  local any_missing=false
  detect_package_manager

  if [[ "$pkgman" == "pacman" ]]; then
    packages=(clang ninja cmake bear zsh libcamera opencv ffmpeg spdlog)
    for pkg in "${packages[@]}"; do
      if pacman -Q "$pkg" &>/dev/null; then
        echo "${GREEN}✅ $pkg is installed${NC}"
      else
        echo "${RED}❌ $pkg is missing${NC}"
        any_missing=true
      fi
    done

  elif [[ "$pkgman" == "dpkg" ]]; then
    packages=(clang ninja-build cmake bear zsh libcamera-dev libopencv-dev libavcodec-dev libavformat-dev libavutil-dev libswscale-dev libspdlog-dev)
    for pkg in "${packages[@]}"; do
      if dpkg -s "$pkg" &>/dev/null; then
        echo "${GREEN}✅ $pkg is installed${NC}"
      else
        echo "${RED}❌ $pkg is missing${NC}"
        any_missing=true
      fi
    done

  else
    echo "${RED}❌ Unsupported package manager. Please install dependencies manually.${NC}"
    exit 1
  fi

  $any_missing && return 1 || return 0
}

# 🔍 Check and optionally install dependencies
if ! check_dependencies; then
  echo -n "📦 Do you want to install all required dependencies? (y/n): "
  read choice
  case "$choice" in
    y|Y )
      echo "Installing dependencies... 🔧"
      if [[ "$pkgman" == "pacman" ]]; then
        sudo pacman -S --needed clang ninja cmake bear zsh libcamera opencv ffmpeg spdlog
      elif [[ "$pkgman" == "dpkg" ]]; then
        sudo apt update
        sudo apt install -y \
          build-essential ninja-build cmake bear clang zsh \
          libcamera-dev libopencv-dev \
          libavcodec-dev libavformat-dev libavutil-dev libswscale-dev \
          libspdlog-dev
      fi
      ;;
    n|N )
      echo "Skipping dependency installation. Build cancelled 🚫"
      exit 1
      ;;
    * )
      echo "Invalid choice. Please run the script again and choose 'y' or 'n'."
      exit 1
      ;;
  esac
else
  echo "All required dependencies are installed. ✅"
fi

# 🏗️ Proceed with build
echo "🔍 Checking for presence of build directory"

if [[ -d build ]]; then
  echo "Build directory exists. Continuing build... ✅"
else
  echo "${YELLOW}Build directory not found. Creating build directory... 🛠️${NC}"
  mkdir build
  echo "Build directory created. 📁"
fi

cd build

echo "${BLUE}Starting ninja build with Clang ⚙️"

cmake -G Ninja \
  -DCMAKE_C_COMPILER=clang \
  -DCMAKE_CXX_COMPILER=clang++ \
  ..

echo "Wrapping build with Bear 🐻"
bear -- ninja

cd ..

ln -sf build/compile_commands.json compile_commands.json

cp build/PiSecurityCam PiSecurityCam

echo "Build Complete ✅"