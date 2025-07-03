import 'package:feeling_sync_chat/controllers/login_controller.dart';
import 'package:feeling_sync_chat/services/auth_service.dart';
import 'package:get/get.dart';

class AuthBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AuthService());
    Get.lazyPut(() => LoginController());
  }
}