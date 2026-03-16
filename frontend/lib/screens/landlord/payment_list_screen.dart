import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import 'payment_ledger_screen.dart';
import '../shared/notifications_screen.dart';

/// Wireframes H1 (empty) + H2 (populated)
class LandlordPaymentScreen extends StatefulWidget {
  const LandlordPaymentScreen({super.key});
  @override
  State<LandlordPaymentScreen> createState() => _LandlordPaymentScreenState();
}

class _LandlordPaymentScreenState extends State<LandlordPaymentScreen> {
  List<dynamic> _properties = [];
  Map<String, dynamic>? _stats;
  bool _loading = true;
  String _filter = 'All';

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      _properties = await ApiService.getList('/properties');
      _stats = await ApiService.get('/dashboard/landlord');
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  bool get _hasPayments => (_stats?['totalRevenue'] ?? 0) > 0 || _properties.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(padding: const EdgeInsets.only(left: 16), child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset('assets/logo.png', width: 32, height: 32))),
        title: const Text('Payments'),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () =>
            Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()))),
        ],
      ),
      body: RefreshIndicator(onRefresh: _load,
        child: _loading ? const Center(child: CircularProgressIndicator())
          : !_hasPayments ? _buildEmpty() : _buildPopulated()),
    );
  }

  Widget _buildEmpty() {
    return ListView(padding: const EdgeInsets.all(24), children: [
      const SizedBox(height: 40),
      Center(child: Icon(Icons.shield_outlined, size: 64, color: AppColors.primary.withAlpha(100))),
      const SizedBox(height: 20),
      const Center(child: Text('Unlock Effortless\nRent Collection', textAlign: TextAlign.center,
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700))),
      const SizedBox(height: 8),
      const Center(child: Text("You haven't set up a payment provider yet.\nConnect your bank to automate rent collection.",
        textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary, height: 1.5))),
      const SizedBox(height: 24),
      ElevatedButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Set STRIPE_SECRET_KEY in your environment to connect Stripe'))),
        style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('Connect Payment Provider'), SizedBox(width: 8), Icon(Icons.arrow_forward, size: 20)])),
      const SizedBox(height: 28),
      ...[
        ('Secure Connection', 'Link your business bank account through our encrypted Stripe integration.'),
        ('Set Billing Rules', 'Define rent amounts, due dates, and automatic grace periods for late fees.'),
        ('Start Collecting', 'Tenants receive an invite to pay via ACH or Card. Funds settle in 2-3 days.'),
      ].asMap().entries.map((e) => Padding(padding: const EdgeInsets.only(bottom: 16), child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(width: 28, height: 28, decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(15), borderRadius: BorderRadius.circular(8)),
            child: Center(child: Text('${e.key + 1}', style: const TextStyle(
              color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 13)))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(e.value.$1, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text(e.value.$2, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4)),
          ])),
        ]))),
      const SizedBox(height: 16),
      // Security badges
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        _Badge('PCI COMPLIANT'), const SizedBox(width: 8),
        _Badge('STRIPE VERIFIED'), const SizedBox(width: 8),
        _Badge('AES-256 BIT'),
      ]),
    ]);
  }

  Widget _buildPopulated() {
    return ListView(padding: const EdgeInsets.all(16), children: [
      // Revenue stats
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [AppColors.textDark, AppColors.textDark.withAlpha(200)]),
          borderRadius: BorderRadius.circular(16)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('TOTAL COLLECTED', style: TextStyle(fontSize: 11, color: Colors.white54, letterSpacing: 0.5)),
          const SizedBox(height: 4),
          Text('\$${_stats?['totalRevenue'] ?? '0'}',
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white)),
        ]),
      ),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: _MiniStat('Outstanding', '\$0', AppColors.warning)),
        const SizedBox(width: 12),
        Expanded(child: _MiniStat('Next Payout', '\$0', AppColors.success)),
      ]),
      const SizedBox(height: 16),
      // Filter tabs
      SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(
        children: ['All', 'Pending', 'Paid', 'Overdue'].map((f) =>
          Padding(padding: const EdgeInsets.only(right: 8), child: ChoiceChip(
            label: Text(f), selected: _filter == f,
            onSelected: (_) => setState(() => _filter = f),
            selectedColor: AppColors.primary,
            labelStyle: TextStyle(color: _filter == f ? Colors.white : AppColors.textSecondary, fontSize: 13),
          ))).toList())),
      const SizedBox(height: 16),
      // Property-based payment view
      ..._properties.map((p) => Card(margin: const EdgeInsets.only(bottom: 12),
        child: ExpansionTile(
          leading: CircleAvatar(radius: 18, backgroundColor: AppColors.primary.withAlpha(15),
            child: const Icon(Icons.apartment, color: AppColors.primary, size: 18)),
          title: Text(p['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          subtitle: Text('${p['totalUnits']} units', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          children: [
            FutureBuilder<List<dynamic>>(
              future: ApiService.getList('/payments/property/${p['id']}'),
              builder: (_, snap) {
                if (snap.connectionState != ConnectionState.done)
                  return const Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator());
                final payments = snap.data ?? [];
                if (payments.isEmpty)
                  return const Padding(padding: EdgeInsets.all(16), child: Text('No payments yet',
                    style: TextStyle(color: AppColors.textSecondary)));
                return Column(children: [
                  ...payments.map((pay) => ListTile(
                    leading: CircleAvatar(radius: 16,
                      backgroundColor: (pay['status'] == 'SUCCESSFUL' ? AppColors.success : AppColors.warning).withAlpha(20),
                      child: Icon(Icons.attach_money, size: 16,
                        color: pay['status'] == 'SUCCESSFUL' ? AppColors.success : AppColors.warning)),
                    title: Text('\$${pay['amount']}', style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text('Due: ${pay['dueDate']}', style: const TextStyle(fontSize: 13)),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: (pay['status'] == 'SUCCESSFUL' ? AppColors.success : AppColors.warning).withAlpha(15),
                        borderRadius: BorderRadius.circular(6)),
                      child: Text(pay['status'] ?? '', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                        color: pay['status'] == 'SUCCESSFUL' ? AppColors.success : AppColors.warning)),
                    ),
                  )),
                  if (payments.isNotEmpty)
                    TextButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(
                        builder: (_) => PaymentLedgerScreen(
                          leaseId: payments.first['leaseId'] as int,
                          tenantName: 'Tenant',
                          unitName: payments.first['unitName'] ?? ''))),
                      child: const Text('View Ledger >', style: TextStyle(fontSize: 13))),
                ]);
              }),
          ],
        ),
      )),
    ]);
  }
}

class _MiniStat extends StatelessWidget {
  final String label; final String value; final Color color;
  const _MiniStat(this.label, this.value, this.color);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: color)),
      ]),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  const _Badge(this.label);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: AppColors.success.withAlpha(10), borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.success.withAlpha(30))),
      child: Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.success)),
    );
  }
}
