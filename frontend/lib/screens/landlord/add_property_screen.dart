import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

/// Wireframes C4 (Step 1), C5 (Step 2), C6 (Step 3), C9 (Success)
class AddPropertyScreen extends StatefulWidget {
  final VoidCallback onCreated;
  const AddPropertyScreen({super.key, required this.onCreated});

  @override
  State<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends State<AddPropertyScreen> {
  int _step = 1;
  bool _saving = false;

  // Step 1 fields
  final _nameC = TextEditingController();
  final _addressC = TextEditingController();
  final _cityC = TextEditingController();
  final _stateC = TextEditingController();
  final _zipC = TextEditingController();
  final _descC = TextEditingController();
  String _type = 'RESIDENTIAL';

  // Step 2 fields
  final _unitsC = TextEditingController(text: '1');
  final _floorsC = TextEditingController(text: '1');
  bool _parking = false;
  bool _storage = false;
  bool _amenity = false;

  // Result
  Map<String, dynamic>? _created;

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameC.dispose(); _addressC.dispose(); _cityC.dispose();
    _stateC.dispose(); _zipC.dispose(); _descC.dispose();
    _unitsC.dispose(); _floorsC.dispose();
    super.dispose();
  }

  void _next() {
    if (_step == 1) {
      if (!_formKey.currentState!.validate()) return;
      setState(() => _step = 2);
    } else if (_step == 2) {
      setState(() => _step = 3);
    }
  }

  void _back() {
    if (_step > 1) setState(() => _step--);
    else Navigator.pop(context);
  }

