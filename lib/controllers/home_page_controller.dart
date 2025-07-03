import 'package:feeling_sync_chat/services/friend_service.dart';
import 'package:feeling_sync_chat/services/chat_service.dart';
import 'package:feeling_sync_chat/models/friend_model.dart';
import 'package:get/get.dart';

class HomePageController extends GetxController {
  // Dependencies
  final FriendService _friendService;
  final ChatService _chatService;

  // Reactive State
  final RxList<Friend> friends = <Friend>[].obs; // all accepted friends
  final RxList<Friend> searchResults = <Friend>[].obs; // search results
  final RxBool isLoading = false.obs;
  final RxString searchError = ''.obs;
  final Rx<Friend?> selectedFriend = Rxn<Friend>();

  // Additional reactive states to fix your errors:
  final RxBool isSearching = false.obs;  // true while searching
  final Rxn<Friend> searchResult = Rxn<Friend>(); // single search result

  HomePageController({
    FriendService? friendService,
    ChatService? chatService,
  })  : _friendService = friendService ?? Get.find<FriendService>(),
        _chatService = chatService ?? Get.find<ChatService>();

  @override
  void onInit() {
    super.onInit();
    refreshAcceptedFriends();
  }

  // This refreshes the accepted friends list, same as your loadFriends
  Future<void> refreshAcceptedFriends() async {
    await loadFriends();
  }

  /// Loads all accepted friends with their chat status
  Future<void> loadFriends() async {
    try {
      isLoading.value = true;
      final accepted = await _friendService.getAcceptedFriends();
      friends.assignAll(accepted);
      await _verifyChatsForFriends();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load friends: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  /// Clears search state and results
  void clearSearch() {
    searchResults.clear();
    searchError.value = '';
    searchResult.value = null;
    isSearching.value = false;
  }

  /// Searches for friends by name and updates searchResult and searchResults
  Future<void> searchFriend(String query) async {
    if (query.isEmpty) {
      clearSearch();
      return;
    }

    try {
      isSearching.value = true;
      searchError.value = '';
      final results = await _friendService.searchFriends(query);
      searchResults.assignAll(results);

      // Assuming you want the first search result as searchResult
      if (results.isNotEmpty) {
        searchResult.value = results.first;
      } else {
        searchResult.value = null;
      }
    } catch (e) {
      searchError.value = 'Search failed: ${e.toString()}';
    } finally {
      isSearching.value = false;
    }
  }

  /// Removes a friend connection
  Future<void> removeFriend(int friendId) async {
    try {
      isLoading.value = true;
      await _friendService.removeFriend(friendId);
      friends.removeWhere((f) => f.id == friendId);
      Get.snackbar('Success', 'Friend removed');
    } catch (e) {
      Get.snackbar('Error', 'Failed to remove friend: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  /// Verifies/creates chats for all friends missing chatId
  Future<void> _verifyChatsForFriends() async {
    for (final friend in friends.where((f) => f.chatId == null)) {
      try {
        final chatId = await _chatService.createChat(friend.id);
        if (chatId != null) {
          final index = friends.indexWhere((f) => f.id == friend.id);
          friends[index] = friend.copyWith(chatId: chatId);
        }
      } catch (e) {
        print('Failed to create chat for friend ${friend.id}: $e');
      }
    }
  }

  /// Creates a new chat and returns its ID
  Future<int?> createChat(int friendId) async {
    try {
      final chatId = await _chatService.createChat(friendId);
      if (chatId != null) {
        // Update friend with new chatId
        final index = friends.indexWhere((f) => f.id == friendId);
        if (index != -1) {
          friends[index] = friends[index].copyWith(chatId: chatId);
        }
      }
      return chatId;
    } catch (e) {
      Get.snackbar('Error', 'Failed to create chat: ${e.toString()}');
      return null;
    }
  }

  /// Selects a friend for chat
  void selectFriend(Friend friend) {
    selectedFriend.value = friend;
  }

  /// Getter to expose accepted friends (alias for friends list)
  List<Friend> get acceptedFriends => friends;
}
