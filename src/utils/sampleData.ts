import { Message, Priority, DeliveryStatus } from '../types';
import { MessageStorage } from '../services/storage';

export const addSampleData = async (): Promise<void> => {
  const sampleMessages: Message[] = [
    {
      id: '1',
      content: 'Emergency: Need medical supplies at location A',
      priority: Priority.URGENT,
      timestamp: new Date(Date.now() - 3600000).toISOString(), // 1 hour ago
      deliveryStatus: DeliveryStatus.PENDING,
    },
    {
      id: '2',
      content: 'Status update: All clear in sector B',
      priority: Priority.NORMAL,
      timestamp: new Date(Date.now() - 7200000).toISOString(), // 2 hours ago
      deliveryStatus: DeliveryStatus.SENT,
    },
    {
      id: '3',
      content: 'Water distribution scheduled for tomorrow at 9 AM',
      priority: Priority.NORMAL,
      timestamp: new Date(Date.now() - 1800000).toISOString(), // 30 minutes ago
      deliveryStatus: DeliveryStatus.DELIVERED,
    },
    {
      id: '4',
      content: 'URGENT: Power outage in building C, need backup generator',
      priority: Priority.URGENT,
      timestamp: new Date().toISOString(), // Now
      deliveryStatus: DeliveryStatus.PENDING,
    },
  ];

  try {
    // Clear existing data first
    await MessageStorage.clearAllMessages();
    
    // Add sample messages
    for (const message of sampleMessages) {
      await MessageStorage.saveMessage(message);
    }
    
    console.log('Sample data added successfully');
  } catch (error) {
    console.error('Error adding sample data:', error);
  }
};

export const clearAllData = async (): Promise<void> => {
  try {
    await MessageStorage.clearAllMessages();
    console.log('All data cleared successfully');
  } catch (error) {
    console.error('Error clearing data:', error);
  }
}; 