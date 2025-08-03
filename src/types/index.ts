export interface Message {
  id: string;
  content: string;
  priority: Priority;
  timestamp: string; // ISO string
  deliveryStatus: DeliveryStatus;
}

export enum Priority {
  URGENT = 'urgent',
  NORMAL = 'normal'
}

export enum DeliveryStatus {
  PENDING = 'pending',
  SENT = 'sent',
  DELIVERED = 'delivered'
}

export interface AppStats {
  totalMessages: number;
  pendingMessages: number;
  urgentMessages: number;
}

// Bluetooth types
export interface BluetoothDevice {
  id: string;
  name: string | null;
  rssi: number;
  isConnectable: boolean;
  isConnected: boolean;
}

export enum BluetoothConnectionStatus {
  DISCONNECTED = 'disconnected',
  CONNECTING = 'connecting',
  CONNECTED = 'connected',
  DISCONNECTING = 'disconnecting',
  ERROR = 'error'
}

export enum BluetoothScanStatus {
  IDLE = 'idle',
  SCANNING = 'scanning',
  STOPPED = 'stopped',
  ERROR = 'error'
} 