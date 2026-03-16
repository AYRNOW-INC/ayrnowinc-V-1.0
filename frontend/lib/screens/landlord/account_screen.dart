import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import 'edit_preferences_screen.dart';
import 'onboarding_screen.dart';
import 'pending_document_review_screen.dart';
import '../shared/notifications_screen.dart';
import '../shared/move_out_screen.dart';
import '../tenant/tenant_onboarding_screen.dart';

/// Landlord Account Settings — per wireframe B4
class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isLandlord = auth.isLandlord;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Settings'),
        actions: [
          IconButton(icon: const Icon(Icons.settings_outlined), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditPreferencesScreen()))),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Profile card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    '${auth.user?['firstName']?[0] ?? ''}${auth.user?['lastName']?[0] ?? ''}',
                    style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('${auth.user?['firstName']} ${auth.user?['lastName']}',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                    const SizedBox(width: 6),
                    const Icon(Icons.verified, color: AppColors.primary, size: 18),
                  ],
                ),
                const SizedBox(height: 4),
                Text(auth.user?['email'] ?? '', style: const TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => const EditPreferencesScreen())),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    minimumSize: const Size(120, 36),
                  ),
                  child: const Text('Edit Profile', style: TextStyle(fontSize: 14)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          if (isLandlord) ...[
            // BUSINESS & FINANCE section
            _SectionHeader('BUSINESS & FINANCE'),
            const SizedBox(height: 8),
            _SettingsItem(
              icon: Icons.payment, title: 'Payment Provider',
              subtitle: 'Stripe connected',
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: AppColors.success.withAlpha(20), borderRadius: BorderRadius.circular(4)),
                child: const Text('Active', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.success)),
              ),
            ),
            _SettingsItem(icon: Icons.account_balance, title: 'Tax Information', subtitle: 'W-9 and 1099-K records'),
            _SettingsItem(icon: Icons.card_membership, title: 'Subscription Plan', subtitle: 'Pro Tier'),
            _SettingsItem(icon: Icons.folder_open, title: 'Document Reviews', subtitle: 'Pending tenant documents',
              onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => const PendingDocumentReviewScreen()))),
            _SettingsItem(icon: Icons.exit_to_app, title: 'Move-Out Reviews', subtitle: 'Pending tenant move-out requests',
              onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => const MoveOutScreen(isLandlord: true)))),
            _SettingsItem(icon: Icons.checklist, title: 'Setup Guide', subtitle: 'Onboarding checklist',
              onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => const LandlordOnboardingScreen()))),
          ] else ...[
            // FINANCIALS section (tenant)
            _SectionHeader('FINANCIALS'),
            const SizedBox(height: 8),
            _SettingsItem(icon: Icons.credit_card, title: 'Payment Methods', subtitle: 'Manage your cards'),
            _SettingsItem(icon: Icons.receipt_long, title: 'Payment History', subtitle: 'View all past rent receipts'),
            const SizedBox(height: 20),
            _SectionHeader('PROPERTY'),
            const SizedBox(height: 8),
            _SettingsItem(icon: Icons.description, title: 'Current Lease', subtitle: 'View active lease details'),
            _SettingsItem(icon: Icons.checklist, title: 'Onboarding', subtitle: 'Setup progress checklist',
              onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => const TenantOnboardingScreen()))),
            _SettingsItem(icon: Icons.exit_to_app, title: 'Move-Out Request', subtitle: 'Start the formal end of tenancy',
              onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => const MoveOutScreen()))),
          ],

          const SizedBox(height: 20),
          // PREFERENCES section
          _SectionHeader('PREFERENCES'),
          const SizedBox(height: 8),
          _SettingsItem(
            icon: Icons.notifications_outlined, title: 'Notifications',
            subtitle: 'Push, email, and SMS alerts',
            onTap: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => const NotificationsScreen())),
          ),
          _SettingsItem(icon: Icons.security, title: 'Security', subtitle: 'Password and 2FA settings'),

          const SizedBox(height: 20),
          // LEGAL & SUPPORT section
          _SectionHeader('LEGAL & SUPPORT'),
          const SizedBox(height: 8),
          _SettingsItem(icon: Icons.article_outlined, title: 'Terms of Service'),
          _SettingsItem(icon: Icons.help_outline, title: 'Help Center'),
          _SettingsItem(icon: Icons.open_in_new, title: 'Privacy Policy'),
          if (!isLandlord)
            _SettingsItem(icon: Icons.headset_mic_outlined, title: 'Contact Support',
              subtitle: 'Direct chat with property manager'),

          const SizedBox(height: 24),
          // Sign out
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () => auth.logout(),
              icon: const Icon(Icons.logout, color: AppColors.error),
              label: const Text('Sign Out', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.error),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Version
          const Center(
            child: Text('AYRNOW V1.0.0 (BUILD 1)',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(title, style: const TextStyle(
      fontSize: 12, fontWeight: FontWeight.w600,
      color: AppColors.textSecondary, letterSpacing: 0.5));
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsItem({required this.icon, required this.title, this.subtitle, this.trailing, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        leading: Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.textSecondary, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        subtitle: subtitle != null
          ? Text(subtitle!, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary))
          : null,
        trailing: trailing ?? const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        onTap: onTap ?? () {},
      ),
    );
  }
}
