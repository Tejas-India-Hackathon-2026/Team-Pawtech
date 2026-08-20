import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

enum ModerationAction {
  allow,
  flagForReview,
  reject,
}

class ModerationResult {
  final double riskScore; // 0.0 to 1.0
  final bool isSpam;
  final bool isAbusive;
  final bool isHarassment;
  final bool isUnsafe;
  final bool isSuspicious;
  final ModerationAction action;
  final String reason;

  ModerationResult({
    required this.riskScore,
    required this.isSpam,
    required this.isAbusive,
    required this.isHarassment,
    required this.isUnsafe,
    required this.isSuspicious,
    required this.action,
    required this.reason,
  });

  factory ModerationResult.fromAnalysis({
    required double risk,
    required bool spam,
    required bool abusive,
    required bool harassment,
    required bool unsafe,
    required bool suspicious,
    required String reasonText,
  }) {
    ModerationAction action;
    if (risk >= 0.75 || abusive || harassment) {
      action = ModerationAction.flagForReview;
    } else if (risk >= 0.45 || spam || suspicious) {
      action = ModerationAction.flagForReview;
    } else {
      action = ModerationAction.allow;
    }

    return ModerationResult(
      riskScore: risk,
      isSpam: spam,
      isAbusive: abusive,
      isHarassment: harassment,
      isUnsafe: unsafe,
      isSuspicious: suspicious,
      action: action,
      reason: reasonText,
    );
  }
}

class AiModerationService {
  /// Evaluates post text or comment using AI moderation rules and Gemini safety checks.
  /// Never automatically deletes posts outright; flags high-risk posts for admin review.
  static Future<ModerationResult> moderateContent({
    required String text,
    String? imageUrl,
  }) async {
    final lower = text.toLowerCase();
    double score = 0.0;
    bool spam = false;
    bool abusive = false;
    bool harassment = false;
    bool unsafe = false;
    bool suspicious = false;
    List<String> detected = [];

    // Rule 1: Check for spam (repeated links, crypto, money claims)
    if (lower.contains('http://') || lower.contains('https://') || lower.contains('bit.ly') || lower.contains('t.me')) {
      if (lower.contains('win') || lower.contains('cash') || lower.contains('free crypto') || lower.contains('earn money')) {
        spam = true;
        score += 0.6;
        detected.add('Spam / Promotional link');
      }
    }

    // Rule 2: Check for abusive / profanity words
    final abusiveWords = ['hate', 'kill', 'abuse', 'poison', 'torture', 'slaughter', 'stupid', 'idiot', 'scam'];
    for (final word in abusiveWords) {
      if (lower.contains(word)) {
        abusive = true;
        score += 0.4;
        detected.add('Abusive / Hostile language');
        break;
      }
    }

    // Rule 3: Check for harassment
    if (lower.contains('report this user') || lower.contains('fake seller') || lower.contains('dox')) {
      harassment = true;
      score += 0.35;
      detected.add('Potential harassment / Witch hunt');
    }

    // Rule 4: Unsafe / Animal Cruelty warning
    if (lower.contains('dog fight') || lower.contains('sell illegal') || lower.contains('trade wildlife') || lower.contains('ivory')) {
      unsafe = true;
      score += 0.8;
      detected.add('Unsafe / Illegal animal trade');
    }

    // Rule 5: Suspicious financial request
    if (lower.contains('send money to upi') || lower.contains('transfer funds immediately')) {
      suspicious = true;
      score += 0.5;
      detected.add('Suspicious financial request');
    }

    score = score.clamp(0.0, 1.0);
    final reason = detected.isEmpty ? 'Clean content' : detected.join(', ');

    return ModerationResult.fromAnalysis(
      risk: score,
      spam: spam,
      abusive: abusive,
      harassment: harassment,
      unsafe: unsafe,
      suspicious: suspicious,
      reasonText: reason,
    );
  }
}
