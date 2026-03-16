import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import 'property_detail_screen.dart';
import 'add_property_screen.dart';
import '../shared/notifications_screen.dart';

/// Wireframes C1 (empty) + C2 (populated) — Guided card-based property list
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
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load properties'), backgroundColor: Colors.red));
    }
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
      ],
    );
  }

  /// C2: Populated list with guided property cards
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
        // Count
        Text('${filtered.length} PROPERTIES', style: const TextStyle(
          fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary, letterSpacing: 0.5)),
        const SizedBox(height: 12),
        // Property cards
        ...filtered.map((p) => _GuidedPropertyCard(
          property: p,
          onTap: () => Navigator.push(context, MaterialPageRoute(
            builder: (_) => PropertyDetailScreen(propertyId: p['id'], onChanged: _load))),
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

/// Guided property card with progress indicator and smart next-step CTA
class _GuidedPropertyCard extends StatelessWidget {
  final Map<String, dynamic> property;
  final VoidCallback onTap;

  const _GuidedPropertyCard({required this.property, required this.onTap});

  int get _totalUnits => (property['totalUnits'] ?? 0) as int;
  int get _occupiedUnits => (property['occupiedUnits'] ?? 0) as int;
  int get _vacantUnits => _totalUnits - _occupiedUnits;
  int get _occupancy => _totalUnits > 0 ? (_occupiedUnits * 100 ~/ _totalUnits) : 0;

  // Determine property-level workflow step
  _PropertyStep get _step {
    if (_totalUnits == 0) return _PropertyStep.addUnits;
    if (_vacantUnits > 0 && _occupiedUnits == 0) return _PropertyStep.inviteTenants;
    if (_vacantUnits > 0) return _PropertyStep.partiallyOccupied;
    return _PropertyStep.fullyOccupied;
  }

  @override
  Widget build(BuildContext context) {
    final step = _step;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with property type icon and status
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [step.color.withAlpha(15), step.color.withAlpha(5)],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  // Property type icon
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 8)],
                    ),
                    child: Icon(_propertyIcon, color: AppColors.primary, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Expanded(child: Text(property['name'] ?? '', style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textDark))),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: step.color.withAlpha(20),
                            borderRadius: BorderRadius.circular(6)),
                          child: Text(step.badge, style: TextStyle(
                            fontSize: 10, fontWeight: FontWeight.w700, color: step.color)),
                        ),
                      ]),
                      const SizedBox(height: 4),
                      Row(children: [
                        const Icon(Icons.location_on_outlined, size: 13, color: AppColors.textSecondary),
                        const SizedBox(width: 3),
                        Expanded(child: Text(
                          '${property['address'] ?? ''}, ${property['city'] ?? ''}',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          overflow: TextOverflow.ellipsis)),
                      ]),
                    ],
                  )),
                ],
              ),
            ),
            // Stats row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(children: [
                _MiniStat(Icons.apartment, '$_totalUnits', 'Units'),
                _MiniStat(Icons.person, '$_occupiedUnits', 'Occupied'),
                _MiniStat(Icons.meeting_room_outlined, '$_vacantUnits', 'Vacant'),
                // Occupancy bar
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('$_occupancy%', style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700,
                      color: _occupancy >= 80 ? AppColors.success : _occupancy >= 40 ? AppColors.warning : AppColors.textSecondary)),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _occupancy / 100,
                        minHeight: 4,
                        backgroundColor: AppColors.border,
                        valueColor: AlwaysStoppedAnimation(
                          _occupancy >= 80 ? AppColors.success : _occupancy >= 40 ? AppColors.warning : AppColors.textSecondary),
                      ),
                    ),
                  ],
                )),
              ]),
            ),
            // Next step guidance + primary CTA
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(children: [
                // Next step hint
                Expanded(child: Row(children: [
                  Icon(step.icon, size: 16, color: step.color),
                  const SizedBox(width: 6),
                  Expanded(child: Text(step.hint, style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w500, color: step.color))),
                ])),
                // Primary CTA
                SizedBox(
                  height: 34,
                  child: ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: step.color,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    child: Text(step.cta, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  IconData get _propertyIcon {
    switch ((property['propertyType'] ?? '').toString().toUpperCase()) {
      case 'RESIDENTIAL': return Icons.home;
      case 'COMMERCIAL': return Icons.store;
      default: return Icons.apartment;
    }
  }
}

enum _PropertyStep {
  addUnits(
    badge: 'SETUP',
    hint: 'Add units to get started',
    cta: 'Add Units',
    icon: Icons.add_circle_outline,
    color: AppColors.warning,
  ),
  inviteTenants(
    badge: 'READY',
    hint: 'Invite tenants to fill units',
    cta: 'View Units',
    icon: Icons.person_add_outlined,
    color: AppColors.primary,
  ),
  partiallyOccupied(
    badge: 'ACTIVE',
    hint: 'Some units need tenants',
    cta: 'Manage',
    icon: Icons.trending_up,
    color: AppColors.teal,
  ),
  fullyOccupied(
    badge: 'FULL',
    hint: 'All units occupied',
    cta: 'Manage',
    icon: Icons.check_circle_outline,
    color: AppColors.success,
  );

  final String badge;
  final String hint;
  final String cta;
  final IconData icon;
  final Color color;
  const _PropertyStep({required this.badge, required this.hint, required this.cta,
    required this.icon, required this.color});
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _MiniStat(this.icon, this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Column(children: [
        Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 13, color: AppColors.textSecondary),
          const SizedBox(width: 3),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
        ]),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
      ]),
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
