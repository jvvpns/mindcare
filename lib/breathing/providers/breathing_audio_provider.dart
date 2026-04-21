import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── State ──────────────────────────────────────────────────────────────────

class BreathingAudioState {
  final bool isMuted;
  final bool isPlaying;

  const BreathingAudioState({
    this.isMuted = false,
    this.isPlaying = false,
  });

  BreathingAudioState copyWith({bool? isMuted, bool? isPlaying}) =>
      BreathingAudioState(
        isMuted: isMuted ?? this.isMuted,
        isPlaying: isPlaying ?? this.isPlaying,
      );
}

// ── Notifier ───────────────────────────────────────────────────────────────

class BreathingAudioNotifier extends StateNotifier<BreathingAudioState> {
  BreathingAudioNotifier() : super(const BreathingAudioState());

  final AudioPlayer _player = AudioPlayer();
  Timer? _fadeTimer;
  double _currentVolume = 0.0;

  // Target volume (40% — audible but not distracting over haptics/phase labels)
  static const double _targetVolume = 0.40;
  static const double _fadeStep = 0.02;
  static const Duration _fadeTick = Duration(milliseconds: 50);

  // ── Public API ────────────────────────────────────────────────────────────

  Future<void> play() async {
    if (state.isPlaying) return;

    try {
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.setVolume(0.0);
      _currentVolume = 0.0;
      await _player.play(AssetSource('audio/breathing_sound.mp3'));
      state = state.copyWith(isPlaying: true);

      // Only fade in if not muted
      if (!state.isMuted) {
        _fadeIn();
      }
    } catch (e) {
      debugPrint('BreathingAudio: play error — $e');
    }
  }

  Future<void> pause() async {
    if (!state.isPlaying) return;
    state = state.copyWith(isPlaying: false);
    _fadeOut(then: () async => await _player.pause());
  }

  Future<void> stop() async {
    state = state.copyWith(isPlaying: false);
    _fadeOut(then: () async => await _player.stop());
  }

  void toggleMute() {
    final nowMuted = !state.isMuted;
    state = state.copyWith(isMuted: nowMuted);

    if (nowMuted) {
      // Instantly silence (not fade — mute is intentional)
      _fadeTimer?.cancel();
      _player.setVolume(0);
    } else if (state.isPlaying) {
      // Restore audio smoothly
      _fadeIn();
    }
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  void _fadeIn() {
    _fadeTimer?.cancel();
    _fadeTimer = Timer.periodic(_fadeTick, (timer) {
      _currentVolume = (_currentVolume + _fadeStep).clamp(0.0, _targetVolume);
      _player.setVolume(_currentVolume);
      if (_currentVolume >= _targetVolume) timer.cancel();
    });
  }

  void _fadeOut({Future<void> Function()? then}) {
    _fadeTimer?.cancel();
    _fadeTimer = Timer.periodic(_fadeTick, (timer) async {
      _currentVolume = (_currentVolume - _fadeStep).clamp(0.0, _targetVolume);
      _player.setVolume(_currentVolume);
      if (_currentVolume <= 0) {
        timer.cancel();
        await then?.call();
      }
    });
  }

  @override
  void dispose() {
    _fadeTimer?.cancel();
    _player.dispose();
    super.dispose();
  }
}

// ── Provider ───────────────────────────────────────────────────────────────

final breathingAudioProvider = StateNotifierProvider.autoDispose<
    BreathingAudioNotifier, BreathingAudioState>(
  (ref) => BreathingAudioNotifier(),
);
