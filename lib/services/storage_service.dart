import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/message.dart';

class StorageService {
  static const String _messagesKey = 'gazalink_messages';

  // Get all messages
  Future<List<Message>> getMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final messagesJson = prefs.getStringList(_messagesKey) ?? [];
    
    return messagesJson
        .map((json) => Message.fromJson(jsonDecode(json)))
        .toList();
  }

  // Save a message
  Future<void> saveMessage(Message message) async {
    final messages = await getMessages();
    
    // Check if message already exists
    final existingIndex = messages.indexWhere((m) => m.id == message.id);
    if (existingIndex != -1) {
      messages[existingIndex] = message;
    } else {
      messages.add(message);
    }
    
    await _saveMessages(messages);
  }

  // Update a message
  Future<void> updateMessage(Message message) async {
    final messages = await getMessages();
    
    final index = messages.indexWhere((m) => m.id == message.id);
    if (index != -1) {
      messages[index] = message;
      await _saveMessages(messages);
    }
  }

  // Delete a message
  Future<void> deleteMessage(String messageId) async {
    final messages = await getMessages();
    messages.removeWhere((message) => message.id == messageId);
    await _saveMessages(messages);
  }

  // Clear all messages
  Future<void> clearAllMessages() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_messagesKey);
  }

  // Get sorted messages (urgent first, then by timestamp)
  Future<List<Message>> getSortedMessages() async {
    final messages = await getMessages();
    
    messages.sort((a, b) {
      // First sort by priority (urgent first)
      if (a.priority != b.priority) {
        return a.priority == Priority.urgent ? -1 : 1;
      }
      // Then sort by timestamp (oldest first)
      return a.timestamp.compareTo(b.timestamp);
    });
    
    return messages;
  }

  // Helper method to save messages
  Future<void> _saveMessages(List<Message> messages) async {
    final prefs = await SharedPreferences.getInstance();
    final messagesJson = messages
        .map((message) => jsonEncode(message.toJson()))
        .toList();
    
    await prefs.setStringList(_messagesKey, messagesJson);
  }

  // Get app statistics
  Future<Map<String, int>> getAppStats() async {
    final messages = await getMessages();
    
    return {
      'totalMessages': messages.length,
      'pendingMessages': messages
          .where((m) => m.deliveryStatus == DeliveryStatus.pending)
          .length,
      'urgentMessages': messages
          .where((m) => m.priority == Priority.urgent)
          .length,
    };
  }

  // Step 1: Serialize local message queue into JSON string, including all message fields
  Future<String> getMessagesAsJson() async {
    try {
      final messages = await getMessages();
      final jsonString = jsonEncode(messages.map((m) => m.toJson()).toList());
      return jsonString;
    } catch (e) {
      throw Exception('Failed to serialize messages to JSON: $e');
    }
  }

  // Step 2: Deserialize JSON string of messages and merge into local queue without duplicates
  Future<void> mergeIncomingMessages(String jsonMessages) async {
    try {
      final List<dynamic> messagesData = jsonDecode(jsonMessages);
      final List<Message> incomingMessages = messagesData
          .map((data) => Message.fromJson(data))
          .toList();
      
      final List<Message> localMessages = await getMessages();
      final List<Message> mergedMessages = List.from(localMessages);
      
      for (final incomingMessage in incomingMessages) {
        // Check if message already exists by ID
        final existingIndex = mergedMessages.indexWhere(
          (local) => local.id == incomingMessage.id
        );
        
        if (existingIndex == -1) {
          // New message - add it
          mergedMessages.add(incomingMessage);
        } else {
          // Existing message - update if incoming is newer or has better status
          final existing = mergedMessages[existingIndex];
          if (incomingMessage.timestamp.isAfter(existing.timestamp) ||
              incomingMessage.deliveryStatus.index > existing.deliveryStatus.index) {
            mergedMessages[existingIndex] = incomingMessage;
          }
        }
      }
      
      // Save merged messages
      await _saveMessages(mergedMessages);
    } catch (e) {
      throw Exception('Failed to merge incoming messages: $e');
    }
  }

  // Step 5: Update delivery status when message is confirmed as received by another device
  Future<void> updateDeliveryStatus(String messageId, DeliveryStatus status) async {
    try {
      final messages = await getMessages();
      final index = messages.indexWhere((m) => m.id == messageId);
      
      if (index != -1) {
        messages[index] = messages[index].copyWith(deliveryStatus: status);
        await _saveMessages(messages);
      }
    } catch (e) {
      throw Exception('Failed to update delivery status: $e');
    }
  }
}