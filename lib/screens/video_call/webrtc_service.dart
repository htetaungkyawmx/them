import 'dart:async';
import 'dart:convert';

import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:them_dating_app/screens/video_call/models/room_model.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebRTCService {
  static final WebRTCService _instance = WebRTCService._internal();
  factory WebRTCService() => _instance;
  WebRTCService._internal();

  // Peer connections map (for group call)
  final Map<String, RTCPeerConnection> _peerConnections = {};
  final Map<String, MediaStream> _remoteStreams = {};

  MediaStream? _localStream;
  WebSocketChannel? _channel;

  final _localRenderer = RTCVideoRenderer();
  final Map<String, RTCVideoRenderer> _remoteRenderers = {};

  String? _roomId;
  String? _userId;
  String? _userName;
  bool _isReconnecting = false;

  // Callbacks
  Function(List<ParticipantModel> participants)? onParticipantsUpdate;
  Function(String userId, MediaStream stream)? onRemoteStreamAdded;
  Function(String userId)? onRemoteStreamRemoved;
  Function()? onConnected;
  Function(String)? onError;

  List<ParticipantModel> _participants = [];

  List<ParticipantModel> get participants => _participants;
  RTCVideoRenderer get localRenderer => _localRenderer;
  RTCVideoRenderer? get remoteRenderer => _remoteRenderers.isNotEmpty ? _remoteRenderers.values.first : null;
  Map<String, RTCVideoRenderer> get remoteRenderers => _remoteRenderers;

  Future<void> initializeRenderers() async {
    await _localRenderer.initialize();
  }

  Future<void> connectToSignalingServer(String serverUrl) async {
    try {
      _channel = IOWebSocketChannel.connect(
        serverUrl,
        pingInterval: const Duration(seconds: 30),
      );

      _channel!.stream.listen(
        _handleSignalingMessage,
        onError: (error) {
          print('❌ WebSocket error: $error');
          onError?.call('Connection error');
          _attemptReconnect(serverUrl);
        },
        onDone: () {
          print('🔌 WebSocket connection closed');
          _attemptReconnect(serverUrl);
        },
      );

      print('✅ Connected to signaling server');
      onConnected?.call();
    } catch (e) {
      print('❌ Failed to connect: $e');
      onError?.call('Failed to connect to server');
      _attemptReconnect(serverUrl);
    }
  }

  void _attemptReconnect(String serverUrl) {
    if (_isReconnecting) return;
    _isReconnecting = true;

    Future.delayed(const Duration(seconds: 5), () {
      _isReconnecting = false;
      connectToSignalingServer(serverUrl);
    });
  }

  void _handleSignalingMessage(dynamic message) {
    try {
      final data = message is String ? jsonDecode(message) : message;

      if (data is! Map<String, dynamic>) return;

      switch (data['type']) {
        case 'room-joined':
          _handleRoomJoined(data);
          break;
        case 'user-joined':
          _handleUserJoined(data);
          break;
        case 'user-left':
          _handleUserLeft(data);
          break;
        case 'offer':
          _handleOffer(data);
          break;
        case 'answer':
          _handleAnswer(data);
          break;
        case 'ice-candidate':
          _handleIceCandidate(data);
          break;
        case 'participant-update':
          _updateParticipants(data['participants']);
          break;
        case 'room-full':
          onError?.call('Room is full');
          break;
        case 'error':
          onError?.call(data['message'] ?? 'Unknown error');
          break;
      }
    } catch (e) {
      print('Error handling message: $e');
    }
  }

  Future<void> createRoom(String roomId, String userId, String userName) async {
    _roomId = roomId;
    _userId = userId;
    _userName = userName;

    if (_channel != null) {
      _channel!.sink.add(jsonEncode({
        'type': 'create-room',
        'roomId': roomId,
        'userId': userId,
        'userName': userName,
      }));
    }

    await _setupLocalStream();
  }

  Future<void> joinRoom(String roomId, String userId, String userName) async {
    _roomId = roomId;
    _userId = userId;
    _userName = userName;

    if (_channel != null) {
      _channel!.sink.add(jsonEncode({
        'type': 'join-room',
        'roomId': roomId,
        'userId': userId,
        'userName': userName,
      }));
    }

    await _setupLocalStream();
  }

  Future<void> _setupLocalStream() async {
    final constraints = {
      'audio': true,
      'video': {
        'facingMode': 'user',
        'width': 640,
        'height': 480,
      }
    };

    try {
      _localStream = await navigator.mediaDevices.getUserMedia(constraints);
      _localRenderer.srcObject = _localStream;

      // Add local participant
      _participants.add(ParticipantModel(
        id: _userId!,
        name: _userName!,
        role: 'Host',
      ));
      onParticipantsUpdate?.call(_participants);

    } catch (e) {
      print('Error getting user media: $e');
      onError?.call('Could not access camera/microphone');
    }
  }

  void _handleRoomJoined(Map<String, dynamic> data) {
    print('✅ Joined room: ${data['roomId']}');

    // Update participants list
    if (data['participants'] != null) {
      _updateParticipants(data['participants']);
    }
  }

  void _handleUserJoined(Map<String, dynamic> data) async {
    final newUserId = data['userId'];
    final newUserName = data['userName'];

    print('👤 User joined: $newUserName');

    // Add to participants list
    _participants.add(ParticipantModel(
      id: newUserId,
      name: newUserName,
    ));
    onParticipantsUpdate?.call(_participants);

    // Create peer connection for new user
    await _createPeerConnection(newUserId);

    // Create and send offer
    final offer = await _peerConnections[newUserId]!.createOffer();
    await _peerConnections[newUserId]!.setLocalDescription(offer);

    if (_channel != null) {
      _channel!.sink.add(jsonEncode({
        'type': 'offer',
        'offer': {
          'sdp': offer.sdp,
          'type': offer.type,
        },
        'to': newUserId,
        'from': _userId,
        'roomId': _roomId,
      }));
    }
  }

  void _handleUserLeft(Map<String, dynamic> data) {
    final leftUserId = data['userId'];

    print('👋 User left: $leftUserId');

    // Remove from participants
    _participants.removeWhere((p) => p.id == leftUserId);
    onParticipantsUpdate?.call(_participants);

    // Close peer connection
    if (_peerConnections.containsKey(leftUserId)) {
      _peerConnections[leftUserId]!.close();
      _peerConnections.remove(leftUserId);
    }

    // Remove remote stream
    if (_remoteStreams.containsKey(leftUserId)) {
      _remoteStreams.remove(leftUserId);
    }

    // Remove renderer
    if (_remoteRenderers.containsKey(leftUserId)) {
      _remoteRenderers[leftUserId]!.dispose();
      _remoteRenderers.remove(leftUserId);
    }

    onRemoteStreamRemoved?.call(leftUserId);
  }

  Future<void> _createPeerConnection(String peerId) async {
    final configuration = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
        {'urls': 'stun:stun1.l.google.com:19302'},
        {'urls': 'stun:stun2.l.google.com:19302'},
        {'urls': 'stun:stun3.l.google.com:19302'},
        {'urls': 'stun:stun4.l.google.com:19302'},
      ]
    };

    final peerConnection = await createPeerConnection(configuration);

    peerConnection.onIceCandidate = (candidate) {
      if (_channel != null && candidate != null) {
        _channel!.sink.add(jsonEncode({
          'type': 'ice-candidate',
          'candidate': {
            'candidate': candidate.candidate,
            'sdpMid': candidate.sdpMid,
            'sdpMLineIndex': candidate.sdpMLineIndex,
          },
          'to': peerId,
          'from': _userId,
          'roomId': _roomId,
        }));
      }
    };

    peerConnection.onIceConnectionState = (state) {
      print('ICE connection state with $peerId: $state');
    };

    peerConnection.onTrack = (event) {
      if (event.track.kind == 'video') {
        _handleRemoteStream(peerId, event.streams[0]);
      }
    };

    // Add local tracks
    if (_localStream != null) {
      _localStream!.getTracks().forEach((track) {
        peerConnection.addTrack(track, _localStream!);
      });
    }

    _peerConnections[peerId] = peerConnection;
  }

  void _handleRemoteStream(String peerId, MediaStream stream) {
    print('📹 Remote stream added from $peerId');

    _remoteStreams[peerId] = stream;

    // Create renderer for this peer
    final renderer = RTCVideoRenderer();
    renderer.initialize().then((_) {
      renderer.srcObject = stream;
      _remoteRenderers[peerId] = renderer;
      onRemoteStreamAdded?.call(peerId, stream);
    });
  }

  void _handleRemoveRemoteStream(String peerId) {
    print('❌ Remote stream removed from $peerId');
    _remoteStreams.remove(peerId);
    onRemoteStreamRemoved?.call(peerId);
  }

  Future<void> _handleOffer(Map<String, dynamic> data) async {
    final fromUserId = data['from'];
    final offerData = data['offer'];

    final offer = RTCSessionDescription(
        offerData['sdp'],
        offerData['type']
    );

    await _createPeerConnection(fromUserId);
    await _peerConnections[fromUserId]!.setRemoteDescription(offer);

    final answer = await _peerConnections[fromUserId]!.createAnswer();
    await _peerConnections[fromUserId]!.setLocalDescription(answer);

    if (_channel != null) {
      _channel!.sink.add(jsonEncode({
        'type': 'answer',
        'answer': {
          'sdp': answer.sdp,
          'type': answer.type,
        },
        'to': fromUserId,
        'from': _userId,
        'roomId': _roomId,
      }));
    }
  }

  Future<void> _handleAnswer(Map<String, dynamic> data) async {
    final fromUserId = data['from'];
    final answerData = data['answer'];

    final answer = RTCSessionDescription(
        answerData['sdp'],
        answerData['type']
    );

    await _peerConnections[fromUserId]!.setRemoteDescription(answer);
  }

  Future<void> _handleIceCandidate(Map<String, dynamic> data) async {
    final fromUserId = data['from'];
    final candidateData = data['candidate'];

    final candidate = RTCIceCandidate(
        candidateData['candidate'],
        candidateData['sdpMid'],
        candidateData['sdpMLineIndex']
    );

    if (_peerConnections.containsKey(fromUserId)) {
      await _peerConnections[fromUserId]!.addCandidate(candidate);
    }
  }

  void _updateParticipants(List<dynamic> participantsData) {
    _participants = participantsData.map((p) => ParticipantModel(
      id: p['id'],
      name: p['name'],
      role: p['role'] ?? 'Participant',
      isAudioEnabled: p['isAudioEnabled'] ?? true,
      isVideoEnabled: p['isVideoEnabled'] ?? true,
      isSpeaking: p['isSpeaking'] ?? false,
    )).toList();

    onParticipantsUpdate?.call(_participants);
  }

  void toggleMute() {
    if (_localStream != null) {
      final audioTracks = _localStream!.getAudioTracks();
      if (audioTracks.isNotEmpty) {
        audioTracks.first.enabled = !audioTracks.first.enabled;

        // Send update to server
        if (_channel != null) {
          _channel!.sink.add(jsonEncode({
            'type': 'toggle-audio',
            'roomId': _roomId,
            'userId': _userId,
            'enabled': audioTracks.first.enabled,
          }));
        }

        // Update local participant status
        final participantIndex = _participants.indexWhere((p) => p.id == _userId);
        if (participantIndex != -1) {
          _participants[participantIndex] = _participants[participantIndex].copyWith(
            isAudioEnabled: audioTracks.first.enabled,
          );
          onParticipantsUpdate?.call(_participants);
        }
      }
    }
  }

  void toggleCamera() {
    if (_localStream != null) {
      final videoTracks = _localStream!.getVideoTracks();
      if (videoTracks.isNotEmpty) {
        videoTracks.first.enabled = !videoTracks.first.enabled;

        // Send update to server
        if (_channel != null) {
          _channel!.sink.add(jsonEncode({
            'type': 'toggle-video',
            'roomId': _roomId,
            'userId': _userId,
            'enabled': videoTracks.first.enabled,
          }));
        }

        // Update local participant status
        final participantIndex = _participants.indexWhere((p) => p.id == _userId);
        if (participantIndex != -1) {
          _participants[participantIndex] = _participants[participantIndex].copyWith(
            isVideoEnabled: videoTracks.first.enabled,
          );
          onParticipantsUpdate?.call(_participants);
        }
      }
    }
  }

  Future<void> switchCamera() async {
    if (_localStream != null) {
      await Helper.switchCamera(_localStream!);
    }
  }

  void setSpeaking(bool isSpeaking) {
    if (_channel != null) {
      _channel!.sink.add(jsonEncode({
        'type': 'speaking',
        'roomId': _roomId,
        'userId': _userId,
        'isSpeaking': isSpeaking,
      }));
    }

    final participantIndex = _participants.indexWhere((p) => p.id == _userId);
    if (participantIndex != -1) {
      _participants[participantIndex] = _participants[participantIndex].copyWith(
        isSpeaking: isSpeaking,
      );
      onParticipantsUpdate?.call(_participants);
    }
  }

  // Add hangUp method (alias for leaveRoom)
  Future<void> hangUp() async {
    await leaveRoom();
  }

  Future<void> leaveRoom() async {
    // Close all peer connections
    for (var entry in _peerConnections.entries) {
      await entry.value.close();
    }
    _peerConnections.clear();

    // Stop local stream
    if (_localStream != null) {
      _localStream!.getTracks().forEach((track) => track.stop());
      _localStream = null;
    }

    // Clear remote streams
    _remoteStreams.clear();

    // Dispose renderers
    _localRenderer.srcObject = null;
    for (var renderer in _remoteRenderers.values) {
      renderer.dispose();
    }
    _remoteRenderers.clear();

    // Notify server
    if (_channel != null) {
      _channel!.sink.add(jsonEncode({
        'type': 'leave-room',
        'roomId': _roomId,
        'userId': _userId,
      }));
      await _channel!.sink.close();
      _channel = null;
    }

    _participants.clear();
  }

  void dispose() {
    _localRenderer.dispose();
    for (var renderer in _remoteRenderers.values) {
      renderer.dispose();
    }
  }
}