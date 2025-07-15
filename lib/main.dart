import 'package:feeling_sync_chat/services/notification_service.dart';
import 'package:feeling_sync_chat/services/sentiment_service.dart';
import 'package:feeling_sync_chat/services/friend_service.dart';
import 'package:feeling_sync_chat/services/pusher_service.dart';
import 'package:feeling_sync_chat/services/chat_service.dart';
import 'package:feeling_sync_chat/services/auth_service.dart';
import 'package:feeling_sync_chat/bindings/auth_binding.dart';
import 'package:feeling_sync_chat/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:feeling_sync_chat/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Get.putAsync(() => SharedPreferences.getInstance());
  Get.put(ApiService());
  final pusherService = Get.put(PusherService());
  await pusherService.init();
  final authService = Get.put<AuthService>(AuthService());
  await authService.loadCurrentUserId();
  Get.put(SentimentService());
  Get.put(ChatService());
  Get.put(NotificationService());
  Get.put(FriendService());

  runApp(GetMaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Chat App',
    theme: ThemeData(
      primarySwatch: Colors.blue,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    ),
    initialRoute: Routes.HOME,
    getPages: AppPages.routes,
    initialBinding: AuthBinding(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chat App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: Routes.HOME,
      getPages: AppPages.routes,
    );
  }
}
