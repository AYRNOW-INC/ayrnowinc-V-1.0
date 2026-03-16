import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

/// Wireframe B5: Edit Preferences (landlord account edit)
class EditPreferencesScreen extends StatefulWidget {
  const EditPreferencesScreen({super.key});
  @override
  State<EditPreferencesScreen> createState() => _EditPreferencesScreenState();
}

class _EditPreferencesScreenState extends State<EditPreferencesScreen> {
  final _nameC = TextEditingController();
  final _emailC = TextEditingController();
  final _phoneC = TextEditingController();
  bool _pushNotif = true;
  bool _emailSummary = true;
  bool _smsReminder = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    _nameC.text = '${auth.user?['firstName'] ?? ''} ${auth.user?['lastName'] ?? ''}'.trim();
    _emailC.text = auth.user?['email'] ?? '';
    _phoneC.text = auth.user?['phone'] ?? '';
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final parts = _nameC.text.trim().split(' ');
      await ApiService.put('/users/me', body: {
        'firstName': parts.first,
        'lastName': parts.length > 1 ? parts.sublist(1).join(' ') : '',
        'phone': _phoneC.text.trim(),
      });
      if (mounted) {
        context.read<AuthProvider>().checkAuth();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error));
    }
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Preferences'),
        actions: [TextButton(onPressed: _saving ? null : _save, child: const Text('Save'))],
      ),
      body: ListView(padding: const EdgeInsets.all(24), children: [
        // Avatar
        Center(child: Stack(children: [
          CircleAvatar(radius: 40, backgroundColor: AppColors.primary,
            child: Text(_nameC.text.isNotEmpty ? _nameC.text[0] : 'A',
              style: const TextStyle(fontSize: 28, color: Colors.white))),
          Positioned(bottom: 0, right: 0, child: Container(
            width: 28, height: 28,
            decoration: BoxDecoration(color: AppColors.surfaceLight, shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2)),
            child: const Icon(Icons.camera_alt, size: 14, color: AppColors.textSecondary))),
        ])),
        const SizedBox(height: 24),
        // Contact Information
        _SectionTitle('CONTACT INFORMATION'),
        const SizedBox(height: 12),
        _Field('Full Name', _nameC, Icons.person_outline),
        const SizedBox(height: 12),
        _Field('Email Address', _emailC, Icons.mail_outline, enabled: false),
        const SizedBox(height: 12),
        _Field('Phone Number', _phoneC, Icons.phone_outlined),
        const SizedBox(height: 24),
        // Notifications
        _SectionTitle('NOTIFICATIONS'),
        const SizedBox(height: 8),
        _Toggle('Push Notifications', 'Instant alerts for payment & signature status', _pushNotif,
          (v) => setState(() => _pushNotif = v)),
        _Toggle('Email Summaries', 'Weekly activity and monthly ledgers', _emailSummary,
          (v) => setState(() => _emailSummary = v)),
        _Toggle('SMS Reminders', 'Urgent move-out or maintenance alerts', _smsReminder,
          (v) => setState(() => _smsReminder = v)),
        const SizedBox(height: 24),
        // Lease Preferences
        _SectionTitle('LEASE PREFERENCES'),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(12)),
          child: Row(children: [
            const Icon(Icons.description, color: AppColors.primary, size: 20),
            const SizedBox(width: 12),
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Default Lease Template', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              Text('Standard Residential', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ])),
            TextButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lease template management coming soon'))), child: const Text('Change')),
          ]),
        ),
        const SizedBox(height: 8),
        ListTile(
          leading: const Icon(Icons.payment, color: AppColors.textSecondary),
          title: const Text('Payment Provider Settings'),
          trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment provider settings available in Payments tab'))),
        ),
        const SizedBox(height: 32),
        ElevatedButton(onPressed: _saving ? null : _save,
          style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          child: _saving ? const SizedBox(height: 20, width: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Text('Save All Changes')),
        const SizedBox(height: 8),
        Center(child: TextButton(onPressed: () => Navigator.pop(context),
          child: const Text('Discard Changes', style: TextStyle(color: AppColors.textSecondary)))),
      ]),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);
  @override
  Widget build(BuildContext context) => Text(title, style: const TextStyle(
    fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary, letterSpacing: 0.5));
}

class _Field extends StatelessWidget {
  final String label; final TextEditingController c; final IconData icon; final bool enabled;
  const _Field(this.label, this.c, this.icon, {this.enabled = true});
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
    const SizedBox(height: 6),
    TextField(controller: c, enabled: enabled,
      decoration: InputDecoration(prefixIcon: Icon(icon, size: 20, color: AppColors.textSecondary))),
  ]);
}

class _Toggle extends StatelessWidget {
  final String title; final String subtitle; final bool value; final ValueChanged<bool> onChanged;
  const _Toggle(this.title, this.subtitle, this.value, this.onChanged);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(children: [
      const Icon(Icons.notifications_outlined, size: 20, color: AppColors.textSecondary),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ])),
      Switch(value: value, onChanged: onChanged, activeColor: AppColors.primary),
    ]),
  );
}
