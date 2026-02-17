import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserProfile? _profile;
  bool _isLoading = false;
  String? _error;

  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _profile != null;
  bool get isAdmin => _profile?.isAdmin ?? false;

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();

    // Listen to auth state changes
    _authService.authStateChanges.listen((event) async {
      if (event.event == AuthChangeEvent.signedIn ||
          event.event == AuthChangeEvent.tokenRefreshed) {
        await _loadProfile();
      } else if (event.event == AuthChangeEvent.signedOut) {
        _profile = null;
        notifyListeners();
      }
    });

    // Check current session
    if (_authService.currentUser != null) {
      await _loadProfile();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadProfile() async {
    _profile = await _authService.getCurrentProfile();
    notifyListeners();
  }

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _profile = await _authService.signIn(email, password);
      _isLoading = false;
      notifyListeners();
      return _profile != null;
    } catch (e) {
      _error = _parseError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp(String email, String password, String fullName) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _profile = await _authService.signUp(email, password, fullName);
      _isLoading = false;
      notifyListeners();
      return _profile != null;
    } catch (e) {
      _error = _parseError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _profile = null;
    notifyListeners();
  }

  Future<void> updateProfile(UserProfile updatedProfile) async {
    try {
      await _authService.updateProfile(updatedProfile);
      _profile = updatedProfile;
      notifyListeners();
    } catch (e) {
      _error = _parseError(e);
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  String _parseError(dynamic e) {
    if (e is AuthException) {
      switch (e.message) {
        case 'Invalid login credentials':
          return 'Email o contraseña incorrectos';
        case 'User already registered':
          return 'Este email ya está registrado';
        default:
          return e.message;
      }
    }
    return 'Ha ocurrido un error inesperado';
  }
}
