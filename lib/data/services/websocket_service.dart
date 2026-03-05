import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:them_dating_app/data/models/message_model.dart';

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  WebSocketChannel? _channel;
  final Map<String, Function(MessageModel)> _listeners = {};

  // Connect to WebSocket server
  void connect(String userId) {
    final uri = 'wss://your-server.com/ws?userId=$userId'; // Replace with your server
    _channel = WebSocketChannel.connect(Uri.parse(uri));

    _channel!.stream.listen(
          (data) {
        final message = MessageModel.fromMap(json.decode(data));
        _notifyListeners(message);
      },
      onError: (error) {
        print('WebSocket error: $error');
        // Reconnect logic here
      },
      onDone: () {
        print('WebSocket connection closed');
        // Reconnect logic here
      },
    );
  }

  // Send message
  void sendMessage(MessageModel message) {
    if (_channel != null && _channel!.sink != null) {
      _channel!.sink.add(json.encode(message.toMap()));
    }
  }

  // Listen to messages
  void addListener(String key, Function(MessageModel) callback) {
    _listeners[key] = callback;
  }

  void removeListener(String key) {
    _listeners.remove(key);
  }

  void _notifyListeners(MessageModel message) {
    _listeners.forEach((_, callback) => callback(message));
  }

  // Disconnect
  void disconnect() {
    _channel?.sink.close();
    _channel = null;
    _listeners.clear();
  }
}