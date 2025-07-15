import 'package:feeling_sync_chat/bindings/auth_binding.dart';
import 'package:feeling_sync_chat/services/auth_service.dart';
import 'package:feeling_sync_chat/views/login_page.dart';
import 'package:feeling_sync_chat/views/chat_page.dart';
import 'package:get/get.dart';
part 'app_routes.dart';

class AppPages {
  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: Routes.HOME,
      page: () => LoginPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.CHAT + "/:friendName/:chatId/:friendId",
      page: () {
        // Get currentUserId from AuthService instead of route parameters
        final authService = Get.find<AuthService>();
        final currentUserId = authService.currentUserId ?? 0;

        return ChatView(
          friendName: Get.parameters['friendName']!,
          chatId: int.parse(Get.parameters['chatId']!),
          friendId: int.parse(Get.parameters['friendId']!),
          currentUserId: currentUserId,
        );
      },
    ),
  ];
}
