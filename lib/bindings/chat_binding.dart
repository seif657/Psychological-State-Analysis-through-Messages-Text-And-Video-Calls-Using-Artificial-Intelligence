import 'package:feeling_sync_chat/controllers/chat_controller.dart';
import 'package:get/get.dart';

class ChatBinding implements Bindings {
  final int chatId;
  final int currentUserId;

  ChatBinding({required this.chatId, required this.currentUserId});

  @override
  void dependencies() {
    Get.lazyPut(() => ChatController(
      chatId: chatId,
      currentUserId: currentUserId,
    ), tag: 'chat_$chatId');
  }
}