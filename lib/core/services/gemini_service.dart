import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/foundation.dart';

class GeminiService {
  late final GenerativeModel _model;
  ChatSession? _chat;

  GeminiService() {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      debugPrint('WARNING: GEMINI_API_KEY is missing from .env');
    }

    _model = GenerativeModel(
      model: 'gemini-3.1-flash-lite-preview',
      apiKey: apiKey ?? '',
      systemInstruction: Content.system('''
You are Kelly, a warm, soft-spoken capybara and mental health companion for Filipino nursing students.
Your core traits:
- Empathetic: You listen deeply and validate feelings before offering comfort or advice.
- Gentle: You use soft, supportive language. You never sound clinical, robotic, or overly loud.
- Culturally aware: You understand the high-stress environment of nursing school in the Philippines.
- Concise & Present: Keep responses relatively short (1-3 sentences), suited for a mobile chat interface. Focus on holding space for their emotions.
When the user sends a message, prioritize emotional validation.
'''),
    );
  }

  void startChat() {
    _chat = _model.startChat();
  }

  Future<String> sendMessage(String text) async {
    if (_chat == null) startChat();
    try {
      final response = await _chat?.sendMessage(Content.text(text));
      return response?.text?.trim() ?? "I'm having trouble finding the words right now. Can we try again?";
    } catch (e) {
      debugPrint('Gemini API Error: $e');
      return "I'm having a little trouble connecting right now, but I'm still here with you. Take your time.";
    }
  }
}
