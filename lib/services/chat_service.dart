import 'package:feeling_sync_chat/models/message_model.dart';
import 'package:feeling_sync_chat/services/api_service.dart';
import 'package:get/get.dart';

class ChatService extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();

  /// Fetches all messages for a chat
  Future<List<Message>> getMessages(int chatId) async {
    final response = await _apiService.get('/api/private-chat/$chatId/messages');
    
    return (response.data['messages'] as List)
        .map((json) => Message.fromJson(json))
        .toList();
  }

  /// Sends a new message with sentiment analysis
  Future<Message> sendMessage({
    required int chatId,
    required String content,
    required String sentiment,
  }) async {
    final response = await _apiService.post(
      '/api/private-chat/send-message',
      {
        'content': content,
        'private_chat_id': chatId,
        'sentiment': sentiment,
      },
    );

    return Message.fromJson(response.data['data']);
  }

  /// Creates a new chat with a friend
  Future<int> createChat(int friendId) async {
    final response = await _apiService.post(
      '/api/private-chat/create',
      {'friend_id': friendId},
    );

    return response.data['chat_id'];
  }

  /// Clears all messages in a chat
  Future<void> clearMessages(int chatId) async {
    await _apiService.delete('/api/private-chat/$chatId/clear-messages');
  }

  /// Deletes a specific message
  Future<void> deleteMessage(int messageId) async {
    await _apiService.delete('/api/messages/$messageId');
  }
}