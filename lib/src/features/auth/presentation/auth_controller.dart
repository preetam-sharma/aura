import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';
import '../data/profile_repository.dart';
import '../domain/user_profile.dart';

// Simple approach using AsyncNotifierProvider
class AuthController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    // Initial state
  }

  Future<void> signInWithEmail(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(authRepositoryProvider).signInWithEmail(email, password));
  }
  
  Future<void> signUpWithEmail(String email, String password, String displayName) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).signUpWithEmail(email, password, displayName);
      
      // Initialize profile in Firestore
      final user = ref.read(authRepositoryProvider).currentUser;
      if (user != null) {
        // We use the repository directly to ensure we use the correct UID immediately
        await ProfileRepository(user.uid).updateProfile(
          UserProfile(
            uid: user.uid,
            displayName: displayName,
            email: email,
          ),
        );
      }
    });
  }
  
  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(authRepositoryProvider).signInWithGoogle());
  }

  Future<void> signOut() async {
     state = const AsyncLoading();
     state = await AsyncValue.guard(() => ref.read(authRepositoryProvider).signOut());
  }
}

final authControllerProvider = AsyncNotifierProvider<AuthController, void>(() {
  return AuthController();
});
