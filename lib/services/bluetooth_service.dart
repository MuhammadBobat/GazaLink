import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../models/bluetooth_device.dart';

class BluetoothService {
  static final BluetoothService _instance = BluetoothService._internal();
  factory BluetoothService() => _instance;
  BluetoothService._internal();

  final List<BluetoothDeviceInfo> _discoveredDevices = [];
  final List<BluetoothDeviceInfo> _connectedDevices = [];
  
  BluetoothScanStatus _scanStatus = BluetoothScanStatus.idle;
  BluetoothConnectionStatus _connectionStatus = BluetoothConnectionStatus.disconnected;
  
  bool _isBluetoothEnabled = false;
  StreamSubscription<List<ScanResult>>? _scanSubscription;
  bool _isInitialized = false;

  // Getters
  List<BluetoothDeviceInfo> get discoveredDevices => List.unmodifiable(_discoveredDevices);
  List<BluetoothDeviceInfo> get connectedDevices => List.unmodifiable(_connectedDevices);
  BluetoothScanStatus get scanStatus => _scanStatus;
  BluetoothConnectionStatus get connectionStatus => _connectionStatus;
  bool get isBluetoothEnabled => _isBluetoothEnabled;
  bool get isInitialized => _isInitialized;

  // Initialize Bluetooth service
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Check if Bluetooth is supported
      if (await FlutterBluePlus.isSupported == false) {
        throw Exception('Bluetooth not supported');
      }

      // Listen to Bluetooth state changes
      FlutterBluePlus.adapterState.listen((state) {
        _isBluetoothEnabled = state == BluetoothAdapterState.on;
        developer.log('Bluetooth state changed: $state', name: 'BluetoothService');
      });

      // Get initial state
      final initialState = await FlutterBluePlus.adapterState.first;
      _isBluetoothEnabled = initialState == BluetoothAdapterState.on;
      
