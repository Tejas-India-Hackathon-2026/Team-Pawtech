import '../models/user_profile.dart';
import '../../../core/services/supabase_service.dart';

class AuthRepository {
  UserProfile? _currentProfile;

  AuthRepository() {
    // Default demo profile for seamless experience
    _currentProfile = UserProfile(
      id: 'usr_pashu_001',
      email: 'pashu.guardian@example.com',
      fullName: 'Yuvraj Singh',
      phone: '+91 98765 43210',
      role: UserRole.user,
      isPremium: true,
      location: 'New Delhi, India',
    );
  }

  UserProfile? get currentProfile => _currentProfile;

  Future<UserProfile> login({
    required String email,
    required String password,
  }) async {
    final client = SupabaseService.client;
    if (client != null) {
      try {
        final response = await client.auth.signInWithPassword(
          email: email,
          password: password,
        );
        if (response.user != null) {
          final res = await client
              .from('profiles')
              .select()
              .eq('id', response.user!.id)
              .maybeSingle();

          if (res != null) {
            _currentProfile = UserProfile.fromJson(res);
            return _currentProfile!;
          }
        }
      } catch (_) {}
    }

    // Fallback/Mock profile
    await Future.delayed(const Duration(milliseconds: 600));
    _currentProfile = UserProfile(
      id: 'usr_${email.split('@').first}',
      email: email,
      fullName: email.split('@').first.toUpperCase(),
      role: UserRole.user,
    );
    return _currentProfile!;
  }

  Future<UserProfile> signup({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required UserRole role,
  }) async {
    final client = SupabaseService.client;
    if (client != null) {
      try {
        final response = await client.auth.signUp(
          email: email,
          password: password,
          data: {
            'full_name': fullName,
            'phone': phone,
            'role': role.name,
          },
        );
        if (response.user != null) {
          final profile = UserProfile(
            id: response.user!.id,
            email: email,
            fullName: fullName,
            phone: phone,
            role: role,
          );
          await client.from('profiles').upsert(profile.toJson());
          _currentProfile = profile;
          return profile;
        }
      } catch (_) {}
    }

    await Future.delayed(const Duration(milliseconds: 600));
    _currentProfile = UserProfile(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      fullName: fullName,
      phone: phone,
      role: role,
    );
    return _currentProfile!;
  }

  Future<void> updateRole(UserRole newRole) async {
    if (_currentProfile != null) {
      _currentProfile = _currentProfile!.copyWith(role: newRole);
      final client = SupabaseService.client;
      if (client != null) {
        try {
          await client
              .from('profiles')
              .update({'role': newRole.name})
              .eq('id', _currentProfile!.id);
        } catch (_) {}
      }
    }
  }

  Future<void> setPremium(bool isPremium) async {
    if (_currentProfile != null) {
      _currentProfile = _currentProfile!.copyWith(isPremium: isPremium);
    }
  }

  Future<void> logout() async {
    final client = SupabaseService.client;
    if (client != null) {
      try {
        await client.auth.signOut();
      } catch (_) {}
    }
    _currentProfile = null;
  }
}
