import 'package:feeling_sync_chat/bindings/auth_binding.dart';
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
        return ChatView(
          friendName: Get.parameters['friendName']!,
          chatId: int.parse(Get.parameters['chatId']!),
          friendId: int.parse(Get.parameters['friendId']!), 
          currentUserId: int.parse(Get.parameters['currentUserId']!),
        );
      },
    ),
  ];
}