      _isInitialized = true;
      developer.log('Bluetooth Service initialized successfully. Enabled: $_isBluetoothEnabled', name: 'BluetoothService');
    } catch (e) {
      developer.log('Error initializing Bluetooth: $e', name: 'BluetoothService');
      _isInitialized = false;
      rethrow;
    }
  }

  // Request permissions
  Future<bool> requestPermissions() async {
    try {
      if (!_isInitialized) {
        await initialize();
      }
      
      // Request location permission (required for Bluetooth scanning on Android)
      await FlutterBluePlus.turnOn();
      return true;
    } catch (e) {
      developer.log('Error requesting permissions: $e', name: 'BluetoothService');
      return false;
    }
  }

  // Start scanning
  Future<void> startScan() async {
    try {
      developer.log('Starting Bluetooth scan...', name: 'BluetoothService');
      
      if (!_isInitialized) {
        await initialize();
      }
      
      final hasPermissions = await requestPermissions();
      if (!hasPermissions) {
        developer.log('Bluetooth permissions not granted', name: 'BluetoothService');
        _scanStatus = BluetoothScanStatus.error;
        return;
      }

      if (!_isBluetoothEnabled) {
        developer.log('Bluetooth is not enabled', name: 'BluetoothService');
        _scanStatus = BluetoothScanStatus.error;
        return;
      }

      developer.log('Bluetooth is enabled, starting scan...', name: 'BluetoothService');
      _scanStatus = BluetoothScanStatus.scanning;
      _discoveredDevices.clear();

      // Start scanning
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 10),
        androidUsesFineLocation: false,
      );

      // Listen to scan results
      _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
        for (ScanResult result in results) {
          final deviceInfo = BluetoothDeviceInfo(
            id: result.device.remoteId.toString(),
            name: result.device.platformName.isEmpty 
                ? 'Unknown Device' 
                : result.device.platformName,
            rssi: result.rssi,
            isConnectable: result.advertisementData.connectable,
            device: result.device,
          );

          // Check if device already exists
          final existingIndex = _discoveredDevices.indexWhere(
            (d) => d.id == deviceInfo.id
          );

          if (existingIndex != -1) {
            _discoveredDevices[existingIndex] = deviceInfo;
          } else {
            _discoveredDevices.add(deviceInfo);
          }

          developer.log('Found real device: ${deviceInfo.name} (RSSI: ${deviceInfo.rssi})', name: 'BluetoothService');
        }
      });

      developer.log('Real Bluetooth scan started successfully', name: 'BluetoothService');
    } catch (e) {
      developer.log('Error starting scan: $e', name: 'BluetoothService');
      _scanStatus = BluetoothScanStatus.error;
    }
  }

  // Stop scanning
  Future<void> stopScan() async {
    try {
      developer.log('Stopping Bluetooth scan...', name: 'BluetoothService');
      _scanStatus = BluetoothScanStatus.stopped;
      
      await FlutterBluePlus.stopScan();
      await _scanSubscription?.cancel();
      _scanSubscription = null;
      
      developer.log('Real Bluetooth scan stopped successfully', name: 'BluetoothService');
    } catch (e) {
      developer.log('Error stopping scan: $e', name: 'BluetoothService');
    }
  }

  // Connect to a device
  Future<void> connectToDevice(String deviceId) async {
    try {
      developer.log('Connecting to device: $deviceId', name: 'BluetoothService');
      _connectionStatus = BluetoothConnectionStatus.connecting;
      
      final deviceInfo = _discoveredDevices.firstWhere(
        (d) => d.id == deviceId,
        orElse: () => throw Exception('Device not found'),
      );

      if (deviceInfo.device == null) {
        throw Exception('Device object not available');
      }

      // Connect to the device
      await deviceInfo.device!.connect(timeout: const Duration(seconds: 10));
      
      // Update device status
      final updatedDevice = deviceInfo.copyWith(isConnected: true);
      final index = _discoveredDevices.indexWhere((d) => d.id == deviceId);
      if (index != -1) {
        _discoveredDevices[index] = updatedDevice;
      }
      
      _connectedDevices.add(updatedDevice);
      _connectionStatus = BluetoothConnectionStatus.connected;
      
      developer.log('Successfully connected to real device: ${deviceInfo.name}', name: 'BluetoothService');
    } catch (e) {
      developer.log('Error connecting to device: $e', name: 'BluetoothService');
      _connectionStatus = BluetoothConnectionStatus.error;
      rethrow;
    }
  }

  // Disconnect from a device
  Future<void> disconnectFromDevice(String deviceId) async {
    try {
      developer.log('Disconnecting from device: $deviceId', name: 'BluetoothService');
      _connectionStatus = BluetoothConnectionStatus.disconnecting;
      
      final deviceInfo = _connectedDevices.firstWhere(
        (d) => d.id == deviceId,
        orElse: () => throw Exception('Device not connected'),
      );

      if (deviceInfo.device != null) {
        await deviceInfo.device!.disconnect();
      }
      
      // Update device status
      final updatedDevice = deviceInfo.copyWith(isConnected: false);
      final index = _discoveredDevices.indexWhere((d) => d.id == deviceId);
      if (index != -1) {
        _discoveredDevices[index] = updatedDevice;
      }
      
      _connectedDevices.removeWhere((d) => d.id == deviceId);
      _connectionStatus = BluetoothConnectionStatus.disconnected;
      
      developer.log('Successfully disconnected from real device: ${deviceInfo.name}', name: 'BluetoothService');
    } catch (e) {
      developer.log('Error disconnecting from device: $e', name: 'BluetoothService');
      _connectionStatus = BluetoothConnectionStatus.error;
      rethrow;
    }
  }

  // Get network topology data for DQL
  Map<String, dynamic> getNetworkTopologyData() {
    return {
      'timestamp': DateTime.now().toIso8601String(),
      'discoveredDevices': _discoveredDevices.map((d) => d.toJson()).toList(),
      'connectedDevices': _connectedDevices.length,
      'scanStatus': _scanStatus.name,
      'connectionStatus': _connectionStatus.name,
      'bluetoothEnabled': _isBluetoothEnabled,
    };
  }

  // Cleanup
  void dispose() {
    _scanSubscription?.cancel();
    _discoveredDevices.clear();
    _connectedDevices.clear();
    _scanStatus = BluetoothScanStatus.idle;
    _connectionStatus = BluetoothConnectionStatus.disconnected;
    _isInitialized = false;
  }
}
