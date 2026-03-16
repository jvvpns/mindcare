class AppConstants {
  AppConstants._();

  // ── Supabase ─────────────────────────────────────────────────────────────
  // Keep your actual URL and anon key here — do not commit to public repos
  static const String supabaseUrl     = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

  // ── Gemini ────────────────────────────────────────────────────────────────
  static const String geminiApiKey    = 'YOUR_GEMINI_API_KEY';
  static const String geminiModel     = 'gemini-1.5-flash';

  // ── Hive Box Names ────────────────────────────────────────────────────────
  static const String boxMoodLogs       = 'mood_logs';
  static const String boxStressRatings  = 'stress_ratings';
  static const String boxChatMessages   = 'chat_messages';
  static const String boxPlannerEntries = 'planner_entries';
  static const String boxAssessments    = 'assessments';
  static const String boxSettings       = 'settings';
  static const String boxUserCache      = 'user_cache';

  // ── Supabase Table Names ──────────────────────────────────────────────────
  static const String tableMoodLogs       = 'mood_logs';
  static const String tableStressRatings  = 'stress_ratings';
  static const String tablePlannerEntries = 'planner_entries';
  static const String tableAssessments    = 'assessments';
  static const String tableSettings       = 'settings';

  // ── Hive Type IDs ─────────────────────────────────────────────────────────
  // Each Hive-annotated model needs a unique typeId — never reuse or change
  static const int hiveTypeMoodLog        = 0;
  static const int hiveTypeStressRating   = 1;
  static const int hiveTypeChatMessage    = 2;
  static const int hiveTypePlannerEntry   = 3;
  static const int hiveTypeAssessmentResult = 4;

  // ── App Config ────────────────────────────────────────────────────────────
  static const String appName           = 'MindCare';
  static const String appVersion        = '1.0.0';
  static const int    maxChatHistory    = 50;   // messages kept in Hive per session
  static const int    stressScaleMin    = 1;
  static const int    stressScaleMax    = 5;

  // ── Crisis Keywords ───────────────────────────────────────────────────────
  // Used by crisis detection in chatbot — add more as needed
  static const List<String> crisisKeywords = [
    'suicidal', 'suicide', 'kill myself', 'end my life', 'want to die',
    'self-harm', 'self harm', 'hurt myself', 'cut myself', 'no reason to live',
    'hopeless', 'can\'t go on', 'cannot go on', 'give up on life',
  ];

  // ── Emergency Hotlines (Philippines) ─────────────────────────────────────
  static const String hotlineNationalMH   = '1553';         // DOH National Mental Health
  static const String hotlineCrisisLine   = '(02) 989-8727'; // In Touch Crisis Line
  static const String hotlineSafeSpace    = '(02) 893-7603'; // Hopeline PH

  // ── Notification Channel ──────────────────────────────────────────────────
  static const String notifChannelId   = 'mindcare_reminders';
  static const String notifChannelName = 'Daily Reminders';
  static const String notifChannelDesc = 'Gentle daily reminders for mood check-in and self-care';

  // ── Mood Options ──────────────────────────────────────────────────────────
  static const List<String> moodLabels  = ['Sad', 'Stressed', 'Neutral', 'Calm', 'Motivated'];
  static const List<String> moodEmojis  = ['😔', '😰', '😐', '😊', '😄'];
}