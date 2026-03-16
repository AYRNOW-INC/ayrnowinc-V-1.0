import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../shared/lease_ready_screen.dart';
import '../shared/signing_status_screen.dart';
import '../shared/notifications_screen.dart';
import 'payment_ledger_screen.dart';

/// Wireframes E8 (empty), E9 (populated), E10 (detail), E3-E5 (create wizard)
class LeaseListScreen extends StatefulWidget {
  const LeaseListScreen({super.key});
  @override
  State<LeaseListScreen> createState() => _LeaseListScreenState();
}

class _LeaseListScreenState extends State<LeaseListScreen> {
  List<dynamic> _leases = [];
  bool _loading = true;
  String _filter = 'All';

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try { _leases = await ApiService.getList('/leases/landlord'); } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load leases'), backgroundColor: Colors.red));
    }
    if (mounted) setState(() => _loading = false);
  }

  List<dynamic> get _filtered => _filter == 'All' ? _leases
    : _leases.where((l) => l['status'] == _filter.toUpperCase().replaceAll(' ', '_')).toList();

  Color _statusColor(String s) => switch (s) {
    'DRAFT' => AppColors.textSecondary,
    'SENT_FOR_SIGNING' => AppColors.primary,
    'LANDLORD_SIGNED' || 'TENANT_SIGNED' => AppColors.teal,
    'FULLY_EXECUTED' => AppColors.success,
    _ => AppColors.error,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(padding: const EdgeInsets.only(left: 16), child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset('assets/logo.png', width: 32, height: 32))),
        title: const Text('Leases'),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () =>
            Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()))),
          IconButton(icon: const Icon(Icons.filter_list), onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Use the filter tabs below')))),
        ],
      ),
      body: RefreshIndicator(onRefresh: _load,
        child: _loading ? const Center(child: CircularProgressIndicator())
          : _leases.isEmpty ? _buildEmpty() : _buildPopulated()),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => Navigator.push(context, MaterialPageRoute(
          builder: (_) => _CreateLeaseWizard(onCreated: _load))),
        child: const Icon(Icons.add, color: Colors.white)),
    );
  }

  Widget _buildEmpty() {
    return ListView(padding: const EdgeInsets.all(24), children: [
      const SizedBox(height: 40),
      Center(child: Container(
        width: 80, height: 80,
        decoration: BoxDecoration(color: AppColors.primary.withAlpha(15), shape: BoxShape.circle),
        child: Stack(alignment: Alignment.center, children: [
          const Icon(Icons.description, size: 40, color: AppColors.primary),
          Positioned(bottom: 12, right: 12, child: Container(width: 24, height: 24,
            decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
            child: const Icon(Icons.add, color: Colors.white, size: 16))),
        ]),
      )),
      const SizedBox(height: 20),
      const Center(child: Text('No active leases yet', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700))),
      const SizedBox(height: 8),
      const Center(child: Text('Ready to secure your first tenant?\nCreate a professional lease in minutes.',
        textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary, height: 1.5))),
      const SizedBox(height: 28),
      ...[
        ('Configure Terms', 'Set rent amounts, security deposits, and customized lease clauses easily.', Icons.settings),
        ('Digital E-Signing', 'Invite tenants to sign securely from any device. No paperwork required.', Icons.draw),
        ('Secure Management', 'All documents are encrypted and stored safely for easy access anytime.', Icons.lock),
      ].map((i) => Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(children: [
        Icon(i.$3, color: AppColors.primary, size: 20), const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(i.$1, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(i.$2, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        ])),
      ]))),
      const SizedBox(height: 16),
      ElevatedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(
        builder: (_) => _CreateLeaseWizard(onCreated: _load))),
        style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.add, size: 20), SizedBox(width: 8), Text('Create First Lease')])),
    ]);
  }

  Widget _buildPopulated() {
    final filtered = _filtered;
    return ListView(padding: const EdgeInsets.all(16), children: [
      // Portfolio banner
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.primary.withAlpha(8), borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          const Icon(Icons.description, color: AppColors.primary, size: 20),
          const SizedBox(width: 10),
          Text('LEASE PORTFOLIO', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
            color: AppColors.primary, letterSpacing: 0.3)),
          const Spacer(),
          Text('${_leases.length} Active Leases', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ]),
      ),
      const SizedBox(height: 12),
      // Filter tabs
      SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(
        children: ['All', 'Drafts', 'Sent', 'Active'].map((f) =>
          Padding(padding: const EdgeInsets.only(right: 8), child: ChoiceChip(
            label: Text(f), selected: _filter == f,
            onSelected: (_) => setState(() => _filter = f),
            selectedColor: AppColors.primary,
            labelStyle: TextStyle(color: _filter == f ? Colors.white : AppColors.textSecondary, fontSize: 13),
          ))).toList())),
      const SizedBox(height: 12),
      ...filtered.map((l) => _LeaseCard(lease: l, statusColor: _statusColor(l['status']),
        onTap: () => _showDetail(l),
        onSend: l['status'] == 'DRAFT' ? () async {
          await ApiService.post('/leases/${l['id']}/send'); _load();
        } : null,
        onSign: (l['status'] == 'SENT_FOR_SIGNING' || l['status'] == 'TENANT_SIGNED') ? () async {
          await ApiService.post('/leases/${l['id']}/sign'); _load();
        } : null)),
    ]);
  }

  void _showDetail(Map<String, dynamic> l) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => _LeaseDetailScreen(lease: l, onChanged: _load)));
  }
}