  Future<void> _create() async {
    setState(() => _saving = true);
    try {
      final result = await ApiService.post('/properties', body: {
        'name': _nameC.text.trim(),
        'propertyType': _type,
        'address': _addressC.text.trim(),
        'city': _cityC.text.trim(),
        'state': _stateC.text.trim(),
        'postalCode': _zipC.text.trim(),
        'description': _descC.text.trim(),
        'initialUnitCount': int.tryParse(_unitsC.text) ?? 0,
      });
      widget.onCreated();
      if (mounted) setState(() { _created = result; _step = 4; });
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error));
    }
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _step < 4 ? AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: _back),
        title: Text(_step == 3 ? 'Review & Save' : 'Add Property'),
        actions: [
          if (_step == 3) IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
        ],
      ) : null,
      body: SafeArea(child: switch (_step) {
        1 => _buildStep1(),
        2 => _buildStep2(),
        3 => _buildStep3(),
        4 => _buildSuccess(),
        _ => _buildStep1(),
      }),
    );
  }

  /// C4: Basic Info
  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Progress
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('STEP 1 OF 3', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
            const Text('33% Complete', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ]),
          const SizedBox(height: 4),
          ClipRRect(borderRadius: BorderRadius.circular(4),
            child: const LinearProgressIndicator(value: 0.33, minHeight: 4,
              backgroundColor: AppColors.border, valueColor: AlwaysStoppedAnimation(AppColors.primary))),
          const SizedBox(height: 20),
          const Text('Basic Information', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: 20),
          // Identity section
          _SectionLabel(Icons.apartment, 'IDENTITY'),
          const SizedBox(height: 12),
          const Text('Property Name', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          TextFormField(controller: _nameC, decoration: const InputDecoration(hintText: 'e.g. Sunset Heights Apartments'),
            validator: (v) => v?.isEmpty ?? true ? 'Required' : null),
          const SizedBox(height: 6),
          const Text('A unique name to identify this property in your dashboard.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          const Text('Property Type', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Row(children: [
            _TypeBtn(Icons.home, 'Residential', _type == 'RESIDENTIAL', () => setState(() => _type = 'RESIDENTIAL')),
            const SizedBox(width: 8),
            _TypeBtn(Icons.store, 'Commercial', _type == 'COMMERCIAL', () => setState(() => _type = 'COMMERCIAL')),
            const SizedBox(width: 8),
            _TypeBtn(Icons.warehouse, 'Industrial', _type == 'OTHER', () => setState(() => _type = 'OTHER')),
            const SizedBox(width: 8),
            _TypeBtn(Icons.add, 'Other', _type == 'OTHER', () => setState(() => _type = 'OTHER')),
          ]),
          const SizedBox(height: 24),
          // Location section
          _SectionLabel(Icons.location_on_outlined, 'LOCATION'),
          const SizedBox(height: 12),
          const Text('Street Address', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          TextFormField(controller: _addressC, validator: (v) => v?.isEmpty ?? true ? 'Required' : null),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('City', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              const SizedBox(height: 6),
              TextFormField(controller: _cityC, validator: (v) => v?.isEmpty ?? true ? 'Required' : null),
            ])),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('State', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              const SizedBox(height: 6),
              TextFormField(controller: _stateC, validator: (v) => v?.isEmpty ?? true ? 'Required' : null),
            ])),
          ]),
          const SizedBox(height: 16),
          const Text('Zip Code', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          TextFormField(controller: _zipC, keyboardType: TextInputType.number,
            validator: (v) => v?.isEmpty ?? true ? 'Required' : null),
          const SizedBox(height: 24),
          _SectionLabel(Icons.info_outline, 'NARRATIVE'),
          const SizedBox(height: 12),
          const Text('Description (Optional)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          TextFormField(controller: _descC, maxLines: 3,
            decoration: const InputDecoration(hintText: 'Describe key features, amenities, or special notes...')),
          const SizedBox(height: 28),
          ElevatedButton(onPressed: _next,
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
            child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('Next: Property Structure'), SizedBox(width: 8), Icon(Icons.arrow_forward, size: 20)])),
          const SizedBox(height: 8),
          const Center(child: Text('Your progress is automatically saved as you go.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary))),
        ]),
      ),
    );
  }

  /// C5: Structure Setup
  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Step 2: Define Structure', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
          const Text('66% Complete', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ]),
        const SizedBox(height: 4),
        ClipRRect(borderRadius: BorderRadius.circular(4),
          child: const LinearProgressIndicator(value: 0.66, minHeight: 4,
            backgroundColor: AppColors.border, valueColor: AlwaysStoppedAnimation(AppColors.primary))),
        const SizedBox(height: 16),
        // Property selection summary
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(12)),
          child: Row(children: [
            const Text('PROPERTY SELECTION', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
              color: AppColors.textSecondary, letterSpacing: 0.3)),
            const Spacer(),
            Text(_nameC.text, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            TextButton(onPressed: _back, child: const Text('Change')),
          ]),
        ),
        const SizedBox(height: 24),
        const Text('How is it divided?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
        const SizedBox(height: 16),
        const Text('Division Details', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        const Text('Specify how your property is partitioned for leasing.',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: _StepperField('Total Units', _unitsC)),
          const SizedBox(width: 16),
          Expanded(child: _StepperField('Total Floors', _floorsC)),
        ]),
        const SizedBox(height: 24),
        const Text('Common Features', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        _FeatureToggle('Designated Parking Spaces', _parking, (v) => setState(() => _parking = v)),
        _FeatureToggle('Extra Storage Units', _storage, (v) => setState(() => _storage = v)),
        _FeatureToggle('Shared Amenity Areas', _amenity, (v) => setState(() => _amenity = v)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: AppColors.primary.withAlpha(8), borderRadius: BorderRadius.circular(12)),
          child: const Row(children: [
            Icon(Icons.info_outline, color: AppColors.primary, size: 18),
            SizedBox(width: 10),
            Expanded(child: Text(
              'Defining the structure accurately helps AYRNOW automatically generate rent ledgers and unit identifiers in the next step.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4))),
          ]),
        ),
        const SizedBox(height: 24),
        ElevatedButton(onPressed: _next,
          style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
          child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('Review Property'), SizedBox(width: 8), Icon(Icons.arrow_forward, size: 20)])),
        const SizedBox(height: 8),
        Center(child: TextButton(onPressed: _back, child: const Text('Back to Basic Info'))),
      ]),
    );
  }

  /// C6: Review & Save
  Widget _buildStep3() {
    final unitCount = int.tryParse(_unitsC.text) ?? 0;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Step 3 of 3', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
        ]),
        const SizedBox(height: 4),
        ClipRRect(borderRadius: BorderRadius.circular(4),
          child: const LinearProgressIndicator(value: 1.0, minHeight: 4,
            backgroundColor: AppColors.border, valueColor: AlwaysStoppedAnimation(AppColors.primary))),
        const SizedBox(height: 16),
        // Property image placeholder
        Container(
          height: 160, width: double.infinity,
          decoration: BoxDecoration(color: AppColors.primary.withAlpha(10), borderRadius: BorderRadius.circular(16)),
          child: Stack(children: [
            const Center(child: Icon(Icons.apartment, size: 56, color: AppColors.primary)),
            Positioned(top: 12, left: 12, child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
              child: const Text('Ready to Publish', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
            )),
          ]),
        ),
        const SizedBox(height: 16),
        Text(_nameC.text, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
        if (_descC.text.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(_descC.text, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
        ],
        const SizedBox(height: 20),
        _ReviewSection(Icons.location_on_outlined, 'Location Details', [
          _ReviewItem('Property Type', _type == 'RESIDENTIAL' ? 'Residential' : _type == 'COMMERCIAL' ? 'Commercial' : 'Other'),
          _ReviewItem('Full Address', '${_addressC.text}, ${_cityC.text}, ${_stateC.text} ${_zipC.text}'),
        ]),
        const SizedBox(height: 16),
        _ReviewSection(Icons.apartment, 'Unit Composition', [
          _ReviewItem('Total Units', '$unitCount'),
          _ReviewItem('Total Floors', _floorsC.text),
        ]),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _saving ? null : _create,
          style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
          child: _saving
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Text('Save & Create Property'),
        ),
        const SizedBox(height: 8),
        Center(child: TextButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Draft saving coming soon'))), child: const Text('Save as Draft'))),
      ]),
    );
  }

  /// C9: Property Created Success
  Widget _buildSuccess() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(color: AppColors.success.withAlpha(20), shape: BoxShape.circle),
            child: const Icon(Icons.check_circle, color: AppColors.success, size: 48),
          ),
          const SizedBox(height: 20),
          const Text('Property Created!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text('"${_created?['name']}" has been successfully added to your portfolio.',
            textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, color: AppColors.textSecondary)),
          const SizedBox(height: 24),
          // Summary card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: AppColors.primary, width: 3)),
              color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(12)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('NEWLY REGISTERED', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                color: AppColors.textSecondary, letterSpacing: 0.5)),
              const SizedBox(height: 8),
              Text(_created?['name'] ?? '', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Row(children: [
                const Icon(Icons.location_on, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text('${_created?['address']}, ${_created?['city']}, ${_created?['state']} ${_created?['postalCode']}',
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                _Tag(_created?['propertyType'] ?? ''),
                const SizedBox(width: 8),
                _Tag('${_created?['totalUnits'] ?? 0} Units Total'),
              ]),
            ]),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('View Property'), SizedBox(width: 8), Icon(Icons.arrow_forward, size: 20)]),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Navigate to your dashboard to invite tenants"))),
            icon: const Icon(Icons.person_add, size: 18),
            label: const Text('Invite Your First Tenant'),
            style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          ),
          const SizedBox(height: 12),
          TextButton(onPressed: () { setState(() { _step = 1; _nameC.clear(); _addressC.clear();
            _cityC.clear(); _stateC.clear(); _zipC.clear(); _descC.clear(); }); },
            child: const Text('+ Add Another Property')),
        ]),
      ),
    );
  }
}

