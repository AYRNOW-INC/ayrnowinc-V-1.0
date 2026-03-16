import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'lease_signing_screen.dart';

/// Wireframe F1: Generated Lease Ready for Signature
class LeaseReadyScreen extends StatelessWidget {
  final Map<String, dynamic> lease;
  final VoidCallback onSigned;
  const LeaseReadyScreen({super.key, required this.lease, required this.onSigned});

  @override
  Widget build(BuildContext context) {
    final l = lease;
    final sigs = (l['signatures'] as List<dynamic>?) ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lease Ready'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: AppColors.success.withAlpha(15), borderRadius: BorderRadius.circular(6)),
            child: const Icon(Icons.info_outline, color: AppColors.success, size: 18),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Generated badge
          Center(child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: AppColors.success.withAlpha(15), borderRadius: BorderRadius.circular(8)),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.check_circle, color: AppColors.success, size: 16),
              SizedBox(width: 6),
              Text('Generated', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.success)),
            ]),
          )),
          const SizedBox(height: 20),
          // PDF card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(12)),
            child: Column(children: [
              const Icon(Icons.description, size: 40, color: AppColors.primary),
              const SizedBox(height: 8),
              Text('Lease_Agreement_${l['unitName']}.pdf',
                style: const TextStyle(fontWeight: FontWeight.w600)),
              const Text('READY FOR SIGNATURE', style: TextStyle(fontSize: 12, color: AppColors.success, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("PDF preview available after OpenSign integration"))),
                icon: const Icon(Icons.visibility, size: 16),
                label: const Text('Preview Full PDF'),
              ),
            ]),
          ),
          const SizedBox(height: 24),
          // Lease details
          const Text('LEASE DETAILS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
            color: AppColors.textSecondary, letterSpacing: 0.5)),
          const SizedBox(height: 12),
          _DetailRow(Icons.apartment, '${l['propertyName']}\n${l['unitName']}'),
          _DetailRow(Icons.attach_money, 'Monthly Rent: \$${l['monthlyRent']}'),
          _DetailRow(Icons.calendar_today, 'Start Date: ${l['startDate']}'),
          _DetailRow(Icons.schedule, 'Lease Term: ${l['leaseTermMonths']} Months'),
          _DetailRow(Icons.shield, 'Deposit: \$${l['securityDeposit'] ?? 'N/A'}'),
          const SizedBox(height: 24),
          // Required Signers
          const Text('REQUIRED SIGNERS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
            color: AppColors.textSecondary, letterSpacing: 0.5)),
          const SizedBox(height: 12),
          ...sigs.map((s) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border, width: 0.5)),
            child: Row(children: [
              CircleAvatar(radius: 20, backgroundColor: AppColors.primary.withAlpha(20),
                child: Text((s['signerName'] ?? 'U')[0],
                  style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary))),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(s['signerName'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                Text('${s['signerRole']}', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              ])),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (s['signed'] == true ? AppColors.success : AppColors.primary).withAlpha(15),
                  borderRadius: BorderRadius.circular(6)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(s['signed'] == true ? Icons.check_circle : Icons.verified,
                    size: 14, color: s['signed'] == true ? AppColors.success : AppColors.primary),
                  const SizedBox(width: 4),
                  Text(s['signed'] == true ? 'Signed' : 'Verified',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                      color: s['signed'] == true ? AppColors.success : AppColors.primary)),
                ]),
              ),
            ]),
          )),
          const SizedBox(height: 8),
          const Text('By clicking "Send for Signature", both parties will receive an email with instructions to review and sign this legally binding document electronically.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4)),
          const SizedBox(height: 20),
          // Actions
          Row(children: [
            Expanded(child: TextButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("PDF preview available after OpenSign integration"))), child: const Text('Edit'))),
            const SizedBox(width: 8),
            Expanded(flex: 2, child: ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => LeaseSigningScreen(lease: l, onSigned: onSigned))),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE8553A),
                minimumSize: const Size(0, 52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('Send to Sign'),
            )),
          ]),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon; final String text;
  const _DetailRow(this.icon, this.text);
  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(
      crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
      ]));
  }
}
