import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

/// Wireframe C8: Edit Unit with identity, rent, utilities, notes
class EditUnitScreen extends StatefulWidget {
  final int propertyId;
  final Map<String, dynamic>? unit; // null = create mode
  final VoidCallback onSaved;

  const EditUnitScreen({super.key, required this.propertyId, this.unit, required this.onSaved});

  @override
  State<EditUnitScreen> createState() => _EditUnitScreenState();
}

class _EditUnitScreenState extends State<EditUnitScreen> {
  final _nameC = TextEditingController();
  final _floorC = TextEditingController();
  final _rentC = TextEditingController();
  final _depositC = TextEditingController();
  final _notesC = TextEditingController();
  String _type = 'APARTMENT';
  bool _readyForLeasing = false;
  bool _saving = false;

  // Utilities
  bool _electricity = true;
  bool _water = true;
  bool _internet = false;
  bool _trash = true;
  bool _gas = false;

  bool get _isEdit => widget.unit != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final u = widget.unit!;
      _nameC.text = u['name'] ?? '';
      _floorC.text = u['floor'] ?? '';
      _type = u['unitType'] ?? 'APARTMENT';
      _rentC.text = u['monthlyRent']?.toString() ?? '';
      _depositC.text = '';
    }
  }

  @override
  void dispose() {
    _nameC.dispose(); _floorC.dispose(); _rentC.dispose();
    _depositC.dispose(); _notesC.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameC.text.isEmpty) return;
    setState(() => _saving = true);
    try {
      final body = {
        'name': _nameC.text.trim(),
        'unitType': _type,
        'floor': _floorC.text.trim(),
        'monthlyRent': double.tryParse(_rentC.text),
        'description': _notesC.text.trim(),
      };
      if (_isEdit) {
        await ApiService.put('/properties/${widget.propertyId}/units/${widget.unit!['id']}', body: body);
      } else {
        await ApiService.post('/properties/${widget.propertyId}/units', body: body);
      }
      widget.onSaved();
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
        title: Text(_isEdit ? 'Edit ${_nameC.text}' : 'Add Unit'),
        actions: [
          IconButton(icon: const Icon(Icons.help_outline), onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter unit details to manage this space')))),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Unit Identity
          _Section(Icons.lock_outline, 'Unit Identity',
            'Specify how this unit is identified in the property.'),
          const SizedBox(height: 12),
          const Text('Unit Name / Number', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          TextField(controller: _nameC, decoration: const InputDecoration(hintText: '101')),
          const SizedBox(height: 16),
          const Text('Floor Level', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          TextField(controller: _floorC, decoration: const InputDecoration(hintText: '1'),
            keyboardType: TextInputType.number),
          const SizedBox(height: 16),
          const Text('Unit Type', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: _type,
            items: ['APARTMENT','FLAT','ROOM','UNIT','STORE','OFFICE','SHOP','WAREHOUSE','LAND_BLOCK','LOT','OTHER']
              .map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
            onChanged: (v) => setState(() => _type = v!),
            decoration: const InputDecoration(),
          ),
          const SizedBox(height: 24),

          // Rent & Deposit
          _Section(Icons.attach_money, 'Rent & Deposit',
            'Monthly pricing and security requirements.'),
          const SizedBox(height: 12),
          const Text('Monthly Rent Amount', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          TextField(controller: _rentC, keyboardType: TextInputType.number,
            decoration: const InputDecoration(prefixText: '\$ ')),
          const SizedBox(height: 16),
          const Text('Security Deposit', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          TextField(controller: _depositC, keyboardType: TextInputType.number,
            decoration: const InputDecoration(prefixText: '\$ ')),
          const SizedBox(height: 24),

          // Utility Inclusions
          const Text('Utility Inclusions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          const Text('Select utilities that are included in the base rent.',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: [
            _UtilityChip('Electricity', _electricity, (v) => setState(() => _electricity = v)),
            _UtilityChip('Water', _water, (v) => setState(() => _water = v)),
            _UtilityChip('Internet', _internet, (v) => setState(() => _internet = v)),
            _UtilityChip('Trash', _trash, (v) => setState(() => _trash = v)),
            _UtilityChip('Gas/Heating', _gas, (v) => setState(() => _gas = v)),
          ]),
          const SizedBox(height: 24),

          // Internal Notes
          const Text('Internal Notes', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          TextField(controller: _notesC, maxLines: 4,
            decoration: const InputDecoration(hintText: 'Private notes about this unit...')),
          const SizedBox(height: 16),

          // Ready checkbox
          Row(children: [
            Checkbox(value: _readyForLeasing, onChanged: (v) => setState(() => _readyForLeasing = v!),
              activeColor: AppColors.primary),
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Mark as ready for leasing', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              Text('This will make the unit available for new lease creation.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ])),
          ]),
          const SizedBox(height: 24),

          // Save button
          SizedBox(
            width: double.infinity, height: 52,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.textDark,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: _saving
                ? const SizedBox(height: 20, width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Save Unit Details'),
            ),
          ),
          const SizedBox(height: 8),
          const Center(child: Text('All changes are synced with your property dashboard instantly.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary))),
        ]),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final IconData icon; final String title; final String subtitle;
  const _Section(this.icon, this.title, this.subtitle);

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(icon, size: 18, color: AppColors.textDark),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ]),
      const SizedBox(height: 4),
      Text(subtitle, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
    ]);
  }
}

class _UtilityChip extends StatelessWidget {
  final String label; final bool included; final ValueChanged<bool> onChanged;
  const _UtilityChip(this.label, this.included, this.onChanged);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!included),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: included ? AppColors.teal.withAlpha(15) : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: included ? AppColors.teal : AppColors.border),
        ),
        child: Column(children: [
          Icon(included ? Icons.check_circle : Icons.radio_button_unchecked,
            color: included ? AppColors.teal : AppColors.textSecondary, size: 18),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500,
            color: included ? AppColors.teal : AppColors.textSecondary)),
          Text(included ? 'INCLUDED' : 'EXCLUDED', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600,
            color: included ? AppColors.teal : AppColors.textSecondary, letterSpacing: 0.3)),
        ]),
      ),
    );
  }
}
