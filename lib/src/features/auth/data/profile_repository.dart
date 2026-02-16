import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/user_profile.dart';
import '../data/auth_repository.dart';

class ProfileRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'aura');
  final String? _uid;

  ProfileRepository(this._uid);

  DocumentReference get _profileRef => 
      _firestore.collection('users').doc(_uid);

  Stream<UserProfile?> watchProfile() {
    if (_uid == null) return Stream.value(null);
    return _profileRef.snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserProfile.fromMap(doc.id, doc.data() as Map<String, dynamic>);
    });
  }

  Future<void> updateProfile(UserProfile profile) async {
    if (_uid == null) return;
    await _profileRef.set(profile.toMap(), SetOptions(merge: true));
  }

  Future<void> updateSettings({bool? isDarkMode, bool? isBiometricEnabled}) async {
    if (_uid == null) return;
    final Map<String, dynamic> updates = {};
    if (isDarkMode != null) updates['isDarkMode'] = isDarkMode;
    if (isBiometricEnabled != null) updates['isBiometricEnabled'] = isBiometricEnabled;
    await _profileRef.set(updates, SetOptions(merge: true));
  }
}

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final user = ref.watch(authStateChangesProvider).value;
  return ProfileRepository(user?.uid);
});

final userProfileProvider = StreamProvider<UserProfile?>((ref) {
  return ref.watch(profileRepositoryProvider).watchProfile();
});
