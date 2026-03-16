import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

/// Wireframes D1 (Invite Tenant), D2 (Sent), D4 (Pending Invites)
class InviteScreen extends StatefulWidget {
  const InviteScreen({super.key});
  @override
  State<InviteScreen> createState() => _InviteScreenState();
}

class _InviteScreenState extends State<InviteScreen> {
  List<dynamic> _invitations = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try { _invitations = await ApiService.getList('/invitations'); } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pending Invites'),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Search by name or email in the list below')))),
          const SizedBox(width: 8),
        ]),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading ? const Center(child: CircularProgressIndicator())
          : _invitations.isEmpty
            ? ListView(children: const [SizedBox(height: 100),
                Center(child: Column(children: [
                  Icon(Icons.mail_outline, size: 56, color: AppColors.textSecondary),
                  SizedBox(height: 12),
                  Text('No invitations sent yet', style: TextStyle(fontSize: 18, color: AppColors.textSecondary)),
                ]))])
            : ListView(padding: const EdgeInsets.all(16), children: [
                // Filter tabs
                Row(children: [
                  _FilterChip('${_invitations.where((i) => i['status'] == 'SENT' || i['status'] == 'PENDING').length} Pending', true),
                  const SizedBox(width: 8),
                  _FilterChip('Expiring Soon', false),
                  const Spacer(),
                  const Text('Sort by: Newest', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ]),
                const SizedBox(height: 16),
                ..._invitations.map((inv) => _InviteCard(invite: inv, onCancel: () async {
                  await ApiService.delete('/invitations/${inv['id']}');
                  _load();
                }, onResend: () {})),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: AppColors.primary.withAlpha(8), borderRadius: BorderRadius.circular(12)),
                  child: const Row(children: [
                    Icon(Icons.info_outline, color: AppColors.primary, size: 18),
                    SizedBox(width: 10),
                    Expanded(child: Text('Invites automatically expire after 7 days. You can resend them at any time.',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary))),
                  ]),
                ),
              ]),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _showInviteForm(),
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
    );
  }

  void _showInviteForm() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => _InviteTenantScreen(onSent: _load)));
  }
}

class _FilterChip extends StatelessWidget {
  final String label; final bool active;
  const _FilterChip(this.label, this.active);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: active ? AppColors.primary : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
        color: active ? Colors.white : AppColors.textSecondary)),
    );
  }
}

class _InviteCard extends StatelessWidget {
  final Map<String, dynamic> invite;
  final VoidCallback onCancel;
  final VoidCallback onResend;
  const _InviteCard({required this.invite, required this.onCancel, required this.onResend});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(padding: const EdgeInsets.all(16), child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            CircleAvatar(radius: 20, backgroundColor: AppColors.primary.withAlpha(20),
              child: Text((invite['tenantEmail'] ?? 'T')[0].toUpperCase(),
                style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary))),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(invite['tenantName'] ?? invite['tenantEmail'] ?? 'Unknown',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              Text(invite['tenantEmail'] ?? '', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            ])),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            const Icon(Icons.apartment, size: 14, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text('${invite['propertyName']} - ${invite['unitName']}',
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            Text('Code: ${invite['inviteCode']}',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: invite['status'] == 'ACCEPTED' ? AppColors.success.withAlpha(15) : AppColors.warning.withAlpha(15),
                borderRadius: BorderRadius.circular(6)),
              child: Text(invite['status'] ?? '',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                  color: invite['status'] == 'ACCEPTED' ? AppColors.success : AppColors.warning)),
            ),
          ]),
          if (invite['status'] != 'ACCEPTED' && invite['status'] != 'CANCELLED') ...[
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: OutlinedButton(onPressed: onCancel,
                style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.error), foregroundColor: AppColors.error),
                child: const Text('Cancel'))),
              const SizedBox(width: 8),
              Expanded(child: ElevatedButton(onPressed: onResend,
                style: ElevatedButton.styleFrom(minimumSize: const Size(0, 40)),
                child: const Text('Resend'))),
            ]),
          ],
        ],
      )),
    );
  }
}

