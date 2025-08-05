#!/bin/bash

echo "🚀 Setting up GazaLink Flutter Project..."

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed. Please install Flutter first:"
    echo "   https://docs.flutter.dev/get-started/install"
    exit 1
fi

echo "✅ Flutter is installed"

# Check Flutter version
echo "📱 Flutter version:"
flutter --version

# Clean and get dependencies
echo "🧹 Cleaning project..."
flutter clean

echo "📦 Getting dependencies..."
flutter pub get

# Analyze the project
echo "🔍 Analyzing project..."
flutter analyze

echo "✅ Setup complete!"
echo ""
echo "🎯 Next steps:"
echo "1. For iOS: open ios/Runner.xcworkspace in Xcode"
echo "2. For Android: connect Android device with USB debugging enabled"
echo "3. Run: flutter run"
echo ""
echo "📱 Platform-specific setup:"
echo "- iOS: Configure signing in Xcode with your Apple ID"
echo "- Android: Enable Developer Options and USB Debugging" 