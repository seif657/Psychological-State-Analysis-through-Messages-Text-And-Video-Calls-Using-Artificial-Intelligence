import 'package:feeling_sync_chat/controllers/bottom_navigation_bar_controller.dart';
import 'package:feeling_sync_chat/services/friend_service.dart';
import 'package:get/get.dart';

class NavigationBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => FriendService());
    Get.lazyPut(() => BottomNavigationBarController());
  }
}