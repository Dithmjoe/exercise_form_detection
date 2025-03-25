import 'package:posex/services/auth/auth_user.dart';

abstract class AuthProviders {

  Future<void> initialise();

  AuthUser? get currentUser;
  Future<AuthUser> login({
    required String email,
    required String password,
  });

  Future<AuthUser> createUser({
    required String email,
    required String password,
  });

  Future<void> logOut();

  Future<void> sendEmailVerification();

}