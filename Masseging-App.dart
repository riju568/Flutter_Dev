import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const UltimateWhatsAppSuite());

class UltimateWhatsAppSuite extends StatelessWidget {
  const UltimateWhatsAppSuite({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WhatsApp Communications Engine',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(
          0xFF0B141A,
        ), // WhatsApp Dark background
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1F2C34), // WhatsApp App Bar Dark
          elevation: 1,
        ),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00A884), // WhatsApp Green
          secondary: Color(0xFF00A884),
          surface: Color(0xFF1F2C34),
        ),
      ),
      home: const ChatScreen(),
    );
  }
}

// Global Message Layer Model
class ChatMessage {
  final String text;
  final bool isMe;
  final String time;
  final bool isPayment;
  final double? paymentAmount;
  final bool isVoice;
  final int? voiceDuration; // Seconds
  bool isPlaying;

  ChatMessage({
    required this.text,
    required this.isMe,
    required this.time,
    this.isPayment = false,
    this.paymentAmount,
    this.isVoice = false,
    this.voiceDuration,
    this.isPlaying = false,
  });
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // Method Channel Connection Instance
  static const MethodChannel _notificationChannel = MethodChannel(
    'com.example.app/notifications',
  );

  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [
    ChatMessage(
      text: "Hey, can you look over the API contracts?",
      isMe: false,
      time: "5:01 PM",
    ),
    ChatMessage(
      text: "Sure, let me check them out in a few minutes.",
      isMe: true,
      time: "5:03 PM",
    ),
  ];

  // Dynamic Control System Flags
  bool _isTyping = false;
  bool _isRecording = false;
  int _recordDuration = 0;
  Timer? _recordTimer;

  // Global Call HUD Flags
  bool _isInCall = false;
  bool _isVideoCall = false;
  bool _isMuted = false;
  int _callDuration = 0;
  Timer? _callTimer;

