import 'dart:convert';
import 'package:http/http.dart' as http;

class GroqService {
  // Get your FREE API key from: https://console.groq.com
  // Free tier: 14,400 requests/day, 30 requests/minute
  static const String _apiKey = '';
  
  static const String _baseUrl = 'https://api.groq.com/openai/v1/chat/completions';
  static const String _model = 'llama-3.3-70b-versatile';

  /// Check if Groq API is configured
  static bool get isConfigured => _apiKey != 'YOUR_GROQ_API_KEY';

  /// Get city tagline using Groq API
  static Future<String?> getCityTagline(String cityName) async {
    if (!isConfigured) {
      print('⚠️ Groq API key not configured');
      return null;
    }
    
    try {
      print('🔍 [GROQ] Fetching tagline for $cityName...');
      
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'model': _model,
          'messages': [
            {
              'role': 'user',
              'content': 'What is the famous nickname for $cityName, India? Reply with ONLY 2-4 words, nothing else.'
            }
          ],
          'max_tokens': 20,
          'temperature': 0.3,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final text = data['choices'][0]['message']['content']?.trim() ?? '';
        final cleaned = text.replaceAll(RegExp(r'[\n\r]'), '').trim();
        
        if (cleaned.isNotEmpty && cleaned.length < 50) {
          print('✅ [GROQ] $cityName: $cleaned');
          return cleaned;
        }
      } else {
        print('⚠️ [GROQ] Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('⚠️ [GROQ] Exception: $e');
    }
    return null;
  }

  /// Generate content using Groq API (general purpose)
  static Future<String?> generateContent(String prompt) async {
    if (!isConfigured) {
      print('⚠️ Groq API key not configured');
      return null;
    }
    
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'model': _model,
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
          'max_tokens': 1000,
          'temperature': 0.7,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['choices'][0]['message']['content']?.trim();
      } else {
        print('⚠️ [GROQ] Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('⚠️ [GROQ] Exception: $e');
    }
    return null;
  }

  /// Generate JSON content using Groq API
  static Future<Map<String, dynamic>?> generateJsonContent(String prompt) async {
    final content = await generateContent(prompt);
    if (content == null) return null;
    
    try {
      // Clean markdown formatting if present
      String cleaned = content
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();
      
      return json.decode(cleaned);
    } catch (e) {
      print('⚠️ [GROQ] JSON parse error: $e');
      return null;
    }
  }
}
