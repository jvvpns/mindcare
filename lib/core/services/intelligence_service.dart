import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:hilway/core/constants/app_constants.dart';
import 'package:hilway/core/services/supabase_service.dart';

/// The IntelligenceService acts as the single frontend gateway for all
/// backend-hosted AI and ML features.
class IntelligenceService {
  static final IntelligenceService instance = IntelligenceService._();

  Map<String, dynamic>? lastContext;

  /// Private constructor
  IntelligenceService._();

  final Dio _dio = Dio(BaseOptions(
    baseUrl: AppConstants.backendUrl,
    connectTimeout: const Duration(seconds: 60), // Increased for Render cold starts
    receiveTimeout: const Duration(seconds: 60),
  ));

  Future<String?> _getJwt() async {
    final session = SupabaseService.client.auth.currentSession;
    return session?.accessToken;
  }

  /// 1. Context Service: Fetches optimized context from backend
  Future<Map<String, dynamic>> buildContext() async {
    final jwt = await _getJwt();
    if (jwt == null) throw Exception("Unauthorized: No JWT found.");

    try {
      final response = await _dio.get(
        '/v1/context/build',
        options: Options(
          headers: {
            'Authorization': 'Bearer $jwt',
          },
        ),
      );
      lastContext = response.data;
      return response.data;
    } on DioException catch (e) {
      debugPrint('IntelligenceService: buildContext error: ${e.message}');
      rethrow;
    }
  }

  /// 2. AI Service: Sends message and context for Gemini processing
  Future<Map<String, dynamic>> chatKelly({
    required String message,
    required String contextString,
    required String sessionId,
  }) async {
    return retry(() async {
      try {
        final response = await _dio.post(
          '/v1/chat/kelly',
          data: {
            'message': message,
            'context_string': contextString,
            'session_id': sessionId,
          },
        ).timeout(const Duration(seconds: 45));
        return response.data;
      } on DioException catch (e) {
        debugPrint('IntelligenceService: chatKelly error: ${e.message}');
        rethrow;
      }
    });
  }

  /// 3. ML Engine: Sends feature snapshot for Burnout prediction
  Future<Map<String, dynamic>> predictBurnout({
    required double sleepHours,
    required double moodTrend,
    required double taskLoad,
    required double mealSkipRate,
    double burnoutHistory = 0.0,
    String userId = 'anonymous',
  }) async {
    return retry(() async {
      try {
        final response = await _dio.post(
          '/v1/predict/burnout',
          data: {
            'version': '1.0.0',
            'features': {
              'mood_trend_score': moodTrend,
              'sleep_avg_hours': sleepHours,
              'task_load_index': taskLoad,
              'burnout_history_score': burnoutHistory,
              'meal_skip_rate': mealSkipRate,
            },
            'metadata': {
              'user_id': userId,
              'timestamp': DateTime.now().toUtc().toIso8601String(),
            },
          },
        );
        return response.data;
      } on DioException catch (e) {
        debugPrint('IntelligenceService: predictBurnout error: ${e.message}');
        rethrow;
      }
    });
  }

  /// ── Utilities ────────────────────────────────────────────────────────────

  /// Helper for retrying cold-start failures (common on Render free tier)
  Future<T> retry<T>(Future<T> Function() fn, {int attempts = 3}) async {
    int count = 0;
    while (true) {
      try {
        return await fn();
      } catch (e) {
        count++;
        if (count >= attempts) rethrow;
        debugPrint('IntelligenceService: Retry attempt $count...');
        await Future.delayed(const Duration(seconds: 2));
      }
    }
  }
}
