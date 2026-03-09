import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:them_dating_app/core/theme/theme_provider.dart';
import 'package:them_dating_app/screens/video_call/webrtc_group_call_screen.dart';
import 'package:them_dating_app/screens/video_call/models/room_model.dart';
import 'package:uuid/uuid.dart';

class RoomListScreen extends StatefulWidget {
  final String currentUserId;
  final String currentUserName;

  const RoomListScreen({
    super.key,
    required this.currentUserId,
    required this.currentUserName,
  });

  @override
  State<RoomListScreen> createState() => _RoomListScreenState();
}

class _RoomListScreenState extends State<RoomListScreen> {
  final List<RoomModel> _rooms = [];
  final List<Map<String, String>> _contacts = [
    {'id': '1', 'name': 'John Doe', 'role': 'Product Manager'},
    {'id': '2', 'name': 'Jane Smith', 'role': 'UI/UX Designer'},
    {'id': '3', 'name': 'Mike Johnson', 'role': 'Flutter Developer'},
    {'id': '4', 'name': 'Sarah Wilson', 'role': 'Backend Engineer'},
  ];

  void _createNewRoom() {
    final roomId = const Uuid().v4();
    final room = RoomModel(
      id: roomId,
      name: 'Room ${_rooms.length + 1}',
      createdBy: widget.currentUserId,
      createdAt: DateTime.now(),
      participants: [widget.currentUserId],
    );

    setState(() {
      _rooms.add(room);
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WebRTCGroupCallScreen(
          roomId: room.id,
          userName: widget.currentUserName,
          userId: widget.currentUserId,
          isHost: true,
        ),
      ),
    );
  }

  void _joinRoom(RoomModel room) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WebRTCGroupCallScreen(
          roomId: room.id,
          userName: widget.currentUserName,
          userId: widget.currentUserId,
          isHost: false,
        ),
      ),
    );
  }

  void _startGroupCallWithContacts() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        height: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Contacts',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _contacts.length,
                itemBuilder: (context, index) {
                  final contact = _contacts[index];
                  return CheckboxListTile(
                    title: Text(contact['name']!),
                    subtitle: Text(contact['role']!),
                    value: false,
                    onChanged: (value) {},
                    secondary: CircleAvatar(
                      backgroundColor: Colors.red.withOpacity(0.1),
                      child: Text(
                        contact['name']![0],
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _createNewRoom();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Start Group Call'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.group_add),
            onPressed: _startGroupCallWithContacts,
          ),
        ],
      ),
      body: Column(
        children: [
          // Active Rooms Section
          if (_rooms.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Active Rooms',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('See All'),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _rooms.length,
                itemBuilder: (context, index) {
                  final room = _rooms[index];
                  return Container(
                    width: 150,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF6B6B), Color(0xFF4ECDC4)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _joinRoom(room),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                room.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${room.participants.length} participants',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],

          // Contacts Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Contacts',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {},
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _contacts.length,
              itemBuilder: (context, index) {
                final contact = _contacts[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.red.withOpacity(0.1),
                      child: Text(
                        contact['name']![0],
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                    title: Text(contact['name']!),
                    subtitle: Text(contact['role']!),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.videocam, color: Colors.red),
                          onPressed: () {
                            _startGroupCallWithContacts();
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.phone, color: Colors.green),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewRoom,
        backgroundColor: Colors.red,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}