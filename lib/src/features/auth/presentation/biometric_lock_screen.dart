import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:google_fonts/google_fonts.dart';
class BiometricLockScreen extends StatefulWidget {
  final VoidCallback onAuthenticated;

  const BiometricLockScreen({super.key, required this.onAuthenticated});

  @override
  State<BiometricLockScreen> createState() => _BiometricLockScreenState();
}

class _BiometricLockScreenState extends State<BiometricLockScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  String _authMessage = "Tap to unlock safely";

  @override
  void initState() {
    super.initState();
    _authenticate();
  }

  Future<void> _authenticate() async {
    setState(() {
      _authMessage = "Authenticating...";
    });
    
    try {
        final bool didAuthenticate = await auth.authenticate(
            localizedReason: 'Please authenticate to access Aura',
        );
        
        if (didAuthenticate) {
            widget.onAuthenticated();
        } else {
             setState(() {
                _authMessage = "Authentication failed. Tap to try again.";
             });
        }
    } catch (e) {
        setState(() {
            _authMessage = "Error: $e";
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             const Icon(Icons.lock_outline, size: 80, color: Colors.indigo),
             const SizedBox(height: 24),
             Text(
               "Aura Locked",
               style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
             ),
             const SizedBox(height: 16),
             GestureDetector(
                onTap: _authenticate,
                child: Text(
                  _authMessage,
                  style: GoogleFonts.outfit(fontSize: 16, color: Colors.white70),
                ),
             ),
          ],
        ),
      ),
    );
  }
}
