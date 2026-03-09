import 'package:flutter/material.dart';
import 'package:them_dating_app/core/theme/theme_provider.dart';
import 'package:provider/provider.dart';

class MessageInput extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSend;
  final VoidCallback onImagePressed;
  final VoidCallback onVoicePressed;
  final VoidCallback onEmojiPressed;
  final Function(bool) onTypingChanged;

  const MessageInput({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onSend,
    required this.onImagePressed,
    required this.onVoicePressed,
    required this.onEmojiPressed,
    required this.onTypingChanged,
  });

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  bool _isRecording = false;
  double _recordingDuration = 0.0;

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // More options
          _buildIconButton(
            icon: Icons.add_circle_outline,
            onPressed: _showMoreOptions,
          ),

          const SizedBox(width: 4),

          // Emoji button
          _buildIconButton(
            icon: Icons.emoji_emotions_outlined,
            onPressed: widget.onEmojiPressed,
          ),

          const SizedBox(width: 8),

          // Text field
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.grey[100],
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: widget.controller,
                      focusNode: widget.focusNode,
                      maxLines: null,
                      minLines: 1,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      onChanged: (value) {
                        widget.onTypingChanged(value.isNotEmpty);
                      },
                    ),
                  ),
                  if (widget.controller.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: widget.onSend,
                      color: Colors.red,
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Voice / Image button
          if (widget.controller.text.isEmpty)
            _buildIconButton(
              icon: _isRecording ? Icons.stop_circle : Icons.mic_none,
              color: _isRecording ? Colors.red : null,
              onPressed: _toggleRecording,
            )
          else
            _buildIconButton(
              icon: Icons.image_outlined,
              onPressed: widget.onImagePressed,
            ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onPressed,
    Color? color,
  }) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color?.withOpacity(0.1),
      ),
      child: IconButton(
        icon: Icon(icon, color: color),
        onPressed: onPressed,
        iconSize: 24,
        padding: EdgeInsets.zero,
      ),
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Share',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildShareOption(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  onTap: () {
                    Navigator.pop(context);
                    widget.onImagePressed();
                  },
                ),
                _buildShareOption(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  onTap: () {
                    Navigator.pop(context);
                    // Open camera
                  },
                ),
                _buildShareOption(
                  icon: Icons.audiotrack,
                  label: 'Audio',
                  onTap: () {
                    Navigator.pop(context);
                    widget.onVoicePressed();
                  },
                ),
                _buildShareOption(
                  icon: Icons.location_on,
                  label: 'Location',
                  onTap: () {
                    Navigator.pop(context);
                    // Share location
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.red, size: 30),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  void _toggleRecording() {
    setState(() {
      _isRecording = !_isRecording;
    });

    if (_isRecording) {
      // Start recording
      _startRecording();
    } else {
      // Stop recording
      _stopRecording();
    }
  }

  void _startRecording() {
    // Implement voice recording
    widget.onTypingChanged(false);
  }

  void _stopRecording() {
    // Stop recording and send
    setState(() {
      _recordingDuration = 0.0;
    });
  }
}