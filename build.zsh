#!/bin/zsh
set -e
trap "echo \"${RED}❌ Build failed at line \$LINENO${NC}\"; exit 1" ERR

# 🎨 Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RASPBERRY='\033[1;35m'
WHITE='\033[1;37m'
NC='\033[0m'

pkgman=""
is_rpi=false

detect_package_manager() {
  if command -v pacman &>/dev/null; then
    pkgman="pacman"
  elif command -v dpkg &>/dev/null; then
    pkgman="dpkg"
  else
    pkgman="unknown"
  fi
}

detect_raspberry_pi_os() {
  if [[ -f /etc/os-release ]] && grep -qiE 'raspbian|raspberrypi' /etc/os-release; then
    is_rpi=true
  elif grep -q "Raspberry Pi" /proc/cpuinfo; then
    is_rpi=true
  else
    is_rpi=false
  fi

  if $is_rpi; then
    echo "${RASPBERRY}🍓 Raspberry Pi OS detected${NC}${WHITE} — using RPi-specific OpenCV package.${NC}"
  fi
}

check_dependencies() {
  local any_missing=0
  detect_package_manager
  detect_raspberry_pi_os

  if [[ "$pkgman" == "pacman" ]]; then
    packages=(clang ninja cmake bear zsh libcamera opencv ffmpeg spdlog)
    for pkg in "${packages[@]}"; do
      if pacman -Q "$pkg" &>/dev/null; then
        echo "${GREEN}✅ $pkg is installed${NC}"
      else
        echo "${RED}❌ $pkg is missing${NC}"
        any_missing=1
      fi
    done

  elif [[ "$pkgman" == "dpkg" ]]; then
    packages=(clang ninja-build cmake bear zsh libcamera-dev libopencv-dev libspdlog-dev)
    for pkg in "${packages[@]}"; do
      if dpkg -s "$pkg" &>/dev/null; then
        echo "${GREEN}✅ $pkg is installed${NC}"
      else
        echo "${RED}❌ $pkg is missing${NC}"
        any_missing=1
      fi
    done
  else
    echo "${YELLOW}⚠️ No supported package manager found. Please install dependencies manually.${NC}"
    any_missing=1
  fi

  return $any_missing
}

# 🔍 Check and optionally install dependencies
if ! check_dependencies; then
  echo -n "📦 Do you want to install all required dependencies? (y/n): "
  read -k 1 choice
  echo
  case "$choice" in
    y|Y )
      echo "${BLUE}Installing dependencies... 🔧${NC}"
      if [[ "$pkgman" == "pacman" ]]; then
        sudo pacman -S --needed clang ninja cmake bear zsh libcamera opencv ffmpeg spdlog
      elif [[ "$pkgman" == "dpkg" ]]; then
        sudo apt update
        sudo apt install -y \
          build-essential ninja-build cmake bear clang zsh \
          libcamera-dev libopencv-dev libspdlog-dev || {
            echo "${YELLOW}⚠️ Attempting to fix broken packages...${NC}"
            sudo apt --fix-broken install -y || true
            sudo apt update
            sudo apt install -y \
              build-essential ninja-build cmake bear clang zsh \
              libcamera-dev libopencv-dev libspdlog-dev
        }
      fi
      ;;
    n|N )
      echo "${YELLOW}Skipping dependency installation. Build cancelled 🚫${NC}"
      exit 1
      ;;
    * )
      echo "${RED}Invalid choice. Please run the script again and choose 'y' or 'n'.${NC}"
      exit 1
      ;;
  esac
else
  echo "${GREEN}✅ All required dependencies are installed. Proceeding with the build...${NC}"
fi

# 🏗️ Proceed with build
echo "🔍 Checking for presence of build directory"

if [[ -d build ]]; then
  echo "${BLUE}Build directory exists. Continuing build... ✅${NC}"
else
  mkdir build
  echo "${BLUE}Build directory created. 📁${NC}"
fi

cd build

echo "${BLUE}Starting ninja build with Clang ⚙️${NC}"

cmake -G Ninja \
  -DCMAKE_C_COMPILER=clang \
  -DCMAKE_CXX_COMPILER=clang++ \
  ..

echo "${BLUE}Wrapping build with Bear 🐻${NC}"
bear -- ninja

cd ..

ln -sf build/compile_commands.json compile_commands.json
cp build/PiSecurityCam PiSecurityCam

echo "${GREEN}✅ Build Complete!${NC}"