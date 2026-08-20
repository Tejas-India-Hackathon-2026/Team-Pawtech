import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/services/ai_moderation_service.dart';
import '../../../../shared/widgets/pashu_app_bar.dart';
import '../models/community_post.dart';
import '../providers/community_provider.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({super.key});

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();
  final _locationController = TextEditingController();
  PostType _selectedType = PostType.general;
  bool _isModerating = false;
  bool _hasImage = false;

  void _submitPost() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isModerating = true);

    // 1. Perform Real-time AI Content Moderation Check
    final text = _contentController.text.trim();
    final modResult = await AiModerationService.moderateContent(text: text);

    setState(() => _isModerating = false);

    if (modResult.action == ModerationAction.flagForReview) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Row(
              children: const [
                Icon(Icons.shield_outlined, color: AppColors.warning),
                SizedBox(width: 8),
                Text('Content Flagged for Review', style: TextStyle(fontSize: 15)),
              ],
            ),
            content: Text(
              'Your post has been flagged by AI Moderation for manual admin review.\nReason: ${modResult.reason}\n\nNote: The post is saved in pending status and will not be published automatically if suspicious.',
              style: const TextStyle(fontSize: 13),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _saveAndExit(isFlagged: true, riskScore: modResult.riskScore, reason: modResult.reason);
                },
                child: const Text('Submit Anyway for Review'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Edit Post'),
              ),
            ],
          ),
        );
      }
      return;
    }

    _saveAndExit(isFlagged: false, riskScore: modResult.riskScore, reason: 'Clean');
  }

  void _saveAndExit({required bool isFlagged, required double riskScore, required String reason}) {
    final newPost = CommunityPost(
      id: 'post_${DateTime.now().millisecondsSinceEpoch}',
      authorName: 'User',
      authorRole: 'Animal Lover',
      content: _contentController.text.trim(),
      type: _selectedType,
      location: _locationController.text.trim().isNotEmpty ? _locationController.text.trim() : null,
      timeAgo: 'Just now',
      likes: 0,
      commentsCount: 0,
      isLiked: false,
    );

    ref.read(communityProvider.notifier).addPost(newPost);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(isFlagged ? 'Post submitted for admin moderation review.' : 'Post published to Community Feed!')),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PashuAppBar(title: 'Create Community Post'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Post Category', style: AppTypography.titleSmall),
              const SizedBox(height: 8),
              DropdownButtonFormField<PostType>(
                value: _selectedType,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                items: PostType.values
                    .where((t) => t != PostType.all)
                    .map((t) => DropdownMenuItem(value: t, child: Text(t.label)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedType = val!),
              ),
              const SizedBox(height: 18),
              Text('Post Content', style: AppTypography.titleSmall),
              const SizedBox(height: 6),
              TextFormField(
                controller: _contentController,
                maxLines: 5,
                validator: (v) => v == null || v.trim().isEmpty ? 'Enter post message' : null,
                decoration: InputDecoration(
                  hintText: 'Share a story, lost pet update, or ask a question...',
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),
              Text('Location (Optional)', style: AppTypography.titleSmall),
              const SizedBox(height: 6),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  hintText: 'City or Area (e.g. Bandra, Mumbai)',
                  prefixIcon: const Icon(Icons.location_on, color: AppColors.primary),
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 20),
              Text('Add Photo (Supabase Storage)', style: AppTypography.titleSmall),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => setState(() => _hasImage = !_hasImage),
                child: Container(
                  height: 90,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: _hasImage ? AppColors.primaryContainer.withOpacity(0.3) : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _hasImage ? AppColors.primary : AppColors.outline),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(_hasImage ? Icons.image : Icons.add_a_photo_outlined, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          _hasImage ? 'Photo attached' : 'Tap to attach photo',
                          style: TextStyle(fontWeight: FontWeight.bold, color: _hasImage ? AppColors.primaryDark : AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isModerating ? null : _submitPost,
                  icon: const Icon(Icons.send),
                  label: _isModerating
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Publish Post', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
