import 'package:posex/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'auth_providers.dart';
import 'auth_user.dart';
import 'auth_exceptions.dart';
import 'package:firebase_auth/firebase_auth.dart'
    show FirebaseAuth, FirebaseAuthException;

class FirebaseAuthProvider implements AuthProviders {
  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = currentUser;
      if (user != null) {
        return user;
      } else {
        throw UserNotFoundAuthError();
      }
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "weak-password":
          throw WeakPasswordAuthError();
        case "email-already-in-use":
          throw EmailAlreadyInUseAuthError();
        case "invalid-credentials":
          throw InvalidEmailAuthError();
        default:
          throw GenericAuthError();
      }
    } catch (_) {
      throw GenericAuthError();
    }
  }

  @override
  AuthUser? get currentUser {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return AuthUser.fromFirebase(user);
    } else {
      return null;
    }
  }

  @override
  Future<void> logOut() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
//      try {
        await FirebaseAuth.instance.signOut();
      // } on FirebaseAuthException catch (e) {
      //   throw GenericAuthError();
      // }catch (e){
      //   throw GenericAuthError();
      // }
    } else {
      throw UserNotFoundAuthError();
    }
  }

  @override
  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        return AuthUser.fromFirebase(user);
      } else {
        throw UserNotFoundAuthError();
      }
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "invalid-credentials":
          throw InvalidCredentialsAuthError();
        default:
          throw GenericAuthError();
      }
    } catch (_) {
      throw GenericAuthError();
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.sendEmailVerification();
    } else {
      throw UserNotLoggedInAuthError();
    }
  }
  
  @override
  Future<void> initialise() async {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
  }
}
