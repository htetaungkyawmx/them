import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:them_dating_app/core/theme/theme_provider.dart';
import 'package:them_dating_app/screens/video_call/webrtc_call_screen.dart';
import 'package:them_dating_app/screens/video_call/webrtc_group_call_screen.dart';
import 'package:uuid/uuid.dart';

class RoomModel {
  final String id;
  final String name;
  final String createdBy;
  final DateTime createdAt;
  final int participantCount;
  final bool isActive;

  RoomModel({
    required this.id,
    required this.name,
    required this.createdBy,
    required this.createdAt,
    required this.participantCount,
    required this.isActive,
  });
}

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
    {'id': '1', 'name': 'John Doe', 'role': 'Product Manager', 'online': 'true'},
    {'id': '2', 'name': 'Jane Smith', 'role': 'UI/UX Designer', 'online': 'true'},
    {'id': '3', 'name': 'Mike Johnson', 'role': 'Flutter Developer', 'online': 'false'},
    {'id': '4', 'name': 'Sarah Wilson', 'role': 'Backend Engineer', 'online': 'true'},
    {'id': '5', 'name': 'David Brown', 'role': 'DevOps Engineer', 'online': 'false'},
    {'id': '6', 'name': 'Emily Davis', 'role': 'Product Owner', 'online': 'true'},
  ];

  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  void _loadRooms() {
    // Mock rooms - in production, fetch from server
    setState(() {
      _rooms.addAll([
        RoomModel(
          id: const Uuid().v4(),
          name: 'Team Sync',
          createdBy: widget.currentUserId,
          createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
          participantCount: 3,
          isActive: true,
        ),
        RoomModel(
          id: const Uuid().v4(),
          name: 'Project Discussion',
          createdBy: 'user2',
          createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
          participantCount: 5,
          isActive: true,
        ),
        RoomModel(
          id: const Uuid().v4(),
          name: 'Daily Standup',
          createdBy: 'user3',
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
          participantCount: 2,
          isActive: false,
        ),
      ]);
    });
  }

  void _createNewRoom() {
    final roomId = const Uuid().v4();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WebRTCGroupCallScreen(
          roomId: roomId,
          userName: widget.currentUserName,
          userId: widget.currentUserId,
          isHost: true,
        ),
      ),
    ).then((_) {
      _loadRooms();
    });
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

  void _startCallWithContact(String contactId, String contactName) {
    final roomId = const Uuid().v4();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WebRTCCallScreen(
          roomId: roomId,
          userName: contactName,
          userId: widget.currentUserId,
        ),
      ),
    );
  }

  void _startGroupCallWithContacts() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Select Contacts',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search contacts...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: _contacts.length,
                    itemBuilder: (context, index) {
                      final contact = _contacts[index];
                      return CheckboxListTile(
                        title: Text(contact['name']!),
                        subtitle: Text(contact['role']!),
                        secondary: Stack(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.red.withOpacity(0.1),
                              child: Text(
                                contact['name']![0],
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                            if (contact['online'] == 'true')
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        value: false,
                        onChanged: (value) {},
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
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // Quick Actions
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildQuickActionCard(
                    icon: Icons.video_call,
                    label: 'New Meeting',
                    color: Colors.red,
                    onTap: _createNewRoom,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionCard(
                    icon: Icons.group_add,
                    label: 'Schedule',
                    color: Colors.blue,
                    onTap: _startGroupCallWithContacts,
                  ),
                ),
              ],
            ),
          ),

          // Active Rooms Section
          if (_rooms.where((r) => r.isActive).isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _rooms.length,
                itemBuilder: (context, index) {
                  final room = _rooms[index];
                  if (!room.isActive) return const SizedBox.shrink();

                  return GestureDetector(
                    onTap: () => _joinRoom(room),
                    child: Container(
                      width: 160,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF6B6B), Color(0xFF4ECDC4)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Stack(
                        children: [
                          Padding(
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
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.person,
                                      color: Colors.white70,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${room.participantCount} participants',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatTime(room.createdAt),
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (room.createdBy == widget.currentUserId)
                            const Positioned(
                              top: 8,
                              right: 8,
                              child: Icon(
                                Icons.star,
                                color: Colors.yellow,
                                size: 16,
                              ),
                            ),
                        ],
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
                  'Online Contacts',
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
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: Stack(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.red.withOpacity(0.1),
                          radius: 24,
                          child: Text(
                            contact['name']![0],
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (contact['online'] == 'true')
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    title: Text(
                      contact['name']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(contact['role']!),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (contact['online'] == 'true') ...[
                          IconButton(
                            icon: const Icon(Icons.videocam, color: Colors.red),
                            onPressed: () => _startCallWithContact(
                              contact['id']!,
                              contact['name']!,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.phone, color: Colors.green),
                            onPressed: () {
                              // Audio call
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}