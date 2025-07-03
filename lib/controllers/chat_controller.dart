import 'package:feeling_sync_chat/services/sentiment_service.dart';
import 'package:feeling_sync_chat/services/pusher_service.dart';
import 'package:feeling_sync_chat/services/chat_service.dart';
import 'package:feeling_sync_chat/models/message_model.dart';
import 'package:get/get.dart';

class ChatController extends GetxController {
  // Dependencies
  final ChatService _chatService;
  final PusherService _pusherService;
  final SentimentService _sentimentService;

  // Reactive state
  final RxList<Message> messages = <Message>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  final int chatId;
  final int currentUserId; // This is a normal int, NOT reactive

  ChatController({
    required this.chatId,
    required this.currentUserId,
    ChatService? chatService,
    PusherService? pusherService,
    SentimentService? sentimentService,
  })  : _chatService = chatService ?? Get.find<ChatService>(),
        _pusherService = pusherService ?? Get.find<PusherService>(),
        _sentimentService = sentimentService ?? Get.find<SentimentService>();

  @override
  void onInit() {
    super.onInit();
    _loadInitialMessages();
    _setupPusher();
  }

  Future<void> loadMessages() async {
    // Public method to load messages
    await _loadInitialMessages();
  }

  Future<void> _loadInitialMessages() async {
    try {
      isLoading.value = true;
      messages.assignAll(await _chatService.getMessages(chatId));
    } catch (e) {
      errorMessage.value = 'Failed to load messages: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  void _setupPusher() {
    _pusherService.subscribeToPrivateChannel('chat.$chatId');
    _pusherService.bindEvent('new-message', (data) {
      try {
        final message = Message.fromJson(data);
        _addOrUpdateMessage(message);
      } catch (e) {
        errorMessage.value = 'Failed to process new message';
      }
    });
  }

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    final tempMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch, // Temporary ID
      userId: currentUserId,
      content: content,
      createdAt: DateTime.now(),
      isPending: true,
    );

    // Optimistic UI update
    messages.add(tempMessage);

    try {
      final sentiment = await _sentimentService.analyzeSentiment(content);
      final sentMessage = await _chatService.sendMessage(
        chatId: chatId,
        content: content,
        sentiment: sentiment,
      );

      // Replace temporary message with server response
      _replaceMessage(tempMessage.id, sentMessage);
    } catch (e) {
      // Mark as failed if sending doesn't succeed
      _updateMessageStatus(tempMessage.id, isFailed: true);
      errorMessage.value = 'Failed to send message';
    }
  }

  Future<void> deleteMessage(int messageId) async {
    try {
      await _chatService.deleteMessage(messageId);
      messages.removeWhere((m) => m.id == messageId);
    } catch (e) {
      errorMessage.value = 'Failed to delete message';
    }
  }

  void clearMessages() {
    messages.clear();
  }

  // Helper methods for message management
  void _addOrUpdateMessage(Message message) {
    final index = messages.indexWhere((m) => m.id == message.id);
    if (index >= 0) {
      messages[index] = message;
    } else {
      messages.add(message);
    }
  }

  void _replaceMessage(int oldId, Message newMessage) {
    final index = messages.indexWhere((m) => m.id == oldId);
    if (index >= 0) {
      messages[index] = newMessage;
    }
  }

  void _updateMessageStatus(int messageId, {bool isPending = false, bool isFailed = false}) {
    final index = messages.indexWhere((m) => m.id == messageId);
    if (index >= 0) {
      messages[index] = messages[index].copyWith(
        isPending: isPending,
        isFailed: isFailed,
      );
    }
  }

  @override
  void onClose() {
    _pusherService.unsubscribe('chat.$chatId');
    super.onClose();
  }
}