/// E10: Lease Detail — full screen per wireframe
class _LeaseDetailScreen extends StatelessWidget {
  final Map<String, dynamic> l;
  final VoidCallback onChanged;
  const _LeaseDetailScreen({required Map<String, dynamic> lease, required this.onChanged}) : l = lease;

  Color _statusColor(String s) => switch (s) {
    'DRAFT' => AppColors.textSecondary,
    'SENT_FOR_SIGNING' => AppColors.primary,
    'LANDLORD_SIGNED' || 'TENANT_SIGNED' => AppColors.teal,
    'FULLY_EXECUTED' => AppColors.success,
    _ => AppColors.error,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lease Details'), actions: [
        PopupMenuButton(itemBuilder: (_) => [const PopupMenuItem(child: Text('Download PDF'))]),
      ]),
      body: ListView(padding: const EdgeInsets.all(24), children: [
          Row(children: [
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: _statusColor(l['status']).withAlpha(15), borderRadius: BorderRadius.circular(8)),
              child: Text(l['status'] ?? '', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                color: _statusColor(l['status'])))),
            const Spacer(),
          ]),
          const SizedBox(height: 12),
          Text('${l['propertyName']}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          Text('Unit: ${l['unitName']}', style: const TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          _DetailRow('Tenant', l['tenantName'] ?? ''),
          _DetailRow('Monthly Rent', '\$${l['monthlyRent']}'),
          _DetailRow('Security Deposit', '\$${l['securityDeposit'] ?? 'N/A'}'),
          _DetailRow('Term', '${l['leaseTermMonths']} months'),
          _DetailRow('Period', '${l['startDate']} to ${l['endDate']}'),
          const SizedBox(height: 16),
          if (l['signatures'] != null)
            ...((l['signatures'] as List).map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(children: [
                Icon(s['signed'] ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: s['signed'] ? AppColors.success : AppColors.warning, size: 18),
                const SizedBox(width: 8),
                Text('${s['signerRole']}: ${s['signerName']}'),
                const Spacer(),
                Text(s['signed'] ? 'Signed' : 'Pending',
                  style: TextStyle(color: s['signed'] ? AppColors.success : AppColors.warning,
                    fontWeight: FontWeight.w600, fontSize: 13)),
              ]),
            ))),
          const SizedBox(height: 20),
          if (l['status'] == 'DRAFT') ...[
            Row(children: [
              Expanded(child: OutlinedButton(onPressed: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => LeaseReadyScreen(lease: l, onSigned: onChanged)));
              }, child: const Text('Preview'))),
              const SizedBox(width: 8),
              Expanded(child: ElevatedButton(
                onPressed: () async { await ApiService.post('/leases/${l['id']}/send'); onChanged(); Navigator.pop(context); },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                child: const Text('Send to Sign'))),
            ]),
          ] else if (l['status'] != 'FULLY_EXECUTED') ...[
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => SigningStatusScreen(leaseId: l['id']))),
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 44)),
              child: const Text('View Signing Status')),
          ],
        ]),
    );
  }
}

