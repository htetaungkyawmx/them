import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:provider/provider.dart';
import 'package:them_dating_app/core/theme/theme_provider.dart';
import 'package:them_dating_app/screens/video_call/webrtc_service.dart';

class WebRTCCallScreen extends StatefulWidget {
  final String roomId;
  final String userName;
  final String userId;

  const WebRTCCallScreen({
    super.key,
    required this.roomId,
    required this.userName,
    required this.userId,
  });

  @override
  State<WebRTCCallScreen> createState() => _WebRTCCallScreenState();
}

class _WebRTCCallScreenState extends State<WebRTCCallScreen> {
  final WebRTCService _webrtcService = WebRTCService();
  bool _isMuted = false;
  bool _isCameraEnabled = true;
  bool _isRemoteVideoAvailable = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeCall();
  }

  Future<void> _initializeCall() async {
    try {
      await _webrtcService.initializeRenderers();

      // Set up callbacks before connecting
      _webrtcService.onRemoteStreamAdded = (userId, stream) {
        print('Remote stream added for user: $userId');
        setState(() {
          _isRemoteVideoAvailable = true;
        });
      };

      _webrtcService.onRemoteStreamRemoved = (userId) {
        print('Remote stream removed for user: $userId');
        setState(() {
          _isRemoteVideoAvailable = false;
        });
      };

      _webrtcService.onError = (error) {
        print('WebRTC error: $error');
        setState(() {
          _errorMessage = error;
        });
      };

      _webrtcService.onConnected = () {
        print('Connected to signaling server');
      };

      // Connect to signaling server
      await _webrtcService.connectToSignalingServer('ws://192.168.1.12:3001');

      // Join room
      await _webrtcService.joinRoom(widget.roomId, widget.userId, widget.userName);

    } catch (e) {
      print('Error initializing call: $e');
      setState(() {
        _errorMessage = 'Failed to initialize call';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 80, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(_errorMessage!),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // Remote video
          if (_isRemoteVideoAvailable && _webrtcService.remoteRenderer != null)
            RTCVideoView(
              _webrtcService.remoteRenderer!,
              objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
            )
          else
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.videocam_off,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Waiting for partner to join...',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const CircularProgressIndicator(),
                ],
              ),
            ),

          // Local video (picture-in-picture)
          Positioned(
            top: 50,
            right: 20,
            child: Container(
              width: 120,
              height: 160,
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

          // Call controls
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildControlButton(
                    icon: _isMuted ? Icons.mic_off : Icons.mic,
                    color: _isMuted ? Colors.red : Colors.white,
                    onPressed: _toggleMute,
                  ),
                  _buildControlButton(
                    icon: _isCameraEnabled ? Icons.videocam : Icons.videocam_off,
                    color: _isCameraEnabled ? Colors.white : Colors.red,
                    onPressed: _toggleCamera,
                  ),
                  _buildControlButton(
                    icon: Icons.call_end,
                    color: Colors.red,
                    onPressed: _hangUp,
                    size: 60,
                  ),
                  _buildControlButton(
                    icon: Icons.switch_camera,
                    color: Colors.white,
                    onPressed: _switchCamera,
                  ),
                ],
              ),
            ),
          ),

          // Call info
          Positioned(
            top: 60,
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? Colors.black54 : Colors.white54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.circle, color: Colors.green, size: 12),
                  const SizedBox(width: 8),
                  Text(
                    widget.userName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isRemoteVideoAvailable ? 'Connected' : 'Calling...',
                    style: TextStyle(
                      color: _isRemoteVideoAvailable ? Colors.green : Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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

  void _hangUp() async {
    await _webrtcService.hangUp();
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