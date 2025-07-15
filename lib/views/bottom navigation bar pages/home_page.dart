import 'package:feeling_sync_chat/views/drawer%20pages/friend_requests_page.dart';
import 'package:feeling_sync_chat/controllers/home_page_controller.dart';
import 'package:feeling_sync_chat/services/auth_service.dart';
import 'package:feeling_sync_chat/constant/api_constant.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:feeling_sync_chat/views/login_page.dart';
import 'package:feeling_sync_chat/routes/app_pages.dart';
import 'package:feeling_sync_chat/views/chat_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'dart:convert';
import 'dart:math';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomePageController controller = Get.put(HomePageController());
  final TextEditingController searchController = TextEditingController();
  final authService = Get.find<AuthService>();
  // Used to generate some random dates (for demonstration)
  final List<String> randomDates =
      List.generate(10, (index) => generateRandomDate());
  static String generateRandomDate() {
    final random = Random();
    final now = DateTime.now();
    final daysAgo = random.nextInt(30);
    final randomDate = now.subtract(Duration(days: daysAgo));
    return "${randomDate.day}/${randomDate.month}/${randomDate.year}";
  }

  @override
  void initState() {
    super.initState();
    controller.refreshAcceptedFriends();
    searchController.addListener(() {
      if (searchController.text.trim().isEmpty) {
        controller.clearSearch();
        setState(() {}); // Update UI when search is cleared
      }
    });
  }

  /// 🔥 KEY FIX: Enhanced method to get valid currentUserId
  Future<int> getValidCurrentUserId() async {
    print('🔍 DEBUG - getValidCurrentUserId called');

    // First, try to get from AuthService
    final currentUserId = authService.currentUserId;
    print('🔍 DEBUG - AuthService.currentUserId: $currentUserId');

    if (currentUserId != null && currentUserId > 0) {
      print('🔍 DEBUG - Using AuthService currentUserId: $currentUserId');
      return currentUserId;
    }

    // If AuthService is null/0, try SharedPreferences
    print(
        '🔍 DEBUG - AuthService currentUserId is null/0, checking SharedPreferences');
    final prefs = await SharedPreferences.getInstance();
    final storedUserId = prefs.getInt('user_id');
    print('🔍 DEBUG - SharedPreferences user_id: $storedUserId');

    if (storedUserId != null && storedUserId > 0) {
      // Update AuthService with the stored value
      authService.setCurrentUserId(storedUserId);
      print('🔍 DEBUG - Updated AuthService with stored userId: $storedUserId');
      return storedUserId;
    }

    // If still nothing, try to force reload from SharedPreferences
    print('🔍 DEBUG - Attempting to force load userId');
    await authService.forceLoadUserId();
    final reloadedUserId = authService.currentUserId;

    if (reloadedUserId != null && reloadedUserId > 0) {
      print('🔍 DEBUG - Successfully reloaded userId: $reloadedUserId');
      return reloadedUserId;
    }

    print('❌ DEBUG - No valid userId found anywhere, defaulting to 0');
    return 0;
  }

  /// 🔥 KEY FIX: Enhanced navigation method that ensures valid currentUserId
  Future<void> navigateToChat(
      String friendName, int chatId, int friendId) async {
    print(
        '🔍 DEBUG - navigateToChat called: friendName=$friendName, chatId=$chatId, friendId=$friendId');

    final currentUserId = await getValidCurrentUserId();

    if (currentUserId == 0) {
      print('❌ ERROR - Cannot navigate to chat: currentUserId is 0');
      Get.snackbar(
        "Error",
        "Unable to identify current user. Please try logging in again.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    print('🔍 DEBUG - Navigating to chat with currentUserId: $currentUserId');

    Get.to(() => ChatView(
          friendName: friendName,
          chatId: chatId,
          friendId: friendId,
          currentUserId: currentUserId,
        ));
  }

  Future<void> _deleteFriend(int friendId, int index) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null) {
      Get.snackbar("Error", "User is not authenticated.");
      return;
    }
    try {
      // Call the DELETE endpoint with friend_id as a query parameter
      final url = Uri.parse(
          '${ApiConstants.baseUrl}/api/friends/remove?friend_id=$friendId');
      final response = await http.delete(url, headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      });
      if (response.statusCode == 200) {
        Get.snackbar("Success", "Friend removed successfully.");
        // Remove the friend from the list
        controller.acceptedFriends.removeAt(index);
      } else {
        final message = jsonDecode(response.body)['message'];
        Get.snackbar("Error", message ?? "Failed to remove friend.");
      }
    } catch (e) {
      Get.snackbar("Error", "An error occurred: ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Inbox',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        elevation: 0,
      ),
      drawer: _buildDrawer(context),
      body: Obx(
        () {
          return Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Search friends...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  onSubmitted: (value) {
                    if (value.trim().isNotEmpty) {
                      controller.searchFriend(value.trim());
                    }
                  },
                ),
              ),
              // Content area
              Expanded(
                child: Obx(() {
                  if (searchController.text.trim().isNotEmpty) {
                    // If there's text in the search bar, show search results or the search button.
                    if (controller.searchResult.value != null) {
                      final friend = controller.searchResult.value!;
                      return ListTile(
                        title: Text(friend.name),
                        onTap: () async {
                          // Force non-null friend id using !
                          int friendId = (friend.id as int?)!;
                          int? chatId;
                          // Check if the friend data contains a chat_id. If not, create one.
                          if (friend.chatId != null) {
                            chatId = friend.chatId;
                          } else {
                            chatId = await controller.createChat(friendId);
                          }
                          if (chatId != null) {
                            // 🔥 KEY FIX: Use enhanced navigation method
                            await navigateToChat(
                                friend.name, chatId!, friendId);
                          } else {
                            Get.snackbar("Error",
                                "Unable to create chat for ${friend.name}");
                          }
                        },
                      );
                    } else {
                      return const SizedBox();
                    }
                  } else {
                    // If the search bar is empty, show the accepted friends list.
                    if (controller.acceptedFriends.isEmpty) {
                      return const Center(
                        child: Text(
                          "No accepted friends yet.",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: controller.acceptedFriends.length,
                      itemBuilder: (context, index) {
                        final friend = controller.acceptedFriends[index];
                        return _buildChatItem(
                          context,
                          userName: friend.name,
                          chatId: friend.chatId,
                          screenWidth: MediaQuery.of(context).size.width,
                          // Force non-null friend id using !
                          friendId: (friend.id),
                          index: index,
                        );
                      },
                    );
                  }
                }),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildChatItem(
    BuildContext context, {
    required String userName,
    required int? chatId,
    required double screenWidth,
    required int friendId,
    required int index,
  }) {
    return InkWell(
      onTap: () async {
        if (chatId == null) {
          try {
            final newChatId = await controller.createChat(friendId);
            if (newChatId != null) {
              print(
                  '🔍 DEBUG - Created new chat: $newChatId, using route navigation');
              Get.toNamed("${Routes.CHAT}/$userName/$newChatId/$friendId");
            } else {
              Get.snackbar(
                "Error",
                "Unable to create chat for $userName",
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red,
                colorText: Colors.white,
              );
            }
          } catch (e) {
            Get.snackbar(
              "Error",
              "Failed to open chat for $userName: $e",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          }
        } else {
          // 🔥 KEY FIX: Use enhanced navigation method
          await navigateToChat(userName, chatId, friendId);
        }
      },
      onLongPress: () {
        showDialog(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              title: const Text("Delete User"),
              content: Text("Are you sure you want to delete $userName?"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.of(dialogContext).pop();
                    await _deleteFriend(friendId, index);
                  },
                  child: const Text(
                    "Delete User",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            );
          },
        );
      },
      child: ListTile(
        leading: CircleAvatar(
          radius: screenWidth * 0.068,
          backgroundColor: Colors.grey[300],
          child: Icon(
            Icons.person,
            color: Colors.grey[700],
            size: screenWidth * 0.06,
          ),
        ),
        title: Text(
          userName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: screenWidth * 0.045,
          ),
        ),
        subtitle: Text(
          chatId != null ? "Let's chat!" : "Chat not created.",
          style: TextStyle(fontSize: screenWidth * 0.04),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.red,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Welcome",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.group, color: Colors.red),
            title: const Text("Friend Requests"),
            onTap: () {
              Get.to(() => FriendRequestPage());
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout"),
            onTap: () {
              _logout();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null) {
      Get.snackbar("Error", "User is not logged in.");
      return;
    }
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/api/logout'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        await prefs.remove('auth_token');
        await prefs.remove('user_id'); // Also clear user_id
        Get.offAll(() => LoginPage());
      } else {
        final message = jsonDecode(response.body)['message'];
        Get.snackbar("Error", message ?? "Logout failed.");
      }
    } catch (e) {
      Get.snackbar("Error", "An error occurred: ${e.toString()}");
    }
  }
}
