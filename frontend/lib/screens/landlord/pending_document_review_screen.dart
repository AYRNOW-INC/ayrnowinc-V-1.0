import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../shared/notifications_screen.dart';

/// Wireframe I2: Pending Documents Review (landlord)
class PendingDocumentReviewScreen extends StatefulWidget {
  const PendingDocumentReviewScreen({super.key});
  @override
  State<PendingDocumentReviewScreen> createState() => _PendingDocumentReviewScreenState();
}

class _PendingDocumentReviewScreenState extends State<PendingDocumentReviewScreen> {
  List<dynamic> _leases = [];
  List<dynamic> _allDocs = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _leases = await ApiService.getList('/leases/landlord');
      _allDocs = [];
      for (var l in _leases) {
        final docs = await ApiService.getList('/documents/lease/${l['id']}');
        for (var d in docs) { _allDocs.add({...d as Map<String, dynamic>, 'leaseTenantName': l['tenantName'], 'leaseUnitName': l['unitName']}); }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load pending documents'), backgroundColor: Colors.red));
    }
    if (mounted) setState(() => _loading = false);
  }

  List<dynamic> get _pending => _allDocs.where((d) =>
    d['status'] == 'UPLOADED' || d['status'] == 'UNDER_REVIEW').toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pending Reviews'),
        actions: [IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())))]),
      body: _loading ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(onRefresh: _load, child: _pending.isEmpty
          ? ListView(children: const [SizedBox(height: 100),
              Center(child: Column(children: [
                Icon(Icons.check_circle_outline, size: 56, color: AppColors.success),
                SizedBox(height: 12),
                Text('All documents reviewed', style: TextStyle(fontSize: 18, color: AppColors.textSecondary)),
              ]))])
          : ListView(padding: const EdgeInsets.all(16), children: [
              // Header
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(12)),
                child: Row(children: [
                  const Icon(Icons.folder_open, color: AppColors.primary),
                  const SizedBox(width: 10),
                  const Text('TOTAL PENDING', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary, letterSpacing: 0.5)),
                  const Spacer(),
                  Text('${_pending.length} Documents', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                ]),
              ),
              const SizedBox(height: 16),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('AWAITING APPROVAL', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary, letterSpacing: 0.5)),
                IconButton(icon: const Icon(Icons.filter_list, size: 20), onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Filter options coming soon')))),
              ]),
              ..._pending.map((d) => _DocCard(doc: d, onApprove: () => _review(d['id'], 'APPROVED'),
                onRequestChanges: () => _review(d['id'], 'REJECTED'))),
            ])),
    );
  }

  Future<void> _review(int docId, String status) async {
    try {
      await ApiService.put('/documents/$docId/review', body: {'status': status, 'comment': status == 'REJECTED' ? 'Please resubmit' : null});
      _load();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error));
    }
  }
}

class _DocCard extends StatelessWidget {
  final Map<String, dynamic> doc;
  final VoidCallback onApprove;
  final VoidCallback onRequestChanges;
  const _DocCard({required this.doc, required this.onApprove, required this.onRequestChanges});

  @override
  Widget build(BuildContext context) {
    return Card(margin: const EdgeInsets.only(bottom: 16), child: Padding(
      padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Tenant info
        Row(children: [
          CircleAvatar(radius: 20, backgroundColor: AppColors.primary.withAlpha(20),
            child: Text((doc['leaseTenantName'] ?? 'T')[0],
              style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(doc['leaseTenantName'] ?? 'Tenant', style: const TextStyle(fontWeight: FontWeight.w600)),
            Text(doc['leaseUnitName'] ?? '', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: AppColors.warning.withAlpha(15), borderRadius: BorderRadius.circular(6)),
            child: Text(doc['status'] == 'UPLOADED' ? 'Awaiting Review' : 'Under Review',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.warning)),
          ),
        ]),
        const SizedBox(height: 12),
        // Document type
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(color: AppColors.primary.withAlpha(10), borderRadius: BorderRadius.circular(6)),
          child: Text(doc['documentType'] ?? '', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary)),
        ),
        const SizedBox(height: 8),
        // File preview placeholder
        Container(
          height: 100, width: double.infinity,
          decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(8)),
          child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.insert_drive_file, color: AppColors.textSecondary, size: 32),
            Text(doc['fileName'] ?? 'Document', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ])),
        ),
        const SizedBox(height: 6),
        Text('Uploaded ${doc['createdAt']?.toString().substring(0, 10) ?? ''}',
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 12),
        // Actions
        Row(children: [
          Expanded(child: OutlinedButton(onPressed: onRequestChanges,
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.warning,
              side: const BorderSide(color: AppColors.warning),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            child: const Text('Request Changes'))),
          const SizedBox(width: 8),
          Expanded(child: ElevatedButton(onPressed: onApprove,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            child: const Text('Approve'))),
        ]),
      ])));
  }
}
