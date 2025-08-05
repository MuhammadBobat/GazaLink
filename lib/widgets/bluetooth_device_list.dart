import 'package:flutter/material.dart';
import '../models/bluetooth_device.dart';

class BluetoothDeviceList extends StatelessWidget {
  final List<BluetoothDeviceInfo> devices;
  final BluetoothScanStatus scanStatus;
  final BluetoothConnectionStatus connectionStatus;
  final Function(String) onConnect;
  final Function(String) onDisconnect;

  const BluetoothDeviceList({
    super.key,
    required this.devices,
    required this.scanStatus,
    required this.connectionStatus,
    required this.onConnect,
    required this.onDisconnect,
  });

  @override
  Widget build(BuildContext context) {
    if (scanStatus == BluetoothScanStatus.scanning && devices.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Scanning for devices...'),
          ],
        ),
      );
    }

    if (devices.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bluetooth_disabled, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No devices found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Start scanning to discover nearby devices',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: devices.length,
      itemBuilder: (context, index) {
        final device = devices[index];
        return _buildDeviceCard(device);
      },
    );
  }

  Widget _buildDeviceCard(BluetoothDeviceInfo device) {
    final signalStrength = _getSignalStrength(device.rssi);
    final signalColor = _getSignalColor(device.rssi);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: device.isConnected
            ? BorderSide(color: Colors.green, width: 2)
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        device.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: ${device.id}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Icon(
                      signalStrength,
                      color: signalColor,
                      size: 20,
                    ),
                    Text(
                      '${device.rssi} dBm',
                      style: TextStyle(
                        fontSize: 12,
                        color: signalColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: device.isConnectable ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    device.isConnectable ? 'CONNECTABLE' : 'NOT CONNECTABLE',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                if (device.isConnected)
                  ElevatedButton(
                    onPressed: () => onDisconnect(device.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    child: const Text('Disconnect'),
                  )
                else
                  ElevatedButton(
                    onPressed: device.isConnectable
                        ? () => onConnect(device.id)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    child: const Text('Connect'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getSignalStrength(int rssi) {
    if (rssi >= -50) return Icons.bluetooth_connected;
    if (rssi >= -60) return Icons.bluetooth;
    if (rssi >= -70) return Icons.bluetooth_searching;
    if (rssi >= -80) return Icons.bluetooth_disabled;
    return Icons.bluetooth_disabled;
  }

  Color _getSignalColor(int rssi) {
    if (rssi >= -50) return Colors.green;
    if (rssi >= -60) return Colors.blue;
    if (rssi >= -70) return Colors.orange;
    if (rssi >= -80) return Colors.red;
    return Colors.grey;
  }
}
