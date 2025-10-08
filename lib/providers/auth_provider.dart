import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final supabase = Supabase.instance.client;

  AuthProvider() {
    // Listen to auth state changes and refresh profile accordingly
    // supabase.auth.onAuthStateChange.listen((event) async {
    //     await loadCurrentUser();
    // });
  }

  Profile? currentUser;
  bool isLoading = false;
  String? errorMessage;
  List<Profile> users = [];
  int totalUsers = 0;

  // 🔹 Sign up
  Future<void> signUp(
    String email,
    String password,
    String name,
    String phone,
  ) async {
    try {
      isLoading = true;
      notifyListeners();

      final response = await _authService.signUp(email, password, name, phone);

      if (response.user != null) {
        currentUser = await _authService.getProfile();
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // 🔹 Login
  Future<void> login(String email, String password) async {
    try {
      isLoading = true;
      notifyListeners();

      final response = await _authService.login(email, password);
      if (response.user != null) {
        currentUser = await _authService.getProfile();
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // 🔹 Logout
  Future<void> logout() async {
    await _authService.logout();
    currentUser = null;
    notifyListeners();
  }

  // 🔹 Check current session
  Future<void> loadCurrentUser() async {
    currentUser = await _authService.getProfile();

    notifyListeners();
  }

  // 🔹 Admin: load users
  Future<void> loadUsers() async {
    try {
      isLoading = true;
      notifyListeners();
      users = await _authService.listUsers();
      totalUsers = users.length;
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> promoteToAdmin(String userId) async {
    await _authService.setRole(userId: userId, role: 'admin');
    await loadUsers();
  }

  Future<void> demoteToUser(String userId) async {
    await _authService.setRole(userId: userId, role: 'user');
    await loadUsers();
  }

  Future<void> blockUser(String userId) async {
    await _authService.setBlocked(userId: userId, blocked: true);
    await loadUsers();
  }

  Future<void> unblockUser(String userId) async {
    await _authService.setBlocked(userId: userId, blocked: false);
    await loadUsers();
  }
}
