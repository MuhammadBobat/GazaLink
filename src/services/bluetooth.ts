import { BleManager, Device, State } from 'react-native-ble-plx';
import { BluetoothDevice, BluetoothConnectionStatus, BluetoothScanStatus } from '../types';

class BluetoothService {
  private manager: BleManager;
  private discoveredDevices: Map<string, BluetoothDevice> = new Map();
  private connectedDevices: Map<string, Device> = new Map();
  private scanStatus: BluetoothScanStatus = BluetoothScanStatus.IDLE;
  private connectionStatus: BluetoothConnectionStatus = BluetoothConnectionStatus.DISCONNECTED;

  constructor() {
    this.manager = new BleManager();
  }

  // Initialize Bluetooth
  async initialize(): Promise<boolean> {
    try {
      const state = await this.manager.state();
      return state === State.PoweredOn;
    } catch (error) {
      console.error('Error initializing Bluetooth:', error);
      return false;
    }
  }

  // Start scanning for devices
  async startScan(): Promise<void> {
    try {
      this.scanStatus = BluetoothScanStatus.SCANNING;
      this.discoveredDevices.clear();

      await this.manager.startDeviceScan(
        null, // null means scan for all devices
        { allowDuplicates: false },
        (error, device) => {
          if (error) {
            console.error('Scan error:', error);
            this.scanStatus = BluetoothScanStatus.ERROR;
            return;
          }

          if (device) {
            const bluetoothDevice: BluetoothDevice = {
              id: device.id,
              name: device.name,
              rssi: device.rssi || -100,
              isConnectable: device.isConnectable || false,
              isConnected: this.connectedDevices.has(device.id),
            };

            this.discoveredDevices.set(device.id, bluetoothDevice);
          }
        }
      );
    } catch (error) {
      console.error('Error starting scan:', error);
      this.scanStatus = BluetoothScanStatus.ERROR;
    }
  }

  // Stop scanning
  async stopScan(): Promise<void> {
    try {
      this.manager.stopDeviceScan();
      this.scanStatus = BluetoothScanStatus.STOPPED;
    } catch (error) {
      console.error('Error stopping scan:', error);
    }
  }

  // Connect to a device
  async connectToDevice(deviceId: string): Promise<boolean> {
    try {
      this.connectionStatus = BluetoothConnectionStatus.CONNECTING;
      
      const device = await this.manager.connectToDevice(deviceId);
      await device.discoverAllServicesAndCharacteristics();
      
      this.connectedDevices.set(deviceId, device);
      this.connectionStatus = BluetoothConnectionStatus.CONNECTED;
      
      // Update the discovered device to show as connected
      const discoveredDevice = this.discoveredDevices.get(deviceId);
      if (discoveredDevice) {
        discoveredDevice.isConnected = true;
        this.discoveredDevices.set(deviceId, discoveredDevice);
      }

      return true;
    } catch (error) {
      console.error('Error connecting to device:', error);
      this.connectionStatus = BluetoothConnectionStatus.ERROR;
      return false;
    }
  }

  // Disconnect from a device
  async disconnectFromDevice(deviceId: string): Promise<boolean> {
    try {
      this.connectionStatus = BluetoothConnectionStatus.DISCONNECTING;
      
      const device = this.connectedDevices.get(deviceId);
      if (device) {
        await device.cancelConnection();
        this.connectedDevices.delete(deviceId);
        
        // Update the discovered device to show as disconnected
        const discoveredDevice = this.discoveredDevices.get(deviceId);
        if (discoveredDevice) {
          discoveredDevice.isConnected = false;
          this.discoveredDevices.set(deviceId, discoveredDevice);
        }
      }
      
      this.connectionStatus = BluetoothConnectionStatus.DISCONNECTED;
      return true;
    } catch (error) {
      console.error('Error disconnecting from device:', error);
      this.connectionStatus = BluetoothConnectionStatus.ERROR;
      return false;
    }
  }

  // Get discovered devices
  getDiscoveredDevices(): BluetoothDevice[] {
    return Array.from(this.discoveredDevices.values());
  }

  // Get connected devices
  getConnectedDevices(): BluetoothDevice[] {
    return Array.from(this.connectedDevices.values()).map(device => ({
      id: device.id,
      name: device.name,
      rssi: device.rssi || -100,
      isConnectable: device.isConnectable || false,
      isConnected: true,
    }));
  }

  // Get scan status
  getScanStatus(): BluetoothScanStatus {
    return this.scanStatus;
  }

  // Get connection status
  getConnectionStatus(): BluetoothConnectionStatus {
    return this.connectionStatus;
  }

  // Check if Bluetooth is enabled
  async isBluetoothEnabled(): Promise<boolean> {
    try {
      const state = await this.manager.state();
      return state === State.PoweredOn;
    } catch (error) {
      console.error('Error checking Bluetooth state:', error);
      return false;
    }
  }

  // Cleanup
  destroy(): void {
    this.manager.destroy();
  }
}

export const bluetoothService = new BluetoothService(); 