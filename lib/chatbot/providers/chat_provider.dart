import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:uuid/uuid.dart';
import '../models/chat_message.dart';
import '../../core/services/gemini_service.dart';
import '../../core/services/kelly_context_service.dart';
import '../../core/services/kelly_emotion_service.dart';
import 'kelly_state_provider.dart';
import 'chat_safety_provider.dart';
import 'chat_session_provider.dart';

/// Provides the singleton Gemini API handler.
final geminiServiceProvider = Provider<GeminiService>((ref) => GeminiService());

/// Indicates whether Kelly is currently loading her context (first session init).
final chatInitializingProvider = StateProvider<bool>((ref) => true);

/// Indicates whether Kelly is currently typing a reply.
final chatLoadingProvider = StateProvider<bool>((ref) => false);

/// Central provider for managing the entire conversation list.
final chatMessagesProvider =
    StateNotifierProvider<ChatMessagesNotifier, List<ChatMessage>>(
  (ref) => ChatMessagesNotifier(ref),
);

class ChatMessagesNotifier extends StateNotifier<List<ChatMessage>> {
  final Ref _ref;
  final _uuid = const Uuid();

  ChatMessagesNotifier(this._ref) : super([]) {
    // Listen to session changes
    _ref.listen<String?>(
      currentSessionIdProvider,
      (previous, next) {
        if (previous != next) {
          _initSession(sessionId: next);
        }
      },
      fireImmediately: true,
    );
  }

  /// Option 3: Hybrid context loading.
  /// 1. Build health data summary   → injected into system prompt.
  /// 2. Load last 30 chat messages  → replayed as Gemini session history.
  /// 3. Show persisted messages in UI so the user sees prior conversation.
  Future<void> _initSession({String? sessionId}) async {
    // Only show loading indicator if we are loading a heavy past session.
    if (sessionId != null) {
      _ref.read(chatInitializingProvider.notifier).state = true;
    } else {
      _ref.read(chatInitializingProvider.notifier).state = false;
    }
    _ref.read(chatLoadingProvider.notifier).state = false;

    try {
      final contextService = KellyContextService.instance;
      final geminiService = _ref.read(geminiServiceProvider);

      // ── Part 1: System prompt context ──────────────────────────────────────
      final contextSummary = contextService.buildUserContextSummary();

      // ── Part 2: Reconstruct Gemini history from Hive ───────────────────────
      final geminiHistory = contextService.buildChatHistory(sessionId: sessionId);

      // Start Kelly's session with full context
      geminiService.startSessionWithContext(
        userContextSummary: contextSummary,
        history: geminiHistory,
      );

      // ── Part 3: Populate UI from Hive messages ─────────────────────────────
      final hiveMessages = KellyContextService.instance.buildChatHistory(sessionId: sessionId);
      final uiMessages = hiveMessages.map((content) {
        final isUser = content.role == 'user';
        // Extract text from parts safely
        final textContent = content.parts
            .map((p) => p is TextPart ? p.text : '')
            .where((t) => t.isNotEmpty)
            .join();
        return ChatMessage(
          id: _uuid.v4(),
          text: textContent,
          isUser: isUser,
          timestamp: DateTime.now(),
        );
      }).toList();

      // If no history, show Kelly's greeting
      if (uiMessages.isEmpty) {
        state = [
          ChatMessage(
            id: 'init',
            text: "Hi there! I'm Kelly, your Nursing Student companion. I'm here if you need to vent about clinicals, stress, or just talk through your day. How are you feeling right now?",
            isUser: false,
            timestamp: DateTime.now(),
          ),
        ];
      } else {
        state = uiMessages;
      }
    } catch (e) {
      // Fallback: plain session with greeting
      _ref.read(geminiServiceProvider).startChat();
      state = [
        ChatMessage(
          id: 'init',
          text: "Hi there! I'm Kelly, your Nursing Student companion. I'm here if you need to vent about clinicals, stress, or just talk through your day. How are you feeling right now?",
          isUser: false,
          timestamp: DateTime.now(),
        ),
      ];
    } finally {
      if (sessionId != null) {
        _ref.read(chatInitializingProvider.notifier).state = false;
      }
    }
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // 1. Empathy Hook: Detect sentiment to animate Kelly mascot.
    final emotion = KellyEmotionService.detectEmotion(text);
    _ref.read(kellyEmotionProvider.notifier).state = emotion;

    // 1b. Safety Check: If crisis keywords are found, activate the persistent bar.
    if (KellyEmotionService.isCrisis(text)) {
      _ref.read(isCrisisActiveProvider.notifier).state = true;
    }

    // 1c. Session Check: Create a new session if none exists
    String? currentSessionId = _ref.read(currentSessionIdProvider);
    if (currentSessionId == null) {
      final sessionNotifier = _ref.read(chatSessionsProvider.notifier);
      final newSession = await sessionNotifier.createSession(text);
      currentSessionId = newSession.id;
    }

    // 2. Optimistic UI: Add user message instantly.
    final userMsg = ChatMessage(
      id: _uuid.v4(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
      detectedEmotion: emotion,
    );
    state = [...state, userMsg];

    // 3. Persist user message to Hive.
    await KellyContextService.instance.persistMessage(
      content: text,
      role: 'user',
      sessionId: currentSessionId,
    );

    // Update Session Time
    await _ref.read(chatSessionsProvider.notifier).updateSessionTime(currentSessionId);

    // 4. Show "Kelly is typing..."
    _ref.read(chatLoadingProvider.notifier).state = true;

    // 5. Get Gemini reply.
    final service = _ref.read(geminiServiceProvider);
    final reply = await service.sendMessage(text);

    // 6. Persist Kelly's reply to Hive.
    await KellyContextService.instance.persistMessage(
      content: reply,
      role: 'assistant',
      sessionId: currentSessionId,
    );

    // 7. Publish AI message & clear loading.
    final aiMsg = ChatMessage(
      id: _uuid.v4(),
      text: reply,
      isUser: false,
      timestamp: DateTime.now(),
      detectedEmotion: emotion, // Pass emotion so the bubble renders the correct chathead
    );

    _ref.read(chatLoadingProvider.notifier).state = false;
    state = [...state, aiMsg];
  }
}
