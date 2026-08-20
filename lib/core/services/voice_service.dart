import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

class VoiceService {
  static final VoiceService _instance = VoiceService._internal();
  factory VoiceService() => _instance;
  VoiceService._internal();

  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();

  bool _isSpeechInitialized = false;
  bool _isListening = false;

  bool get isListening => _isListening;

  Future<bool> initializeSpeech() async {
    if (_isSpeechInitialized) return true;
    try {
      _isSpeechInitialized = await _speech.initialize(
        onError: (val) => debugPrint('STT Error: $val'),
        onStatus: (val) => debugPrint('STT Status: $val'),
      );
      return _isSpeechInitialized;
    } catch (e) {
      debugPrint('Speech init failed: $e');
      return false;
    }
  }

  Future<void> startListening({
    required Function(String text) onResult,
    String languageCode = 'en-IN',
  }) async {
    final available = await initializeSpeech();
    if (available) {
      _isListening = true;
      await _speech.listen(
        onResult: (val) {
          if (val.recognizedWords.isNotEmpty) {
            onResult(val.recognizedWords);
          }
        },
        localeId: languageCode,
      );
    }
  }

  Future<void> stopListening() async {
    _isListening = false;
    await _speech.stop();
  }

  // Text To Speech
  Future<void> speak(String text, {String languageCode = 'en-IN', VoidCallback? onComplete}) async {
    try {
      if (onComplete != null) {
        _tts.setCompletionHandler(onComplete);
        _tts.setErrorHandler((_) {
          if (onComplete != null) onComplete();
        });
      }
      await _tts.setLanguage(languageCode);
      await _tts.setPitch(1.0);
      await _tts.setSpeechRate(0.5);
      await _tts.speak(text);
    } catch (e) {
      debugPrint('TTS Error: $e');
      if (onComplete != null) onComplete();
    }
  }

  Future<void> stopSpeaking() async {
    try {
      await _tts.stop();
    } catch (_) {}
  }
}
