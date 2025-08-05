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
}
