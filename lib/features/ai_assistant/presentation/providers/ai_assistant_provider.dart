import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/chat_message.dart';
import '../../../../core/services/voice_service.dart';

class AiAssistantState {
  final List<ChatMessage> messages;
  final bool isThinking;
  final bool isRecordingVoice;
  final String? currentlyPlayingId;

  const AiAssistantState({
    this.messages = const [],
    this.isThinking = false,
    this.isRecordingVoice = false,
    this.currentlyPlayingId,
  });

  AiAssistantState copyWith({
    List<ChatMessage>? messages,
    bool? isThinking,
    bool? isRecordingVoice,
    String? currentlyPlayingId,
    bool clearPlaying = false,
  }) {
    return AiAssistantState(
      messages: messages ?? this.messages,
      isThinking: isThinking ?? this.isThinking,
      isRecordingVoice: isRecordingVoice ?? this.isRecordingVoice,
      currentlyPlayingId:
          clearPlaying ? null : (currentlyPlayingId ?? this.currentlyPlayingId),
    );
  }
}

class AiAssistantNotifier extends StateNotifier<AiAssistantState> {
  AiAssistantNotifier() : super(const AiAssistantState()) {
    _initWelcome();
  }

  void _initWelcome() {
    state = state.copyWith(messages: [
      ChatMessage(
        id: 'msg_welcome',
        text:
            'Namaste! I am Pashu Mitra (पशु मित्र), your dedicated AI animal welfare and veterinary assistant. You can ask me about animal first aid, disease symptoms, puppy vaccinations, cow milk nutrition, or speak directly in your regional language.',
        isUser: false,
      ),
    ]);
  }

  Future<void> sendMessage(String text, {String langCode = 'en'}) async {
    if (text.trim().isEmpty) return;

    final userMsg = ChatMessage(
      id: const Uuid().v4(),
      text: text.trim(),
      isUser: true,
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isThinking: true,
    );

    // AI intelligent answer generation
    await Future.delayed(const Duration(milliseconds: 1000));

    String reply =
        'For animal first aid, always ensure the animal is placed in a cool, ventilated area. Never give human paracetamol/Crocin to dogs or cats as it causes liver failure. Clean superficial wounds with 5% povidone iodine (Betadine). If vomiting or bleeding continues, consult a registered veterinarian or broadcast an SOS in the Find Help section.';

    final query = text.toLowerCase();
    if (query.contains('vaccin') || query.contains('teeka') || query.contains('rabies')) {
      reply =
          'Core Vaccination Schedule for Dogs in India:\n1. 6-8 Weeks: Puppy DP (Distemper + Parvo)\n2. 10-12 Weeks: 7-in-1 / 9-in-1 (DHPPiL)\n3. 14-16 Weeks: 7-in-1 Booster + Anti-Rabies Vaccine (ARV)\n4. Annual Booster: 1x 7-in-1 and 1x Anti-Rabies every single year.';
    } else if (query.contains('cow') || query.contains('cattle') || query.contains('gaay') || query.contains('lumpy')) {
      reply =
          'For Cattle & Dairy care: Ensure daily mineral mixture (50g/day), clean drinking water (70-80 L/day), and green fodder. Watch out for Lumpy Skin Disease (nodules on skin with fever) — isolate affected cattle immediately and notify local animal husbandry dispensary for goat pox vaccination.';
    } else if (query.contains('dog food') || query.contains('diet') || query.contains('feed')) {
      reply =
          'Healthy Desi Dog Diet: Boiled eggs, boiled chicken/rice, curd (dahi), pumpkin, carrots, boiled lentils without excessive turmeric/chili. Toxic items to strictly avoid: Chocolate, cooked bones, onions, garlic, grapes/raisins, and sugary sweets.';
    }

    final aiMsg = ChatMessage(
      id: const Uuid().v4(),
      text: reply,
      isUser: false,
    );

    state = state.copyWith(
      messages: [...state.messages, aiMsg],
      isThinking: false,
      currentlyPlayingId: aiMsg.id,
    );

    // Automatically speak out bot reply via Text-To-Speech
    await VoiceService().speak(
      reply,
      languageCode: langCode,
      onComplete: () {
        state = state.copyWith(clearPlaying: true);
      },
    );
  }

  Future<void> toggleVoicePlayback(String messageId, String text, String langCode) async {
    if (state.currentlyPlayingId == messageId) {
      await VoiceService().stopSpeaking();
      state = state.copyWith(clearPlaying: true);
    } else {
      state = state.copyWith(currentlyPlayingId: messageId);
      await VoiceService().speak(
        text,
        languageCode: langCode,
        onComplete: () {
          state = state.copyWith(clearPlaying: true);
        },
      );
    }
  }
}

final aiAssistantProvider =
    StateNotifierProvider<AiAssistantNotifier, AiAssistantState>((ref) {
  return AiAssistantNotifier();
});
