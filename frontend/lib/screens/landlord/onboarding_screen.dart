import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../shared/notifications_screen.dart';
import 'add_property_screen.dart';

class LandlordOnboardingScreen extends StatelessWidget {
  const LandlordOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset('assets/logo.png', width: 32, height: 32),
          ),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () =>
            Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()))),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Welcome header
          const Text('Welcome, Michael!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          const SizedBox(height: 4),
          const Text("Let's get your first property ready.",
            style: TextStyle(fontSize: 15, color: AppColors.textSecondary)),
          const SizedBox(height: 20),
          // Progress bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('SETUP PROGRESS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary, letterSpacing: 0.5)),
                    const Text('33%', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary)),
                  ],
                ),
                const SizedBox(height: 4),
                const Text('1 of 3 steps completed',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: const LinearProgressIndicator(
                    value: 0.33, minHeight: 6,
                    backgroundColor: AppColors.border,
                    valueColor: AlwaysStoppedAnimation(AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Onboarding Checklist
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Onboarding Checklist',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textDark)),
              Text('Step 1 of 3', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 16),
          _ChecklistItem(
            icon: Icons.verified, color: AppColors.success,
            title: 'Account Verified',
            subtitle: 'Your account identity has been successfully confirmed.',
            completed: true,
          ),
          const SizedBox(height: 12),
          _ChecklistItem(
            icon: Icons.apartment, color: AppColors.primary,
            title: 'Add Your First Property',
            subtitle: 'Register your building or unit to start managing leases.',
            completed: false,
            actionLabel: 'Start Now >',
            onAction: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => AddPropertyScreen(onCreated: () {}))),
          ),
          const SizedBox(height: 12),
          _ChecklistItem(
            icon: Icons.people_outline, color: AppColors.textSecondary,
            title: 'Invite Your Tenants',
            subtitle: 'Once a property is added, invite tenants to join AYRNOW.',
            completed: false,
          ),
          const SizedBox(height: 12),
          _ChecklistItem(
            icon: Icons.description_outlined, color: AppColors.textSecondary,
            title: 'Setup Digital Leases',
            subtitle: 'Create lease templates, security deposits and rental terms.',
            completed: false,
          ),
          const SizedBox(height: 32),
          // Help card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Icon(Icons.help_outline, color: AppColors.textSecondary, size: 32),
                const SizedBox(height: 12),
                const Text('Need help setting up?',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                const SizedBox(height: 4),
                const Text('Watch our 2-minute guide on how to automate your rent collections.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Video guide coming soon"))),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Watch Video Guide'),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => Navigator.push(context, MaterialPageRoute(
          builder: (_) => AddPropertyScreen(onCreated: () {}))),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _ChecklistItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final bool completed;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _ChecklistItem({
    required this.icon, required this.color, required this.title,
    required this.subtitle, required this.completed,
    this.actionLabel, this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: completed ? AppColors.success.withAlpha(50) : AppColors.border, width: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: color.withAlpha(15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w600,
                  color: completed ? AppColors.textSecondary : AppColors.textDark)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4)),
                if (actionLabel != null) ...[
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: onAction,
                    child: Text(actionLabel!, style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary)),
                  ),
                ],
              ],
            ),
          ),
          if (completed)
            const Icon(Icons.check_circle, color: AppColors.success, size: 22)
          else
            const Icon(Icons.radio_button_unchecked, color: AppColors.border, size: 22),
        ],
      ),
    );
  }
}
