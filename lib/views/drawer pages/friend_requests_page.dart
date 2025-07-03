import 'package:feeling_sync_chat/controllers/friend_request_controller.dart';
import 'package:feeling_sync_chat/controllers/home_page_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FriendRequestPage extends StatefulWidget {
  @override
  _FriendRequestPageState createState() => _FriendRequestPageState();
}

class _FriendRequestPageState extends State<FriendRequestPage> {
  final FriendRequestController controller = FriendRequestController();

  bool isLoading = true;
  List<Map<String, dynamic>> friendRequests = [];
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchFriendRequests();
  }

  Future<void> _fetchFriendRequests() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      setState(() {
        friendRequests = controller.requests
            .map((r) => {
                  'id': r.id,
                  'name': r.senderName,
                })
            .toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _handleRequest(int userId, bool isAccept) async {
    setState(() => isLoading = true);

    try {
      if (isAccept) {
        await controller.acceptRequest(userId);
      } else {
        await controller.rejectRequest(userId);
      }

      setState(() {
        friendRequests.removeWhere((request) => request['id'] == userId);
      });

      if (isAccept) {
        final homePageController = Get.find<HomePageController>();
        homePageController.refreshAcceptedFriends();
      } else {
        _showErrorSnackbar("Failed to process the request.");
      }
    } catch (e) {
      _showErrorSnackbar(e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      "Error",
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Friend Requests"),
        backgroundColor: Colors.red,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchFriendRequests,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchFriendRequests,
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                )
              : friendRequests.isEmpty
                  ? const Center(
                      child: Text(
                        "No incoming friend requests.",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: friendRequests.length,
                      itemBuilder: (context, index) {
                        final request = friendRequests[index];
                        final userId = request['id'] as int;
                        final userName =
                            request['name']?.toString() ?? "Unknown user";

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.red[100],
                              child: Text(
                                userName[0].toUpperCase(),
                                style: TextStyle(
                                  color: Colors.red[900],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              userName,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.check,
                                      color: Colors.green),
                                  onPressed: () => _handleRequest(userId, true),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close,
                                      color: Colors.red),
                                  onPressed: () =>
                                      _handleRequest(userId, false),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
