import 'package:aura_bot_flutter/domain/entities/user_entity.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.fullName,
    required super.email,
    required super.mobileNumber,
    required super.username,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      mobileNumber: map['mobileNumber'] ?? '',
      username: map['username'] ?? '',
    );
  }

  factory UserModel.fromFirebaseUser(firebase_auth.User user, Map<String, dynamic> firestoreMap) {
    return UserModel(
      id: user.uid,
      fullName: firestoreMap['fullName'] ?? user.displayName ?? '',
      email: user.email ?? '',
      mobileNumber: firestoreMap['mobileNumber'] ?? user.phoneNumber ?? '',
      username: firestoreMap['username'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'email': email,
      'mobileNumber': mobileNumber,
      'username': username,
    };
  }
}
