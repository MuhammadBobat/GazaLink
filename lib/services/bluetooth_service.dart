import 'dart:async';
import 'dart:developer' as developer;
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../models/bluetooth_device.dart';
import '../models/message.dart';
import '../models/sync_status.dart';
import 'storage_service.dart';

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

  // Custom UUIDs for GazaLink
  static const String SERVICE_UUID = '9fa480e0-4967-4542-9390-d343dc5d04ae'; // GazaLink Service
  static const String MESSAGE_CHAR_UUID = 'af0badb1-5b99-43cd-917a-a77bc549e3cc'; // Message Queue Characteristic
  static const int MTU_SIZE = 512; // Maximum transmission unit size

  // Sync status
  final _syncStatusController = StreamController<SyncProgress>.broadcast();
  Stream<SyncProgress> get syncStatus => _syncStatusController.stream;
  SyncStatus _currentSyncStatus = SyncStatus.idle;

  // Retry configuration
  static const int MAX_RETRY_ATTEMPTS = 3;
  static const Duration RETRY_DELAY = Duration(seconds: 2);

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

      // Start scanning with service UUID filter
      _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
        for (ScanResult result in results) {
          // Only add devices that advertise our service UUID
          if (result.advertisementData.serviceUuids.contains(SERVICE_UUID)) {
            final deviceInfo = BluetoothDeviceInfo(
              id: result.device.remoteId.toString(),
              name: result.device.platformName.isEmpty 
                  ? 'Unknown Device' 
                  : result.device.platformName,
              rssi: result.rssi,
              isConnectable: result.advertisementData.connectable,
              device: result.device,
            );

            // Update or add device to list
            final index = _discoveredDevices.indexWhere((d) => d.id == deviceInfo.id);
            if (index != -1) {
              _discoveredDevices[index] = deviceInfo;
            } else {
              _discoveredDevices.add(deviceInfo);
            }

            developer.log('Found GazaLink device: ${deviceInfo.name} (RSSI: ${deviceInfo.rssi})', name: 'BluetoothService');
          }
        }
      });

      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 10),
        androidScanMode: AndroidScanMode.lowLatency,
        withServices: [Guid(SERVICE_UUID)], // Only scan for devices with our service
      );

      developer.log('GazaLink Bluetooth scan started successfully', name: 'BluetoothService');
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
      
      developer.log('GazaLink Bluetooth scan stopped successfully', name: 'BluetoothService');
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
      
      developer.log('Successfully connected to GazaLink device: ${deviceInfo.name}', name: 'BluetoothService');
      
      // Trigger message queue synchronization upon connection
      await syncMessageQueues();
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
      
      developer.log('Successfully disconnected from GazaLink device: ${deviceInfo.name}', name: 'BluetoothService');
    } catch (e) {
      developer.log('Error disconnecting from device: $e', name: 'BluetoothService');
      _connectionStatus = BluetoothConnectionStatus.error;
      rethrow;
    }
  }

  // Sync message queues with connected device
  Future<void> syncMessageQueues() async {
    try {
      developer.log('Starting message queue synchronization...', name: 'BluetoothService');
      
      if (_connectedDevices.isEmpty) {
        developer.log('No connected devices to sync with', name: 'BluetoothService');
        return;
      }

      // Step 3: Automatically trigger sending the local queue as JSON
      await _sendLocalQueueToPeers();
      
      developer.log('Message queue sync completed', name: 'BluetoothService');
      
    } catch (e) {
      developer.log('Error during message queue sync: $e', name: 'BluetoothService');
      rethrow;
    }
  }

  // Send local message queue to all connected peers
  Future<void> _sendLocalQueueToPeers() async {
    try {
      final storageService = StorageService();
      final localMessagesJson = await storageService.getMessagesAsJson();
      
      _updateSyncStatus(
        SyncStatus.inProgress,
        0.0,
        'Preparing to send messages to ${_connectedDevices.length} peer(s)',
      );

      // Split data into chunks if needed
      final chunks = _splitDataIntoChunks(localMessagesJson);
      final totalChunks = chunks.length;
      
      for (final connectedDevice in _connectedDevices) {
        try {
          // Discover services
          _updateSyncStatus(
            SyncStatus.inProgress,
            0.1,
            'Discovering services on ${connectedDevice.name}...',
          );
          
          final services = await connectedDevice.device!.discoverServices();
          final service = services.firstWhere(
            (s) => s.serviceUuid.toString() == SERVICE_UUID,
            orElse: () => throw Exception('Required GazaLink service not found'),
          );
          
          final characteristic = service.characteristics.firstWhere(
            (c) => c.characteristicUuid.toString() == MESSAGE_CHAR_UUID,
            orElse: () => throw Exception('Required GazaLink message characteristic not found'),
          );

          // Send data chunks
          int sentChunks = 0;
          for (final chunk in chunks) {
            await _sendChunkWithRetry(characteristic, chunk);
            sentChunks++;
            
            final progress = (sentChunks / totalChunks) * 0.5; // 50% progress for sending
            _updateSyncStatus(
              SyncStatus.inProgress,
              progress,
              'Sending messages to ${connectedDevice.name} (${sentChunks}/$totalChunks)',
            );
          }

          // Wait for and process response
          _updateSyncStatus(
            SyncStatus.inProgress,
            0.75,
            'Receiving messages from ${connectedDevice.name}...',
          );
          
          final response = await _receiveDataWithRetry(characteristic);
          await _receiveMessageQueueFromPeer(response, connectedDevice.id);
          
          _updateSyncStatus(
            SyncStatus.completed,
            1.0,
            'Sync completed with ${connectedDevice.name}',
          );
        } catch (e) {
          developer.log('Error syncing with device ${connectedDevice.name}: $e', name: 'BluetoothService');
          _updateSyncStatus(
            SyncStatus.error,
            0.0,
            'Error syncing with ${connectedDevice.name}',
            error: e.toString(),
          );
          // Continue with next device even if one fails
          continue;
        }
      }
    } catch (e) {
      developer.log('Error sending local queue: $e', name: 'BluetoothService');
      _updateSyncStatus(
        SyncStatus.error,
        0.0,
        'Error sending messages',
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Split data into MTU-sized chunks
  List<List<int>> _splitDataIntoChunks(String data) {
    final bytes = utf8.encode(data);
    final chunks = <List<int>>[];
    
    for (var i = 0; i < bytes.length; i += MTU_SIZE) {
      final end = (i + MTU_SIZE < bytes.length) ? i + MTU_SIZE : bytes.length;
      chunks.add(bytes.sublist(i, end));
    }
    
    return chunks;
  }

  // Send a chunk with retry logic
  Future<void> _sendChunkWithRetry(BluetoothCharacteristic characteristic, List<int> chunk, [int attempt = 1]) async {
    try {
      await characteristic.write(chunk, withoutResponse: false);
    } catch (e) {
      if (attempt < MAX_RETRY_ATTEMPTS) {
        developer.log('Retry attempt $attempt for chunk', name: 'BluetoothService');
        await Future.delayed(RETRY_DELAY);
        await _sendChunkWithRetry(characteristic, chunk, attempt + 1);
      } else {
        throw Exception('Failed to send chunk after $MAX_RETRY_ATTEMPTS attempts');
      }
    }
  }

  // Receive data with retry logic
  Future<String> _receiveDataWithRetry(BluetoothCharacteristic characteristic, [int attempt = 1]) async {
    try {
      final receivedChunks = <List<int>>[];
      
      while (true) {
        final value = await characteristic.read();
        if (value.isEmpty) break; // End of transmission
        receivedChunks.add(value);
      }
      
      final allBytes = receivedChunks.expand((chunk) => chunk).toList();
      return utf8.decode(allBytes);
    } catch (e) {
      if (attempt < MAX_RETRY_ATTEMPTS) {
        developer.log('Retry attempt $attempt for receiving data', name: 'BluetoothService');
        await Future.delayed(RETRY_DELAY);
        return _receiveDataWithRetry(characteristic, attempt + 1);
      } else {
        throw Exception('Failed to receive data after $MAX_RETRY_ATTEMPTS attempts');
      }
    }
  }

  // Receive and merge incoming message queue from peer
  Future<void> _receiveMessageQueueFromPeer(String jsonData, String peerDeviceId) async {
    try {
      developer.log('Processing incoming messages from peer: $peerDeviceId', name: 'BluetoothService');
      
      final storageService = StorageService();
      await storageService.mergeIncomingMessages(jsonData);
      
      // Update delivery status for messages we just received
      await _updateDeliveryStatusesForReceivedMessages(jsonData);
      
      developer.log('Successfully merged messages from peer: $peerDeviceId', name: 'BluetoothService');
      
    } catch (e) {
      developer.log('Error receiving messages from peer $peerDeviceId: $e', name: 'BluetoothService');
      rethrow;
    }
  }

  // Update delivery statuses for received messages
  Future<void> _updateDeliveryStatusesForReceivedMessages(String jsonData) async {
    try {
      final List<dynamic> messagesData = jsonDecode(jsonData);
      final storageService = StorageService();
      
      for (final messageData in messagesData) {
        final message = Message.fromJson(messageData);
        // Mark messages as "sent" since we received them from another device
        await storageService.updateDeliveryStatus(message.id, DeliveryStatus.sent);
      }
      
      developer.log('Updated delivery statuses for ${messagesData.length} received messages', name: 'BluetoothService');
      
    } catch (e) {
      developer.log('Error updating delivery statuses: $e', name: 'BluetoothService');
    }
  }

  // Update sync status
  void _updateSyncStatus(SyncStatus status, double progress, String message, {String? error}) {
    _currentSyncStatus = status;
    _syncStatusController.add(SyncProgress(
      status: status,
      progress: progress,
      message: message,
      error: error,
    ));
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
    _syncStatusController.close();
    _scanSubscription?.cancel();
    _discoveredDevices.clear();
    _connectedDevices.clear();
    _scanStatus = BluetoothScanStatus.idle;
    _connectionStatus = BluetoothConnectionStatus.disconnected;
    _isInitialized = false;
  }
}