#!/bin/bash
# Exit immediately if a command exits with a non-zero status
set -e

echo "Downloading Flutter SDK..."
git clone https://github.com/flutter/flutter.git -b stable

echo "Adding Flutter to PATH..."
export PATH="$PATH:`pwd`/flutter/bin"

echo "Verifying Flutter version..."
flutter --version

echo "Building Flutter Web..."
flutter build web --release
