import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Wireframe H5: Rent Payment Success
class PaymentSuccessScreen extends StatelessWidget {
  final Map<String, dynamic> payment;
  const PaymentSuccessScreen({super.key, required this.payment});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: Center(child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          // Success icon
          Container(width: 80, height: 80,
            decoration: BoxDecoration(color: AppColors.success.withAlpha(20), shape: BoxShape.circle),
            child: const Icon(Icons.check_circle, color: AppColors.success, size: 48)),
          const SizedBox(height: 20),
          const Text('Payment Successful!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          const Text('Your rent payment has been processed.', style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 24),
          // Transaction details
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(12)),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('TRANSACTION ID', style: TextStyle(fontSize: 11, color: AppColors.textSecondary, letterSpacing: 0.5)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: AppColors.success.withAlpha(15), borderRadius: BorderRadius.circular(6)),
                  child: const Text('COMPLETED', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.success)),
                ),
              ]),
              const SizedBox(height: 4),
              Align(alignment: Alignment.centerLeft,
                child: Text('#ARN-${payment['id'] ?? '0000'}',
                  style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary))),
              const Divider(height: 24),
              _DetailRow(Icons.apartment, 'Property', payment['propertyName'] ?? ''),
              _DetailRow(Icons.door_front_door, 'Unit', payment['unitName'] ?? ''),
              _DetailRow(Icons.calendar_today, 'Date & Time', payment['paidAt']?.toString().substring(0, 16) ?? 'Just now'),
              _DetailRow(Icons.payment, 'Payment Method', 'Card ending in ****'),
            ]),
          ),
          const SizedBox(height: 16),
          // Payment summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border, width: 0.5)),
            child: Column(children: [
              const Text('PAYMENT SUMMARY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                color: AppColors.textSecondary, letterSpacing: 0.5)),
              const SizedBox(height: 12),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Base Rent'),
                Text('\$${payment['amount'] ?? '0.00'}'),
              ]),
              const Divider(height: 16),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Total Paid', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                Text('\$${payment['amount'] ?? '0.00'}',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: AppColors.success)),
              ]),
            ]),
          ),
          const SizedBox(height: 20),
          // Actions
          Row(children: [
            Expanded(child: OutlinedButton.icon(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Feature coming soon'))),
              icon: const Icon(Icons.save_alt, size: 16), label: const Text('Save PDF'),
              style: OutlinedButton.styleFrom(minimumSize: const Size(0, 44),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))))),
            const SizedBox(width: 12),
            Expanded(child: OutlinedButton.icon(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Feature coming soon'))),
              icon: const Icon(Icons.share, size: 16), label: const Text('Share'),
              style: OutlinedButton.styleFrom(minimumSize: const Size(0, 44),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))))),
          ]),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('Go to Dashboard')),
          const SizedBox(height: 8),
          TextButton(onPressed: () => Navigator.pop(context),
            child: const Text('View Lease Agreement')),
          const SizedBox(height: 8),
          const Text('A confirmation email has been sent to your registered address.',
            textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ]),
      ))),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon; final String label; final String value;
  const _DetailRow(this.icon, this.label, this.value);
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(children: [
      Icon(icon, size: 16, color: AppColors.textSecondary),
      const SizedBox(width: 10),
      Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
      const Spacer(),
      Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
    ]));
}
