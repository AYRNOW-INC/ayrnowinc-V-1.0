import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'document_screen.dart';
import 'tenant_lease_screen.dart';
import 'tenant_payment_screen.dart';

/// Wireframe K3: Tenant Onboarding with progress checklist
class TenantOnboardingScreen extends StatefulWidget {
  const TenantOnboardingScreen({super.key});

  @override
  State<TenantOnboardingScreen> createState() => _TenantOnboardingScreenState();
}

class _TenantOnboardingScreenState extends State<TenantOnboardingScreen> {
  int _done = 1;
  final int _total = 4;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    try {
      final data = await ApiService.get('/dashboard/tenant');
      int done = 0;
      if (data['hasProfile'] == true || (data['profileComplete'] ?? false)) done++;
      if ((data['documentsUploaded'] ?? 0) > 0) done++;
      if ((data['activeLeases'] ?? 0) > 0) done++;
      if ((data['totalPayments'] ?? 0) > 0) done++;
      if (done == 0) done = 1; // at minimum account is verified
      if (mounted) setState(() => _done = done);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final name = auth.user?['firstName'] ?? 'there';
    final pct = (_done / _total * 100).round();

    return Scaffold(
      appBar: AppBar(
        leading: Padding(padding: const EdgeInsets.only(left: 16), child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset('assets/logo.png', width: 32, height: 32))),
        title: const Text('Onboarding'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Progress header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppColors.primary, AppColors.primary.withAlpha(200)]),
              borderRadius: BorderRadius.circular(16)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('YOUR JOURNEY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                color: Colors.white70, letterSpacing: 0.5)),
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Almost there, $name!', style: const TextStyle(fontSize: 20,
                  fontWeight: FontWeight.w700, color: Colors.white)),
                Text('$pct%\nCOMPLETE', textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
              ]),
              const SizedBox(height: 12),
              ClipRRect(borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(value: _done / _total, minHeight: 6,
                  backgroundColor: Colors.white24, valueColor: const AlwaysStoppedAnimation(Colors.white))),
              const SizedBox(height: 4),
              Text('$_done of $_total tasks completed', style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ]),
          ),
          const SizedBox(height: 24),
          // Required Steps
          const Text('REQUIRED STEPS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
            color: AppColors.textSecondary, letterSpacing: 0.5)),
          const SizedBox(height: 16),
          _Step(Icons.person_outline, 'Complete Profile',
            'Personal info and contact details', true, null, null),
          const SizedBox(height: 12),
          _Step(Icons.upload_file, 'Upload Documents',
            'Government ID and Proof of Income', _done >= 2, 'Start >',
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DocumentScreen()))),
          const SizedBox(height: 12),
          _Step(Icons.credit_card, 'Add Payment Method',
            'Link your bank for rent payments', _done >= 4, 'Start >',
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TenantPaymentScreen()))),
          const SizedBox(height: 12),
          _Step(Icons.description, 'Review Lease',
            'Sign your new residential agreement', _done >= 3, 'Start >',
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TenantLeaseScreen()))),
          const SizedBox(height: 24),
          // Pro-tip
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.primary.withAlpha(8), borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withAlpha(30))),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(width: 36, height: 36,
                decoration: BoxDecoration(color: AppColors.primary.withAlpha(15), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.lightbulb_outline, color: AppColors.primary, size: 18)),
              const SizedBox(width: 12),
              const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Pro-tip', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                SizedBox(height: 2),
                Text('Having your government ID and latest bank statements ready will speed up the verification process.',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4)),
              ])),
            ]),
          ),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const TenantLeaseScreen())),
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
            child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('Continue to Lease Review'), SizedBox(width: 8), Icon(Icons.arrow_forward, size: 20)])),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool done;
  final String? action;
  final VoidCallback? onTap;

  const _Step(this.icon, this.title, this.subtitle, this.done, this.action, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
          border: Border.all(color: done ? AppColors.success.withAlpha(50) : AppColors.border, width: 0.5)),
        child: Row(children: [
          Container(width: 40, height: 40,
            decoration: BoxDecoration(
              color: (done ? AppColors.success : AppColors.primary).withAlpha(15),
              borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: done ? AppColors.success : AppColors.primary, size: 20)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600,
              color: done ? AppColors.textSecondary : AppColors.textDark)),
            Text(subtitle, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          ])),
          if (done)
            const Text('DONE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.success))
          else if (action != null)
            Text(action!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary))
          else
            const Icon(Icons.radio_button_unchecked, color: AppColors.border, size: 22),
        ]),
      ),
    );
  }
}
