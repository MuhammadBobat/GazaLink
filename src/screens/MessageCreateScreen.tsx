import React, { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TextInput,
  TouchableOpacity,
  SafeAreaView,
  Alert,
  ActivityIndicator,
} from 'react-native';
import { Priority, DeliveryStatus } from '../types';
import { MessageStorage } from '../services/storage';

interface MessageCreateScreenProps {
  navigation: any;
}

const MessageCreateScreen: React.FC<MessageCreateScreenProps> = ({ navigation }) => {
  const [messageContent, setMessageContent] = useState('');
  const [selectedPriority, setSelectedPriority] = useState<Priority>(Priority.NORMAL);
  const [isSubmitting, setIsSubmitting] = useState(false);

  const generateId = (): string => {
    return Date.now().toString() + Math.random().toString(36).substr(2, 9);
  };

  const handleCreateMessage = async () => {
    if (!messageContent.trim()) {
      Alert.alert('Error', 'Please enter a message');
      return;
    }

    setIsSubmitting(true);

    try {
      const newMessage = {
        id: generateId(),
        content: messageContent.trim(),
        priority: selectedPriority,
        timestamp: new Date().toISOString(),
        deliveryStatus: DeliveryStatus.PENDING,
      };

      await MessageStorage.saveMessage(newMessage);

      Alert.alert(
        'Success',
        'Message created successfully!',
        [
          {
            text: 'OK',
            onPress: () => {
              setMessageContent('');
              setSelectedPriority(Priority.NORMAL);
              navigation.navigate('MessageQueue');
            },
          },
        ]
      );
    } catch (error) {
      console.error('Error creating message:', error);
      Alert.alert('Error', 'Failed to create message. Please try again.');
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleClearForm = () => {
    setMessageContent('');
    setSelectedPriority(Priority.NORMAL);
  };

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.title}>Create Message</Text>
        <Text style={styles.subtitle}>Offline Bluetooth P2P Communication</Text>
      </View>

      <View style={styles.form}>
        <Text style={styles.label}>Message Content</Text>
        <TextInput
          style={styles.textInput}
          value={messageContent}
          onChangeText={setMessageContent}
          placeholder="Enter your message here..."
          multiline
          numberOfLines={4}
          textAlignVertical="top"
          editable={!isSubmitting}
        />

        <Text style={styles.label}>Priority</Text>
        <View style={styles.priorityContainer}>
          <TouchableOpacity
            style={[
              styles.priorityButton,
              selectedPriority === Priority.NORMAL && styles.selectedPriority,
            ]}
            onPress={() => setSelectedPriority(Priority.NORMAL)}
            disabled={isSubmitting}
          >
            <Text
              style={[
                styles.priorityText,
                selectedPriority === Priority.NORMAL && styles.selectedPriorityText,
              ]}
            >
              Normal
            </Text>
          </TouchableOpacity>
          <TouchableOpacity
            style={[
              styles.priorityButton,
              selectedPriority === Priority.URGENT && styles.urgentPriority,
            ]}
            onPress={() => setSelectedPriority(Priority.URGENT)}
            disabled={isSubmitting}
          >
            <Text
              style={[
                styles.priorityText,
                selectedPriority === Priority.URGENT && styles.selectedPriorityText,
              ]}
            >
              Urgent
            </Text>
          </TouchableOpacity>
        </View>

        <View style={styles.buttonContainer}>
          <TouchableOpacity 
            style={[styles.createButton, isSubmitting && styles.disabledButton]} 
            onPress={handleCreateMessage}
            disabled={isSubmitting}
          >
            {isSubmitting ? (
              <ActivityIndicator color="#ffffff" size="small" />
            ) : (
              <Text style={styles.createButtonText}>Create Message</Text>
            )}
          </TouchableOpacity>

          <TouchableOpacity 
            style={styles.clearButton} 
            onPress={handleClearForm}
            disabled={isSubmitting}
          >
            <Text style={styles.clearButtonText}>Clear Form</Text>
          </TouchableOpacity>
        </View>
      </View>

      <View style={styles.navigation}>
        <TouchableOpacity
          style={styles.navButton}
          onPress={() => navigation.navigate('MessageQueue')}
          disabled={isSubmitting}
        >
          <Text style={styles.navButtonText}>Message Queue</Text>
        </TouchableOpacity>
        <TouchableOpacity
          style={styles.navButton}
          onPress={() => navigation.navigate('Dashboard')}
          disabled={isSubmitting}
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
  form: {
    flex: 1,
    padding: 20,
  },
  label: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#2c3e50',
    marginBottom: 10,
    marginTop: 20,
  },
  textInput: {
    backgroundColor: '#ffffff',
    borderWidth: 1,
    borderColor: '#bdc3c7',
    borderRadius: 8,
    padding: 15,
    fontSize: 16,
    minHeight: 100,
  },
  priorityContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginTop: 10,
  },
  priorityButton: {
    flex: 1,
    backgroundColor: '#ecf0f1',
    padding: 15,
    borderRadius: 8,
    marginHorizontal: 5,
    alignItems: 'center',
    borderWidth: 2,
    borderColor: 'transparent',
  },
  selectedPriority: {
    backgroundColor: '#3498db',
    borderColor: '#2980b9',
  },
  urgentPriority: {
    backgroundColor: '#e74c3c',
    borderColor: '#c0392b',
  },
  priorityText: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#7f8c8d',
  },
  selectedPriorityText: {
    color: '#ffffff',
  },
  buttonContainer: {
    marginTop: 30,
  },
  createButton: {
    backgroundColor: '#27ae60',
    padding: 15,
    borderRadius: 8,
    alignItems: 'center',
    marginBottom: 10,
  },
  disabledButton: {
    backgroundColor: '#95a5a6',
  },
  createButtonText: {
    color: '#ffffff',
    fontSize: 18,
    fontWeight: 'bold',
  },
  clearButton: {
    backgroundColor: '#95a5a6',
    padding: 15,
    borderRadius: 8,
    alignItems: 'center',
  },
  clearButtonText: {
    color: '#ffffff',
    fontSize: 16,
    fontWeight: 'bold',
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

export default MessageCreateScreen; 