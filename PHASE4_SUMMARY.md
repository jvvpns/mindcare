# HILWAY Phase 4: Kelly & Chatbot UX Overview

This phase focused on "Mindful UI" and "Immersive AI Companion" experiences, heavily leveraging soft aesthetics and fluid motion.

## 1. Architectural Changes
- **Standalone Chatbot Route**: Moved `ChatbotScreen` out of the `ShellRoute` (persistent bottom nav) in `app_router.dart`. It now functions as a full-screen immersive overlay with a custom `FadeTransition`.
- **Navigation Overhaul**: Replaced standard `NavigationBar` with a custom styling utilizing a `Scaffold` with a `BottomAppBar` in `main_shell.dart`. Features a center-docked Floating Action Button (FAB) wrapped in a `Hero` widget (tag: `kelly_chat_fab`).
- **Startup Logic**: Added `SplashBreathingScreen` as the landing page for authenticated users. It handles a "centering" 3-second breathing animation before redirecting to the Dashboard.

## 2. UI & Component Updates
- **Dashboard Grid**: Implemented a flex-based activity grid:
    - `Next Duty`: A minimalist task preview card.
    - `Stress Trend`: A miniature line chart (`fl_chart`) visualizing user stress levels.
- **Mood Checker**: Refined `mood_checker_row` with vertical pill layouts and localized emojis: `Happy 😄, Angry 😡, Sleepy 😴, Bored 😒`.
- **Kelly Prompt Card**: A persistent dashboard greeting card that replaces previous shortcut rows, acting as the entry point for the chatbot.
- **Chatbot UI**: A soft, premium chat interface with:
    - `Hero` morphing header (from nav FAB).
    - Dedicated `kelly_state_provider` for Mascot emotion management.
    - Privacy-centric input area ("🔒 Stored Locally").

## 3. UI Design System & Aesthetic
- **Color Palette**: Utilizes soft backgrounds (`AppColors.background`) and card-based elevations (`HilwayCard` on `AppColors.surface`). Accents often use HSL-derived transparency (e.g., `AppColors.primary.withValues(alpha: 0.15)`) for a glassmorphism effect.
- **Micro-Animations**:
    - **Breathing**: A 3-second `TweenSequence` scaling from `1.0` to `1.6` with `Curves.easeInOutSine`.
    - **Hero Morph**: Uses a custom `Hero` tag `kelly_chat_fab` to expand the center nav button into the chatbot header asset.
- **Typography**: Focused on readability; uses standard `headingSmall/Medium` but pairs them with `AppColors.textSecondary` for softer visual hierarchy.
- **Mood Iconography**: Styled pill row: `😄 Happy, 😡 Angry, 😴 Sleepy, 😒 Bored`.

## 4. State & Logic
- **`kelly_state_provider.dart`**: Manages mascot emotions (default, happy, sad, excited, concerned, calm, surprised).
- **Sentiment Hooks**: `ChatbotScreen` uses `KellyEmotionService` to update Kelly's state based on user input for upcoming Rive integration.

## 5. Branch Info
- **Branch**: `mood-dashboard`
- **Verification**: `flutter analyze` reports **0 issues**.
