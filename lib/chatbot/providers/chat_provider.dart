import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/chat_message.dart';
import '../../core/services/gemini_service.dart';
import '../../core/services/kelly_emotion_service.dart';
import 'kelly_state_provider.dart';

/// Provides the singleton Gemini API handler.
final geminiServiceProvider = Provider<GeminiService>((ref) {
  final service = GeminiService();
  service.startChat();
  return service;
});

/// Indicates whether Kelly is currently "thinking" or "typing".
final chatLoadingProvider = StateProvider<bool>((ref) => false);

/// Central provider for managing the entire conversation list.
final chatMessagesProvider = StateNotifierProvider<ChatMessagesNotifier, List<ChatMessage>>((ref) {
  return ChatMessagesNotifier(ref);
});

class ChatMessagesNotifier extends StateNotifier<List<ChatMessage>> {
  final Ref _ref;
  final _uuid = const Uuid();

  ChatMessagesNotifier(this._ref) : super([
    ChatMessage(
      id: 'init',
      text: "Hi! I'm Kelly. I'm here to listen. How are you feeling right now?",
      isUser: false,
      timestamp: DateTime.now(),
    )
  ]);

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // 1. Empathy Hook: Detect sentiment to animate the Kelly mascot state.
    final emotion = KellyEmotionService.detectEmotion(text);
    _ref.read(kellyEmotionProvider.notifier).state = emotion;

    // 2. Optimistic UI: Add User Message instantly.
    final userMsg = ChatMessage(
      id: _uuid.v4(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
      detectedEmotion: emotion, // Used by the Reaction Log debugger.
    );
    state = [...state, userMsg];

    // 3. Initiate "Kelly is typing"
    _ref.read(chatLoadingProvider.notifier).state = true;

    // 4. Await Gemini API response
    final service = _ref.read(geminiServiceProvider);
    final reply = await service.sendMessage(text);

    // 5. Publish AI Message & clear loading.
    final aiMsg = ChatMessage(
      id: _uuid.v4(),
      text: reply,
      isUser: false,
      timestamp: DateTime.now(),
    );
    
    _ref.read(chatLoadingProvider.notifier).state = false;
    state = [...state, aiMsg];
  }
}
