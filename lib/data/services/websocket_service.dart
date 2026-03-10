import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'package:them_dating_app/data/models/message_model.dart';

typedef MessageCallback = void Function(MessageModel);
typedef TypingCallback = void Function(Map<String, dynamic>);
typedef OnlineCallback = void Function(Map<String, dynamic>);

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  WebSocketChannel? _channel;

  // Separate callbacks for different types
  MessageCallback? _messageCallback;
  TypingCallback? _typingCallback;
  OnlineCallback? _onlineCallback;

  String? _userId;
  bool _isReconnecting = false;

  // Connect to WebSocket server
  void connect(String userId) {
    _userId = userId;
    _connect();
  }

  void _connect() {
    try {
      final uri = 'ws://192.168.1.12:3001'; // Your server URL
      _channel = IOWebSocketChannel.connect(uri);

      _channel!.stream.listen(
        _handleMessage,
        onError: (error) {
          print('WebSocket error: $error');
          _attemptReconnect();
        },
        onDone: () {
          print('WebSocket connection closed');
          _attemptReconnect();
        },
      );

      // Send user online status
      _send('online', {'userId': _userId, 'isOnline': true});
    } catch (e) {
      print('WebSocket connection error: $e');
      _attemptReconnect();
    }
  }

  void _attemptReconnect() {
    if (_isReconnecting) return;
    _isReconnecting = true;

    Future.delayed(const Duration(seconds: 5), () {
      _isReconnecting = false;
      if (_userId != null) {
        _connect();
      }
    });
  }

  void _handleMessage(dynamic message) {
    try {
      final data = json.decode(message as String);
      final type = data['type'];
      final messageData = data['data'];

      switch (type) {
        case 'message':
          if (_messageCallback != null) {
            final messageModel = MessageModel(
              id: messageData['id'],
              senderId: messageData['senderId'],
              receiverId: messageData['receiverId'],
              content: messageData['content'],
              timestamp: DateTime.parse(messageData['timestamp']),
            );
            _messageCallback!(messageModel);
          }
          break;

        case 'typing':
          if (_typingCallback != null) {
            _typingCallback!(messageData);
          }
          break;

        case 'online':
          if (_onlineCallback != null) {
            _onlineCallback!(messageData);
          }
          break;

        default:
          print('Unknown message type: $type');
      }
    } catch (e) {
      print('Error handling message: $e');
    }
  }

  // Set callbacks
  void setMessageCallback(MessageCallback callback) {
    _messageCallback = callback;
  }

  void setTypingCallback(TypingCallback callback) {
    _typingCallback = callback;
  }

  void setOnlineCallback(OnlineCallback callback) {
    _onlineCallback = callback;
  }

  // Remove callbacks
  void removeMessageCallback() {
    _messageCallback = null;
  }

  void removeTypingCallback() {
    _typingCallback = null;
  }

  void removeOnlineCallback() {
    _onlineCallback = null;
  }

  // Send message
  void sendMessage(MessageModel message) {
    _send('message', message.toMap());
  }

  // Send typing indicator
  void sendTyping(String matchId, String userId, bool isTyping) {
    _send('typing', {
      'matchId': matchId,
      'userId': userId,
      'isTyping': isTyping,
    });
  }

  // Send online status
  void sendOnlineStatus(String userId, bool isOnline) {
    _send('online', {
      'userId': userId,
      'isOnline': isOnline,
    });
  }

  void _send(String type, dynamic data) {
    if (_channel != null && _channel!.sink != null) {
      _channel!.sink.add(json.encode({
        'type': type,
        'data': data,
        'timestamp': DateTime.now().toIso8601String(),
      }));
    }
  }

  // Disconnect
  void disconnect() {
    if (_userId != null) {
      sendOnlineStatus(_userId!, false);
    }
    _channel?.sink.close();
    _channel = null;
    _messageCallback = null;
    _typingCallback = null;
    _onlineCallback = null;
  }
}