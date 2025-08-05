import 'package:go_router/go_router.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/bluetooth_service.dart';
import '../services/storage_service.dart';
import '../models/message.dart';
import '../models/bluetooth_device.dart';
import '../widgets/bluetooth_device_list.dart';

class MessageQueueScreen extends StatefulWidget {
  const MessageQueueScreen({super.key});

  @override
  State<MessageQueueScreen> createState() => _MessageQueueScreenState();
}

class _MessageQueueScreenState extends State<MessageQueueScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Message> _messages = [];
  List<BluetoothDeviceInfo> _bluetoothDevices = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
    _initializeBluetooth();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    final storageService = context.read<StorageService>();
    final messages = await storageService.getSortedMessages();
    
    setState(() {
      _messages = messages;
      _isLoading = false;
    });
  }

  Future<void> _initializeBluetooth() async {
    try {
      final bluetoothService = context.read<BluetoothService>();
      await bluetoothService.initialize();
      
      // Update UI periodically
      Timer.periodic(const Duration(seconds: 2), (timer) {
        if (mounted) {
          setState(() {
            _bluetoothDevices = bluetoothService.discoveredDevices;
          });
        }
      });
    } catch (e) {
      // Don't crash the app if Bluetooth fails to initialize
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bluetooth initialization failed: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _refresh() async {
    setState(() => _isLoading = true);
    
    if (_tabController.index == 0) {
      await _loadData();
    } else {
      final bluetoothService = context.read<BluetoothService>();
      setState(() {
        _bluetoothDevices = bluetoothService.discoveredDevices;
      });
    }
    
    setState(() => _isLoading = false);
  }

  Future<void> _deleteMessage(String messageId) async {
    final storageService = context.read<StorageService>();
    await storageService.deleteMessage(messageId);
    await _loadData();
  }

  Future<void> _startBluetoothScan() async {
    try {
      final bluetoothService = context.read<BluetoothService>();
      await bluetoothService.startScan();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start Bluetooth scan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _stopBluetoothScan() async {
    try {
      final bluetoothService = context.read<BluetoothService>();
      await bluetoothService.stopScan();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to stop Bluetooth scan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _connectToDevice(String deviceId) async {
    final bluetoothService = context.read<BluetoothService>();
    try {
      await bluetoothService.connectToDevice(deviceId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Device connected successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Connection failed: $e')),
        );
      }
    }
  }

  Future<void> _disconnectFromDevice(String deviceId) async {
    final bluetoothService = context.read<BluetoothService>();
    try {
      await bluetoothService.disconnectFromDevice(deviceId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Device disconnected successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Disconnection failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'GazaLink',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Messages'),
            Tab(text: 'Bluetooth'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMessagesTab(),
          _buildBluetoothTab(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildMessagesTab() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: _messages.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.message_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No messages in queue',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Create your first message to get started',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageCard(message);
              },
            ),
    );
  }

  Widget _buildMessageCard(Message message) {
    final isUrgent = message.priority == Priority.urgent;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isUrgent
            ? BorderSide(color: Colors.red, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    message.content,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteMessage(message.id),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isUrgent ? Colors.red : Colors.blue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    message.priority.name.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatTimestamp(message.timestamp),
                  style: const TextStyle(color: Colors.grey),
                ),
                const Spacer(),
                Text(
                  message.deliveryStatus.name,
                  style: TextStyle(
                    color: message.deliveryStatus == DeliveryStatus.delivered
                        ? Colors.green
                        : Colors.orange,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBluetoothTab() {
    final bluetoothService = context.watch<BluetoothService>();
    
    return RefreshIndicator(
      onRefresh: _refresh,
      child: Column(
        children: [
          _buildBluetoothControls(bluetoothService),
          Expanded(
            child: BluetoothDeviceList(
              devices: _bluetoothDevices,
              scanStatus: bluetoothService.scanStatus,
              connectionStatus: bluetoothService.connectionStatus,
              onConnect: _connectToDevice,
              onDisconnect: _disconnectFromDevice,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBluetoothControls(BluetoothService bluetoothService) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: bluetoothService.scanStatus == BluetoothScanStatus.scanning
                      ? _stopBluetoothScan
                      : _startBluetoothScan,
                  icon: Icon(
                    bluetoothService.scanStatus == BluetoothScanStatus.scanning
                        ? Icons.stop
                        : Icons.search,
                  ),
                  label: Text(
                    bluetoothService.scanStatus == BluetoothScanStatus.scanning
                        ? 'Stop Scan'
                        : 'Start Scan',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: bluetoothService.scanStatus == BluetoothScanStatus.scanning
                        ? Colors.red
                        : Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildBluetoothStatus(bluetoothService),
        ],
      ),
    );
  }

  Widget _buildBluetoothStatus(BluetoothService bluetoothService) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                bluetoothService.isBluetoothEnabled
                    ? Icons.bluetooth_connected
                    : Icons.bluetooth_disabled,
                color: bluetoothService.isBluetoothEnabled
                    ? Colors.green
                    : Colors.red,
              ),
              const SizedBox(width: 8),
              Text(
                'Bluetooth: ${bluetoothService.isBluetoothEnabled ? "Enabled" : "Disabled"}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.search,
                color: bluetoothService.scanStatus == BluetoothScanStatus.scanning
                    ? Colors.blue
                    : Colors.grey,
              ),
              const SizedBox(width: 8),
              Text(
                'Scan: ${bluetoothService.scanStatus.name}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.link,
                color: bluetoothService.connectionStatus == BluetoothConnectionStatus.connected
                    ? Colors.green
                    : Colors.grey,
              ),
              const SizedBox(width: 8),
              Text(
                'Connection: ${bluetoothService.connectionStatus.name}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      currentIndex: 0,
      onTap: (index) {
        switch (index) {
          case 1:
            context.go('/create');
            break;
          case 2:
            context.go('/dashboard');
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.queue),
          label: 'Messages',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add),
          label: 'Create',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
      ],
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}
