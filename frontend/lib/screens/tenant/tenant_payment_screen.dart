import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import 'payment_success_screen.dart';

/// Wireframe H4 (Rent Payment) + tenant payment list
class TenantPaymentScreen extends StatefulWidget {
  const TenantPaymentScreen({super.key});
  @override
  State<TenantPaymentScreen> createState() => _TenantPaymentScreenState();
}

class _TenantPaymentScreenState extends State<TenantPaymentScreen> {
  List<dynamic> _payments = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try { _payments = await ApiService.getList('/payments/tenant'); } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Color _statusColor(String s) => switch (s) {
    'SUCCESSFUL' => AppColors.success,
    'FAILED' || 'OVERDUE' => AppColors.error,
    _ => AppColors.warning,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(padding: const EdgeInsets.only(left: 16), child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset('assets/logo.png', width: 32, height: 32))),
        title: const Text('Pay'),
      ),
      body: RefreshIndicator(onRefresh: _load,
        child: _loading ? const Center(child: CircularProgressIndicator())
          : _payments.isEmpty ? _buildEmpty() : _buildList()),
    );
  }

  Widget _buildEmpty() {
    return const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.payment_outlined, size: 56, color: AppColors.textSecondary),
      SizedBox(height: 12),
      Text('No payments', style: TextStyle(fontSize: 18, color: AppColors.textSecondary)),
      SizedBox(height: 4),
      Text('Your payment history will appear here', style: TextStyle(color: AppColors.textSecondary)),
    ]));
  }

  Widget _buildList() {
    return ListView(padding: const EdgeInsets.all(16), children: [
      ..._payments.map((p) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(padding: const EdgeInsets.all(14), child: Row(children: [
          CircleAvatar(radius: 20, backgroundColor: _statusColor(p['status']).withAlpha(20),
            child: Icon(Icons.attach_money, color: _statusColor(p['status']), size: 20)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('\$${p['amount']}', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            Text('${p['paymentType']} - Due: ${p['dueDate']}',
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            Text('${p['propertyName']} - ${p['unitName']}',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ])),
          if (p['status'] == 'PENDING')
            ElevatedButton(onPressed: () => _showPaymentSummary(p),
              style: ElevatedButton.styleFrom(minimumSize: const Size(70, 36),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              child: const Text('Pay', style: TextStyle(fontSize: 13)))
          else
            GestureDetector(
              onTap: p['status'] == 'SUCCESSFUL' ? () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => PaymentSuccessScreen(payment: p as Map<String, dynamic>))) : null,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: _statusColor(p['status']).withAlpha(15),
                  borderRadius: BorderRadius.circular(6)),
                child: Text(p['status'] == 'SUCCESSFUL' ? 'View Receipt' : (p['status'] ?? ''),
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                    color: _statusColor(p['status']))),
              ),
            ),
        ])),
      )),
    ]);
  }

  void _showPaymentSummary(dynamic p) {
    showModalBottomSheet(context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('TRANSACTION SUMMARY', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
            color: AppColors.textSecondary, letterSpacing: 0.5)),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('${p['paymentType']} Rent', style: const TextStyle(fontSize: 15)),
            Text('\$${p['amount']}', style: const TextStyle(fontSize: 15)),
          ]),
          const Divider(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Total to Pay', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            Text('\$${p['amount']}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.primary)),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            const Icon(Icons.shield, size: 14, color: AppColors.textSecondary),
            const SizedBox(width: 6),
            const Text('SECURE SSL ENCRYPTED TRANSACTION', style: TextStyle(fontSize: 10,
              color: AppColors.textSecondary, letterSpacing: 0.3)),
          ]),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () { Navigator.pop(ctx); _pay(p['id'] as int); },
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: Text('Pay \$${p['amount']}'),
          ),
          const SizedBox(height: 8),
          const Text('By clicking "Pay", you authorize AYRNOW to charge your selected payment method.',
            textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ]),
      ),
    );
  }

  Future<void> _pay(int id) async {
    try {
      final res = await ApiService.post('/payments/$id/checkout');
      final url = res['checkoutUrl'];
      if (url != null) await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error));
    }
  }
}
