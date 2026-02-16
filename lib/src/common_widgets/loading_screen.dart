import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'glass_container.dart';
import '../constants/app_theme.dart';

class LoadingScreen extends StatelessWidget {
  final String message;
  
  const LoadingScreen({
    super.key, 
    this.message = 'Synchronizing with the universe...',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0F172A), // Dark Slate
                    Color(0xFF1E293B),
                    Color(0xFF3F51B5), // Indigo
                  ],
                ),
              ),
            ),
          ),
          
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo or Brand Icon
                GlassContainer(
                  blur: 20,
                  opacity: 0.1,
                  padding: const EdgeInsets.all(24),
                  borderRadius: BorderRadius.circular(30),
                  child: Hero(
                    tag: 'app_logo',
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 100,
                      height: 100,
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                
                // Pulsing Loader
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(seconds: 2),
                  builder: (context, value, child) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: CircularProgressIndicator(
                            value: null, // Indeterminate
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.indigo.withValues(alpha: 0.5 + (0.5 * value)),
                            ),
                          ),
                        ),
                        Text(
                          'A', // Brand Initial
                          style: GoogleFonts.outfit(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
                
                // Loading Message
                Text(
                  message,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    color: Colors.white70,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
          
          // Subtle particles or background elements can be added here
        ],
      ),
    );
  }
}
