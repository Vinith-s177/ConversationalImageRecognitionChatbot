import 'package:flutter/material.dart';
import 'package:aura_bot_flutter/domain/entities/user_entity.dart';
import 'package:aura_bot_flutter/domain/repositories/auth_repository.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository authRepository;

  UserEntity? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserEntity? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AuthViewModel({required this.authRepository}) {
    _checkCurrentUser();
  }

  Future<void> _checkCurrentUser() async {
    _isLoading = true;
    notifyListeners();
    try {
      _currentUser = await authRepository.getCurrentUser();
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login({required String email, required String password}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _currentUser = await authRepository.login(email: email, password: password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String mobileNumber,
    required String username,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _currentUser = await authRepository.register(
        fullName: fullName,
        email: email,
        mobileNumber: mobileNumber,
        username: username,
        password: password,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    try {
      await authRepository.logout();
      _currentUser = null;
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> forgotPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    final success = await authRepository.forgotPassword(email);
    if (!success) _errorMessage = "Failed to send OTP.";
    _isLoading = false;
    notifyListeners();
    return success;
  }

  Future<bool> verifyOtp(String email, String otp) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    final success = await authRepository.verifyOtp(email, otp);
    if (!success) _errorMessage = "Invalid OTP.";
    _isLoading = false;
    notifyListeners();
    return success;
  }

  Future<bool> resetPassword(String email, String otp, String newPassword) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    final success = await authRepository.resetPassword(email, otp, newPassword);
    if (!success) _errorMessage = "Failed to reset password.";
    _isLoading = false;
    notifyListeners();
    return success;
  }
}
