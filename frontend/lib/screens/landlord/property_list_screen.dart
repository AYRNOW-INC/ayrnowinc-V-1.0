import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import 'property_detail_screen.dart';
import 'add_property_screen.dart';
import '../shared/notifications_screen.dart';

/// Wireframes C1 (empty) + C2 (populated)
class PropertyListScreen extends StatefulWidget {
  const PropertyListScreen({super.key});

  @override
  State<PropertyListScreen> createState() => _PropertyListScreenState();
}

class _PropertyListScreenState extends State<PropertyListScreen> {
  List<dynamic> _properties = [];
  bool _loading = true;
  String _filter = 'All';
  final _searchC = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchC.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _properties = await ApiService.getList('/properties');
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  List<dynamic> get _filtered {
    var list = _properties;
    if (_filter != 'All') {
      list = list.where((p) => p['propertyType'] == _filter.toUpperCase()).toList();
    }
    final q = _searchC.text.toLowerCase();
    if (q.isNotEmpty) {
      list = list.where((p) =>
        (p['name'] ?? '').toString().toLowerCase().contains(q) ||
        (p['address'] ?? '').toString().toLowerCase().contains(q)
      ).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Properties'),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()))),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
          ? const Center(child: CircularProgressIndicator())
          : _properties.isEmpty ? _buildEmpty() : _buildPopulated(),
      ),
      floatingActionButton: _properties.isNotEmpty
        ? FloatingActionButton(
            backgroundColor: AppColors.primary,
            onPressed: () => _goAddProperty(),
            child: const Icon(Icons.add, color: Colors.white),
          )
        : null,
    );
  }

  /// C1: Empty state
  Widget _buildEmpty() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 40),
        Center(
          child: Container(
            width: 100, height: 100,
            decoration: BoxDecoration(color: AppColors.primary.withAlpha(15), shape: BoxShape.circle),
            child: Stack(alignment: Alignment.center, children: [
              const Icon(Icons.apartment, size: 48, color: AppColors.primary),
              Positioned(bottom: 16, right: 16, child: Container(
                width: 28, height: 28,
                decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
                child: const Icon(Icons.add, color: Colors.white, size: 18),
              )),
            ]),
          ),
        ),
        const SizedBox(height: 20),
        const Center(child: Text('Start Your Portfolio',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700))),
        const SizedBox(height: 8),
        const Center(child: Text(
          'Add your first property to begin\nmanaging units, leases, and tenant\npayments seamlessly.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15, color: AppColors.textSecondary, height: 1.5),
        )),
        const SizedBox(height: 28),
        _HowItWorks(number: '1', icon: Icons.location_on_outlined,
          title: 'Property Details', subtitle: 'Enter address, type, and basic info for your residential or commercial asset.'),
        const SizedBox(height: 12),
        _HowItWorks(number: '2', icon: Icons.apartment,
          title: 'Define Units', subtitle: 'Set up individual units or spaces with specific rent and utility settings.'),
        const SizedBox(height: 12),
        _HowItWorks(number: '3', icon: Icons.people_outline,
          title: 'Invite & Lease', subtitle: 'Bring tenants on board, create digital leases, and automate payments.'),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _goAddProperty,
          style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.add, size: 20), SizedBox(width: 8), Text('Add First Property'),
          ]),
        ),
        const SizedBox(height: 16),
        Center(child: TextButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Your data is encrypted and securely stored'))),
          child: const Text('Learn how AYRNOW protects your data >',
            style: TextStyle(color: AppColors.primary, fontSize: 13)))),
      ],
    );
  }

  /// C2: Populated list
  Widget _buildPopulated() {
    final filtered = _filtered;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Search bar
        TextField(
          controller: _searchC,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'Search by name or address...',
            prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
            filled: true, fillColor: AppColors.surfaceLight,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
        const SizedBox(height: 12),
        // Filter tabs
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: ['All', 'Residential', 'Commercial', 'Other'].map((f) =>
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(f),
                selected: _filter == f,
                onSelected: (_) => setState(() => _filter = f),
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: _filter == f ? Colors.white : AppColors.textSecondary,
                  fontWeight: FontWeight.w500, fontSize: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                side: BorderSide(color: _filter == f ? AppColors.primary : AppColors.border),
              ),
            ),
          ).toList()),
        ),
        const SizedBox(height: 12),
        // Count + sort
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${filtered.length} PROPERTIES FOUND',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                color: AppColors.textSecondary, letterSpacing: 0.3)),
            TextButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sort options coming soon'))), child: const Text('Sort by: Recent',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary))),
          ],
        ),
        const SizedBox(height: 8),
        // Property cards
        ...filtered.map((p) => _PropertyCard(
          property: p,
          onTap: () => Navigator.push(context, MaterialPageRoute(
            builder: (_) => PropertyDetailScreen(propertyId: p['id'], onChanged: _load))),
          onView: () => Navigator.push(context, MaterialPageRoute(
            builder: (_) => PropertyDetailScreen(propertyId: p['id'], onChanged: _load))),
          onEdit: () => Navigator.push(context, MaterialPageRoute(
            builder: (_) => PropertyDetailScreen(propertyId: p['id'] as int, onChanged: _load))),
          onLease: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Navigate to Leases tab to create a lease for this property'))),
        )),
      ],
    );
  }

  void _goAddProperty() {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => AddPropertyScreen(onCreated: _load),
    ));
  }
}

