import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile.dart';

class AuthService {
  final supabase = Supabase.instance.client;

  // 🔹 Sign up new user
  Future<AuthResponse> signUp(
    String email,
    String password,
    String name,
    String phone,
  ) async {
    final response = await supabase.auth.signUp(
      email: email,
      password: password,
      data: {'name': name, 'phone': phone},
    );
    return response;
  }

  // 🔹 Login
  Future<AuthResponse> login(String email, String password) async {
    final response = await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return response;
  }

  // 🔹 Logout
  Future<void> logout() async {
    await supabase.auth.signOut();
  }

  // 🔹 Get current profile
  Future<Profile?> getProfile() async {
    final user = supabase.auth.currentUser;

    if (user == null) return null;

    final response = await supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (response == null) return null;

    return Profile.fromJson(response);
  }

  // 🔹 Admin: list users count and list
  Future<int> countUsers() async {
    final data = await supabase.from('profiles').select('id');
    return (data as List).length;
  }

  Future<List<Profile>> listUsers() async {
    final data = await supabase.from('profiles').select();
    return (data as List).map((e) => Profile.fromJson(e)).toList();
  }

  Future<void> setRole({required String userId, required String role}) async {
    await supabase.from('profiles').update({'role': role}).eq('id', userId);
  }

  Future<void> setBlocked({
    required String userId,
    required bool blocked,
  }) async {
    await supabase
        .from('profiles')
        .update({'blocked': blocked})
        .eq('id', userId);
  }
}
