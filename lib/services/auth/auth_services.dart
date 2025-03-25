import 'package:posex/services/auth/firebase_auth_provider.dart';

import 'auth_providers.dart';
import 'auth_user.dart';

class AuthServices implements AuthProviders {
  final AuthProviders provider;
  const AuthServices(this.provider);

  factory AuthServices.firebase() => AuthServices(FirebaseAuthProvider());
  
  @override
  Future<AuthUser> createUser({required String email, required String password}) => provider.createUser(email: email, password: password);
  
  @override
  AuthUser? get currentUser => provider.currentUser;
  
  @override
  Future<void> logOut() => provider.logOut();
  
  @override
  Future<AuthUser> login({required String email, required String password}) => provider.login(email: email, password: password);
  
  @override
  Future<void> sendEmailVerification() => provider.sendEmailVerification();
  
  @override
  Future<void> initialise() => provider.initialise();

  
}