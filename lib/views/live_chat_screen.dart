import 'package:flutter/material.dart';
import 'dart:async';
import '../services/chat_service.dart';
import '../services/auth_session.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({required this.text, required this.isUser, required this.timestamp});
}

class LiveChatScreen extends StatefulWidget {
  const LiveChatScreen({super.key});

  @override
  State<LiveChatScreen> createState() => _LiveChatScreenState();
}

class _LiveChatScreenState extends State<LiveChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  
  bool _isLoading = true;
  String? _userId;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _initChat();
  }

  Future<void> _initChat() async {
    final userData = await AuthSession.load();
    if (userData != null && userData['id'] != null) {
      _userId = userData['id'].toString();
      await _fetchMessages();
      
      // Start polling every 3 seconds
      _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) {
        _fetchMessages(isBackground: true);
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchMessages({bool isBackground = false}) async {
    if (_userId == null) return;
    
    final data = await ChatService.fetchMessages(_userId!);
    
    if (!mounted) return;
    
    final newMessages = data.map((m) {
      return ChatMessage(
        text: m['message'],
        isUser: m['is_from_admin'] == 0, // 0 = false in MySQL boolean
        timestamp: DateTime.parse(m['created_at']).toLocal(),
      );
    }).toList();

    // If new message came in, scroll to bottom
    bool shouldScroll = newMessages.length > _messages.length;

    setState(() {
      _messages.clear();
      _messages.addAll(newMessages);
      if (!isBackground) _isLoading = false;
    });

    if (shouldScroll) {
      _scrollToBottom();
    }
  }

  Future<void> _sendMessage() async {
    if (_controller.text.trim().isEmpty || _userId == null) return;

    final userText = _controller.text.trim();
    _controller.clear();

    // Optimistically add message
    setState(() {
      _messages.add(ChatMessage(
        text: userText,
        isUser: true,
        timestamp: DateTime.now(),
      ));
    });
    _scrollToBottom();

    // Send to server
    await ChatService.sendMessage(_userId!, userText);

    // Fetch messages immediately to get the bot's instant reply
    await _fetchMessages();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Support Chat'),
        elevation: 1,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Colors.blue))
        : Column(
            children: [
              if (_messages.isEmpty)
                Expanded(
                  child: Center(
                    child: Text("Start a conversation with our support team.", style: TextStyle(color: Colors.grey.shade600)),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return _buildMessageBubble(message);
                    },
                  ),
                ),
              _buildMessageInput(),
            ],
          ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: message.isUser ? Colors.blue : Colors.grey.shade200,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: message.isUser ? const Radius.circular(16) : Radius.zero,
            bottomRight: message.isUser ? Radius.zero : const Radius.circular(16),
          ),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: message.isUser ? Colors.white : Colors.black87,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, -2),
            blurRadius: 4,
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Type your message...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Colors.blue,
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white, size: 20),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
