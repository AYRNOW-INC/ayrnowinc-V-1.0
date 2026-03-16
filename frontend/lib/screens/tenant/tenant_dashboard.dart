import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../shared/notifications_screen.dart';
import 'tenant_onboarding_screen.dart';
import 'tenant_payment_screen.dart';
import 'tenant_lease_screen.dart';
import 'document_screen.dart';

/// Wireframes K1 (pre-active) + K2 (active)
class TenantDashboard extends StatefulWidget {
  const TenantDashboard({super.key});
  @override
  State<TenantDashboard> createState() => _TenantDashboardState();
}

class _TenantDashboardState extends State<TenantDashboard> {
  Map<String, dynamic>? _stats;
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try { _stats = await ApiService.get('/dashboard/tenant'); } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load dashboard'), backgroundColor: Colors.red));
    }
    if (mounted) setState(() => _loading = false);
  }

  bool get _hasLease => _stats?['leaseStatus'] != null && _stats?['leaseStatus'] != 'NONE';

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(
        leading: Padding(padding: const EdgeInsets.only(left: 16), child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset('assets/logo.png', width: 32, height: 32))),
        title: Text(_hasLease ? 'Dashboard' : 'My New Home'),
        actions: [IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () =>
          Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())))],
      ),
      body: RefreshIndicator(onRefresh: _load,
        child: _loading ? const Center(child: CircularProgressIndicator())
          : _hasLease ? _buildActive(auth) : _buildPreActive(auth)),
    );
  }

  /// K1: Pre-active
  Widget _buildPreActive(AuthProvider auth) {
    return ListView(padding: const EdgeInsets.all(20), children: [
      // Countdown card
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: AppColors.primary.withAlpha(8), borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withAlpha(30))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('COUNTDOWN TO MOVE-IN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
            color: AppColors.primary, letterSpacing: 0.5)),
          const SizedBox(height: 8),
          Row(children: [
            const Icon(Icons.calendar_today, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Builder(builder: (_) {
              final leaseStart = _stats?['nextDueDate'];
              if (leaseStart != null) {
                try {
                  final due = DateTime.parse(leaseStart);
                  final days = due.difference(DateTime.now()).inDays;
                  return Text('$days Days to go', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.primary));
                } catch (_) {}
              }
              return const Text('Coming soon', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.primary));
            }),
          ]),
          if (_stats?['propertyName'] != null) ...[
            const SizedBox(height: 12),
            Text('${_stats!['propertyName']}', style: const TextStyle(fontWeight: FontWeight.w600)),
            if (_stats?['unitName'] != null) Text(_stats!['unitName'], style: const TextStyle(color: AppColors.textSecondary)),
          ],
        ]),
      ),
      const SizedBox(height: 24),
      // Onboarding checklist
      const Text('Onboarding Checklist', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
      const SizedBox(height: 4),
      Builder(builder: (_) {
        int done = 0;
        if (_stats?['hasProfile'] == true || (_stats?['profileComplete'] ?? false)) done++;
        if ((_stats?['documentsUploaded'] ?? 0) > 0) done++;
        if ((_stats?['activeLeases'] ?? 0) > 0) done++;
        if ((_stats?['totalPayments'] ?? 0) > 0) done++;
        if (done == 0) done = 1;
        final pct = (done / 4 * 100).round();
        return Text('$pct% Complete', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600));
      }),
      const SizedBox(height: 12),
      _CheckItem(Icons.verified, 'Verify Identity', true),
      _CheckItem(Icons.description, 'Review & Sign Lease', false),
      _CheckItem(Icons.payment, 'Set Up Auto-Pay', false),
      _CheckItem(Icons.electrical_services, 'Utilities Transfer', false),
      const SizedBox(height: 24),
      // Quick cards
      Row(children: [
        Expanded(child: _QuickCard('Lease', 'View Terms', Icons.description, AppColors.primary)),
        const SizedBox(width: 12),
        Expanded(child: _QuickCard('Documents', '3 Files', Icons.folder, AppColors.teal)),
      ]),
      const SizedBox(height: 20),
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          const Icon(Icons.help_outline, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          const Expanded(child: Text('Need help moving? Contact your landlord directly',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary))),
          const Icon(Icons.arrow_forward, color: AppColors.textSecondary, size: 18),
        ]),
      ),
    ]);
  }

  /// K2: Active
  Widget _buildActive(AuthProvider auth) {
    final amountDue = _stats?['amountDue'] ?? 0;
    return ListView(padding: const EdgeInsets.all(20), children: [
      // Greeting
      Row(children: [
        CircleAvatar(radius: 24, backgroundColor: AppColors.primary,
          child: Text('${auth.user?['firstName']?[0] ?? ''}',
            style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.w600))),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Hello, ${auth.user?['firstName'] ?? ''}',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
          if (_stats?['unitName'] != null)
            Text('${_stats!['unitName']} - ${_stats!['propertyName']}',
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        ]),
      ]),
      const SizedBox(height: 20),
      // Payment due banner
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [AppColors.primary, AppColors.primary.withAlpha(200)]),
          borderRadius: BorderRadius.circular(16)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('NEXT PAYMENT DUE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
              color: Colors.white70, letterSpacing: 0.5)),
            Text(_stats?['nextDueDate'] ?? 'No due date', style: const TextStyle(color: Colors.white70, fontSize: 13)),
          ]),
          const SizedBox(height: 8),
          Text('\$$amountDue', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: Colors.white)),
          const SizedBox(height: 4),
          const Text('Standard Monthly Rent + Utilities', style: TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, height: 44, child: ElevatedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => const TenantPaymentScreen())),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text('Pay Now', style: TextStyle(fontWeight: FontWeight.w700)))),
        ]),
      ),
      const SizedBox(height: 20),
      // Quick Actions grid
      const Text('QUICK ACTIONS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
        color: AppColors.textSecondary, letterSpacing: 0.5)),
      const SizedBox(height: 12),
      Row(children: [
        _ActionButton(Icons.description, 'View Lease', () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const TenantLeaseScreen()))),
        const SizedBox(width: 12),
        _ActionButton(Icons.upload_file, 'Upload Docs', () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const DocumentScreen()))),
      ]),
      const SizedBox(height: 12),
      Row(children: [
        _ActionButton(Icons.history, 'History', () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const TenantPaymentScreen()))),
        const SizedBox(width: 12),
        _ActionButton(Icons.build, 'Maintenance', () {
          showDialog(context: context, builder: (_) => AlertDialog(
            title: const Text('Maintenance Requests'),
            content: const Text('Maintenance request functionality will be available in a future update. For urgent issues, please contact your landlord directly.'),
            actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
          ));
        }),
      ]),
      const SizedBox(height: 20),
      // Recent Activity
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('RECENT ACTIVITY', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
          color: AppColors.textSecondary, letterSpacing: 0.5)),
        TextButton(onPressed: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const NotificationsScreen())), child: const Text('View All')),
      ]),
      _ActivityRow(Icons.attach_money, AppColors.success, 'Payment activity', 'Check payments tab'),
      _ActivityRow(Icons.description, AppColors.primary, 'Lease activity', 'Check leases tab'),
    ]);
  }
}

