import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();

  /// Putar suara notifikasi
  Future<void> playSound() async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('audio/notification.mp3'));
    } catch (e) {
      // Fallback ke system sound jika asset gagal
      try {
        await SystemSound.play(SystemSoundType.alert);
      } catch (_) {}
      debugPrint('NotificationService: playSound error: $e');
    }
  }

  /// Getarkan HP (Android only, web diabaikan)
  Future<void> vibrate() async {
    if (kIsWeb) return; // Web tidak support vibration
    try {
      final hasVibrator = await Vibration.hasVibrator() ?? false;
      if (!hasVibrator) {
        HapticFeedback.heavyImpact();
        return;
      }

      final hasAmplitude = await Vibration.hasAmplitudeControl() ?? false;
      if (hasAmplitude) {
        // Getar dua kali dengan intensitas penuh
        await Vibration.vibrate(
          pattern: [0, 300, 100, 300],
          intensities: [0, 200, 0, 200],
        );
      } else {
        // Tanpa amplitude control: getar biasa
        await Vibration.vibrate(duration: 300);
        await Future.delayed(const Duration(milliseconds: 150));
        await Vibration.vibrate(duration: 300);
      }
    } catch (e) {
      debugPrint('NotificationService: vibrate error: $e');
      try {
        HapticFeedback.heavyImpact();
      } catch (_) {}
    }
  }

  /// Bunyi + Getar sekaligus
  Future<void> notify() async {
    await Future.wait([playSound(), vibrate()]);
  }

  /// Bunyi + Getar untuk peringatan lebih kuat (admin: ada reservasi baru)
  Future<void> notifyUrgent() async {
    await Future.wait([playSound(), _vibrateUrgent()]);
  }

  Future<void> _vibrateUrgent() async {
    if (kIsWeb) return;
    try {
      final hasVibrator = await Vibration.hasVibrator() ?? false;
      if (!hasVibrator) {
        HapticFeedback.heavyImpact();
        await Future.delayed(const Duration(milliseconds: 200));
        HapticFeedback.heavyImpact();
        await Future.delayed(const Duration(milliseconds: 200));
        HapticFeedback.heavyImpact();
        return;
      }

      final hasAmplitude = await Vibration.hasAmplitudeControl() ?? false;
      if (hasAmplitude) {
        // 3x getar kuat
        await Vibration.vibrate(
          pattern: [0, 500, 150, 500, 150, 500],
          intensities: [0, 255, 0, 255, 0, 255],
        );
      } else {
        // Tanpa amplitude control: 3x getar biasa
        for (int i = 0; i < 3; i++) {
          await Vibration.vibrate(duration: 400);
          if (i < 2) await Future.delayed(const Duration(milliseconds: 200));
        }
      }
    } catch (e) {
      debugPrint('NotificationService: vibrateUrgent error: $e');
      try {
        HapticFeedback.heavyImpact();
      } catch (_) {}
    }
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
