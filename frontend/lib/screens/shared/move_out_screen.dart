import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

/// Wireframes J1 (Move-Out Request) + J2 (Pending Move-Outs)
class MoveOutScreen extends StatefulWidget {
  final bool isLandlord;
  const MoveOutScreen({super.key, this.isLandlord = false});
  @override
  State<MoveOutScreen> createState() => _MoveOutScreenState();
}

class _MoveOutScreenState extends State<MoveOutScreen> {
  List<dynamic> _requests = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _requests = await ApiService.getList(
        widget.isLandlord ? '/move-out/landlord' : '/move-out/tenant');
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load move-out requests'), backgroundColor: Colors.red));
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.isLandlord ? 'Move-Outs' : 'Move-Out Request'),
        actions: [if (widget.isLandlord) IconButton(icon: const Icon(Icons.refresh), onPressed: _load)]),
      body: RefreshIndicator(onRefresh: _load,
        child: _loading ? const Center(child: CircularProgressIndicator())
          : _requests.isEmpty
            ? ListView(children: [const SizedBox(height: 100),
                Center(child: Column(children: [
                  Icon(Icons.exit_to_app, size: 56, color: AppColors.textSecondary),
                  const SizedBox(height: 12),
                  Text(widget.isLandlord ? 'No pending move-out requests' : 'No move-out requests',
                    style: const TextStyle(fontSize: 18, color: AppColors.textSecondary)),
                ]))])
            : widget.isLandlord ? _buildLandlordView() : _buildTenantView()),
      floatingActionButton: !widget.isLandlord ? FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: _showRequestForm,
        child: const Icon(Icons.exit_to_app, color: Colors.white)) : null,
    );
  }

  /// J2: Landlord view
  Widget _buildLandlordView() {
    final pending = _requests.where((r) => r['status'] == 'SUBMITTED' || r['status'] == 'UNDER_REVIEW').length;
    return ListView(padding: const EdgeInsets.all(16), children: [
      // Summary banner
      if (pending > 0) Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.warning.withAlpha(10), borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.warning.withAlpha(30))),
        child: Row(children: [
          Text('$pending Pending Requests', style: const TextStyle(fontWeight: FontWeight.w600)),
          const Spacer(),
          const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20),
        ]),
      ),
      const SizedBox(height: 16),
      ..._requests.map((m) => Card(margin: const EdgeInsets.only(bottom: 12), child: Padding(
        padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            CircleAvatar(radius: 20, backgroundColor: AppColors.primary.withAlpha(20),
              child: Text((m['tenantName'] ?? 'T')[0], style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary))),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(m['tenantName'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              Text('${m['propertyName']} - ${m['unitName']}', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            ])),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            const Icon(Icons.calendar_today, size: 14, color: AppColors.textSecondary),
            const SizedBox(width: 6),
            Text('Proposed: ${m['requestedDate']}', style: const TextStyle(fontSize: 13)),
            const SizedBox(width: 8),
            if (m['requestedDate'] != null) Builder(builder: (_) {
              try {
                final days = DateTime.parse(m['requestedDate']).difference(DateTime.now()).inDays;
                if (days < 14) return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: AppColors.error.withAlpha(15), borderRadius: BorderRadius.circular(4)),
                  child: Text('URGENT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.error)));
                return const SizedBox();
              } catch (_) { return const SizedBox(); }
            }),
          ]),
          if (m['reason'] != null && m['reason'].toString().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(m['reason'], style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          ],
          if (m['status'] == 'SUBMITTED') ...[
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: ElevatedButton(
                onPressed: () async {
                  await ApiService.put('/move-out/${m['id']}/review', body: {'status': 'APPROVED'});
                  _load();
                },
                style: ElevatedButton.styleFrom(minimumSize: const Size(0, 40)),
                child: const Text('Approve'))),
              const SizedBox(width: 8),
              Expanded(child: OutlinedButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Full move-out details shown in the card above'))), child: const Text('Details'))),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.error),
                onPressed: () async {
                  await ApiService.put('/move-out/${m['id']}/review', body: {'status': 'REJECTED'});
                  _load();
                }),
            ]),
          ] else
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: (m['status'] == 'APPROVED' ? AppColors.success : AppColors.error).withAlpha(15),
                borderRadius: BorderRadius.circular(6)),
              child: Text(m['status'] ?? '', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                color: m['status'] == 'APPROVED' ? AppColors.success : AppColors.error)),
            ),
        ])))),
    ]);
  }

  /// J1: Tenant view
  Widget _buildTenantView() {
    return ListView(padding: const EdgeInsets.all(16), children: [
      ..._requests.map((m) => Card(margin: const EdgeInsets.only(bottom: 12), child: ListTile(
        leading: Icon(Icons.exit_to_app,
          color: m['status'] == 'APPROVED' ? AppColors.success : AppColors.warning),
        title: Text('${m['propertyName']} - ${m['unitName']}'),
        subtitle: Text('Requested: ${m['requestedDate']}\n${m['reason'] ?? ''}'),
        isThreeLine: true,
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: (m['status'] == 'APPROVED' ? AppColors.success
              : m['status'] == 'REJECTED' ? AppColors.error : AppColors.warning).withAlpha(15),
            borderRadius: BorderRadius.circular(6)),
          child: Text(m['status'] ?? '', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
            color: m['status'] == 'APPROVED' ? AppColors.success
              : m['status'] == 'REJECTED' ? AppColors.error : AppColors.warning)),
        ),
      ))),
    ]);
  }

  void _showRequestForm() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => _MoveOutForm(onSubmitted: _load)));
  }
}

