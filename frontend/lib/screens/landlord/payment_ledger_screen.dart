import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

/// Wireframe H3: Payment Ledger (detailed tenant payment history)
class PaymentLedgerScreen extends StatefulWidget {
  final int leaseId;
  final String tenantName;
  final String unitName;
  const PaymentLedgerScreen({super.key, required this.leaseId, required this.tenantName, required this.unitName});
  @override
  State<PaymentLedgerScreen> createState() => _PaymentLedgerScreenState();
}

class _PaymentLedgerScreenState extends State<PaymentLedgerScreen> {
  List<dynamic> _payments = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try { _payments = await ApiService.getList('/payments/lease/${widget.leaseId}'); } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  double get _totalPaid => _payments.where((p) => p['status'] == 'SUCCESSFUL')
    .fold(0.0, (sum, p) => sum + (p['amount'] as num).toDouble());
  double get _outstanding => _payments.where((p) => p['status'] == 'PENDING')
    .fold(0.0, (sum, p) => sum + (p['amount'] as num).toDouble());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ledger Detail'),
        actions: [
          Container(margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: AppColors.primary.withAlpha(15), borderRadius: BorderRadius.circular(8)),
            child: Text(widget.unitName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary))),
          IconButton(icon: const Icon(Icons.filter_list), onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Filter options coming soon')))),
        ]),
      body: _loading ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(onRefresh: _load, child: ListView(padding: const EdgeInsets.all(16), children: [
            // Balance card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [AppColors.primary, AppColors.primary.withAlpha(180)]),
                borderRadius: BorderRadius.circular(16)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Running Balance', style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 4),
                Text('\$${_totalPaid.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white)),
                const Text('Credit', style: TextStyle(color: Colors.white70)),
              ]),
            ),
            const SizedBox(height: 12),
            // Stats
            Row(children: [
              _MiniStat('PAID', '\$${_totalPaid.toStringAsFixed(0)}', AppColors.success),
              const SizedBox(width: 12),
              _MiniStat('OUTSTANDING', '\$${_outstanding.toStringAsFixed(0)}', AppColors.warning),
            ]),
            const SizedBox(height: 12),
            // Export
            Row(children: [
              CircleAvatar(radius: 18, backgroundColor: AppColors.primary.withAlpha(15),
                child: Text(widget.tenantName.isNotEmpty ? widget.tenantName[0] : 'T',
                  style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary))),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(widget.tenantName, style: const TextStyle(fontWeight: FontWeight.w600)),
                const Text('Lease Active', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ])),
              OutlinedButton.icon(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PDF export coming soon'))), icon: const Icon(Icons.download, size: 16),
                label: const Text('Export PDF', style: TextStyle(fontSize: 12)),
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)))),
            ]),
            const SizedBox(height: 20),
            // Activity
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Recent Activity', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              TextButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All transactions shown below'))), child: const Text('View All')),
            ]),
            if (_payments.isEmpty)
              const Padding(padding: EdgeInsets.all(32),
                child: Center(child: Text('No payments recorded', style: TextStyle(color: AppColors.textSecondary))))
            else
              ..._payments.map((p) {
                final isSuccess = p['status'] == 'SUCCESSFUL';
                return Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Row(children: [
                  CircleAvatar(radius: 18,
                    backgroundColor: (isSuccess ? AppColors.success : AppColors.warning).withAlpha(20),
                    child: Icon(isSuccess ? Icons.check : Icons.schedule, size: 16,
                      color: isSuccess ? AppColors.success : AppColors.warning)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('${p['paymentType']} Payment', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    Text(p['dueDate'] ?? '', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ])),
                  Text('${isSuccess ? '+' : ''}\$${p['amount']}',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15,
                      color: isSuccess ? AppColors.success : AppColors.textDark)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: (isSuccess ? AppColors.success : AppColors.warning).withAlpha(15),
                      borderRadius: BorderRadius.circular(4)),
                    child: Text(isSuccess ? 'Paid' : p['status'] ?? '', style: TextStyle(fontSize: 10,
                      fontWeight: FontWeight.w700, color: isSuccess ? AppColors.success : AppColors.warning)),
                  ),
                ]));
              }),
            const SizedBox(height: 20),
            // Totals
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(12)),
              child: Column(children: [
                _TotalRow('Total Invoiced', '\$${(_totalPaid + _outstanding).toStringAsFixed(2)}'),
                _TotalRow('Total Received', '\$${_totalPaid.toStringAsFixed(2)}'),
                const Divider(),
                _TotalRow('Outstanding Balance', '\$${_outstanding.toStringAsFixed(2)}', bold: true),
              ]),
            ),
          ])),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label; final String value; final Color color;
  const _MiniStat(this.label, this.value, this.color);
  @override
  Widget build(BuildContext context) => Expanded(child: Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.border, width: 0.5)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, letterSpacing: 0.3)),
      const SizedBox(height: 4),
      Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: color)),
    ]),
  ));
}

class _TotalRow extends StatelessWidget {
  final String label; final String value; final bool bold;
  const _TotalRow(this.label, this.value, {this.bold = false});
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: TextStyle(fontSize: 14, color: bold ? AppColors.textDark : AppColors.textSecondary,
        fontWeight: bold ? FontWeight.w600 : FontWeight.w400)),
      Text(value, style: TextStyle(fontSize: 14, fontWeight: bold ? FontWeight.w700 : FontWeight.w500)),
    ]));
}
