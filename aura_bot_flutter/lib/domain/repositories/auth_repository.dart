import 'package:aura_bot_flutter/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> login({
    required String email,
    required String password,
  });
  
  Future<UserEntity> register({
    required String fullName,
    required String email,
    required String mobileNumber,
    required String username,
    required String password,
  });
  
  Future<void> logout();
  
  Future<UserEntity?> getCurrentUser();

  Future<bool> forgotPassword(String email);
  
  Future<bool> verifyOtp(String email, String otp);
  
  Future<bool> resetPassword(String email, String otp, String newPassword);
}
