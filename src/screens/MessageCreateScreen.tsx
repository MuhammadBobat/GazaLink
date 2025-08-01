import React, { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TextInput,
  TouchableOpacity,
  SafeAreaView,
  Alert,
} from 'react-native';
import { Priority } from '../types';

interface MessageCreateScreenProps {
  navigation: any;
}

const MessageCreateScreen: React.FC<MessageCreateScreenProps> = ({ navigation }) => {
  const [messageText, setMessageText] = useState('');
  const [selectedPriority, setSelectedPriority] = useState<Priority>(Priority.NORMAL);

  const handleCreateMessage = () => {
    if (!messageText.trim()) {
      Alert.alert('Error', 'Please enter a message');
      return;
    }

    // Here you would typically save the message to local storage
    // For now, we'll just show a success message and navigate back
    Alert.alert(
      'Success',
      'Message created successfully!',
      [
        {
          text: 'OK',
          onPress: () => navigation.navigate('MessageQueue'),
        },
      ]
    );
  };

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.title}>Create Message</Text>
        <Text style={styles.subtitle}>Offline Bluetooth P2P Communication</Text>
      </View>

      <View style={styles.form}>
        <Text style={styles.label}>Message Text</Text>
        <TextInput
          style={styles.textInput}
          value={messageText}
          onChangeText={setMessageText}
          placeholder="Enter your message here..."
          multiline
          numberOfLines={4}
          textAlignVertical="top"
        />

        <Text style={styles.label}>Priority</Text>
        <View style={styles.priorityContainer}>
          <TouchableOpacity
            style={[
              styles.priorityButton,
              selectedPriority === Priority.NORMAL && styles.selectedPriority,
            ]}
            onPress={() => setSelectedPriority(Priority.NORMAL)}
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

        <TouchableOpacity style={styles.createButton} onPress={handleCreateMessage}>
          <Text style={styles.createButtonText}>Create Message</Text>
        </TouchableOpacity>
      </View>

      <View style={styles.navigation}>
        <TouchableOpacity
          style={styles.navButton}
          onPress={() => navigation.navigate('MessageQueue')}
        >
          <Text style={styles.navButtonText}>Message Queue</Text>
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
  createButton: {
    backgroundColor: '#27ae60',
    padding: 15,
    borderRadius: 8,
    marginTop: 30,
    alignItems: 'center',
  },
  createButtonText: {
    color: '#ffffff',
    fontSize: 18,
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