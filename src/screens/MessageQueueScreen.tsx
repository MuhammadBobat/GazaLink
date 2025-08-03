import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  FlatList,
  TouchableOpacity,
  SafeAreaView,
  ActivityIndicator,
  RefreshControl,
  Alert,
} from 'react-native';
import { Message, Priority, DeliveryStatus, BluetoothDevice, BluetoothConnectionStatus, BluetoothScanStatus } from '../types';
import { MessageStorage } from '../services/storage';
import { bluetoothService } from '../services/bluetooth';
import BluetoothDeviceList from '../components/BluetoothDeviceList';

interface MessageQueueScreenProps {
  navigation: any;
}

type TabType = 'messages' | 'bluetooth';

const MessageQueueScreen: React.FC<MessageQueueScreenProps> = ({ navigation }) => {
  const [activeTab, setActiveTab] = useState<TabType>('messages');
  const [messages, setMessages] = useState<Message[]>([]);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  
  // Bluetooth states
  const [bluetoothDevices, setBluetoothDevices] = useState<BluetoothDevice[]>([]);
  const [scanStatus, setScanStatus] = useState<BluetoothScanStatus>(BluetoothScanStatus.IDLE);
  const [connectionStatus, setConnectionStatus] = useState<BluetoothConnectionStatus>(BluetoothConnectionStatus.DISCONNECTED);
  const [bluetoothEnabled, setBluetoothEnabled] = useState(false);

  // Load messages from storage on mount
  useEffect(() => {
    loadMessages();
    initializeBluetooth();
  }, []);

  // Load messages when screen comes into focus
  useEffect(() => {
    const unsubscribe = navigation.addListener('focus', () => {
      loadMessages();
      updateBluetoothDevices();
    });

    return unsubscribe;
  }, [navigation]);

  // Update Bluetooth devices periodically
  useEffect(() => {
    const interval = setInterval(() => {
      if (activeTab === 'bluetooth') {
        updateBluetoothDevices();
      }
    }, 2000);

    return () => clearInterval(interval);
  }, [activeTab]);

  const initializeBluetooth = async () => {
    try {
      const enabled = await bluetoothService.isBluetoothEnabled();
      setBluetoothEnabled(enabled);
    } catch (error) {
      console.error('Error checking Bluetooth status:', error);
    }
  };

  const updateBluetoothDevices = () => {
    const devices = bluetoothService.getDiscoveredDevices();
    setBluetoothDevices(devices);
    setScanStatus(bluetoothService.getScanStatus());
    setConnectionStatus(bluetoothService.getConnectionStatus());
  };

  const loadMessages = async () => {
    try {
      setLoading(true);
      const sortedMessages = await MessageStorage.getSortedMessages();
      setMessages(sortedMessages);
    } catch (error) {
      console.error('Error loading messages:', error);
    } finally {
      setLoading(false);
    }
  };

  const onRefresh = async () => {
    setRefreshing(true);
    if (activeTab === 'messages') {
      await loadMessages();
    } else {
      updateBluetoothDevices();
    }
    setRefreshing(false);
  };

  const handleDeleteMessage = async (messageId: string) => {
    try {
      await MessageStorage.deleteMessage(messageId);
      await loadMessages();
    } catch (error) {
      console.error('Error deleting message:', error);
    }
  };

  const handleStartScan = async () => {
    if (!bluetoothEnabled) {
      Alert.alert('Bluetooth Disabled', 'Please enable Bluetooth to scan for devices.');
      return;
    }

    try {
      await bluetoothService.startScan();
      updateBluetoothDevices();
    } catch (error) {
      console.error('Error starting scan:', error);
      Alert.alert('Scan Error', 'Failed to start Bluetooth scan.');
    }
  };

  const handleStopScan = async () => {
    try {
      await bluetoothService.stopScan();
      updateBluetoothDevices();
    } catch (error) {
      console.error('Error stopping scan:', error);
    }
  };

  const handleConnectDevice = async (deviceId: string) => {
    try {
      const success = await bluetoothService.connectToDevice(deviceId);
      if (success) {
        Alert.alert('Success', 'Device connected successfully!');
      } else {
        Alert.alert('Connection Failed', 'Failed to connect to device.');
      }
      updateBluetoothDevices();
    } catch (error) {
      console.error('Error connecting to device:', error);
      Alert.alert('Connection Error', 'An error occurred while connecting.');
    }
  };

  const handleDisconnectDevice = async (deviceId: string) => {
    try {
      const success = await bluetoothService.disconnectFromDevice(deviceId);
      if (success) {
        Alert.alert('Success', 'Device disconnected successfully!');
      } else {
        Alert.alert('Disconnection Failed', 'Failed to disconnect from device.');
      }
      updateBluetoothDevices();
    } catch (error) {
      console.error('Error disconnecting from device:', error);
      Alert.alert('Disconnection Error', 'An error occurred while disconnecting.');
    }
  };

  const renderMessage = ({ item }: { item: Message }) => (
    <View style={[styles.messageItem, item.priority === Priority.URGENT && styles.urgentMessage]}>
      <Text style={styles.messageText}>{item.content}</Text>
      <View style={styles.messageMeta}>
        <Text style={[styles.priorityBadge, item.priority === Priority.URGENT && styles.urgentBadge]}>
          {item.priority.toUpperCase()}
        </Text>
        <Text style={styles.timestamp}>
          {new Date(item.timestamp).toLocaleTimeString()}
        </Text>
        <Text style={[styles.status, item.deliveryStatus === DeliveryStatus.DELIVERED && styles.deliveredStatus]}>
          {item.deliveryStatus}
        </Text>
      </View>
      <TouchableOpacity
        style={styles.deleteButton}
        onPress={() => handleDeleteMessage(item.id)}
      >
        <Text style={styles.deleteButtonText}>Delete</Text>
      </TouchableOpacity>
    </View>
  );

  const renderTabContent = () => {
    if (activeTab === 'messages') {
      if (loading) {
        return (
          <View style={styles.loadingContainer}>
            <ActivityIndicator size="large" color="#3498db" />
            <Text style={styles.loadingText}>Loading messages...</Text>
          </View>
        );
      }

      return (
        <FlatList
          data={messages}
          renderItem={renderMessage}
          keyExtractor={(item) => item.id}
          style={styles.messageList}
          refreshControl={
            <RefreshControl refreshing={refreshing} onRefresh={onRefresh} />
          }
          ListEmptyComponent={
            <View style={styles.emptyState}>
              <Text style={styles.emptyText}>No messages in queue</Text>
              <Text style={styles.emptySubtext}>Create your first message to get started</Text>
            </View>
          }
        />
      );
    } else {
      return (
        <View style={styles.bluetoothContainer}>
          <View style={styles.bluetoothControls}>
            <TouchableOpacity
              style={[
                styles.scanButton,
                scanStatus === BluetoothScanStatus.SCANNING && styles.scanningButton,
              ]}
              onPress={scanStatus === BluetoothScanStatus.SCANNING ? handleStopScan : handleStartScan}
            >
              <Text style={styles.scanButtonText}>
                {scanStatus === BluetoothScanStatus.SCANNING ? 'Stop Scan' : 'Start Scan'}
              </Text>
            </TouchableOpacity>
            
            <View style={styles.bluetoothStatus}>
              <View style={[styles.statusDot, bluetoothEnabled && styles.statusDotEnabled]} />
              <Text style={styles.statusText}>
                Bluetooth: {bluetoothEnabled ? 'Enabled' : 'Disabled'}
              </Text>
            </View>
          </View>

          <BluetoothDeviceList
            devices={bluetoothDevices}
            onConnect={handleConnectDevice}
            onDisconnect={handleDisconnectDevice}
            connectionStatus={connectionStatus}
            isLoading={scanStatus === BluetoothScanStatus.SCANNING}
          />
        </View>
      );
    }
  };

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.title}>Message Queue</Text>
        <Text style={styles.subtitle}>Offline Bluetooth P2P Communication</Text>
        {activeTab === 'messages' && (
          <Text style={styles.messageCount}>{messages.length} messages</Text>
        )}
      </View>

      <View style={styles.tabContainer}>
        <TouchableOpacity
          style={[styles.tab, activeTab === 'messages' && styles.activeTab]}
          onPress={() => setActiveTab('messages')}
        >
          <Text style={[styles.tabText, activeTab === 'messages' && styles.activeTabText]}>
            Messages
          </Text>
        </TouchableOpacity>
        <TouchableOpacity
          style={[styles.tab, activeTab === 'bluetooth' && styles.activeTab]}
          onPress={() => setActiveTab('bluetooth')}
        >
          <Text style={[styles.tabText, activeTab === 'bluetooth' && styles.activeTabText]}>
            Bluetooth
          </Text>
        </TouchableOpacity>
      </View>

      {renderTabContent()}

      <View style={styles.navigation}>
        <TouchableOpacity
          style={styles.navButton}
          onPress={() => navigation.navigate('MessageCreate')}
        >
          <Text style={styles.navButtonText}>Create Message</Text>
        </TouchableOpacity>
        <TouchableOpacity
          style={styles.navButton}
          onPress={() => navigation.navigate('Dashboard')}
        >
          <Text style={styles.navButtonText}>Dashboard</Text>
        </TouchableOpacity>
      </View>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  header: {
    padding: 20,
    backgroundColor: '#2c3e50',
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#ffffff',
    textAlign: 'center',
  },
  subtitle: {
    fontSize: 14,
    color: '#bdc3c7',
    textAlign: 'center',
    marginTop: 5,
  },
  messageCount: {
    fontSize: 12,
    color: '#bdc3c7',
    textAlign: 'center',
    marginTop: 5,
  },
  tabContainer: {
    flexDirection: 'row',
    backgroundColor: '#ffffff',
    borderBottomWidth: 1,
    borderBottomColor: '#ecf0f1',
  },
  tab: {
    flex: 1,
    paddingVertical: 15,
    alignItems: 'center',
  },
  activeTab: {
    borderBottomWidth: 2,
    borderBottomColor: '#3498db',
  },
  tabText: {
    fontSize: 16,
    color: '#7f8c8d',
    fontWeight: 'bold',
  },
  activeTabText: {
    color: '#3498db',
  },
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  loadingText: {
    marginTop: 10,
    fontSize: 16,
    color: '#7f8c8d',
  },
  messageList: {
    flex: 1,
    padding: 15,
  },
  messageItem: {
    backgroundColor: '#ffffff',
    padding: 15,
    marginBottom: 10,
    borderRadius: 8,
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.1,
    shadowRadius: 3.84,
    elevation: 5,
  },
  urgentMessage: {
    borderLeftWidth: 4,
    borderLeftColor: '#e74c3c',
  },
  messageText: {
    fontSize: 16,
    color: '#2c3e50',
    marginBottom: 10,
  },
  messageMeta: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 10,
  },
  priorityBadge: {
    fontSize: 12,
    fontWeight: 'bold',
    color: '#7f8c8d',
    backgroundColor: '#ecf0f1',
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: 4,
  },
  urgentBadge: {
    color: '#ffffff',
    backgroundColor: '#e74c3c',
  },
  timestamp: {
    fontSize: 12,
    color: '#7f8c8d',
  },
  status: {
    fontSize: 12,
    color: '#f39c12',
    fontWeight: 'bold',
  },
  deliveredStatus: {
    color: '#27ae60',
  },
  deleteButton: {
    backgroundColor: '#e74c3c',
    padding: 8,
    borderRadius: 4,
    alignItems: 'center',
  },
  deleteButtonText: {
    color: '#ffffff',
    fontSize: 12,
    fontWeight: 'bold',
  },
  emptyState: {
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
  bluetoothContainer: {
    flex: 1,
    padding: 15,
  },
  bluetoothControls: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 15,
  },
  scanButton: {
    backgroundColor: '#3498db',
    paddingHorizontal: 20,
    paddingVertical: 10,
    borderRadius: 6,
  },
  scanningButton: {
    backgroundColor: '#e74c3c',
  },
  scanButtonText: {
    color: '#ffffff',
    fontSize: 14,
    fontWeight: 'bold',
  },
  bluetoothStatus: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  statusDot: {
    width: 10,
    height: 10,
    borderRadius: 5,
    backgroundColor: '#e74c3c',
    marginRight: 8,
  },
  statusDotEnabled: {
    backgroundColor: '#27ae60',
  },
  statusText: {
    fontSize: 14,
    color: '#7f8c8d',
  },
  navigation: {
    flexDirection: 'row',
    padding: 15,
    backgroundColor: '#ffffff',
    borderTopWidth: 1,
    borderTopColor: '#ecf0f1',
  },
  navButton: {
    flex: 1,
    backgroundColor: '#3498db',
    padding: 15,
    borderRadius: 8,
    marginHorizontal: 5,
    alignItems: 'center',
  },
  navButtonText: {
    color: '#ffffff',
    fontSize: 16,
    fontWeight: 'bold',
  },
});

export default MessageQueueScreen; 