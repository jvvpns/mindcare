# HILWAY: Master Context & AI Handover Document

> [!IMPORTANT]
> **ATTENTION AI ASSISTANTS:**
> If you are reading this document, you are taking over the HILWAY project. Read this entire file carefully. It contains the exact technical state, non-negotiable architectural rules, and the roadmap for this application. **Do not hallucinate architectural patterns.**

## 1. Project Overview & Aesthetic
**HILWAY** (Holistic Inner Life Well-being and AI for You) is a premium mental health companion app tailored specifically for **Filipino nursing students in Roxas City**.

- **Aesthetic standard ("Soft Premium")**: The UI relies on glassmorphism (blurred overlays via `BackdropFilter`), high border radii (`20px` to `24px`), soft shadows, and muted pastel colors.
- **Living Background System**: The application uses a reactive `HilwayBackground` widget featuring drift-animated gradients and touch-reactive orbs to maintain a "meditative" brand identity.
- **Privacy Core**: All personal health data and AI context (moods, assessments, journal summaries) reside **locally** in encrypted Hive boxes. Kelly (the AI) has access to this data via system prompt injection but the data never leaves the device's persistent storage except for the active chat session context.
- **Rule**: NEVER hardcode colors or fonts. ALWAYS use `AppColors` and `AppTextStyles` from `lib/core/constants/`.

---

## 2. Technical Stack & Architecture

- **State Management**: `flutter_riverpod`. We use `StateNotifierProvider` for logic and `StateProvider` for UI-local states.
- **Storage**: `hive_flutter`.
  - 🚨 **CRITICAL RULE**: We **DO NOT USE `build_runner`**. All Hive TypeAdapters (`.g.dart` files) must be maintained **MANUALLY**.
- **AI / ML**: 
  - `google_generative_ai` (Gemini 1.5 Flash) powers Kelly.
  - `tflite_flutter` (running `burnout_model.tflite`) powers on-device burnout prediction.
- **Notifications**: `flutter_local_notifications` + `timezone` for offline-first clinical reminders.
- **Routing**: `go_router`.

---

## 3. Core Features Status

### ✅ Completed & Analyzed
- **Kelly Chatbot**: Multi-session support, sentiment detection, and premium Hero-animated glassmorphic UI.
- **Burnout Assessment**: Local ML inference model integration for risk levels (Low/Medium/High).
- **Academic Planner (Phase 7)**: **[ADVANCED]** Hybrid Weekly/Monthly calendar with dot activity indicators. Supports Clinical Duty time-blocking and 100% offline persistence.
- **Hero Dashboard (Phase 7.5)**: **[CLINICAL BENTO]** Reorganized vitals-first layout using expanded Bento-Box grid for rapid clinical duty oversight.
- **Crisis Intervention**: Dedicated UI with localized Roxas City hotlines (KaEstorya) and premium glassmorphic cards with emergency glows.
- **Mindful Breathing**: Animated gradients and 4-4-4 rhythm glassmorphic tool.
- **AI Resilience Pulse**: predictive, TFLite-powered gauge using `CustomPainter`.
- **Living Background & Glass**: High-performance `CustomPaint` mesh background with refined `HilwayCard` frosting and ambient glow system.

### 🚧 Current Sprint: Mascots & Memory
- **Rive Mascot**: Replacing SVG emotions with fluid Rive animations for Kelly to heighten empathy.
- **Long-term Memory**: Implementing a local retrieval-augmented generation (RAG) light pattern to allow Kelly to remember student preferences across weeks.

---

## 4. Localized Support (Roxas City Schools)
The app specifically supports the following institutions, storing affiliated hospital and contact data for each:
1.  **Filamer Christian University, Inc.** (Partner: Capiz Emmanuel Hospital)
2.  **University of Perpetual Help System Pueblo de Panay Campus** (Partner: UPH Clinical Partners)
3.  **St. Anthony College of Roxas City, Inc.** (Partner: St. Anthony College Hospital)
4.  **College of St. John - Roxas** (Partner: CSJ Clinical Partners)

---

## 5. Future Roadmap (Phase 8+)
- **Clinical Duty Tool**: Nursing-specific shift checklist templates (Medication rounds, IVF monitoring).
- **Peer Support (Optional)**: Highly restricted, anonymous local peer venting forum.
- **Haptic Integration**: Adding professional-grade vibration feedback for all clinical interactions.

---

## 6. Technical Stability Rules
1. **Navigation**: ALWAYS use `context.go()` for switching between main app modules (Planner, Mood, Dashboard) to prevent GoRouter duplicate key crashes.
2. **Readability**: Ensure text has high contrast (using `primaryDark` or solid backgrounds) when placed over the animated mesh background.
3. **Hero Tags**: Maintain the `kelly_orb_hero` tag for smooth transitions between the shell and chatbot.

---

## 7. Next Steps for Developer
1. **Rive Integration**: Setup `rive` package and import Kelly mascot assets.
2. **Shift Checklist**: Start the implementation of the Clinical Duty templates.