class _TypeBtn extends StatelessWidget {
  final IconData icon; final String label; final bool selected; final VoidCallback onTap;
  const _TypeBtn(this.icon, this.label, this.selected, this.onTap);

  @override
  Widget build(BuildContext context) {
    return Expanded(child: GestureDetector(onTap: onTap, child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: selected ? AppColors.primary : AppColors.border, width: selected ? 2 : 1),
        color: selected ? AppColors.primary.withAlpha(8) : Colors.white,
      ),
      child: Column(children: [
        Icon(icon, color: selected ? AppColors.primary : AppColors.textSecondary, size: 24),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500,
          color: selected ? AppColors.primary : AppColors.textSecondary)),
      ]),
    )));
  }
}

class _SectionLabel extends StatelessWidget {
  final IconData icon; final String label;
  const _SectionLabel(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 18, color: AppColors.textDark),
      const SizedBox(width: 8),
      Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 0.3)),
    ]);
  }
}

class _StepperField extends StatelessWidget {
  final String label; final TextEditingController controller;
  const _StepperField(this.label, this.controller);

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      const SizedBox(height: 6),
      Row(children: [
        IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: () {
          final v = int.tryParse(controller.text) ?? 0;
          if (v > 0) controller.text = '${v - 1}';
        }),
        Expanded(child: TextField(controller: controller, textAlign: TextAlign.center,
          keyboardType: TextInputType.number)),
        IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: () {
          final v = int.tryParse(controller.text) ?? 0;
          controller.text = '${v + 1}';
        }),
      ]),
    ]);
  }
}

class _FeatureToggle extends StatelessWidget {
  final String label; final bool value; final ValueChanged<bool> onChanged;
  const _FeatureToggle(this.label, this.value, this.onChanged);

  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        const Icon(Icons.check_circle_outline, size: 18, color: AppColors.success),
        const SizedBox(width: 10),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
        Switch(value: value, onChanged: onChanged, activeColor: AppColors.primary),
      ]));
  }
}

class _ReviewSection extends StatelessWidget {
  final IconData icon; final String title; final List<_ReviewItem> items;
  const _ReviewSection(this.icon, this.title, this.items);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 12),
        ...items.map((i) => Padding(padding: const EdgeInsets.only(bottom: 8),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(i.label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            Text(i.value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          ]))),
      ]),
    );
  }
}

class _ReviewItem {
  final String label; final String value;
  const _ReviewItem(this.label, this.value);
}

class _Tag extends StatelessWidget {
  final String label;
  const _Tag(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: AppColors.primary.withAlpha(15), borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.primary)),
    );
  }
}
