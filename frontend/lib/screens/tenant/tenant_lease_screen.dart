import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import 'tenant_lease_review_screen.dart';
import '../shared/signing_status_screen.dart';
import '../shared/move_out_screen.dart';

/// Wireframes G1 (View Lease) + tenant lease list
class TenantLeaseScreen extends StatefulWidget {
  const TenantLeaseScreen({super.key});
  @override
  State<TenantLeaseScreen> createState() => _TenantLeaseScreenState();
}

class _TenantLeaseScreenState extends State<TenantLeaseScreen> {
  List<dynamic> _leases = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try { _leases = await ApiService.getList('/leases/tenant'); } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load leases'), backgroundColor: Colors.red));
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(padding: const EdgeInsets.only(left: 16), child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset('assets/logo.png', width: 32, height: 32))),
        title: const Text('My Lease'),
        actions: [IconButton(icon: const Icon(Icons.info_outline), onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lease information and support'))))],
      ),
      body: RefreshIndicator(onRefresh: _load,
        child: _loading ? const Center(child: CircularProgressIndicator())
          : _leases.isEmpty ? _buildEmpty() : _buildLease(_leases.first)),
    );
  }

  Widget _buildEmpty() {
    return const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.description_outlined, size: 56, color: AppColors.textSecondary),
      SizedBox(height: 12),
      Text('No active leases', style: TextStyle(fontSize: 18, color: AppColors.textSecondary)),
      SizedBox(height: 4),
      Text('Your lease will appear here once created', style: TextStyle(color: AppColors.textSecondary)),
    ]));
  }

  Widget _buildLease(Map<String, dynamic> l) {
    final isActive = l['status'] == 'FULLY_EXECUTED';
    final canSign = l['status'] == 'SENT_FOR_SIGNING' || l['status'] == 'LANDLORD_SIGNED';
    return ListView(padding: const EdgeInsets.all(20), children: [
      // Current Lease card
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Text('CURRENT LEASE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
              color: AppColors.primary, letterSpacing: 0.5)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isActive ? AppColors.success : AppColors.warning,
                borderRadius: BorderRadius.circular(8)),
              child: Text(isActive ? 'Active' : l['status'] ?? '',
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ]),
          const SizedBox(height: 12),
          Text('\$${l['monthlyRent']}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
          Text('per month - Due on the ${l['paymentDueDay'] ?? 1}st',
            style: const TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          Row(children: [
            const Icon(Icons.location_on, size: 14, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text('${l['propertyName']}, ${l['unitName']}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ]),
          const SizedBox(height: 4),
          Row(children: [
            const Icon(Icons.calendar_today, size: 14, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text('Term: ${l['startDate']} - ${l['endDate']}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ]),
        ]),
      ),
      const SizedBox(height: 16),
      // Download PDF
      OutlinedButton.icon(
        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF download will be available when OpenSign integration is complete'))),
        icon: const Icon(Icons.download, size: 18),
        label: const Text('Download PDF'),
        style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
      ),
      const SizedBox(height: 24),
      // Lease Details
      const Text('Lease Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      const SizedBox(height: 12),
      _DetailCard(Icons.shield, 'Security Deposit', '\$${l['securityDeposit'] ?? 'N/A'}',
        badge: 'Held in Escrow', badgeColor: AppColors.teal),
      const SizedBox(height: 8),
      _DetailCard(Icons.schedule, 'Notice Period', '60 Days',
        action: 'End Lease', onAction: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MoveOutScreen()))),
      const SizedBox(height: 8),
      _DetailCard(Icons.electrical_services, 'Utility Responsibility', 'Tenant Paid',
        subtitle: 'Water/Trash Incl.'),
      // Sign button — goes through review first (F5 → F2)
      if (canSign) ...[
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () => Navigator.push(context, MaterialPageRoute(
            builder: (_) => TenantLeaseReviewScreen(lease: l, onSigned: _load))),
          icon: const Icon(Icons.draw),
          label: const Text('Review & Sign Lease'),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 52), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        ),
      ],
      // Signing status for leases in progress
      if (!isActive && !canSign && l['status'] != 'DRAFT') ...[
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(
            builder: (_) => SigningStatusScreen(leaseId: l['id']))),
          style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 44)),
          child: const Text('View Signing Status')),
      ],
      const SizedBox(height: 24),
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          const Expanded(child: Text('Need to make a change?', style: TextStyle(color: AppColors.textSecondary))),
          OutlinedButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Contact your landlord via the Account tab'))), child: const Text('Contact')),
        ]),
      ),
    ]);
  }
}

class _DetailCard extends StatelessWidget {
  final IconData icon; final String title; final String value;
  final String? badge; final Color? badgeColor; final String? subtitle;
  final String? action; final VoidCallback? onAction;
  const _DetailCard(this.icon, this.title, this.value, {this.badge, this.badgeColor, this.subtitle, this.action, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5)),
      child: Row(children: [
        Icon(icon, color: AppColors.primary, size: 22),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          if (subtitle != null) Text(subtitle!, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ])),
        if (badge != null) Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: (badgeColor ?? AppColors.primary).withAlpha(15), borderRadius: BorderRadius.circular(6)),
          child: Text(badge!, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: badgeColor ?? AppColors.primary)),
        ),
        if (action != null) TextButton(onPressed: onAction, child: Row(children: [
          Text(action!, style: const TextStyle(fontSize: 13)),
          const Icon(Icons.arrow_forward, size: 14),
        ])),
      ]),
    );
  }
}
