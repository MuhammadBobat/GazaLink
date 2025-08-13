import 'package:flutter/material.dart';
import '../models/sync_status.dart';
import '../services/bluetooth_service.dart';

class SyncProgressIndicator extends StatelessWidget {
  const SyncProgressIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final bluetoothService = BluetoothService();

    return StreamBuilder<SyncProgress>(
      stream: bluetoothService.syncStatus,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();

        final progress = snapshot.data!;
        
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _getBackgroundColor(progress.status),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (progress.status == SyncStatus.inProgress)
                LinearProgressIndicator(
                  value: progress.progress,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor,
                  ),
                ),
              const SizedBox(height: 8),
              Text(
                progress.message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (progress.error != null)
                Text(
                  progress.error!,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Color _getBackgroundColor(SyncStatus status) {
    switch (status) {
      case SyncStatus.inProgress:
        return Colors.blue;
      case SyncStatus.completed:
        return Colors.green;
      case SyncStatus.error:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}