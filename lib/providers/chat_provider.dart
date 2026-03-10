import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:them_dating_app/data/models/message_model.dart';
import 'package:them_dating_app/data/models/match_model.dart';
import 'package:them_dating_app/data/services/websocket_service.dart';

class ChatProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final WebSocketService _webSocketService = WebSocketService();

  List<MatchModel> _matches = [];
  List<MessageModel> _messages = [];
  bool _isLoading = false;
  String? _error;
  Map<String, bool> _typingUsers = {};
  Map<String, bool> _onlineUsers = {};

  List<MatchModel> get matches => _matches;
  List<MessageModel> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, bool> get typingUsers => _typingUsers;
  Map<String, bool> get onlineUsers => _onlineUsers;

  // Initialize chat for user
  void initialize(String userId) {
    _webSocketService.connect(userId);

    // Set callbacks
    _webSocketService.setMessageCallback(_onNewMessage);
    _webSocketService.setTypingCallback(_onTypingIndicator);
    _webSocketService.setOnlineCallback(_onOnlineStatus);

    _loadMatches(userId);
  }

  void _onNewMessage(MessageModel message) {
    _messages.insert(0, message);
    notifyListeners();
  }

  void _onTypingIndicator(Map<String, dynamic> data) {
    final userId = data['userId'];
    final isTyping = data['isTyping'];
    _typingUsers[userId] = isTyping;
    notifyListeners();
  }

  void _onOnlineStatus(Map<String, dynamic> data) {
    final userId = data['userId'];
    final isOnline = data['isOnline'];
    _onlineUsers[userId] = isOnline;
    notifyListeners();
  }

  void sendTypingIndicator(String matchId, String userId, bool isTyping) {
    _webSocketService.sendTyping(matchId, userId, isTyping);
  }

  void setUserOnline(String userId, bool isOnline) {
    _webSocketService.sendOnlineStatus(userId, isOnline);
  }

  // Load matches
  Future<void> _loadMatches(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('matches')
          .where('userId1', isEqualTo: userId)
          .where('status', isEqualTo: MatchStatus.matched.index)
          .orderBy('lastMessageAt', descending: true)
          .get();

      final snapshot2 = await _firestore
          .collection('matches')
          .where('userId2', isEqualTo: userId)
          .where('status', isEqualTo: MatchStatus.matched.index)
          .orderBy('lastMessageAt', descending: true)
          .get();

      _matches = [
        ...snapshot.docs.map((doc) => MatchModel.fromMap(doc.data() as Map<String, dynamic>)),
        ...snapshot2.docs.map((doc) => MatchModel.fromMap(doc.data() as Map<String, dynamic>)),
      ];

      _matches.sort((a, b) =>
          (b.lastMessageAt ?? DateTime.now()).compareTo(a.lastMessageAt ?? DateTime.now())
      );
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Load chat messages
  Future<void> loadMessages(String matchId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('matches')
          .doc(matchId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .limit(50)
          .get();

      _messages = snapshot.docs
          .map((doc) => MessageModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Send message
  Future<void> sendMessage(MessageModel message) async {
    try {
      await _firestore
          .collection('matches')
          .doc(message.id.split('_')[0])
          .collection('messages')
          .doc(message.id)
          .set(message.toMap());

      await _firestore
          .collection('matches')
          .doc(message.id.split('_')[0])
          .update({
        'lastMessage': message.content,
        'lastMessageAt': FieldValue.serverTimestamp(),
      });

      _webSocketService.sendMessage(message);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Mark message as read
  Future<void> markAsRead(String messageId) async {
    try {
      await _firestore
          .collection('messages')
          .doc(messageId)
          .update({
        'status': MessageStatus.read.index,
        'readAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error marking message as read: $e');
    }
  }

  // Clean up
  void dispose() {
    _webSocketService.disconnect();
  }
}