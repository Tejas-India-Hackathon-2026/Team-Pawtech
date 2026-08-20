import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/services/voice_service.dart';
import '../../../../shared/widgets/pashu_card.dart';
import '../../../../l10n/l10n.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../providers/ai_assistant_provider.dart';

class PashuMitraChatScreen extends ConsumerStatefulWidget {
  const PashuMitraChatScreen({super.key});

  @override
  ConsumerState<PashuMitraChatScreen> createState() => _PashuMitraChatScreenState();
}

class _PashuMitraChatScreenState extends ConsumerState<PashuMitraChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isListening = false;

  final samplePrompts = [
    '🐶 Puppy Vaccination Chart',
    '🩸 Bleeding Paw First Aid',
    '🐄 Cattle Lumpy Skin Signs',
    '🥗 Safe Home Foods for Indie Dogs',
    '🐱 Kitten Deworming Dosage',
  ];

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    VoiceService().stopSpeaking();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage([String? presetText]) {
    final text = presetText ?? _textController.text.trim();
    if (text.isNotEmpty) {
      final currentLocale = ref.read(localeProvider);
      ref
          .read(aiAssistantProvider.notifier)
          .sendMessage(text, langCode: currentLocale.languageCode);
      _textController.clear();
      _scrollToBottom();
    }
  }

  Future<void> _toggleMic() async {
    final currentLocale = ref.read(localeProvider);
    if (_isListening) {
      await VoiceService().stopListening();
      setState(() => _isListening = false);
    } else {
      setState(() => _isListening = true);
      await VoiceService().startListening(
        languageCode: '${currentLocale.languageCode}-IN',
        onResult: (text) {
          setState(() {
            _textController.text = text;
            _isListening = false;
          });
          _sendMessage(text);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(aiAssistantProvider);
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final currentLocale = ref.watch(localeProvider);
    final lang = currentLocale.languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: AppColors.accentOrange,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.smart_toy, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Pashu Mitra AI',
                        style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 6),
                      if (user?.isPremium ?? false)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            '⭐ PRIORITY',
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                        ),
                    ],
                  ),
                  Text(
                    'Voice & Multilingual AI Assistant (13 Languages)',
                    style: AppTypography.bodySmall.copyWith(fontSize: 10, color: AppColors.primary),
                  ),
                ],
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.g_translate, color: AppColors.primary),
            onSelected: (code) => ref.read(localeProvider.notifier).setLanguage(code),
            itemBuilder: (ctx) => AppLanguages.supportedLanguages.entries
                .map((e) => PopupMenuItem(value: e.key, child: Text('${e.value["name"]} (${e.value["englishName"]})')))
                .toList(),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Mandatory Medical Disclaimer Banner
            Container(
              color: AppColors.warningContainer.withOpacity(0.5),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              child: Row(
                children: const [
                  Icon(Icons.info_outline, color: AppColors.warning, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'AI Assistant provides guidance only. "It is not a substitute for a qualified veterinarian for serious medical issues."',
                      style: TextStyle(fontSize: 10, color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),

            // Quick Prompt Chips
            Container(
              height: 44,
              padding: const EdgeInsets.symmetric(vertical: 4),
              color: AppColors.surfaceVariant.withOpacity(0.5),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: samplePrompts.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final prompt = samplePrompts[index];
                  return ActionChip(
                    label: Text(
                      prompt,
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textPrimary,
                        fontSize: 11,
                      ),
                    ),
                    backgroundColor: AppColors.surface,
                    side: const BorderSide(color: AppColors.border),
                    onPressed: () => _sendMessage(prompt),
                  );
                },
              ),
            ),

            // Chat Messages List
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                itemCount: chatState.messages.length,
                itemBuilder: (context, index) {
                  final msg = chatState.messages[index];
                  final isPlaying = chatState.currentlyPlayingId == msg.id;

                  if (msg.isUser) {
                    return Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        margin: const EdgeInsets.only(left: 48, bottom: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                            bottomLeft: Radius.circular(16),
                            bottomRight: Radius.circular(4),
                          ),
                        ),
                        child: Text(
                          msg.text,
                          style: AppTypography.bodyLarge.copyWith(color: Colors.white),
                        ),
                      ),
                    );
                  }

                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(right: 32, bottom: 14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: AppColors.primaryContainer,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.pets, size: 16, color: AppColors.primary),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(4),
                                      topRight: Radius.circular(16),
                                      bottomLeft: Radius.circular(16),
                                      bottomRight: Radius.circular(16),
                                    ),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        msg.text,
                                        style: AppTypography.bodyLarge.copyWith(
                                          color: AppColors.textPrimary,
                                          height: 1.45,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          IconButton(
                                            icon: Icon(
                                              isPlaying ? Icons.stop_circle : Icons.volume_up,
                                              size: 20,
                                              color: AppColors.primary,
                                            ),
                                            tooltip: 'Listen Audio Response',
                                            onPressed: () => ref
                                                .read(aiAssistantProvider.notifier)
                                                .toggleVoicePlayback(msg.id, msg.text, lang),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            if (chatState.isThinking)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Pashu Mitra AI is thinking in ${AppLanguages.getLanguageName(lang)}...',
                      style: AppTypography.bodySmall.copyWith(fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),

            // Input Bar with STT Voice & Send
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: const Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: _isListening
                          ? AppColors.emergencyRed
                          : AppColors.primaryContainer,
                    ),
                    icon: Icon(
                      _isListening ? Icons.mic : Icons.mic_none,
                      color: _isListening ? Colors.white : AppColors.primary,
                    ),
                    onPressed: _toggleMic,
                  ),
                  const SizedBox(width: 8),

                  Expanded(
                    child: TextField(
                      controller: _textController,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: 'Ask in ${AppLanguages.getLanguageName(lang)} or speak...',
                        filled: true,
                        fillColor: AppColors.surfaceVariant,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.send, size: 20),
                    onPressed: () => _sendMessage(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
