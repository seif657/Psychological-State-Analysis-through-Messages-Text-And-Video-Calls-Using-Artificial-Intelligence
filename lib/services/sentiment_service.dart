import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SentimentService extends GetxService {
  static const String _baseUrl = 'http://192.168.100.94:5002'; // Your Python API URL

  /// Analyzes text sentiment using Python API
  Future<String> analyzeSentiment(String text) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/analyze'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'text': text}),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return _mapSentiment(data['sentiment'] ?? 'neutral');
      }
      throw Exception('API Error: ${response.statusCode}');
    } catch (e) {
      print('Sentiment analysis failed: $e');
      return 'neutral'; // Fallback value
    }
  }

  /// Maps raw sentiment to consistent values
  String _mapSentiment(String rawSentiment) {
    final lower = rawSentiment.toLowerCase();
    if (lower.contains('positive')) return 'positive';
    if (lower.contains('negative')) return 'negative';
    return 'neutral';
  }

  /// Batch analyzes multiple messages
  Future<Map<String, String>> analyzeMessages(List<String> texts) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/analyze-batch'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'texts': texts}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Map<String, String>.from(data['results']);
      }
      throw Exception('Batch analysis failed');
    } catch (e) {
      print('Batch sentiment analysis error: $e');
      return {for (var text in texts) text: 'neutral'};
    }
  }
}