/// D1: Invite Tenant form
class _InviteTenantScreen extends StatefulWidget {
  final VoidCallback onSent;
  const _InviteTenantScreen({required this.onSent});
  @override
  State<_InviteTenantScreen> createState() => _InviteTenantScreenState();
}

class _InviteTenantScreenState extends State<_InviteTenantScreen> {
  final _nameC = TextEditingController();
  final _emailC = TextEditingController();
  List<dynamic> _properties = [];
  int? _unitId;
  String _tone = 'Professional';
  bool _sending = false;
  bool _sent = false;
  Map<String, dynamic>? _result;

  @override
  void initState() { super.initState(); _loadProperties(); }

  Future<void> _loadProperties() async {
    try { _properties = await ApiService.getList('/properties'); } catch (_) {}
    if (mounted) setState(() {});
  }

  List<Map<String, dynamic>> get _allUnits {
    final units = <Map<String, dynamic>>[];
    for (var p in _properties) {
      for (var u in (p['unitSpaces'] ?? [])) {
        units.add({...u as Map<String, dynamic>, 'propertyName': p['name']});
      }
    }
    return units;
  }

  Future<void> _send() async {
    if (_unitId == null || _emailC.text.isEmpty) return;
    setState(() => _sending = true);
    try {
      _result = await ApiService.post('/invitations', body: {
        'unitSpaceId': _unitId,
        'tenantEmail': _emailC.text.trim(),
      });
      widget.onSent();
      if (mounted) setState(() => _sent = true);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error));
    }
    if (mounted) setState(() => _sending = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_sent) return _buildSent();
    return Scaffold(
      appBar: AppBar(title: const Text('Invite Tenant')),
      body: SingleChildScrollView(padding: const EdgeInsets.all(24), child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: [
          _SectionBar('RECIPIENT DETAILS'),
          const SizedBox(height: 12),
          const Text('Tenant Full Name', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          TextField(controller: _nameC, decoration: const InputDecoration(
            hintText: 'e.g. Sarah Jenkins', prefixIcon: Icon(Icons.person_outline, size: 20))),
          const SizedBox(height: 16),
          const Text('Email Address', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          TextField(controller: _emailC, decoration: const InputDecoration(
            hintText: 'tenant@example.com', prefixIcon: Icon(Icons.mail_outline, size: 20))),
          const SizedBox(height: 24),
          _SectionBar('PROPERTY ASSIGNMENT'),
          const SizedBox(height: 12),
          const Text('Property & Unit', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          DropdownButtonFormField<int>(
            value: _unitId,
            items: _allUnits.map((u) => DropdownMenuItem<int>(
              value: u['id'] as int, child: Text('${u['propertyName']} - ${u['name']}'))).toList(),
            onChanged: (v) => setState(() => _unitId = v),
            decoration: const InputDecoration(hintText: 'Select unit'),
          ),
          const SizedBox(height: 16),
          const Text('Proposed Start Date', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(context: context,
                initialDate: DateTime.now().add(const Duration(days: 30)),
                firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
              if (picked != null) setState(() {});
            },
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.inputBg, borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border)),
              child: const Row(children: [
                Icon(Icons.calendar_today, size: 18, color: AppColors.textSecondary),
                SizedBox(width: 10),
                Text('Select start date', style: TextStyle(color: AppColors.textSecondary)),
              ]),
            ),
          ),
          const SizedBox(height: 24),
          _SectionBar('PERSONALIZED MESSAGE'),
          const SizedBox(height: 8),
          Row(children: ['Professional', 'Friendly', 'Urgent'].map((t) =>
            Padding(padding: const EdgeInsets.only(right: 8), child: ChoiceChip(
              label: Text(t), selected: _tone == t,
              onSelected: (_) => setState(() => _tone = t),
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(color: _tone == t ? Colors.white : AppColors.textSecondary, fontSize: 13),
            ))).toList()),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.warning.withAlpha(10), borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.warning.withAlpha(30))),
            child: const Row(children: [
              Icon(Icons.schedule, color: AppColors.warning, size: 18),
              SizedBox(width: 10),
              Expanded(child: Text('This link will remain active for 7 days. If not accepted, you will need to resend.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary))),
            ]),
          ),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: _sending ? null : _send,
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
            child: _sending ? const SizedBox(height: 20, width: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Send Secure Invitation')),
        ],
      )),
    );
  }

  /// D2: Invite Sent Success
  Widget _buildSent() {
    return Scaffold(
      appBar: AppBar(actions: [IconButton(icon: const Icon(Icons.close),
        onPressed: () => Navigator.pop(context))]),
      body: Center(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: Column(children: [
        Container(width: 80, height: 80,
          decoration: BoxDecoration(color: AppColors.primary.withAlpha(20), shape: BoxShape.circle),
          child: const Icon(Icons.check_circle, color: AppColors.primary, size: 48)),
        const SizedBox(height: 20),
        const Text('Invite Sent Successfully!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        const Text("We've sent an invitation link to the tenant.",
          style: TextStyle(color: AppColors.textSecondary)),
        const SizedBox(height: 24),
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
          Row(children: [
            CircleAvatar(radius: 20, backgroundColor: AppColors.primary.withAlpha(20),
              child: Text((_emailC.text.isNotEmpty ? _emailC.text[0] : 'T').toUpperCase(),
                style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary))),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_nameC.text.isNotEmpty ? _nameC.text : _emailC.text,
                style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(_emailC.text, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: AppColors.warning.withAlpha(15), borderRadius: BorderRadius.circular(6)),
              child: const Text('Pending', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.warning)),
            ),
          ]),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('PROPERTY & UNIT', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            const Text('EXPIRES IN', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ]),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(_result?['propertyName'] ?? '', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
            const Row(children: [Icon(Icons.schedule, size: 14, color: AppColors.warning), SizedBox(width: 4),
              Text('7 days', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500))]),
          ]),
        ]))),
        const SizedBox(height: 20),
        ElevatedButton(onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 52)),
          child: const Text('View Invite Status')),
        const SizedBox(height: 20),
        const Align(alignment: Alignment.centerLeft,
          child: Text('OTHER ACTIONS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
            color: AppColors.textSecondary, letterSpacing: 0.5))),
        const SizedBox(height: 8),
        // Resend Invitation
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border, width: 0.5)),
          child: InkWell(
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Invitation resent'), backgroundColor: AppColors.success)),
            child: const Row(children: [
              Icon(Icons.refresh, color: AppColors.primary, size: 20),
              SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Resend Invitation', style: TextStyle(fontWeight: FontWeight.w600)),
                Text('Send the link again if they missed it', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ])),
              Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20),
            ]),
          ),
        ),
        const SizedBox(height: 8),
        // Copy Direct Link
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border, width: 0.5)),
          child: InkWell(
            onTap: () {
              final code = _result?['inviteCode'] ?? '';
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Invite code copied: $code'), backgroundColor: AppColors.success));
            },
            child: const Row(children: [
              Icon(Icons.link, color: AppColors.primary, size: 20),
              SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Copy Direct Link', style: TextStyle(fontWeight: FontWeight.w600)),
                Text('Share via text message or WhatsApp', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ])),
              Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20),
            ]),
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton(onPressed: () => Navigator.pop(context),
          style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
          child: const Text('Return to Leases')),
      ]))),
    );
  }
}

class _SectionBar extends StatelessWidget {
  final String label;
  const _SectionBar(this.label);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 8),
      decoration: const BoxDecoration(border: Border(left: BorderSide(color: AppColors.primary, width: 3))),
      child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 0.3)),
    );
  }
}
