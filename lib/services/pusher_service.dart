import 'package:feeling_sync_chat/constant/api_constant.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pusher_client/pusher_client.dart';
import 'package:get/get.dart';

class PusherService extends GetxService {
  late PusherClient _pusher;
  Channel? _channel;
  final _isConnected = false.obs;
  final _connectionError = RxString('');

  bool get isConnected => _isConnected.value;
  String? get connectionError => _connectionError.value.isNotEmpty ? _connectionError.value : null;

  @override
  void onInit() {
    super.onInit();
    init(); // Initialize when service is created
  }

  Future<void> init() async {
    try {
      final token = await _getAuthToken();
      
      _pusher = PusherClient(
        '78f7cee4050aca7ef0a4',
        PusherOptions(
          host: "192.168.100.94",
          wsPort: 6001,
          cluster: 'us2',
          encrypted: true,
          auth: PusherAuth(
            '${ApiConstants.baseUrl}/broadcasting/auth',
            headers: {
              'Authorization': 'Bearer ${token ?? ""}',
              'Accept': 'application/json',
            },
          ),
        ),
        enableLogging: true,
      );

      _setupConnectionListeners();
      await _pusher.connect();
    } catch (e) {
      _connectionError.value = 'Pusher initialization failed: $e';
      rethrow;
    }
  }

  void _setupConnectionListeners() {
    _pusher.onConnectionStateChange((state) {
      _isConnected.value = state?.currentState == 'connected';
      if (state?.currentState == 'connected') {
        _connectionError.value = '';
        Get.log('Pusher connected successfully');
      }
    });

    _pusher.onConnectionError((error) {
      _connectionError.value = error?.message ?? 'Unknown connection error';
      Get.log('Pusher error: $_connectionError');
    });
  }

  Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> subscribeToPrivateChannel(String channelName) async {
    try {
      if (!isConnected) {
        await init(); // Reinitialize if not connected
      }

      _channel = _pusher.subscribe('private-$channelName');

      _channel?.bind('pusher:subscription_succeeded', (_) {
        Get.log('Successfully subscribed to channel: private-$channelName');
      });

      _channel?.bind('pusher:subscription_error', (data) {
        Get.log('Subscription error: ${data?.data}');
      });
    } catch (e) {
      Get.log('Failed to subscribe to channel: $e');
      rethrow;
    }
  }

  void bindEvent(String eventName, void Function(dynamic) callback) {
    if (_channel == null) {
      throw Exception('Channel not initialized. Call subscribeToPrivateChannel first');
    }
    _channel!.bind(eventName, (event) {
      Get.log("Event '$eventName' received: ${event?.data}");
      callback(event?.data);
    });
  }

  Future<void> disconnect() async {
    try {
      await _pusher.disconnect();
      _isConnected.value = false;
      _channel = null;
      Get.log('Pusher disconnected');
    } catch (e) {
      Get.log('Error disconnecting Pusher: $e');
    }
  }

  Future<void> unsubscribe(String channelName) async {
    try {
      _pusher.unsubscribe('private-$channelName');
      _channel = null;
      Get.log('Unsubscribed from channel: private-$channelName');
    } catch (e) {
      Get.log('Error unsubscribing: $e');
    }
  }

  @override
  void onClose() {
    disconnect();
    super.onClose();
  }
}