import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatService {
  late IO.Socket socket;

  void connect() {
    socket = IO.io('http://your-server-url:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    socket.on('connect', (_) {
      print('Connected to WebSocket server');
    });

    socket.on('disconnect', (_) {
      print('Disconnected from WebSocket server');
    });

    socket.on('new_message', (data) {
      // Handle new message
      print('New message: $data');
    });
  }

  void sendMessage(String roomId, String message) {
    socket.emit('send_message', {
      'roomId': roomId,
      'message': message,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  void joinRoom(String roomId) {
    socket.emit('join_room', roomId);
  }

  void disconnect() {
    socket.disconnect();
  }
}