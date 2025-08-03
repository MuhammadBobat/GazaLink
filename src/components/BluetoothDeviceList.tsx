import React from 'react';
import {
  View,
  Text,
  StyleSheet,
  FlatList,
  TouchableOpacity,
  ActivityIndicator,
} from 'react-native';
import { BluetoothDevice, BluetoothConnectionStatus } from '../types';

interface BluetoothDeviceListProps {
  devices: BluetoothDevice[];
  onConnect: (deviceId: string) => void;
  onDisconnect: (deviceId: string) => void;
  connectionStatus: BluetoothConnectionStatus;
  isLoading?: boolean;
}

const BluetoothDeviceList: React.FC<BluetoothDeviceListProps> = ({
  devices,
  onConnect,
  onDisconnect,
  connectionStatus,
  isLoading = false,
}) => {
  const renderDevice = ({ item }: { item: BluetoothDevice }) => {
    const isConnecting = connectionStatus === BluetoothConnectionStatus.CONNECTING;
    const canConnect = !item.isConnected && !isConnecting;

    return (
      <View style={[styles.deviceItem, item.isConnected && styles.connectedDevice]}>
        <View style={styles.deviceInfo}>
          <Text style={styles.deviceName}>
            {item.name || `Unknown Device (${item.id.slice(-8)})`}
          </Text>
          <Text style={styles.deviceId}>{item.id}</Text>
          <View style={styles.deviceMeta}>
            <Text style={styles.rssiText}>RSSI: {item.rssi} dBm</Text>
            <View style={[styles.statusIndicator, item.isConnected && styles.connectedIndicator]} />
            <Text style={[styles.statusText, item.isConnected && styles.connectedStatusText]}>
              {item.isConnected ? 'Connected' : 'Available'}
            </Text>
          </View>
        </View>
        
        <TouchableOpacity
          style={[
            styles.actionButton,
            item.isConnected ? styles.disconnectButton : styles.connectButton,
            (!canConnect || isLoading) && styles.disabledButton,
          ]}
          onPress={() => {
            if (item.isConnected) {
              onDisconnect(item.id);
            } else {
              onConnect(item.id);
            }
          }}
          disabled={!canConnect || isLoading}
        >
          {isConnecting && connectionStatus === BluetoothConnectionStatus.CONNECTING ? (
            <ActivityIndicator size="small" color="#ffffff" />
          ) : (
            <Text style={styles.actionButtonText}>
              {item.isConnected ? 'Disconnect' : 'Connect'}
            </Text>
          )}
        </TouchableOpacity>
      </View>
    );
  };

  if (isLoading) {
    return (
      <View style={styles.loadingContainer}>
        <ActivityIndicator size="large" color="#3498db" />
        <Text style={styles.loadingText}>Scanning for devices...</Text>
      </View>
    );
  }

  if (devices.length === 0) {
    return (
      <View style={styles.emptyContainer}>
        <Text style={styles.emptyText}>No devices found</Text>
        <Text style={styles.emptySubtext}>
          Make sure Bluetooth is enabled and devices are nearby
        </Text>
      </View>
    );
  }

  return (
    <FlatList
      data={devices}
      renderItem={renderDevice}
      keyExtractor={(item) => item.id}
      style={styles.deviceList}
      showsVerticalScrollIndicator={false}
    />
  );
};

const styles = StyleSheet.create({
  deviceList: {
    flex: 1,
  },
  deviceItem: {
    backgroundColor: '#ffffff',
    padding: 15,
    marginBottom: 10,
    borderRadius: 8,
    flexDirection: 'row',
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.1,
    shadowRadius: 3.84,
    elevation: 5,
  },
  connectedDevice: {
    borderLeftWidth: 4,
    borderLeftColor: '#27ae60',
  },
  deviceInfo: {
    flex: 1,
  },
  deviceName: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#2c3e50',
    marginBottom: 4,
  },
  deviceId: {
    fontSize: 12,
    color: '#7f8c8d',
    marginBottom: 8,
  },
  deviceMeta: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  rssiText: {
    fontSize: 12,
    color: '#7f8c8d',
    marginRight: 10,
  },
  statusIndicator: {
    width: 8,
    height: 8,
    borderRadius: 4,
    backgroundColor: '#95a5a6',
    marginRight: 6,
  },
  connectedIndicator: {
    backgroundColor: '#27ae60',
  },
  statusText: {
    fontSize: 12,
    color: '#7f8c8d',
    fontWeight: 'bold',
  },
  connectedStatusText: {
    color: '#27ae60',
  },
  actionButton: {
    paddingHorizontal: 16,
    paddingVertical: 8,
    borderRadius: 6,
    minWidth: 80,
    alignItems: 'center',
  },
  connectButton: {
    backgroundColor: '#3498db',
  },
  disconnectButton: {
    backgroundColor: '#e74c3c',
  },
  disabledButton: {
    backgroundColor: '#95a5a6',
  },
  actionButtonText: {
    color: '#ffffff',
    fontSize: 14,
    fontWeight: 'bold',
  },
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    paddingVertical: 50,
  },
  loadingText: {
    marginTop: 10,
    fontSize: 16,
    color: '#7f8c8d',
  },
  emptyContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    paddingVertical: 50,
  },
  emptyText: {
    fontSize: 18,
    color: '#7f8c8d',
    marginBottom: 10,
  },
  emptySubtext: {
    fontSize: 14,
    color: '#bdc3c7',
    textAlign: 'center',
  },
});

export default BluetoothDeviceList; 