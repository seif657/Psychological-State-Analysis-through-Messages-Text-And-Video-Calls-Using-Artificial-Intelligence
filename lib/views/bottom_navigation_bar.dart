import 'package:feeling_sync_chat/controllers/bottom_navigation_bar_controller.dart';
import 'package:feeling_sync_chat/controllers/notification_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BottomNavigationBarr extends StatelessWidget {
  final BottomNavigationBarController controller =
      Get.put(BottomNavigationBarController());
  final NotificationController notificationController =
      Get.put(NotificationController());

  BottomNavigationBarr({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => controller.screens[controller.currentTab.value]),
      bottomNavigationBar: Obx(
        () => BottomAppBar(
          color: Colors.black,
          shape: const CircularNotchedRectangle(),
          child: SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                // Home Icon
                IconButton(
                  icon: Icon(
                    Icons.home,
                    size: 33,
                    color: controller.currentTab.value == 0
                        ? Colors.red
                        : Colors.grey,
                  ),
                  onPressed: () {
                    controller.currentTab.value = 0;
                  },
                ),

                // Add Friend Icon
                IconButton(
                  icon: Icon(
                    Icons.add_circle_sharp,
                    size: 33,
                    color: controller.currentTab.value == 2
                        ? Colors.red
                        : Colors.grey,
                  ),
                  onPressed: () {
                    TextEditingController textController =
                        TextEditingController();
                    bool isLoading = false;
                    String? friendName;
                    String? responseMessage;

                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return StatefulBuilder(
                          builder:
                              (BuildContext context, StateSetter setState) {
                            return AlertDialog(
                              title: Text("Find and Add Friend"),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextField(
                                    controller: textController,
                                    decoration: InputDecoration(
                                      hintText: "Enter Friend's Name",
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  if (isLoading)
                                    CircularProgressIndicator()
                                  else if (friendName != null)
                                    ListTile(
                                      title: Text(friendName!),
                                      trailing: ElevatedButton(
                                        onPressed: () async {
                                          setState(() {
                                            isLoading = true;
                                            responseMessage = null;
                                          });

                                          var result = await controller
                                              .sendFriendRequest(
                                                  textController.text);

                                          setState(() {
                                            isLoading = false;
                                            responseMessage = result;
                                          });

                                          if (result ==
                                              "Friend request sent successfully") {
                                            Get.snackbar(
                                              "Success",
                                              result,
                                              snackPosition:
                                                  SnackPosition.BOTTOM,
                                              backgroundColor: Colors.green,
                                              colorText: Colors.white,
                                            );

                                            Navigator.of(context)
                                                .pop(); // Close the dialog
                                          } else {
                                            Get.snackbar(
                                              "Error",
                                              result,
                                              snackPosition:
                                                  SnackPosition.BOTTOM,
                                              backgroundColor: Colors.red,
                                              colorText: Colors.white,
                                            );
                                          }
                                        },
                                        child: Text("Add Friend"),
                                      ),
                                    )
                                  else if (responseMessage != null)
                                    Text(
                                      responseMessage!,
                                      style: TextStyle(
                                        color: responseMessage ==
                                                "Friend request sent successfully"
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                    ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () async {
                                    if (textController.text.isNotEmpty) {
                                      setState(() {
                                        isLoading = true;
                                        friendName = null;
                                        responseMessage = null;
                                      });

                                      var fetchedName = await controller
                                          .fetchFriendName(textController.text);

                                      setState(() {
                                        isLoading = false;
                                        friendName = fetchedName;

                                        if (friendName == "User not found") {
                                          responseMessage = "User not found";
                                        } else {
                                          responseMessage =
                                              null; // Clear error if a valid name is found
                                        }
                                      });
                                    }
                                  },
                                  child: Text("Search"),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text("Cancel"),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    );
                  },
                ),

                // Notification Icon
                IconButton(
                  icon: Stack(
                    children: [
                      Icon(
                        Icons.notifications,
                        size: 33,
                        color: controller.currentTab.value == 1
                            ? Colors.red
                            : Colors.grey,
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Obx(() {
                          final count =
                              notificationController.notifications.length;
                          return count > 0
                              ? Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 18,
                                    minHeight: 18,
                                  ),
                                  child: Text(
                                    '$count',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                )
                              : Container();
                        }),
                      ),
                    ],
                  ),
                  onPressed: () {
                    controller.currentTab.value = 1;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
