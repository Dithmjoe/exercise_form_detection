import 'package:firebase_auth/firebase_auth.dart' as firebase_auth show User;
import 'package:flutter/foundation.dart';

@immutable
class AuthUser {
  final String? email;
  final bool isEmailVerified;
  const AuthUser({required this.isEmailVerified, required this.email});

  factory AuthUser.fromFirebase(firebase_auth.User user) => AuthUser(isEmailVerified: user.emailVerified, email: user.email);
}