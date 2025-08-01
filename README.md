# GazaLink — Offline Bluetooth Peer-to-Peer Communication Optimizer

A React Native mobile app for reliable offline communication in crisis zones with severely limited infrastructure. The app enables direct device-to-device message exchange solely via Bluetooth peer-to-peer connections, with no internet, WiFi, or cellular dependency.

## 🎯 Project Objective

Build a practical, offline-capable Bluetooth P2P communication tool optimized for crisis zones, ensuring critical messages can be relayed reliably without infrastructure.

## 🚀 Core Features

- **Offline Message Creation & Storage**: Create and manage messages locally with priority levels and timestamps
- **Priority-Based Message Queue**: Messages sorted and relayed based on priority to ensure urgent communications propagate first
- **Bluetooth Peer-to-Peer Syncing**: Devices discover and connect over Bluetooth only, exchanging queued messages securely
- **Deep Reinforcement Learning Backend**: Python backend with Deep Q-Learning agent for routing optimization
- **Device & Message Status Dashboard**: Real-time display of message queue, Bluetooth connectivity, and syncing statistics
- **Cross-Platform Support**: Works on both Android and iOS with offline-first design

## 📱 Current Implementation

This initial version includes:

### Screens
1. **MessageQueueScreen**: Displays a list of messages with priority indicators and status
2. **MessageCreateScreen**: Form for creating new messages with text input and priority selector
3. **DashboardScreen**: Shows basic stats (total messages, pending messages, urgent messages) and Bluetooth status

### Features
- Clean, modern UI with consistent styling
- Navigation between all three screens
- Priority-based message categorization (Urgent/Normal)
- Mock data for demonstration purposes
- Responsive design with proper spacing and shadows

## 🛠 Technical Stack

- **Frontend**: React Native + TypeScript
- **Navigation**: React Navigation v6
- **UI Framework**: Expo
- **Local Storage**: AsyncStorage (planned)
- **Bluetooth**: react-native-ble-plx (planned)
- **Backend**: Python + FastAPI + PyTorch/TensorFlow (planned)

## 📦 Installation & Setup

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd GazaLink
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Start the development server**
   ```bash
   npm start
   ```

4. **Run on device/simulator**
   ```bash
   # For iOS
   npm run ios
   
   # For Android
   npm run android
   
   # For web (development)
   npm run web
   ```

## 🏗 Project Structure

```
GazaLink/
├── src/
│   ├── screens/
│   │   ├── MessageQueueScreen.tsx
│   │   ├── MessageCreateScreen.tsx
│   │   └── DashboardScreen.tsx
│   ├── types/
│   │   └── index.ts
│   └── components/
├── App.tsx
├── package.json
└── README.md
```

## 🎨 UI/UX Design

The app features a clean, modern interface with:
- **Color Scheme**: Dark blue header (#2c3e50) with light gray background (#f5f5f5)
- **Priority Indicators**: Red borders and badges for urgent messages
- **Card-based Layout**: Clean cards with shadows for better visual hierarchy
- **Consistent Navigation**: Bottom navigation buttons on all screens
- **Responsive Design**: Adapts to different screen sizes

## 🔄 User Flow

1. **Message Creation**: Users write messages and set priority levels
2. **Queue Management**: Messages are stored locally and displayed in priority order
3. **Bluetooth Discovery**: App automatically scans for nearby devices
4. **Message Exchange**: Connected devices exchange messages and update delivery status
5. **Dashboard Monitoring**: Real-time view of message statistics and connection health

## 🚧 Next Steps

### Phase 1: Core Functionality
- [ ] Implement local storage with AsyncStorage
- [ ] Add Bluetooth connectivity with react-native-ble-plx
- [ ] Create message persistence and queue management
- [ ] Implement device discovery and pairing

### Phase 2: Advanced Features
- [ ] Add message encryption for security
- [ ] Implement message routing algorithms
- [ ] Create offline-first data synchronization
- [ ] Add message delivery confirmation

### Phase 3: Backend Integration
- [ ] Develop Python FastAPI backend
- [ ] Implement Deep Q-Learning agent
- [ ] Add network optimization algorithms
- [ ] Create analytics and reporting

## 🤝 Contributing

This project is designed for crisis zone communication. Contributions are welcome, especially:
- Bluetooth connectivity improvements
- Security enhancements
- Performance optimizations
- UI/UX improvements
- Testing and documentation

## 📄 License

This project is open source and available under the MIT License.

## ⚠️ Important Notes

- This is a prototype/demonstration version
- Bluetooth functionality is not yet implemented
- Message storage is currently mock data
- Backend integration is planned for future phases

## 🆘 Support

For questions or support, please open an issue in the repository or contact the development team.

---

**GazaLink** - Enabling communication when infrastructure fails. 