import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../common_widgets/glass_container.dart';
import '../../../constants/app_theme.dart';
import '../data/auth_repository.dart';
import '../data/profile_repository.dart';
import '../domain/user_profile.dart';


class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsyncValue = ref.watch(userProfileProvider);
    final user = ref.watch(authStateChangesProvider).value;

    return profileAsyncValue.when(
      data: (profile) {
        final currentProfile = profile ?? UserProfile(uid: user?.uid ?? '');
        
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Profile',
                    style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    child: IconButton(
                      icon: const Icon(Icons.settings_outlined, color: Colors.white70),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Profile Card
              GlassContainer(
                blur: 15,
                opacity: 0.1,
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 35,
                          backgroundColor: AppTheme.indigo.withValues(alpha: 0.2),
                          child: Text(
                            ((currentProfile.displayName ?? user?.displayName ?? 'U').isNotEmpty)
                                ? (currentProfile.displayName ?? user?.displayName ?? 'U').substring(0, 1).toUpperCase()
                                : 'U',
                            style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.indigo),
                          ),
                        ),
                        if (currentProfile.isVerified)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Color(0xFF1E293B),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.verified, color: AppTheme.emerald, size: 18),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentProfile.displayName ?? user?.displayName ?? 'User Name',
                            style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          Text(
                            currentProfile.email ?? user?.email ?? 'user@email.com',
                            style: GoogleFonts.outfit(fontSize: 14, color: Colors.white60),
                          ),
                          if (currentProfile.isVerified)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Row(
                                children: [
                                  Icon(Icons.verified, color: AppTheme.emerald.withValues(alpha: 0.8), size: 14),
                                  const SizedBox(width: 4),
                                  Text('Verified Account', style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.emerald.withValues(alpha: 0.8))),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.white24),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              Text('Quick Settings', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white70)),
              const SizedBox(height: 16),
              
              // Settings Group
              GlassContainer(
                blur: 10,
                opacity: 0.08,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    _buildToggleItem(
                      Icons.dark_mode_outlined, 
                      'Dark Mode', 
                      'Always enabled', 
                      currentProfile.isDarkMode,
                      (val) => ref.read(profileRepositoryProvider).updateSettings(isDarkMode: val),
                    ),
                    const Divider(color: Colors.white10, indent: 56),
                    _buildToggleItem(
                      Icons.fingerprint_outlined, 
                      'Biometric Login', 
                      'Use fingerprint or Face ID', 
                      currentProfile.isBiometricEnabled,
                      (val) => ref.read(profileRepositoryProvider).updateSettings(isBiometricEnabled: val),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              Text('Settings', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white70)),
              const SizedBox(height: 16),
              
              GlassContainer(
                blur: 10,
                opacity: 0.08,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: _buildSettingsList(context, ref, currentProfile),
              ),
              
              const SizedBox(height: 32),
              
              GlassContainer(
                blur: 10,
                opacity: 0.08,
                padding: const EdgeInsets.symmetric(vertical: 16),
                onTap: () => ref.read(authRepositoryProvider).signOut(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.logout, color: AppTheme.rose, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Log Out',
                      style: GoogleFonts.outfit(
                        color: AppTheme.rose,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              Center(
                child: Text(
                  'Aura v1.0.0 - Made with care',
                  style: GoogleFonts.outfit(fontSize: 12, color: Colors.white24),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }

  Widget _buildSettingsList(BuildContext context, WidgetRef ref, UserProfile currentProfile) {
    return Column(
      children: [
        _buildSettingTile(
          icon: Icons.person_outline,
          title: 'Personal Information',
          subtitle: 'Update your profile details',
          onTap: () => _showEditNameDialog(context, ref, currentProfile),
        ),
        const Divider(color: Colors.white10, indent: 56),
        _buildSettingTile(
          icon: Icons.payment_outlined,
          title: 'Payment Methods',
          subtitle: 'Manage cards and accounts',
          onTap: () {},
        ),
        const Divider(color: Colors.white10, indent: 56),
        _buildSettingTile(
          icon: Icons.notifications_none,
          title: 'Notifications',
          subtitle: 'Configure alerts and sounds',
          onTap: () {},
        ),
        const Divider(color: Colors.white10, indent: 56),
        _buildSettingTile(
          icon: Icons.security_outlined,
          title: 'Privacy & Security',
          subtitle: 'Manage your data and access',
          onTap: () {},
        ),
        const Divider(color: Colors.white10, indent: 56),
        _buildSettingTile(
          icon: Icons.help_outline,
          title: 'Help & Support',
          subtitle: 'Get assistance when needed',
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildToggleItem(
    IconData icon, 
    String title, 
    String subtitle, 
    bool value, 
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppTheme.indigo,
            activeTrackColor: AppTheme.indigo.withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.white70, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white24, size: 20),
          ],
        ),
      ),
    );
  }

  void _showEditNameDialog(BuildContext context, WidgetRef ref, UserProfile profile) {
    final controller = TextEditingController(text: profile.displayName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: Text('Edit Name', style: GoogleFonts.outfit(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Enter your name',
            hintStyle: const TextStyle(color: Colors.white24),
            enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.indigo)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(profileRepositoryProvider).updateProfile(
                profile.copyWith(displayName: controller.text),
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.indigo),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
