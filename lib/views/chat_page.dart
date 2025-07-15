import 'package:feeling_sync_chat/views/video_call_request_page.dart';
import 'package:feeling_sync_chat/controllers/chat_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
class ChatView extends StatefulWidget {
  final String friendName;
  final int chatId;
  final int friendId;
  final int currentUserId; // Add this parameter to pass current user id
  ChatView({
    super.key,
    required this.friendName,
    required this.chatId,
    required this.friendId,
    required this.currentUserId, // Required currentUserId here
  });
  @override
  _ChatViewState createState() => _ChatViewState();
}
class _ChatViewState extends State<ChatView> {
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  late ChatController chatController;
  Timer? refreshTimer;
  @override
  void initState() {
    super.initState();
    if (widget.chatId != 0) {
      // Debug print to verify currentUserId
      print('🔍 DEBUG - Current User ID: ${widget.currentUserId}');
      chatController = Get.put(
        ChatController(
          chatId: widget.chatId,
          currentUserId: widget.currentUserId, // Pass currentUserId here
        ),
        tag: widget.chatId.toString(),
      );
      chatController.loadMessages();
      refreshTimer = Timer.periodic(Duration(seconds: 5), (timer) {
        chatController.loadMessages();
      });
    }
  }
  @override
  void dispose() {
    messageController.dispose();
    scrollController.dispose();
    refreshTimer?.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.blue[100],
        ),
        title: Text(
          widget.friendName,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.video_call, size: 28),
            onPressed: () {
              Get.to(() => VideoCallRequestPage());
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete_messages') {
                chatController.clearMessages();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'delete_messages',
                child: Text('Delete All Messages'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (chatController.messages.isEmpty) {
                return const Center(child: Text("No messages yet."));
              }
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (scrollController.hasClients) {
                  scrollController.animateTo(
                    scrollController.position.maxScrollExtent,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                }
              });
              return ListView.builder(
                controller: scrollController,
                itemCount: chatController.messages.length,
                itemBuilder: (context, index) {
                  final message = chatController.messages[index];
                  final bool isSentByMe = message.isFromUser(chatController.currentUserId);
                  // Debug print to verify comparison
                  print(
                      '🔍 DEBUG - Message userId: ${message.userId}, ChatController currentUserId: ${chatController.currentUserId}, isSentByMe: $isSentByMe');
                  return GestureDetector(
                    onLongPress: () {
                      if (isSentByMe) {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text("Delete Message?"),
                            content: const Text(
                                "Do you want to delete this message?"),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  chatController.deleteMessage(message.id);
                                  Navigator.of(context).pop();
                                },
                                child: const Text("Delete Message"),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text("Cancel"),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    child: Align(
                      alignment: isSentByMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color:
                              isSentByMe ? Colors.blueAccent : Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isSentByMe ? "You" : widget.friendName,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isSentByMe ? Colors.white : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              message.content,
                              style: TextStyle(
                                fontSize: 16,
                                color: isSentByMe ? Colors.white : Colors.black,
                              ),
                            ),
                            if (message.sentiment != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                "Sentiment: ${message.sentiment}",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                  color: isSentByMe
                                      ? Colors.white70
                                      : Colors.black54,
                                ),
                              ),
                            ]
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: () {
                    final text = messageController.text.trim();
                    if (text.isNotEmpty) {
                      chatController.sendMessage(text);
                      messageController.clear();
                    }
                  },
                  child: const Icon(Icons.send),
                  mini: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}