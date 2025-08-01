export interface Message {
  id: string;
  text: string;
  priority: Priority;
  timestamp: Date;
  status: MessageStatus;
}

export enum Priority {
  URGENT = 'urgent',
  NORMAL = 'normal'
}

export enum MessageStatus {
  PENDING = 'pending',
  SENT = 'sent',
  DELIVERED = 'delivered'
}

export interface AppStats {
  totalMessages: number;
  pendingMessages: number;
  urgentMessages: number;
} 