/// J1: Move-Out Request Form
class _MoveOutForm extends StatefulWidget {
  final VoidCallback onSubmitted;
  const _MoveOutForm({required this.onSubmitted});
  @override
  State<_MoveOutForm> createState() => _MoveOutFormState();
}

class _MoveOutFormState extends State<_MoveOutForm> {
  List<dynamic> _leases = [];
  int? _leaseId;
  DateTime? _date;
  final _addressC = TextEditingController();
  final _cityC = TextEditingController();
  final _zipC = TextEditingController();
  final _reasonC = TextEditingController();
  String? _reasonTag;
  bool _consent = false;
  bool _saving = false;

  @override
  void initState() { super.initState(); _loadLeases(); }

  Future<void> _loadLeases() async {
    try { _leases = await ApiService.getList('/leases/tenant'); if (mounted) setState(() {}); } catch (_) {}
  }

  Future<void> _submit() async {
    if (_leaseId == null || _date == null || !_consent) return;
    setState(() => _saving = true);
    try {
      await ApiService.post('/move-out', body: {
        'leaseId': _leaseId,
        'requestedDate': '${_date!.year}-${_date!.month.toString().padLeft(2, '0')}-${_date!.day.toString().padLeft(2, '0')}',
        'reason': [if (_reasonTag != null) _reasonTag!, _reasonC.text].join(' - '),
      });
      widget.onSubmitted();
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
      appBar: AppBar(title: const Text('Move-Out Request')),
      body: SingleChildScrollView(padding: const EdgeInsets.all(24), child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Notice banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.primary.withAlpha(8), borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withAlpha(30))),
            child: const Row(children: [
              Icon(Icons.info_outline, color: AppColors.primary, size: 18),
              SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('60-Day Notice Required', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                SizedBox(height: 2),
                Text('As per your signed lease, a minimum 60-day written notice is required before vacating.',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              ])),
            ]),
          ),
          const SizedBox(height: 24),
          // Lease selection
          const Text('Lease', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          DropdownButtonFormField<int>(
            value: _leaseId,
            items: _leases.map((l) => DropdownMenuItem<int>(
              value: l['id'] as int, child: Text('${l['propertyName']} - ${l['unitName']}'))).toList(),
            onChanged: (v) => setState(() => _leaseId = v),
            decoration: const InputDecoration(hintText: 'Select lease')),
          const SizedBox(height: 20),
          // Date picker
          const Text('REQUESTED MOVE-OUT DATE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
            color: AppColors.textSecondary, letterSpacing: 0.5)),
          const SizedBox(height: 8),
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(context: context,
                initialDate: DateTime.now().add(const Duration(days: 60)),
                firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
              if (picked != null) setState(() => _date = picked);
            },
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.inputBg, borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border)),
              child: Row(children: [
                const Icon(Icons.calendar_today, size: 18, color: AppColors.textSecondary),
                const SizedBox(width: 10),
                Text(_date != null ? '${_date!.year}-${_date!.month.toString().padLeft(2, '0')}-${_date!.day.toString().padLeft(2, '0')}' : 'Select date',
                  style: TextStyle(color: _date != null ? AppColors.textDark : AppColors.textSecondary)),
              ]),
            ),
          ),
          const SizedBox(height: 20),
          // Forwarding address
          const Text('FORWARDING ADDRESS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
            color: AppColors.textSecondary, letterSpacing: 0.5)),
          const SizedBox(height: 8),
          TextField(controller: _addressC, decoration: const InputDecoration(labelText: 'Street Address')),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: TextField(controller: _cityC, decoration: const InputDecoration(labelText: 'City'))),
            const SizedBox(width: 12),
            SizedBox(width: 100, child: TextField(controller: _zipC, decoration: const InputDecoration(labelText: 'Zip Code'),
              keyboardType: TextInputType.number)),
          ]),
          const SizedBox(height: 20),
          // Reason
          const Text('Reason for Moving', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: ['Buying a Home', 'Relocation', 'Upsizing', 'Downsizing']
            .map((r) => ChoiceChip(
              label: Text(r), selected: _reasonTag == r,
              onSelected: (_) => setState(() => _reasonTag = _reasonTag == r ? null : r),
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(color: _reasonTag == r ? Colors.white : AppColors.textSecondary, fontSize: 13),
            )).toList()),
          const SizedBox(height: 12),
          TextField(controller: _reasonC, maxLines: 3,
            decoration: const InputDecoration(hintText: 'Additional comments...', labelText: 'Additional Comments')),
          const SizedBox(height: 20),
          // Consent
          Row(children: [
            Checkbox(value: _consent, onChanged: (v) => setState(() => _consent = v!), activeColor: AppColors.primary),
            const Expanded(child: Text('I understand that submitting this request initiates my move-out process and I agree to the move-out terms in my lease.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary))),
          ]),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _consent && !_saving ? _submit : null,
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: _saving ? const SizedBox(height: 20, width: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Request Move-Out')),
        ],
      )),
    );
  }
}
