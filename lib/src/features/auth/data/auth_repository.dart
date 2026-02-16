import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/app_user.dart';

abstract class AuthRepository {
  Stream<AppUser?> authStateChanges();
  Future<void> signInWithEmail(String email, String password);
  Future<void> signUpWithEmail(String email, String password, String displayName);
  Future<void> signInWithGoogle();
  Future<void> signInWithPhone(String phoneNumber);
  Future<void> signOut();
  AppUser? get currentUser;
}

class FirebaseAuthRepository implements AuthRepository {
  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;

  AppUser? _mapFirebaseUser(fb.User? user) {
    if (user == null) return null;
    return AppUser(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
    );
  }

  @override
  Stream<AppUser?> authStateChanges() {
    return _auth.authStateChanges().map(_mapFirebaseUser);
  }

  @override
  AppUser? get currentUser => _mapFirebaseUser(_auth.currentUser);

  @override
  Future<void> signInWithEmail(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  @override
  Future<void> signUpWithEmail(String email, String password, String displayName) async {
    final credentials = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    await credentials.user?.updateDisplayName(displayName);
  }

  @override
  Future<void> signInWithGoogle() async {
    // Note: Actual Google Sign-In requires additional platform configuration
    // This is a placeholder for the logic once GoogleSignIn is configured
    throw UnimplementedError('Google Sign-In needs platform-specific setup');
  }

  @override
  Future<void> signInWithPhone(String phoneNumber) async {
    throw UnimplementedError('Phone Sign-In needs platform-specific setup');
  }
  
  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepository();
});

final authStateChangesProvider = StreamProvider<AppUser?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});
