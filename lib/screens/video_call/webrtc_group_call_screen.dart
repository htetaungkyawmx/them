import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:provider/provider.dart';
import 'package:them_dating_app/core/theme/theme_provider.dart';
import 'package:them_dating_app/screens/video_call/webrtc_service.dart';
import 'package:them_dating_app/screens/video_call/models/room_model.dart';

class WebRTCGroupCallScreen extends StatefulWidget {
  final String roomId;
  final String userName;
  final String userId;
  final bool isHost;

  const WebRTCGroupCallScreen({
    super.key,
    required this.roomId,
    required this.userName,
    required this.userId,
    required this.isHost,
  });

  @override
  State<WebRTCGroupCallScreen> createState() => _WebRTCGroupCallScreenState();
}

class _WebRTCGroupCallScreenState extends State<WebRTCGroupCallScreen> {
  final WebRTCService _webrtcService = WebRTCService();
  bool _isMuted = false;
  bool _isCameraEnabled = true;
  bool _isSpeakerView = false;
  List<ParticipantModel> _participants = [];

  @override
  void initState() {
    super.initState();
    _initializeCall();
  }

  Future<void> _initializeCall() async {
    await _webrtcService.initializeRenderers();
    await _webrtcService.connectToSignalingServer('ws://192.168.1.12:3001');

    _webrtcService.onParticipantsUpdate = (participants) {
      setState(() {
        _participants = participants;
      });
    };

    _webrtcService.onRemoteStreamAdded = (userId, stream) {
      setState(() {});
    };

    _webrtcService.onRemoteStreamRemoved = (userId) {
      setState(() {});
    };

    if (widget.isHost) {
      await _webrtcService.createRoom(widget.roomId, widget.userId, widget.userName);
    } else {
      await _webrtcService.joinRoom(widget.roomId, widget.userId, widget.userName);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return Scaffold(
      body: Stack(
        children: [
          // Main content (speaker view or grid view)
          _isSpeakerView ? _buildSpeakerView() : _buildGridView(),

          // Local video (picture-in-picture)
          Positioned(
            top: 50,
            right: 20,
            child: Container(
              width: 100,
              height: 140,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: RTCVideoView(
                  _webrtcService.localRenderer,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                ),
              ),
            ),
          ),

          // Room info
          Positioned(
            top: 60,
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? Colors.black54 : Colors.white54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Room: ${widget.roomId.substring(0, 8)}...',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${_participants.length} participants',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Participants list (side panel)
          if (_participants.length > 4)
            Positioned(
              top: 60,
              right: 140,
              child: Container(
                width: 200,
                height: 200,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.black54 : Colors.white54,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Participants',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _participants.length,
                        itemBuilder: (context, index) {
                          final participant = _participants[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.circle,
                                  size: 8,
                                  color: participant.isSpeaking
                                      ? Colors.green
                                      : Colors.grey,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    participant.name,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                                if (!participant.isAudioEnabled)
                                  const Icon(Icons.mic_off, size: 12),
                                if (!participant.isVideoEnabled)
                                  const Icon(Icons.videocam_off, size: 12),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Call controls
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildControlButton(
                    icon: _isMuted ? Icons.mic_off : Icons.mic,
                    color: _isMuted ? Colors.red : Colors.white,
                    onPressed: _toggleMute,
                  ),
                  const SizedBox(width: 16),
                  _buildControlButton(
                    icon: _isCameraEnabled ? Icons.videocam : Icons.videocam_off,
                    color: _isCameraEnabled ? Colors.white : Colors.red,
                    onPressed: _toggleCamera,
                  ),
                  const SizedBox(width: 16),
                  _buildControlButton(
                    icon: Icons.call_end,
                    color: Colors.red,
                    onPressed: _leaveRoom,
                    size: 60,
                  ),
                  const SizedBox(width: 16),
                  _buildControlButton(
                    icon: Icons.switch_camera,
                    color: Colors.white,
                    onPressed: _switchCamera,
                  ),
                  const SizedBox(width: 16),
                  _buildControlButton(
                    icon: _isSpeakerView ? Icons.grid_view : Icons.person,
                    color: Colors.white,
                    onPressed: _toggleView,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridView() {
    if (_participants.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(
              'Waiting for participants to join...',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.75,
      ),
      itemCount: _participants.length,
      itemBuilder: (context, index) {
        final participant = _participants[index];
        final hasVideo = _webrtcService.remoteRenderers.containsKey(participant.id);

        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: participant.isSpeaking ? Colors.green : Colors.transparent,
              width: 2,
            ),
          ),
          child: Stack(
            children: [
              if (hasVideo)
                RTCVideoView(
                  _webrtcService.remoteRenderers[participant.id]!,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                )
              else
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.red.withOpacity(0.2),
                        child: Text(
                          participant.name[0],
                          style: const TextStyle(
                            fontSize: 24,
                            color: Colors.red,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        participant.name,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              Positioned(
                bottom: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!participant.isAudioEnabled)
                        const Icon(Icons.mic_off, color: Colors.red, size: 14),
                      if (!participant.isVideoEnabled && hasVideo)
                        const Icon(Icons.videocam_off, color: Colors.red, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        participant.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSpeakerView() {
    final speaker = _participants.firstWhere(
          (p) => p.isSpeaking,
      orElse: () => _participants.isNotEmpty ? _participants.first : ParticipantModel(
        id: '',
        name: 'No one',
      ),
    );

    final hasVideo = _webrtcService.remoteRenderers.containsKey(speaker.id);

    return Stack(
      children: [
        if (hasVideo && speaker.id != widget.userId)
          RTCVideoView(
            _webrtcService.remoteRenderers[speaker.id]!,
            objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
          )
        else
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.red.withOpacity(0.2),
                  child: Text(
                    speaker.name[0],
                    style: const TextStyle(fontSize: 40, color: Colors.red),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  speaker.name,
                  style: const TextStyle(fontSize: 24),
                ),
                const Text('Speaking...'),
              ],
            ),
          ),
        Positioned(
          bottom: 20,
          left: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '🎤 ${speaker.name} is speaking',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    double size = 50,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color.withOpacity(0.3),
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 2),
        ),
        child: Icon(
          icon,
          color: color,
          size: size * 0.5,
        ),
      ),
    );
  }

  void _toggleMute() {
    _webrtcService.toggleMute();
    setState(() {
      _isMuted = !_isMuted;
    });
  }

  void _toggleCamera() {
    _webrtcService.toggleCamera();
    setState(() {
      _isCameraEnabled = !_isCameraEnabled;
    });
  }

  void _switchCamera() {
    _webrtcService.switchCamera();
  }

  void _toggleView() {
    setState(() {
      _isSpeakerView = !_isSpeakerView;
    });
  }

  Future<void> _leaveRoom() async {
    await _webrtcService.leaveRoom();
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _webrtcService.dispose();
    super.dispose();
  }
}