  @override
  void initState() {
    super.initState();
    _messageController.addListener(() {
      setState(() {
        _isTyping = _messageController.text.trim().isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _recordTimer?.cancel();
    _callTimer?.cancel();
    _messageController.dispose();
    super.dispose();
  }

  // --- Platform Channel Execution (System Bubbles / Fallback Alert) ---
  Future<void> _triggerNativePlatformAlert(
    String sender,
    String message,
  ) async {
    try {
      await _notificationChannel.invokeMethod('showIncomingMessage', {
        'sender': sender,
        'message': message,
      });
    } on PlatformException catch (e) {
      debugPrint("Native System Messaging Error: ${e.message}");
    }
  }

  // --- Calling Engine Simulation ---
  void _startCall({required bool isVideo}) {
    setState(() {
      _isInCall = true;
      _isVideoCall = isVideo;
      _callDuration = 0;
    });
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _callDuration++);
    });
    _triggerNativePlatformAlert(
      "Alex Rivera",
      isVideo ? "Incoming Video Call..." : "Incoming Audio Call...",
    );
  }

  void _endCall() {
    _callTimer?.cancel();
    setState(() => _isInCall = false);
  }

  // --- Voice Message Processing Engine ---
  void _handleVoiceRecording() {
    if (!_isRecording) {
      setState(() {
        _isRecording = true;
        _recordDuration = 0;
      });
      _recordTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() => _recordDuration++);
      });
    } else {
      _recordTimer?.cancel();
      setState(() {
        _isRecording = false;
        _messages.add(
          ChatMessage(
            text: "Voice Note",
            isMe: true,
            time: "5:06 PM",
            isVoice: true,
            voiceDuration: _recordDuration == 0 ? 4 : _recordDuration,
          ),
        );
      });
      _triggerNativePlatformAlert(
        "System",
        "Voice memo captured successfully.",
      );
    }
  }

  // --- Standard Messaging Pipeline ---
  void _sendTextMessage() {
    if (_messageController.text.trim().isEmpty) return;
    final text = _messageController.text;
    setState(() {
      _messages.add(ChatMessage(text: text, isMe: true, time: "5:06 PM"));
    });
    _messageController.clear();

    // Simulate Native platform interaction for demo purposes
    _triggerNativePlatformAlert("You", text);
  }

  void _sendPaymentTransaction(double amount) {
    setState(() {
      _messages.add(
        ChatMessage(
          text: "Sent Payment",
          isMe: true,
          time: "5:07 PM",
          isPayment: true,
          paymentAmount: amount,
        ),
      );
    });
    _triggerNativePlatformAlert(
      "WhatsApp Pay",
      "Successfully transferred \$${amount.toStringAsFixed(2)}",
    );
  }

  String _formatTimeLayout(int totalSeconds) {
    int mins = totalSeconds ~/ 60;
    int secs = totalSeconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main Chat Workspace Layer
          Column(
            children: [
              _buildAppBarComponent(),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
                    if (msg.isPayment) return _buildPaymentMessageBubble(msg);
                    if (msg.isVoice) return _buildVoiceMessageBubble(msg);
                    return _buildStandardMessageBubble(msg);
                  },
                ),
              ),
              _buildMessageInputTray(),
            ],
          ),

          // High Priority Overlay Panel (Fullscreen Video/Audio Call Screen)
          if (_isInCall) _buildVoipOverlayCallUI(),
        ],
      ),
    );
  }

  // --- Graphical UI Construction Subcomponents ---

  PreferredSizeWidget _buildAppBarComponent() {
    return AppBar(
      titleSpacing: 0,
      title: Row(
        children: [
          const SizedBox(width: 8),
          const CircleAvatar(
            backgroundColor: Colors.blueGrey,
            child: Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "Alex Rivera",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 2),
              Text(
                "online",
                style: TextStyle(fontSize: 12, color: Color(0xFF00A884)),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () => _startCall(isVideo: true),
          icon: const Icon(Icons.videocam_rounded, color: Color(0xFF00A884)),
        ),
        IconButton(
          onPressed: () => _startCall(isVideo: false),
          icon: const Icon(Icons.call_rounded, color: Color(0xFF00A884)),
        ),
        IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert_rounded)),
      ],
    );
  }

  Widget _buildMessageInputTray() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 8, right: 8, top: 4),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF1F2C34),
                borderRadius: BorderRadius.circular(26),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.emoji_emotions_outlined,
                      color: Colors.white60,
                    ),
                  ),
                  Expanded(
                    child: _isRecording
                        ? Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.circle,
                                  size: 10,
                                  color: Colors.redAccent,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "Recording: ${_formatTimeLayout(_recordDuration)}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : TextField(
                            controller: _messageController,
                            decoration: const InputDecoration(
                              hintText: "Message",
                              border: InputBorder.none,
                              hintStyle: TextStyle(color: Colors.white30),
                            ),
                          ),
                  ),
                  if (!_isRecording) ...[
                    IconButton(
                      onPressed: _showPaymentModalSheet,
                      icon: const Icon(
                        Icons.attach_money_rounded,
                        color: Color(0xFF00A884),
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.white60,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(width: 6),
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFF00A884),
            child: IconButton(
              onPressed: _isTyping ? _sendTextMessage : _handleVoiceRecording,
              icon: Icon(
                _isTyping
                    ? Icons.send_rounded
                    : (_isRecording ? Icons.stop_rounded : Icons.mic_rounded),
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStandardMessageBubble(ChatMessage msg) {
    return Align(
      alignment: msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: msg.isMe ? const Color(0xFF005C4B) : const Color(0xFF1F2C34),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              msg.text,
              style: const TextStyle(fontSize: 15, color: Colors.white),
            ),
            const SizedBox(height: 4),
            Text(
              msg.time,
              style: const TextStyle(fontSize: 10, color: Colors.white38),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoiceMessageBubble(ChatMessage msg) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(10),
        width: 250,
        decoration: BoxDecoration(
          color: const Color(0xFF005C4B),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: () => setState(() => msg.isPlaying = !msg.isPlaying),
              icon: Icon(
                msg.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Slider(
                    value: msg.isPlaying ? 0.4 : 0.0,
                    onChanged: (v) {},
                    activeColor: Colors.tealAccent,
                    inactiveColor: Colors.white12,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatTimeLayout(msg.voiceDuration ?? 0),
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white60,
                          ),
                        ),
                        Text(
                          msg.time,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white30,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMessageBubble(ChatMessage msg) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        width: 230,
        decoration: BoxDecoration(
          color: const Color(0xFF1F2C34),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Color(0xFF005C4B),
                borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Colors.white),
                  const SizedBox(width: 12),
                  Text(
                    "\$${msg.paymentAmount?.toStringAsFixed(2)} Sent",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "WhatsApp Pay Secure • ${msg.time}",
                style: const TextStyle(fontSize: 11, color: Colors.white38),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoipOverlayCallUI() {
    return Container(
      color: const Color(0xFF111B21),
      width: double.infinity,
      height: double.infinity,
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 40.0),
              child: Column(
                children: [
                  const Text(
                    "Alex Rivera",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isVideoCall
                        ? "WhatsApp Video Call"
                        : "WhatsApp Voice Call",
                    style: const TextStyle(color: Colors.white60),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _formatTimeLayout(_callDuration),
                    style: const TextStyle(
                      fontSize: 18,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            _isVideoCall
                ? Container(
                    width: 200,
                    height: 280,
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: const Icon(
                      Icons.videocam_off_rounded,
                      size: 48,
                      color: Colors.white24,
                    ),
                  )
                : const CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.blueGrey,
                    child: Icon(Icons.person, size: 60, color: Colors.white),
                  ),
            Container(
              margin: const EdgeInsets.only(bottom: 40),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
              decoration: BoxDecoration(
                color: const Color(0xFF1F2C34),
                borderRadius: BorderRadius.circular(32),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => setState(() => _isMuted = !_isMuted),
                    icon: Icon(
                      _isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 24),
                  CircleAvatar(
                    backgroundColor: Colors.red,
                    radius: 28,
                    child: IconButton(
                      onPressed: _endCall,
                      icon: const Icon(
                        Icons.call_end_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.volume_up_rounded,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPaymentModalSheet() {
    final TextEditingController localAmountController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1F2C34),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Enter Transfer Amount",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            TextField(
              controller: localAmountController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              autofocus: true,
              style: const TextStyle(
                fontSize: 36,
                color: Color(0xFF00A884),
                fontWeight: FontWeight.bold,
              ),
              decoration: const InputDecoration(
                hintText: "\$0.00",
                border: InputBorder.none,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                double? parsedValue = double.tryParse(
                  localAmountController.text,
                );
                if (parsedValue != null && parsedValue > 0) {
                  _sendPaymentTransaction(parsedValue);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00A884),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Confirm & Authorize Payment",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
