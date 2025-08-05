# GazaLink - Offline Bluetooth P2P Communication for Crisis Zones

A Flutter mobile application designed for reliable offline communication in crisis zones with severely limited infrastructure. The app enables direct device-to-device message exchange solely via Bluetooth peer-to-peer connections, with no internet, WiFi, or cellular dependency.

## 🚀 Features

### ✅ Completed Features
- **Offline Message Creation & Storage**: Create and manage messages locally with priority levels and timestamps
- **Priority-Based Message Queue**: Messages sorted and relayed based on priority (urgent messages first)
- **Real Bluetooth P2P Syncing**: Devices discover and connect over Bluetooth for message exchange
- **Cross-Platform Support**: Works on both iOS and Android
- **Modern UI**: Clean, intuitive interface with Material Design 3
- **Local Storage**: Persistent message storage using SharedPreferences
- **Device Status Dashboard**: Real-time Bluetooth connectivity and app statistics

### 🔄 In Development
- **Deep Q-Learning Backend**: Python backend with DRL agent for routing optimization (when internet available)
- **Message Encryption**: End-to-end encryption for secure communication
- **Network Topology Mapping**: Advanced routing algorithms for fragmented networks

## 🛠 Technical Stack

### Frontend
- **Framework**: Flutter 3.8+
- **Language**: Dart
- **State Management**: Provider
- **Navigation**: Go Router
- **UI**: Material Design 3

### Bluetooth & Storage
- **Bluetooth**: flutter_blue_plus (Real BLE functionality)
- **Local Storage**: SharedPreferences
- **Device Management**: Cross-platform Bluetooth device discovery and connection

### Backend (Planned)
- **Framework**: Python FastAPI
- **ML**: PyTorch/TensorFlow for Deep Q-Learning
- **Data Exchange**: JSON over HTTP (when internet available)

## 📱 Platform Support

### iOS
- ✅ **Real Bluetooth functionality** (No Apple Developer account required for testing)
- ✅ **Free development** using personal Apple ID
- ✅ **7-day app validity** (renewable)
- ✅ **All native features** including Bluetooth, camera, etc.

### Android
- ✅ **Real Bluetooth functionality**
- ✅ **Free development and testing**
- ✅ **All native features**

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.8+
- Dart SDK 3.8+
- iOS: Xcode 15+ (for iOS development)
- Android: Android Studio (for Android development)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd GazaLink
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   # For iOS
   flutter run -d ios
   
   # For Android
   flutter run -d android
   ```

### iOS Setup (Free Development)

1. **Open Xcode project**
   ```bash
   open ios/Runner.xcworkspace
   ```

2. **Configure signing**
   - Select "Runner" target
   - Go to "Signing & Capabilities"
   - Check "Automatically manage signing"
   - Select your personal Apple ID as Team
   - Update Bundle Identifier to unique value (e.g., `com.yourname.gazalink`)

3. **Run on device**
   - Connect iPhone via USB
   - Enable Developer Mode on iPhone
   - Trust your Apple ID in Settings > General > VPN & Device Management
   - Run from Xcode or Flutter

### Android Setup

1. **Enable Developer Options**
   - Go to Settings > About Phone
   - Tap "Build Number" 7 times
   - Enable "USB Debugging"

2. **Connect device**
   - Connect Android device via USB
   - Allow USB debugging when prompted

3. **Run app**
   ```bash
   flutter run -d android
   ```

## 🔧 Development

### Project Structure
```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── message.dart         # Message model
│   └── bluetooth_device.dart # Bluetooth device model
├── services/                # Business logic
│   ├── bluetooth_service.dart # Bluetooth operations
│   └── storage_service.dart  # Local storage
├── screens/                 # UI screens
│   ├── message_queue_screen.dart
│   ├── message_create_screen.dart
│   └── dashboard_screen.dart
└── widgets/                 # Reusable widgets
    └── bluetooth_device_list.dart
```

### Key Features Implementation

#### Real Bluetooth Functionality
- Uses `flutter_blue_plus` for actual Bluetooth Low Energy (BLE) communication
- Device discovery, connection, and disconnection
- Signal strength monitoring (RSSI)
- Cross-platform compatibility

#### Message Management
- Priority-based sorting (urgent messages first)
- Persistent local storage
- Real-time status updates
- Message creation with validation

#### User Interface
- Material Design 3 components
- Responsive layout
- Intuitive navigation
- Real-time status indicators

## 🔒 Permissions

### iOS
- `NSBluetoothAlwaysUsageDescription`: Bluetooth communication
- `NSBluetoothPeripheralUsageDescription`: Device discovery
- `NSLocationWhenInUseUsageDescription`: Location for Bluetooth scanning

### Android
- `BLUETOOTH`: Basic Bluetooth functionality
- `BLUETOOTH_ADMIN`: Bluetooth administration
- `BLUETOOTH_SCAN`: Bluetooth device scanning
- `BLUETOOTH_CONNECT`: Bluetooth device connection
- `ACCESS_FINE_LOCATION`: Location for Bluetooth scanning
- `ACCESS_COARSE_LOCATION`: Approximate location

## 🧪 Testing

### Bluetooth Testing
- **Real devices required**: Bluetooth functionality needs physical devices
- **Two devices recommended**: For full P2P testing
- **Any Bluetooth device works**: For discovery testing

### Development Testing
- **Hot reload**: Supported for UI changes
- **Real Bluetooth**: Always active (no simulation)
- **Cross-platform**: Test on both iOS and Android

## 🚧 Known Issues & Solutions

### iOS Code Signing
- **Issue**: Code signing errors with free Apple ID
- **Solution**: Refresh signing in Xcode, ensure unique Bundle Identifier

### Bluetooth Permissions
- **Issue**: No devices found during scan
- **Solution**: Ensure location permissions granted, Bluetooth enabled

### Device Connection
- **Issue**: Connection timeouts
- **Solution**: Check device compatibility, signal strength

## 📈 Roadmap

### Phase 1: Core Functionality ✅
- [x] Flutter project setup
- [x] Message creation and storage
- [x] Basic UI and navigation

### Phase 2: Local Storage ✅
- [x] Persistent message storage
- [x] Priority-based message queue
- [x] Message status tracking

### Phase 3: Bluetooth Connectivity ✅
- [x] Real Bluetooth device discovery
- [x] Device connection and disconnection
- [x] Cross-platform compatibility

### Phase 4: Advanced Features (In Progress)
- [ ] Message encryption
- [ ] Network topology mapping
- [ ] Advanced routing algorithms

### Phase 5: Backend Integration (Planned)
- [ ] Python FastAPI backend
- [ ] Deep Q-Learning implementation
- [ ] Cloud synchronization (when internet available)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly on both platforms
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- Flutter team for the excellent cross-platform framework
- flutter_blue_plus contributors for Bluetooth functionality
- Material Design team for the design system

---

**GazaLink** - Empowering communication in crisis zones through innovative technology.
