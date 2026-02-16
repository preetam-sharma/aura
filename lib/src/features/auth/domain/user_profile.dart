class UserProfile {
  final String uid;
  final String? displayName;
  final String? email;
  final bool isDarkMode;
  final bool isBiometricEnabled;
  final bool isVerified;

  UserProfile({
    required this.uid,
    this.displayName,
    this.email,
    this.isDarkMode = true,
    this.isBiometricEnabled = false,
    this.isVerified = false,
  });

  UserProfile copyWith({
    String? displayName,
    String? email,
    bool? isDarkMode,
    bool? isBiometricEnabled,
    bool? isVerified,
  }) {
    return UserProfile(
      uid: uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      isBiometricEnabled: isBiometricEnabled ?? this.isBiometricEnabled,
      isVerified: isVerified ?? this.isVerified,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'displayName': displayName,
      'email': email,
      'isDarkMode': isDarkMode,
      'isBiometricEnabled': isBiometricEnabled,
      'isVerified': isVerified,
    };
  }

  factory UserProfile.fromMap(String uid, Map<String, dynamic> map) {
    return UserProfile(
      uid: uid,
      displayName: map['displayName'],
      email: map['email'],
      isDarkMode: map['isDarkMode'] ?? true,
      isBiometricEnabled: map['isBiometricEnabled'] ?? false,
      isVerified: map['isVerified'] ?? false,
    );
  }
}