class _CheckItem extends StatelessWidget {
  final IconData icon; final String label; final bool done;
  const _CheckItem(this.icon, this.label, this.done);
  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Row(children: [
      Icon(done ? Icons.check_circle : Icons.radio_button_unchecked,
        color: done ? AppColors.success : AppColors.border, size: 22),
      const SizedBox(width: 12),
      Text(label, style: TextStyle(fontSize: 15, color: done ? AppColors.textSecondary : AppColors.textDark,
        decoration: done ? TextDecoration.lineThrough : null)),
      const Spacer(),
      if (!done) const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20),
    ]));
  }
}

class _QuickCard extends StatelessWidget {
  final String title; final String subtitle; final IconData icon; final Color color;
  const _QuickCard(this.title, this.subtitle, this.icon, this.color);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: color.withAlpha(10), borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(30))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: color)),
        Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ]),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon; final String label; final VoidCallback onTap;
  const _ActionButton(this.icon, this.label, this.onTap);
  @override
  Widget build(BuildContext context) {
    return Expanded(child: GestureDetector(onTap: onTap, child: Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(12)),
      child: Column(children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
      ]),
    )));
  }
}

class _ActivityRow extends StatelessWidget {
  final IconData icon; final Color color; final String title; final String subtitle;
  const _ActivityRow(this.icon, this.color, this.title, this.subtitle);
  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Row(children: [
      CircleAvatar(radius: 18, backgroundColor: color.withAlpha(20),
        child: Icon(icon, color: color, size: 18)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        Text(subtitle, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
      ])),
      const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 18),
    ]));
  }
}
