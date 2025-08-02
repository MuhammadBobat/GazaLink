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
} from 'react-native';
import { Message, Priority, DeliveryStatus } from '../types';
import { MessageStorage } from '../services/storage';

interface MessageQueueScreenProps {
  navigation: any;
}

const MessageQueueScreen: React.FC<MessageQueueScreenProps> = ({ navigation }) => {
  const [messages, setMessages] = useState<Message[]>([]);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);

  // Load messages from storage on mount
  useEffect(() => {
    loadMessages();
  }, []);

  // Load messages when screen comes into focus
  useEffect(() => {
    const unsubscribe = navigation.addListener('focus', () => {
      loadMessages();
    });

    return unsubscribe;
  }, [navigation]);

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
    await loadMessages();
    setRefreshing(false);
  };

  const handleDeleteMessage = async (messageId: string) => {
    try {
      await MessageStorage.deleteMessage(messageId);
      await loadMessages(); // Reload messages after deletion
    } catch (error) {
      console.error('Error deleting message:', error);
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

  if (loading) {
    return (
      <SafeAreaView style={styles.container}>
        <View style={styles.header}>
          <Text style={styles.title}>Message Queue</Text>
          <Text style={styles.subtitle}>Offline Bluetooth P2P Communication</Text>
        </View>
        <View style={styles.loadingContainer}>
          <ActivityIndicator size="large" color="#3498db" />
          <Text style={styles.loadingText}>Loading messages...</Text>
        </View>
      </SafeAreaView>
    );
  }

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.title}>Message Queue</Text>
        <Text style={styles.subtitle}>Offline Bluetooth P2P Communication</Text>
        <Text style={styles.messageCount}>{messages.length} messages</Text>
      </View>

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