import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../shared/lease_signing_screen.dart';

/// Wireframe F5: Tenant Lease Review (pre-sign highlights + checklist)
class TenantLeaseReviewScreen extends StatefulWidget {
  final Map<String, dynamic> lease;
  final VoidCallback onSigned;
  const TenantLeaseReviewScreen({super.key, required this.lease, required this.onSigned});
  @override
  State<TenantLeaseReviewScreen> createState() => _TenantLeaseReviewScreenState();
}

class _TenantLeaseReviewScreenState extends State<TenantLeaseReviewScreen> {
  bool _confirmDetails = false;
  bool _reviewDeposit = false;
  bool _acceptRules = false;

  bool get _allChecked => _confirmDetails && _reviewDeposit && _acceptRules;

  @override
  Widget build(BuildContext context) {
    final l = widget.lease;
    return Scaffold(
      appBar: AppBar(title: const Text('Review Lease'),
        actions: [Container(
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: AppColors.textSecondary.withAlpha(20), borderRadius: BorderRadius.circular(8)),
          child: const Text('Draft', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        )]),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        // Lease Highlights
        const Text('Lease Highlights', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        const Text('Essential terms of your agreement', style: TextStyle(color: AppColors.textSecondary)),
        const SizedBox(height: 16),
        Row(children: [
          _HighlightCard(Icons.attach_money, 'MONTHLY RENT', '\$${l['monthlyRent']}', AppColors.primary),
          const SizedBox(width: 12),
          _HighlightCard(Icons.calendar_today, 'LEASE TERM', '${l['leaseTermMonths']} Months', AppColors.warning),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          _HighlightCard(Icons.shield, 'SECURITY DEPOSIT', '\$${l['securityDeposit'] ?? 'N/A'}', AppColors.teal),
          const SizedBox(width: 12),
          _HighlightCard(Icons.home, 'MOVE-IN DATE', l['startDate'] ?? '', AppColors.success),
        ]),
        const SizedBox(height: 24),
        // PDF Preview placeholder
        Container(
          height: 200,
          decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border)),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.description, size: 48, color: AppColors.textSecondary),
            const SizedBox(height: 8),
            const Text('Lease Agreement.pdf', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: AppColors.primary.withAlpha(10), borderRadius: BorderRadius.circular(8)),
              child: const Text('Tap to view full document', style: TextStyle(fontSize: 13, color: AppColors.primary)),
            ),
          ]),
        ),
        const SizedBox(height: 24),
        // Required Actions
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border, width: 0.5)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Row(children: [
              Icon(Icons.checklist, color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text('Required Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ]),
            const SizedBox(height: 12),
            _CheckAction('Confirm personal details', _confirmDetails, (v) => setState(() => _confirmDetails = v!)),
            _CheckAction('Review security deposit terms', _reviewDeposit, (v) => setState(() => _reviewDeposit = v!)),
            Row(children: [
              Checkbox(value: _acceptRules, onChanged: (v) => setState(() => _acceptRules = v!), activeColor: AppColors.primary),
              const Expanded(child: Text('Read and accept house rules')),
              TextButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please review and accept the house rules'))), child: const Text('Start', style: TextStyle(fontWeight: FontWeight.w600))),
            ]),
          ]),
        ),
        const SizedBox(height: 12),
        const Text(
          'By proceeding to sign, you acknowledge that you have read and understood all terms of this residential lease agreement and agree to be bound by them legally.',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
        ),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Ready to finalize?', style: TextStyle(color: AppColors.textSecondary)),
          const Text('Step 3 of 4', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13)),
        ]),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _allChecked ? () => Navigator.push(context, MaterialPageRoute(
            builder: (_) => LeaseSigningScreen(lease: l, onSigned: widget.onSigned))) : null,
          style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
          child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('Go to Lease Signing'), SizedBox(width: 8), Icon(Icons.arrow_forward, size: 20)])),
      ]),
    );
  }
}

class _HighlightCard extends StatelessWidget {
  final IconData icon; final String label; final String value; final Color color;
  const _HighlightCard(this.icon, this.label, this.value, this.color);
  @override
  Widget build(BuildContext context) => Expanded(child: Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: color.withAlpha(8), borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color.withAlpha(30))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, color: color, size: 20),
      const SizedBox(height: 8),
      Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color, letterSpacing: 0.3)),
      const SizedBox(height: 2),
      Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
    ]),
  ));
}

class _CheckAction extends StatelessWidget {
  final String label; final bool value; final ValueChanged<bool?> onChanged;
  const _CheckAction(this.label, this.value, this.onChanged);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(children: [
      Checkbox(value: value, onChanged: onChanged, activeColor: AppColors.primary),
      Expanded(child: Text(label)),
    ]),
  );
}
