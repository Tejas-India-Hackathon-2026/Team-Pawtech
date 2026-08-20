import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

enum MicPermissionResult {
  granted,
  denied,
  permanentlyDenied,
}

class VoiceService {
  static final VoiceService _instance = VoiceService._internal();
  factory VoiceService() => _instance;
  VoiceService._internal();

  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();

  bool _isSpeechInitialized = false;
  bool _isListening = false;

  bool get isListening => _isListening;

  /// Check and request microphone permission using permission_handler
  Future<MicPermissionResult> checkAndRequestMicPermission() async {
    PermissionStatus status = await Permission.microphone.status;
    if (status.isGranted) {
      return MicPermissionResult.granted;
    }

    status = await Permission.microphone.request();
    if (status.isGranted) {
      return MicPermissionResult.granted;
    } else if (status.isPermanentlyDenied) {
      return MicPermissionResult.permanentlyDenied;
    } else {
      return MicPermissionResult.denied;
    }
  }

  /// Open app settings if mic permission is permanently denied
  Future<bool> openSettings() async {
    return await openAppSettings();
  }

  /// Initialize Speech-to-Text engine
  Future<bool> initializeSpeech({Function(String errorMsg)? onError}) async {
    if (_isSpeechInitialized) return true;
    try {
      _isSpeechInitialized = await _speech.initialize(
        onError: (val) {
          debugPrint('STT Error: ${val.errorMsg}');
          if (onError != null) onError(val.errorMsg);
        },
        onStatus: (val) => debugPrint('STT Status: $val'),
      );
      return _isSpeechInitialized;
    } catch (e) {
      debugPrint('Speech init failed: $e');
      if (onError != null) onError(e.toString());
      return false;
    }
  }

  /// Start listening to user speech
  Future<bool> startListening({
    required Function(String text) onResult,
    required Function(String errorMsg) onError,
    required VoidCallback onDone,
    String languageCode = 'hi-IN',
  }) async {
    // 1. Permission check
    final permRes = await checkAndRequestMicPermission();
    if (permRes != MicPermissionResult.granted) {
      onError(permRes == MicPermissionResult.permanentlyDenied
          ? 'permanently_denied'
          : 'permission_denied');
      return false;
    }

    // 2. Initialize engine
    final available = await initializeSpeech(onError: onError);
    if (!available) {
      onError('STT engine initialization failed. Please use text input.');
      return false;
    }

    try {
      _isListening = true;
      await _speech.listen(
        onResult: (val) {
          if (val.recognizedWords.isNotEmpty) {
            onResult(val.recognizedWords);
          }
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 4),
        localeId: languageCode,
        cancelOnError: true,
        partialResults: true,
      );
      return true;
    } catch (e) {
      _isListening = false;
      onError('Mic recording error: ${e.toString()}');
      return false;
    }
  }

  /// Stop active listening
  Future<void> stopListening() async {
    _isListening = false;
    try {
      await _speech.stop();
    } catch (_) {}
  }

  /// Text To Speech response playback
  Future<void> speak(String text, {String languageCode = 'hi-IN', VoidCallback? onComplete}) async {
    try {
      await _tts.stop();
      if (onComplete != null) {
        _tts.setCompletionHandler(onComplete);
        _tts.setErrorHandler((_) {
          if (onComplete != null) onComplete();
        });
      }
      
      // Select appropriate TTS language code
      final ttsLang = languageCode.startsWith('hi') ? 'hi-IN' : 'en-IN';
      await _tts.setLanguage(ttsLang);
      await _tts.setPitch(1.0);
      await _tts.setSpeechRate(0.48);
      await _tts.speak(text);
    } catch (e) {
      debugPrint('TTS Error: $e');
      if (onComplete != null) onComplete();
    }
  }

  /// Stop current active speech playback
  Future<void> stopSpeaking() async {
    try {
      await _tts.stop();
    } catch (_) {}
  }
}
