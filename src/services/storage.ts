import AsyncStorage from '@react-native-async-storage/async-storage';
import { Message } from '../types';

const MESSAGES_STORAGE_KEY = '@gazalink_messages';

export class MessageStorage {
  // Get all messages from storage
  static async getMessages(): Promise<Message[]> {
    try {
      const messagesJson = await AsyncStorage.getItem(MESSAGES_STORAGE_KEY);
      if (messagesJson) {
        return JSON.parse(messagesJson);
      }
      return [];
    } catch (error) {
      console.error('Error getting messages from storage:', error);
      return [];
    }
  }

  // Save a new message to storage
  static async saveMessage(message: Message): Promise<void> {
    try {
      const existingMessages = await this.getMessages();
      const updatedMessages = [...existingMessages, message];
      await AsyncStorage.setItem(MESSAGES_STORAGE_KEY, JSON.stringify(updatedMessages));
    } catch (error) {
      console.error('Error saving message to storage:', error);
      throw error;
    }
  }

  // Update an existing message
  static async updateMessage(updatedMessage: Message): Promise<void> {
    try {
      const existingMessages = await this.getMessages();
      const updatedMessages = existingMessages.map(message => 
        message.id === updatedMessage.id ? updatedMessage : message
      );
      await AsyncStorage.setItem(MESSAGES_STORAGE_KEY, JSON.stringify(updatedMessages));
    } catch (error) {
      console.error('Error updating message in storage:', error);
      throw error;
    }
  }

  // Delete a message
  static async deleteMessage(messageId: string): Promise<void> {
    try {
      const existingMessages = await this.getMessages();
      const updatedMessages = existingMessages.filter(message => message.id !== messageId);
      await AsyncStorage.setItem(MESSAGES_STORAGE_KEY, JSON.stringify(updatedMessages));
    } catch (error) {
      console.error('Error deleting message from storage:', error);
      throw error;
    }
  }

  // Clear all messages
  static async clearAllMessages(): Promise<void> {
    try {
      await AsyncStorage.removeItem(MESSAGES_STORAGE_KEY);
    } catch (error) {
      console.error('Error clearing messages from storage:', error);
      throw error;
    }
  }

  // Get messages sorted by priority and timestamp
  static async getSortedMessages(): Promise<Message[]> {
    const messages = await this.getMessages();
    return messages.sort((a, b) => {
      // First sort by priority (urgent first)
      if (a.priority !== b.priority) {
        return a.priority === 'urgent' ? -1 : 1;
      }
      // Then sort by timestamp (earlier first)
      return new Date(a.timestamp).getTime() - new Date(b.timestamp).getTime();
    });
  }
} 