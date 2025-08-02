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