#!/bin/zsh
set -e
trap 'echo "❌ Build failed at line $LINENO"; exit 1' ERR

echo "🔍 Checking for presence of build directory"

if [[ -d build ]]; then
  echo "Build directory exists. Continuing build... ✅"
else
  mkdir build
  echo "Build directory created. 📁"
fi

cd build

echo "Starting ninja build with Clang ⚙️"

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
