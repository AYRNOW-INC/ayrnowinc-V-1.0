import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

/// Wireframe I1: Document Upload/Status with progress
class DocumentScreen extends StatefulWidget {
  const DocumentScreen({super.key});
  @override
  State<DocumentScreen> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends State<DocumentScreen> {
  List<dynamic> _documents = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try { _documents = await ApiService.getList('/documents/tenant'); } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load documents'), backgroundColor: Colors.red));
    }
    if (mounted) setState(() => _loading = false);
  }

  int get _verified => _documents.where((d) => d['status'] == 'APPROVED').length;
  int get _total => 4; // Required: ID, Income, Insurance, Background

  Color _statusColor(String s) => switch (s) {
    'APPROVED' => AppColors.success,
    'REJECTED' => AppColors.error,
    'UNDER_REVIEW' => AppColors.warning,
    'MISSING' => AppColors.error,
    _ => AppColors.primary,
  };

  IconData _typeIcon(String t) => switch (t) {
    'ID' => Icons.badge,
    'PROOF_OF_INCOME' => Icons.receipt_long,
    'BACKGROUND_CHECK' => Icons.verified_user,
    _ => Icons.insert_drive_file,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(padding: const EdgeInsets.only(left: 16), child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset('assets/logo.png', width: 32, height: 32))),
        title: const Text('My Documents'),
      ),
      body: RefreshIndicator(onRefresh: _load,
        child: _loading ? const Center(child: CircularProgressIndicator())
          : ListView(padding: const EdgeInsets.all(20), children: [
              // Progress card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.primary.withAlpha(8), borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withAlpha(30))),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    const Icon(Icons.info_outline, color: AppColors.primary, size: 18),
                    const SizedBox(width: 8),
                    const Text('SUBMISSION PROGRESS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                      color: AppColors.primary, letterSpacing: 0.5)),
                  ]),
                  const SizedBox(height: 8),
                  Text('$_verified of $_total Verified documents', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(value: _verified / _total, minHeight: 6,
                        backgroundColor: AppColors.border, valueColor: const AlwaysStoppedAnimation(AppColors.success)))),
                    const SizedBox(width: 12),
                    Text('${(_verified * 100 ~/ _total)}% Complete', style: const TextStyle(fontSize: 12, color: AppColors.success, fontWeight: FontWeight.w600)),
                  ]),
                ]),
              ),
              const SizedBox(height: 20),
              const Text('Required Documents', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                color: AppColors.textSecondary, letterSpacing: 0.5)),
              const SizedBox(height: 12),
              // Document type slots
              ...['ID', 'PROOF_OF_INCOME', 'BACKGROUND_CHECK'].map((type) {
                final doc = _documents.cast<Map<String, dynamic>?>().firstWhere(
                  (d) => d?['documentType'] == type, orElse: () => null);
                final status = doc?['status'] ?? 'MISSING';
                final label = switch (type) {
                  'ID' => 'Government Issued ID',
                  'PROOF_OF_INCOME' => 'Proof of Income',
                  'BACKGROUND_CHECK' => 'Background Check',
                  _ => type,
                };
                final desc = switch (type) {
                  'ID' => "Driver's license, Passport, or State ID card.",
                  'PROOF_OF_INCOME' => 'Last 3 months of paystubs or tax returns.',
                  'BACKGROUND_CHECK' => 'Background clearance document.',
                  _ => '',
                };
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border, width: 0.5)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Icon(_typeIcon(type), color: AppColors.primary, size: 22),
                      const SizedBox(width: 10),
                      Expanded(child: Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600))),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: _statusColor(status).withAlpha(15),
                          borderRadius: BorderRadius.circular(6)),
                        child: Text(status, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                          color: _statusColor(status))),
                      ),
                    ]),
                    const SizedBox(height: 6),
                    Text(desc, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    if (doc != null) ...[
                      const SizedBox(height: 6),
                      Text('Last updated: ${doc['createdAt']?.toString().substring(0, 10) ?? ''}',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                    if (status == 'MISSING' || status == 'REJECTED') ...[
                      const SizedBox(height: 10),
                      SizedBox(width: double.infinity, child: ElevatedButton.icon(
                        onPressed: () => _upload(type),
                        icon: const Icon(Icons.upload, size: 16),
                        label: const Text('Upload'),
                        style: ElevatedButton.styleFrom(minimumSize: const Size(0, 38),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                      )),
                    ] else if (status == 'APPROVED' || status == 'UNDER_REVIEW') ...[
                      const SizedBox(height: 6),
                      TextButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Document preview coming soon'))), child: const Text('View >', style: TextStyle(fontSize: 13))),
                    ],
                    if (doc?['reviewComment'] != null) ...[
                      const SizedBox(height: 6),
                      Text('Review: ${doc!['reviewComment']}', style: const TextStyle(fontSize: 12, color: AppColors.warning)),
                    ],
                  ]),
                );
              }),
              const SizedBox(height: 16),
              // Additional docs
              OutlinedButton.icon(
                onPressed: () => _upload('BACKGROUND_CHECK'),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Extra File'),
                style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 44),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              ),
              const SizedBox(height: 20),
              Center(child: TextButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Contact your landlord through the Account tab'))),
                child: const Text('Need help with your documents? Contact Landlord Support',
                  style: TextStyle(fontSize: 13, color: AppColors.primary), textAlign: TextAlign.center))),
            ])),
    );
  }

  Future<void> _upload(String type) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom, allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png']);
    if (result == null || result.files.isEmpty) return;
    try {
      await ApiService.uploadFile('/documents', result.files.first.path!, 'file',
        fields: {'documentType': type});
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Document uploaded'), backgroundColor: AppColors.success));
      _load();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e'), backgroundColor: AppColors.error));
    }
  }
}
