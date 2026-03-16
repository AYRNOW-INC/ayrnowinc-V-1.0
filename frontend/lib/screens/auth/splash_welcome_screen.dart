import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class SplashWelcomeScreen extends StatelessWidget {
  final VoidCallback onLogin;
  final VoidCallback onCreateAccount;

  const SplashWelcomeScreen({
    super.key,
    required this.onLogin,
    required this.onCreateAccount,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient blobs (per React reference)
          Positioned(
            top: -80,
            right: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withAlpha(12),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.teal.withAlpha(12),
              ),
            ),
          ),
          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const Spacer(flex: 3),
                  // App logo
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.asset('assets/logo.png', width: 80, height: 80),
                  ),
                  const SizedBox(height: 32),
                  // Headline
                  const Text(
                    'Simplify Your Rental\nJourney',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                      height: 1.2,
                      letterSpacing: -0.75,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Subtitle
                  const Text(
                    'Lease, manage, and pay with the most\ntrusted platform for landlords and tenants.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),
                  const Spacer(flex: 3),
                  // Login button (blue filled)
                  ElevatedButton(
                    onPressed: onLogin,
                    child: const Text('Login'),
                  ),
                  const SizedBox(height: 12),
                  // Create Account button (grey)
                  OutlinedButton(
                    onPressed: onCreateAccount,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: AppColors.surfaceLight,
                      side: BorderSide.none,
                    ),
                    child: const Text('Create Account'),
                  ),
                  const SizedBox(height: 24),
                  // Trust badge
                  Text(
                    'TRUSTED BY 10,000+ LANDLORDS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary.withAlpha(153),
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