class _LeaseCard extends StatelessWidget {
  final Map<String, dynamic> lease;
  final Color statusColor;
  final VoidCallback onTap;
  final VoidCallback? onSend;
  final VoidCallback? onSign;

  const _LeaseCard({required this.lease, required this.statusColor, required this.onTap, this.onSend, this.onSign});

  @override
  Widget build(BuildContext context) {
    return Card(margin: const EdgeInsets.only(bottom: 12), child: InkWell(onTap: onTap,
      child: Padding(padding: const EdgeInsets.all(14), child: Row(
        children: [
          // Property image placeholder
          Container(width: 48, height: 48,
            decoration: BoxDecoration(color: AppColors.primary.withAlpha(15), borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.apartment, color: AppColors.primary, size: 24)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(lease['propertyName'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15))),
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: statusColor.withAlpha(15), borderRadius: BorderRadius.circular(6)),
                child: Text(lease['status'] ?? '', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: statusColor))),
            ]),
            const SizedBox(height: 2),
            Text('${lease['unitName']} - ${lease['tenantName']}',
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 6),
            Row(children: [
              Text('\$${lease['monthlyRent']}/mo', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(width: 16),
              Text('${lease['leaseTermMonths']} Months', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            ]),
          ])),
          if (onSend != null) IconButton(icon: const Icon(Icons.send, color: AppColors.primary, size: 20), onPressed: onSend),
          if (onSign != null) IconButton(icon: const Icon(Icons.draw, color: AppColors.success, size: 20), onPressed: onSign),
          const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20),
        ],
      ))));
  }
}

class _DetailRow extends StatelessWidget {
  final String label; final String value;
  const _DetailRow(this.label, this.value);
  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      ]));
  }
}

/// E3-E7: Create Lease Wizard (5 steps matching wireframes)
class _CreateLeaseWizard extends StatefulWidget {
  final VoidCallback onCreated;
  const _CreateLeaseWizard({required this.onCreated});
  @override
  State<_CreateLeaseWizard> createState() => _CreateLeaseWizardState();
}

class _CreateLeaseWizardState extends State<_CreateLeaseWizard> {
  int _step = 1;
  List<dynamic> _properties = [];
  Map<String, dynamic>? _selectedProperty;
  Map<String, dynamic>? _selectedUnit;
  final _tenantIdC = TextEditingController();
  final _rentC = TextEditingController();
  final _termC = TextEditingController(text: '12');
  final _depositC = TextEditingController();
  final _notesC = TextEditingController();
  final List<String> _clauses = ['General Occupancy', 'Security Deposit Usage', 'Quiet Enjoyment'];
  bool _saving = false;

  @override
  void initState() { super.initState(); _loadProperties(); }

  Future<void> _loadProperties() async {
    try { _properties = await ApiService.getList('/properties'); if (mounted) setState(() {}); } catch (_) {}
  }

