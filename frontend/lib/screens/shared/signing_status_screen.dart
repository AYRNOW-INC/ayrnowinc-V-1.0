import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

/// Wireframe F3: Lease Signing Status Timeline
class SigningStatusScreen extends StatefulWidget {
  final int leaseId;
  const SigningStatusScreen({super.key, required this.leaseId});

  @override
  State<SigningStatusScreen> createState() => _SigningStatusScreenState();
}

class _SigningStatusScreenState extends State<SigningStatusScreen> {
  Map<String, dynamic>? _lease;
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try { _lease = await ApiService.get('/leases/${widget.leaseId}'); } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load signing status'), backgroundColor: Colors.red));
    }
    if (mounted) setState(() => _loading = false);
  }

  int get _progress {
    return switch (_lease?['status']) {
      'DRAFT' => 1,
      'SENT_FOR_SIGNING' => 2,
      'LANDLORD_SIGNED' => 3,
      'TENANT_SIGNED' => 3,
      'FULLY_EXECUTED' => 5,
      _ => 0,
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return Scaffold(appBar: AppBar(), body: const Center(child: CircularProgressIndicator()));
    if (_lease == null) return Scaffold(appBar: AppBar(), body: const Center(child: Text('Lease not found')));

    final l = _lease!;
    final sigs = (l['signatures'] as List<dynamic>?) ?? [];
    final landlordSigned = sigs.any((s) => s['signerRole'] == 'LANDLORD' && s['signed'] == true);
    final tenantSigned = sigs.any((s) => s['signerRole'] == 'TENANT' && s['signed'] == true);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Signing Status'),
        actions: [PopupMenuButton(itemBuilder: (_) => [
          const PopupMenuItem(child: Text('Refresh')),
        ], onSelected: (_) => _load())],
      ),
      body: RefreshIndicator(onRefresh: _load,
        child: ListView(padding: const EdgeInsets.all(20), children: [
          // Property header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(12)),
            child: Row(children: [
              Container(width: 48, height: 48,
                decoration: BoxDecoration(color: AppColors.primary.withAlpha(15), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.apartment, color: AppColors.primary)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(l['propertyName'] ?? '', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                Text('${l['unitName']}', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              ])),
            ]),
          ),
          const SizedBox(height: 16),
          // Progress bar
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Overall Progress', style: TextStyle(fontWeight: FontWeight.w600)),
            Text('$_progress of 5 Steps Complete', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          ]),
          const SizedBox(height: 8),
          ClipRRect(borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(value: _progress / 5, minHeight: 6,
              backgroundColor: AppColors.border, valueColor: const AlwaysStoppedAnimation(AppColors.primary))),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: AppColors.primary.withAlpha(10), borderRadius: BorderRadius.circular(6)),
            child: Text(_statusMessage(l['status']),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
          ),
          const SizedBox(height: 24),
          // Timeline
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('TIMELINE TRACKING', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
              color: AppColors.textSecondary, letterSpacing: 0.5)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: AppColors.success.withAlpha(15), borderRadius: BorderRadius.circular(6)),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.circle, size: 8, color: AppColors.success),
                SizedBox(width: 4),
                Text('Real-time', style: TextStyle(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.w600)),
              ]),
            ),
          ]),
          const SizedBox(height: 16),
          _TimelineItem(
            title: 'Lease Drafted',
            subtitle: 'Prepared by ${l['landlordName']}',
            done: _progress >= 1,
            current: _progress == 1,
          ),
          _TimelineItem(
            title: 'Sent for Signature',
            subtitle: 'Email sent to ${l['tenantName']}',
            done: _progress >= 2,
            current: _progress == 2,
          ),
          _TimelineItem(
            title: 'Landlord Signed',
            subtitle: landlordSigned ? 'Signed by ${l['landlordName']}' : 'Waiting for landlord',
            done: landlordSigned,
            current: !landlordSigned && _progress >= 2,
            action: !landlordSigned && _progress >= 2 ? 'Send Reminder' : null,
          ),
          _TimelineItem(
            title: 'Tenant Signature Required',
            subtitle: tenantSigned ? 'Signed by ${l['tenantName']}' : 'Waiting for ${l['tenantName']}',
            done: tenantSigned,
            current: !tenantSigned && landlordSigned,
            action: !tenantSigned && _progress >= 2 ? 'Send Reminder' : null,
          ),
          _TimelineItem(
            title: 'Fully Executed',
            subtitle: 'Lease active & finalized',
            done: l['status'] == 'FULLY_EXECUTED',
            current: false,
            isLast: true,
          ),
          const SizedBox(height: 24),
          // Document card
          const Text('CURRENT DOCUMENT', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
            color: AppColors.textSecondary, letterSpacing: 0.5)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(12)),
            child: Row(children: [
              const Icon(Icons.description, color: AppColors.primary, size: 32),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Lease_Agreement_${l['unitName']}.pdf',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const Text('PDF DOCUMENT', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ])),
              TextButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('PDF download available after signing is complete'))), child: const Text('Download')),
              TextButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('PDF preview available after signing is complete'))), child: const Text('View')),
            ]),
          ),
        ])),
    );
  }

  String _statusMessage(String? status) => switch (status) {
    'DRAFT' => 'Lease is in draft mode',
    'SENT_FOR_SIGNING' => 'Awaiting signatures',
    'LANDLORD_SIGNED' => 'Awaiting tenant signature',
    'TENANT_SIGNED' => 'Awaiting landlord signature',
    'FULLY_EXECUTED' => 'Lease fully executed',
    _ => status ?? 'Unknown',
  };
}

class _TimelineItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool done;
  final bool current;
  final String? action;
  final bool isLast;

  const _TimelineItem({
    required this.title, required this.subtitle,
    required this.done, required this.current,
    this.action, this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Timeline line + dot
      SizedBox(width: 32, child: Column(children: [
        Container(width: 24, height: 24,
          decoration: BoxDecoration(shape: BoxShape.circle,
            color: done ? AppColors.success : current ? AppColors.primary : AppColors.border),
          child: Icon(done ? Icons.check : current ? Icons.radio_button_checked : Icons.circle,
            size: 14, color: done || current ? Colors.white : AppColors.textSecondary)),
        if (!isLast) Expanded(child: Container(width: 2,
          color: done ? AppColors.success.withAlpha(50) : AppColors.border)),
      ])),
      const SizedBox(width: 12),
      Expanded(child: Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15,
            color: done || current ? AppColors.textDark : AppColors.textSecondary)),
          const SizedBox(height: 2),
          Text(subtitle, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          if (action != null) ...[
            const SizedBox(height: 6),
            OutlinedButton.icon(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Reminder sent to signer'))),
              icon: const Icon(Icons.send, size: 14),
              label: Text(action!, style: const TextStyle(fontSize: 12)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                minimumSize: Size.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ]),
      )),
    ]));
  }
}
