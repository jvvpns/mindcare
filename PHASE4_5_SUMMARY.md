# HILWAY Phase 4.5: Empathetic AI & Reaction Log

This phase focused on the "Brain" of the chatbot, integrating Google Gemini and establishing a validation system for emotional resonance.

## 1. AI Engine (Gemini Integration)
- **`GeminiService`**: A clean, singleton service using `google_generative_ai`.
- **System Prompting**: Specifically tuned for Kelly's persona:
    - Warm, soft-spoken, and capybara-themed.
    - Specialized in validating Filipino nursing students' high-stress environments.
    - Enforced conciseness (1-3 sentences) for better mobile UX.
- **Asynchronous Handling**: Includes robust error handling and "attentive" fallback responses if the API is unreachable.

## 2. Conversational State Management
- **`ChatMessage` Model**: Tracks `id`, `text`, `isUser`, `timestamp`, and `detectedEmotion`.
- **`chat_provider.dart`**: A Riverpod-based `ChatMessagesNotifier` that:
    - Detects sentiment *before* sending to AI to update the mascot state.
    - Handles "Optimistic UI" (instantly showing user messages).
    - Manages the "Kelly is typing" loading state.

## 3. Empathetic UI Components
- **`ChatMessageBubble`**: Soft-styled bubbles with distinct alignment and color coding (Primary for user, Surface for Kelly).
- **`TypingIndicator`**: A gentle, pulsing three-dot animation to provide visual feedback during AI generation.
- **Auto-Scrolling**: `ChatbotScreen` now automatically tracks and scrolls to the bottom when new messages arrive.

## 4. Reaction Log (Validation Tool)
- **The Bug Icon**: A debug entry point in the chat header.
- **`ReactionLogSheet`**: A bottom-sheet overlay that displays:
    - **Triggered Emotions**: Exactly which `KellyEmotion` was mapped to the user's last input.
    - **Response Mapping**: Side-by-side view of User Input vs. Kelly's generated output.
    - **Timestamps**: For auditing conversation flow.

## 5. Technical Stack
- **Dependencies**: `google_generative_ai`, `uuid`, `intl`.
- **Architecture**: Separated into `models`, `providers`, `services`, and `widgets` inside the `lib/chatbot` feature folder.

## 6. Branch Info
- **Branch**: `mood-dashboard`
- **Verification**: `flutter analyze` reports **0 issues**.
