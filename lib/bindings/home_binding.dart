import 'package:feeling_sync_chat/controllers/home_page_controller.dart';
import 'package:feeling_sync_chat/services/friend_service.dart';
import 'package:get/get.dart';

class HomeBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => FriendService());
    Get.lazyPut(() => HomePageController());
  }
}