  Future<void> _create() async {
    setState(() => _saving = true);
    try {
      final now = DateTime.now();
      await ApiService.post('/leases', body: {
        'propertyId': _selectedProperty!['id'],
        'unitSpaceId': _selectedUnit!['id'],
        'tenantId': int.parse(_tenantIdC.text),
        'leaseTermMonths': int.tryParse(_termC.text) ?? 12,
        'monthlyRent': double.tryParse(_rentC.text) ?? 0,
        'securityDeposit': double.tryParse(_depositC.text),
        'startDate': '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
      });
      widget.onCreated();
      if (mounted) Navigator.pop(context);
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
        title: const Text('New Lease'),
        actions: [Center(child: Padding(padding: const EdgeInsets.only(right: 16),
          child: Text('STEP $_step OF 5', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary))))],
      ),
      body: SingleChildScrollView(padding: const EdgeInsets.all(24), child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: [
          ClipRRect(borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(value: _step / 5, minHeight: 4,
              backgroundColor: AppColors.border, valueColor: const AlwaysStoppedAnimation(AppColors.primary))),
          const SizedBox(height: 24),
          if (_step == 1) ..._buildStep1(),
          if (_step == 2) ..._buildStep2(),
          if (_step == 3) ..._buildStep3(),
          if (_step == 4) ..._buildStep4(),
          if (_step == 5) ..._buildStep5(),
        ],
      )),
    );
  }

  List<Widget> _buildStep1() {
    final units = (_selectedProperty?['unitSpaces'] as List<dynamic>?) ?? [];
    return [
      const Text('Select Property & Unit', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
      const SizedBox(height: 8),
      const Text('Choose the property and specific unit for this new lease agreement.',
        style: TextStyle(color: AppColors.textSecondary)),
      const SizedBox(height: 20),
      ..._properties.map((p) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: InkWell(
          onTap: () => setState(() { _selectedProperty = p; _selectedUnit = null; }),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _selectedProperty?['id'] == p['id'] ? AppColors.primary : Colors.transparent, width: 2)),
            child: Row(children: [
              Container(width: 56, height: 56,
                decoration: BoxDecoration(color: AppColors.primary.withAlpha(15), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.apartment, color: AppColors.primary)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(p['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                Text('${p['totalUnits']} Units - ${(p['unitSpaces'] as List?)?.where((u) => u['status'] == 'VACANT').length ?? 0} Available',
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              ])),
            ]),
          ),
        ),
      )),
      if (_selectedProperty != null && units.isNotEmpty) ...[
        const SizedBox(height: 16),
        const Text('Select Unit', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        DropdownButtonFormField<Map<String, dynamic>>(
          value: _selectedUnit,
          items: units.map((u) => DropdownMenuItem(value: u as Map<String, dynamic>, child: Text(u['name'] ?? ''))).toList(),
          onChanged: (v) => setState(() => _selectedUnit = v),
          decoration: const InputDecoration(hintText: 'Choose unit')),
      ],
      const SizedBox(height: 24),
      ElevatedButton(
        onPressed: _selectedUnit != null ? () => setState(() => _step = 2) : null,
        style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 52)),
        child: const Text('Next: Tenant Information')),
    ];
  }

  List<Widget> _buildStep2() {
    return [
      const Text('Tenant Information', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
      const SizedBox(height: 8),
      const Text('Enter the tenant user ID to assign this lease.',
        style: TextStyle(color: AppColors.textSecondary)),
      const SizedBox(height: 20),
      const Text('Tenant User ID', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      const SizedBox(height: 6),
      TextField(controller: _tenantIdC, keyboardType: TextInputType.number,
        decoration: const InputDecoration(hintText: 'Enter tenant ID',
          prefixIcon: Icon(Icons.person_outline, size: 20))),
      const SizedBox(height: 24),
      Row(children: [
        Expanded(child: OutlinedButton(onPressed: () => setState(() => _step = 1), child: const Text('Back'))),
        const SizedBox(width: 12),
        Expanded(child: ElevatedButton(
          onPressed: _tenantIdC.text.isNotEmpty ? () => setState(() => _step = 3) : null,
          child: const Text('Next Step'))),
      ]),
    ];
  }

  List<Widget> _buildStep3() {
    return [
      const Text('Lease Terms', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
      const SizedBox(height: 8),
      const Text('Define the financial commitment and duration of the agreement.',
        style: TextStyle(color: AppColors.textSecondary)),
      const SizedBox(height: 20),
      Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Monthly Rent', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          TextField(controller: _rentC, keyboardType: TextInputType.number,
            decoration: const InputDecoration(prefixText: '\$ ')),
        ])),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Term (Months)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          TextField(controller: _termC, keyboardType: TextInputType.number),
        ])),
      ]),
      const SizedBox(height: 16),
      const Text('Security Deposit', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      const SizedBox(height: 6),
      TextField(controller: _depositC, keyboardType: TextInputType.number,
        decoration: const InputDecoration(prefixText: '\$ ')),
      const SizedBox(height: 24),
      // Summary
      if (_rentC.text.isNotEmpty) Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(12)),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Total Annual Rent:', style: TextStyle(fontWeight: FontWeight.w600)),
          Text('\$${((double.tryParse(_rentC.text) ?? 0) * (int.tryParse(_termC.text) ?? 12)).toStringAsFixed(0)}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primary)),
        ]),
      ),
      const SizedBox(height: 24),
      Row(children: [
        Expanded(child: OutlinedButton(onPressed: () => setState(() => _step = 2), child: const Text('Back'))),
        const SizedBox(width: 12),
        Expanded(child: ElevatedButton(
          onPressed: () => setState(() => _step = 4),
          child: const Text('Continue to Clauses'))),
      ]),
      const SizedBox(height: 8),
      Center(child: TextButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Draft saving coming soon'))),
        child: const Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.save, size: 14), SizedBox(width: 4), Text('Save Progress as Draft', style: TextStyle(fontSize: 13))]))),
    ];
  }

  /// E6: Clauses & Notes (step 4 of 5)
  List<Widget> _buildStep4() {
    return [
      const Text('Clauses & Notes', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
      const SizedBox(height: 8),
      const Text('Add specific legal clauses and private internal notes for this lease agreement.',
        style: TextStyle(color: AppColors.textSecondary)),
      const SizedBox(height: 20),
      // Clause templates
      const Text('CLAUSE TEMPLATES', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
        color: AppColors.textSecondary, letterSpacing: 0.5)),
      const SizedBox(height: 8),
      SizedBox(height: 80, child: ListView(scrollDirection: Axis.horizontal, children: [
        _ClauseTemplate('Pet Policy', Icons.pets, () => setState(() { if (!_clauses.contains('Pet Policy')) _clauses.add('Pet Policy'); })),
        const SizedBox(width: 8),
        _ClauseTemplate('Late Fees', Icons.schedule, () => setState(() { if (!_clauses.contains('Late Fee Policy')) _clauses.add('Late Fee Policy'); })),
        const SizedBox(width: 8),
        _ClauseTemplate('Parking', Icons.local_parking, () => setState(() { if (!_clauses.contains('Parking Rules')) _clauses.add('Parking Rules'); })),
      ])),
      const SizedBox(height: 20),
      // Active clauses
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('ACTIVE CLAUSES (${_clauses.length})', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
          color: AppColors.textSecondary, letterSpacing: 0.5)),
        TextButton.icon(onPressed: () => setState(() => _clauses.add('Custom Clause ${_clauses.length + 1}')),
          icon: const Icon(Icons.add, size: 16), label: const Text('Add Custom', style: TextStyle(fontSize: 13))),
      ]),
      const SizedBox(height: 8),
      ..._clauses.asMap().entries.map((e) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 0.5)),
        child: Row(children: [
          Container(width: 28, height: 28,
            decoration: BoxDecoration(color: AppColors.primary.withAlpha(15), borderRadius: BorderRadius.circular(6)),
            child: Center(child: Text('${e.key + 1}', style: const TextStyle(fontSize: 12,
              fontWeight: FontWeight.w700, color: AppColors.primary)))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(e.value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const Text('Standard clause text...', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ])),
          TextButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Clause editing coming soon'))), child: const Text('Edit Clause', style: TextStyle(fontSize: 12))),
        ]),
      )),
      const SizedBox(height: 16),
      // Internal notes
      const Row(children: [
        Icon(Icons.note, size: 18, color: AppColors.warning),
        SizedBox(width: 8),
        Text('INTERNAL NOTES', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
          color: AppColors.textSecondary, letterSpacing: 0.5)),
      ]),
      const SizedBox(height: 8),
      TextField(controller: _notesC, maxLines: 3,
        decoration: const InputDecoration(hintText: "Add private notes for your records (e.g., 'Tenant requested early keys').\nThese will NOT be visible to the tenant.")),
      const SizedBox(height: 4),
      const Align(alignment: Alignment.centerRight,
        child: Text('Private to Landlord Only', style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontStyle: FontStyle.italic))),
      const SizedBox(height: 24),
      Row(children: [
        Expanded(child: OutlinedButton(onPressed: () => setState(() => _step = 3), child: const Text('Back'))),
        const SizedBox(width: 12),
        Expanded(child: ElevatedButton(
          onPressed: () => setState(() => _step = 5),
          child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('Review Lease'), SizedBox(width: 6), Icon(Icons.arrow_forward, size: 18)]))),
      ]),
    ];
  }

  /// E7: Review (step 5 of 5)
  List<Widget> _buildStep5() {
    return [
      // Step dots
      Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(5, (i) =>
        Container(margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 10, height: 10,
          decoration: BoxDecoration(shape: BoxShape.circle,
            color: i < 5 ? AppColors.primary : AppColors.border)))),
      const SizedBox(height: 20),
      // Generated badge
      Center(child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: AppColors.success.withAlpha(15), borderRadius: BorderRadius.circular(8)),
        child: const Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.description, color: AppColors.success, size: 16),
          SizedBox(width: 6),
          Text('Lease Agreement Ready', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.success)),
        ]),
      )),
      const SizedBox(height: 20),
      // Review sections
      _ReviewSection(Icons.apartment, 'Property & Unit', [
        if (_selectedProperty != null) 'Property: ${_selectedProperty!['name']}',
        if (_selectedUnit != null) 'Unit: ${_selectedUnit!['name']}',
      ]),
      const SizedBox(height: 12),
      _ReviewSection(Icons.person, 'Tenant Details', [
        'Tenant ID: ${_tenantIdC.text}',
      ]),
      const SizedBox(height: 12),
      _ReviewSection(Icons.attach_money, 'Lease Terms', [
        'Monthly Rent: \$${_rentC.text}',
        'Term: ${_termC.text} months',
        if (_depositC.text.isNotEmpty) 'Security Deposit: \$${_depositC.text}',
      ]),
      const SizedBox(height: 12),
      _ReviewSection(Icons.gavel, 'Clauses & Notes', [
        '${_clauses.length} clauses included',
        if (_notesC.text.isNotEmpty) 'Internal notes added',
      ]),
      const SizedBox(height: 24),
      // Actions
      ElevatedButton.icon(
        onPressed: _saving ? null : _create,
        icon: _saving ? const SizedBox(height: 16, width: 16,
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
          : const Icon(Icons.check, size: 18),
        label: Text(_saving ? 'Creating...' : 'Send for Signature'),
        style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
      ),
      const SizedBox(height: 12),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        TextButton.icon(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PDF preview available after lease creation'))), icon: const Icon(Icons.picture_as_pdf, size: 16),
          label: const Text('PDF Preview', style: TextStyle(fontSize: 13))),
        const SizedBox(width: 16),
        TextButton.icon(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Draft saving coming soon'))), icon: const Icon(Icons.save, size: 16),
          label: const Text('Save Draft', style: TextStyle(fontSize: 13))),
      ]),
    ];
  }
}

class _ClauseTemplate extends StatelessWidget {
  final String label; final IconData icon; final VoidCallback onAdd;
  const _ClauseTemplate(this.label, this.icon, this.onAdd);
  @override
  Widget build(BuildContext context) => Container(
    width: 120, padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(12)),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(icon, color: AppColors.primary, size: 20),
      const SizedBox(height: 6),
      Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
      GestureDetector(onTap: onAdd, child: const Text('+ Add', style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600))),
    ]),
  );
}

class _ReviewSection extends StatelessWidget {
  final IconData icon; final String title; final List<String> items;
  const _ReviewSection(this.icon, this.title, this.items);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.border, width: 0.5)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Expanded(child: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600))),
        TextButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Use Back to edit this section'))), child: const Text('Edit', style: TextStyle(fontSize: 13))),
      ]),
      ...items.map((i) => Padding(padding: const EdgeInsets.only(top: 4),
        child: Text(i, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)))),
    ]),
  );
}