class _PropertyCard extends StatelessWidget {
  final Map<String, dynamic> property;
  final VoidCallback onTap;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onLease;

  const _PropertyCard({required this.property, required this.onTap,
    required this.onView, required this.onEdit, required this.onLease});

  int get _occupancy {
    final total = property['totalUnits'] ?? 0;
    final occ = property['occupiedUnits'] ?? 0;
    return total > 0 ? (occ * 100 ~/ total) : 0;
  }

  Color get _occColor => _occupancy >= 90 ? AppColors.success : _occupancy >= 50 ? AppColors.warning : AppColors.error;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder with occupancy badge
            Stack(children: [
              Container(
                height: 160, width: double.infinity,
                color: AppColors.primary.withAlpha(15),
                child: const Center(child: Icon(Icons.apartment, size: 56, color: AppColors.primary)),
              ),
              Positioned(top: 12, left: 12, child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: _occColor, borderRadius: BorderRadius.circular(20)),
                child: Text('$_occupancy% Occupied',
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
              )),
            ]),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(child: Text(property['name'] ?? '',
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700))),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(6)),
                      child: Text(property['propertyType'] ?? '',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
                    ),
                  ]),
                  const SizedBox(height: 6),
                  Row(children: [
                    const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Expanded(child: Text(
                      '${property['address']}, ${property['city']}, ${property['state']}',
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      overflow: TextOverflow.ellipsis)),
                  ]),
                  const SizedBox(height: 12),
                  Row(children: [
                    _InfoChip(Icons.apartment, '${property['totalUnits']} Total Units'),
                    const SizedBox(width: 12),
                    _InfoChip(Icons.people, '$_occupancy%'),
                  ]),
                  const SizedBox(height: 12),
                  // Action buttons row
                  Row(children: [
                    _ActionBtn('VIEW', Icons.visibility_outlined, onView),
                    const SizedBox(width: 8),
                    _ActionBtn('EDIT', Icons.edit_outlined, onEdit),
                    const SizedBox(width: 8),
                    _ActionBtn('LEASE', Icons.description_outlined, onLease),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 14, color: AppColors.textSecondary),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
    ]);
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _ActionBtn(this.label, this.icon, this.onTap);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 14),
        label: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 8),
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          foregroundColor: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _HowItWorks extends StatelessWidget {
  final String number;
  final IconData icon;
  final String title;
  final String subtitle;
  const _HowItWorks({required this.number, required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5)),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: AppColors.primary.withAlpha(15), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: AppColors.primary, size: 18),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(subtitle, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.3)),
        ])),
      ]),
    );
  }
}
