import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import 'add_property_screen.dart';
import 'edit_unit_screen.dart';
import 'lease_list_screen.dart';
import '../shared/invite_screen.dart';

/// Wireframe C3: Property Detail with hero, stats, tabs, unit list
class PropertyDetailScreen extends StatefulWidget {
  final int propertyId;
  final VoidCallback onChanged;
  const PropertyDetailScreen({super.key, required this.propertyId, required this.onChanged});

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> with SingleTickerProviderStateMixin {
  Map<String, dynamic>? _property;
  bool _loading = true;
  late TabController _tabC;

  @override
  void initState() {
    super.initState();
    _tabC = TabController(length: 4, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabC.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final p = await ApiService.get('/properties/${widget.propertyId}');
      if (mounted) setState(() { _property = p; _loading = false; });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load property details'), backgroundColor: Colors.red));
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return Scaffold(appBar: AppBar(), body: const Center(child: CircularProgressIndicator()));
    if (_property == null) return Scaffold(appBar: AppBar(), body: const Center(child: Text('Property not found')));

    final p = _property!;
    final units = (p['unitSpaces'] as List<dynamic>?) ?? [];
    final total = p['totalUnits'] ?? 0;
    final occupied = p['occupiedUnits'] ?? 0;
    final occupancy = total > 0 ? (occupied * 100 ~/ total) : 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(p['name'] ?? 'Property'),
        actions: [
          PopupMenuButton(itemBuilder: (_) => [
            const PopupMenuItem(value: 'settings', child: Text('Lease Settings')),
            const PopupMenuItem(value: 'edit', child: Text('Edit Property')),
            const PopupMenuItem(value: 'delete', child: Text('Delete Property')),
          ], onSelected: (v) {
            if (v == 'settings') _showLeaseSettings();
            if (v == 'edit') {
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => AddPropertyScreen(property: _property, onCreated: _load),
              )).then((_) => _load());
            }
            if (v == 'delete') _confirmDelete();
          }),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          children: [
            // Hero section
            Stack(children: [
              Container(
                height: 180, width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary.withAlpha(30), AppColors.primary.withAlpha(10)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                ),
                child: const Center(child: Icon(Icons.apartment, size: 64, color: AppColors.primary)),
              ),
              Positioned(top: 12, left: 12, child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppColors.success, borderRadius: BorderRadius.circular(8)),
                child: const Text('Active Property', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
              )),
              Positioned(bottom: 12, left: 16, right: 16, child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p['name'] ?? '', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                  Row(children: [
                    const Icon(Icons.location_on, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text('${p['address']}, ${p['city']}, ${p['state']}',
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                  ]),
                ],
              )),
            ]),
            // 3 stat circles
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(children: [
                _StatCircle('$occupancy%', 'Occupancy', AppColors.primary),
                const SizedBox(width: 12),
                _StatCircle('$occupied/$total', 'Units', AppColors.teal),
                const SizedBox(width: 12),
                _StatCircle('\$0', 'Revenue', AppColors.success),
              ]),
            ),
            // Tab bar
            TabBar(
              controller: _tabC,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              tabs: const [
                Tab(text: 'Units'),
                Tab(text: 'Tenants'),
                Tab(text: 'Leases'),
                Tab(text: 'Payments'),
              ],
            ),
            // Tab content — changes based on selected tab
            AnimatedBuilder(
              animation: _tabC,
              builder: (context, _) => Padding(
                padding: const EdgeInsets.all(16),
                child: _buildTabContent(p, units),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(Map<String, dynamic> p, List<dynamic> units) {
    switch (_tabC.index) {
      case 0: // Units
        return _buildUnitsTab(units);
      case 1: // Tenants
        return _buildTenantsTab(units);
      case 2: // Leases
        return _buildLeasesTab();
      case 3: // Payments
        return _buildPaymentsTab();
      default:
        return _buildUnitsTab(units);
    }
  }

  Widget _buildUnitsTab(List<dynamic> units) {
    final vacant = units.where((u) => u['status'] == 'VACANT').toList();
    final occupied = units.where((u) => u['status'] == 'OCCUPIED').toList();
    return Column(children: [
      // Filter row
      SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [
        _TabFilter('All (${units.length})', true),
        _TabFilter('Occupied (${occupied.length})', false),
        _TabFilter('Vacant (${vacant.length})', false),
      ])),
      const SizedBox(height: 12),
      if (units.isEmpty)
        const Padding(padding: EdgeInsets.all(32), child: Text('No units yet', style: TextStyle(color: AppColors.textSecondary)))
      else
        ...units.map((u) => _GuidedUnitCard(
          unit: u,
          onEdit: () => Navigator.push(context, MaterialPageRoute(
            builder: (_) => EditUnitScreen(propertyId: widget.propertyId, unit: u, onSaved: _load))),
          onAction: () => _handleUnitAction(u),
        )),
      const SizedBox(height: 8),
      OutlinedButton.icon(
        onPressed: () => Navigator.push(context, MaterialPageRoute(
          builder: (_) => EditUnitScreen(propertyId: widget.propertyId, onSaved: _load))),
        icon: const Icon(Icons.add, size: 18),
        label: const Text('Add New Unit'),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 44),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          side: BorderSide(color: AppColors.primary.withAlpha(60)),
        ),
      ),
    ]);
  }

  Widget _buildTenantsTab(List<dynamic> units) {
    final occupiedUnits = units.where((u) => u['status'] == 'OCCUPIED').toList();
    if (occupiedUnits.isEmpty) return const Padding(padding: EdgeInsets.all(32),
      child: Center(child: Text('No tenants assigned yet', style: TextStyle(color: AppColors.textSecondary))));
    return Column(children: occupiedUnits.map((u) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        CircleAvatar(radius: 20, backgroundColor: AppColors.primary.withAlpha(20),
          child: const Icon(Icons.person, color: AppColors.primary, size: 20)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Tenant — ${u['name']}', style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(u['unitType'] ?? '', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        ])),
        if (u['monthlyRent'] != null) Text('\$${u['monthlyRent']}/mo', style: const TextStyle(fontWeight: FontWeight.w600)),
      ]),
    )).toList());
  }

  Widget _buildLeasesTab() {
    return FutureBuilder<List<dynamic>>(
      future: ApiService.getList('/leases/landlord'),
      builder: (_, snap) {
        if (snap.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
        final leases = (snap.data ?? []).where((l) => l['propertyId'] == widget.propertyId).toList();
        if (leases.isEmpty) return const Padding(padding: EdgeInsets.all(32),
          child: Center(child: Text('No leases for this property', style: TextStyle(color: AppColors.textSecondary))));
        return Column(children: leases.map((l) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(children: [
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: l['status'] == 'FULLY_EXECUTED' ? AppColors.success.withAlpha(15) : AppColors.warning.withAlpha(15),
                borderRadius: BorderRadius.circular(6)),
              child: Text(l['status'] ?? '', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                color: l['status'] == 'FULLY_EXECUTED' ? AppColors.success : AppColors.warning))),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${l['unitName']} — ${l['tenantName']}', style: const TextStyle(fontWeight: FontWeight.w600)),
              Text('\$${l['monthlyRent']}/mo', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            ])),
          ]),
        )).toList());
      },
    );
  }

  Widget _buildPaymentsTab() {
    return FutureBuilder<List<dynamic>>(
      future: ApiService.getList('/payments/property/${widget.propertyId}'),
      builder: (_, snap) {
        if (snap.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
        final payments = snap.data ?? [];
        if (payments.isEmpty) return const Padding(padding: EdgeInsets.all(32),
          child: Center(child: Text('No payments for this property', style: TextStyle(color: AppColors.textSecondary))));
        return Column(children: payments.map((pay) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(children: [
            Icon(pay['status'] == 'SUCCESSFUL' ? Icons.check_circle : Icons.schedule,
              color: pay['status'] == 'SUCCESSFUL' ? AppColors.success : AppColors.warning, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('\$${pay['amount']} — ${pay['paymentType']}', style: const TextStyle(fontWeight: FontWeight.w600)),
              Text('Due: ${pay['dueDate']}', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            ])),
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: (pay['status'] == 'SUCCESSFUL' ? AppColors.success : AppColors.warning).withAlpha(15),
                borderRadius: BorderRadius.circular(6)),
              child: Text(pay['status'] ?? '', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                color: pay['status'] == 'SUCCESSFUL' ? AppColors.success : AppColors.warning))),
          ]),
        )).toList());
      },
    );
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Property'),
        content: const Text('Are you sure you want to delete this property? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      try {
        await ApiService.delete('/properties/${widget.propertyId}');
        if (mounted) {
          widget.onChanged();
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete: $e'), backgroundColor: AppColors.error));
        }
      }
    }
  }

  void _showLeaseSettings() {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => _LeaseSettingsScreen(propertyId: widget.propertyId)));
  }

  /// Route to the correct next action based on unit workflow step
  void _handleUnitAction(Map<String, dynamic> unit) {
    final step = (unit['workflowStep'] ?? 'SETUP').toString();
    switch (step) {
      case 'SETUP':
      case 'INVITE':
        // Navigate to invite screen
        Navigator.push(context, MaterialPageRoute(builder: (_) => const InviteScreen()));
        break;
      case 'LEASE':
        // Navigate to lease creation
        Navigator.push(context, MaterialPageRoute(builder: (_) => const LeaseListScreen()));
        break;
      case 'SIGN':
      case 'ACTIVE':
        // Navigate to lease list for management
        Navigator.push(context, MaterialPageRoute(builder: (_) => const LeaseListScreen()));
        break;
      default:
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => EditUnitScreen(propertyId: widget.propertyId, unit: unit, onSaved: _load)));
    }
  }
}

class _TabFilter extends StatelessWidget {
  final String label; final bool active;
  const _TabFilter(this.label, this.active);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(right: 8),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: active ? AppColors.primary : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
        color: active ? Colors.white : AppColors.textSecondary))),
  );
}

class _StatCircle extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  const _StatCircle(this.value, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withAlpha(10),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha(30)),
        ),
        child: Column(children: [
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: color)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ]),
      ),
    );
  }
}

/// Guided unit card with 5-step workflow tracker and state-based CTA
class _GuidedUnitCard extends StatelessWidget {
  final Map<String, dynamic> unit;
  final VoidCallback onEdit;
  final VoidCallback onAction;
  const _GuidedUnitCard({required this.unit, required this.onEdit, required this.onAction});

  _UnitStep get _currentStep {
    // Use backend-computed workflowStep if available
    final wfStep = (unit['workflowStep'] ?? '').toString().toUpperCase();
    switch (wfStep) {
      case 'ACTIVE': return _UnitStep.active;
      case 'SIGN': return _UnitStep.sign;
      case 'LEASE': return _UnitStep.lease;
      case 'INVITE': return _UnitStep.invite;
      case 'SETUP': return _UnitStep.setup;
      default:
        // Fallback: derive from status field
        if ((unit['status'] ?? '').toString().toUpperCase() == 'OCCUPIED') return _UnitStep.active;
        return _UnitStep.setup;
    }
  }

  @override
  Widget build(BuildContext context) {
    final step = _currentStep;
    final isOccupied = unit['status'] == 'OCCUPIED';
    final rent = unit['monthlyRent'];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 0.5,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Unit identity + status badge
            Row(children: [
              // Unit icon badge
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: step.color.withAlpha(20),
                  borderRadius: BorderRadius.circular(10)),
                child: Center(child: Icon(
                  isOccupied ? Icons.person : Icons.meeting_room_outlined,
                  color: step.color, size: 20)),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(unit['name'] ?? '', style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                  Row(children: [
                    Text(unit['unitType'] ?? '', style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary)),
                    if (rent != null) ...[
                      const Text(' · ', style: TextStyle(color: AppColors.textSecondary)),
                      Text('\$$rent/mo', style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                    ],
                    if (unit['tenantName'] != null) ...[
                      const Text(' · ', style: TextStyle(color: AppColors.textSecondary)),
                      Flexible(child: Text(unit['tenantName'], style: const TextStyle(
                        fontSize: 12, color: AppColors.teal), overflow: TextOverflow.ellipsis)),
                    ],
                  ]),
                ],
              )),
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: step.color.withAlpha(15),
                  borderRadius: BorderRadius.circular(8)),
                child: Text(step.badge, style: TextStyle(
                  fontSize: 10, fontWeight: FontWeight.w700, color: step.color, letterSpacing: 0.3)),
              ),
            ]),
            const SizedBox(height: 12),
            // Row 2: Step progress tracker
            _StepTracker(currentStep: step),
            const SizedBox(height: 12),
            // Row 3: Next step hint + actions
            Row(children: [
              Icon(step.icon, size: 14, color: step.color),
              const SizedBox(width: 6),
              Expanded(child: Text(step.hint, style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w500, color: step.color))),
              // Edit button (secondary)
              SizedBox(
                height: 32,
                child: OutlinedButton(
                  onPressed: onEdit,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    foregroundColor: AppColors.textSecondary,
                  ),
                  child: const Text('Edit', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 8),
              // Primary CTA
              SizedBox(
                height: 32,
                child: ElevatedButton(
                  onPressed: onAction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: step.color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: Text(step.cta, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

/// 5-step unit lifecycle
enum _UnitStep {
  setup(
    stepNum: 0, badge: 'SETUP', hint: 'Ready for tenant invite',
    cta: 'Invite', icon: Icons.person_add_outlined, color: AppColors.warning,
  ),
  invite(
    stepNum: 1, badge: 'INVITE SENT', hint: 'Waiting for tenant response',
    cta: 'Follow Up', icon: Icons.mail_outline, color: AppColors.primary,
  ),
  lease(
    stepNum: 2, badge: 'NEEDS LEASE', hint: 'Create lease for tenant',
    cta: 'Create Lease', icon: Icons.description_outlined, color: AppColors.primary,
  ),
  sign(
    stepNum: 3, badge: 'SIGN PENDING', hint: 'Lease awaiting signatures',
    cta: 'View Lease', icon: Icons.draw_outlined, color: AppColors.teal,
  ),
  active(
    stepNum: 4, badge: 'ACTIVE', hint: 'Lease active · Collecting rent',
    cta: 'Manage', icon: Icons.check_circle_outline, color: AppColors.success,
  );

  final int stepNum;
  final String badge;
  final String hint;
  final String cta;
  final IconData icon;
  final Color color;
  const _UnitStep({required this.stepNum, required this.badge, required this.hint,
    required this.cta, required this.icon, required this.color});
}

/// Horizontal 5-step progress tracker
class _StepTracker extends StatelessWidget {
  final _UnitStep currentStep;
  const _StepTracker({required this.currentStep});

  static const _labels = ['Setup', 'Invite', 'Lease', 'Sign', 'Active'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (i) {
        final isComplete = i < currentStep.stepNum;
        final isCurrent = i == currentStep.stepNum;
        final isPending = i > currentStep.stepNum;
        return Expanded(
          child: Row(children: [
            // Step dot
            Container(
              width: 20, height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isComplete ? AppColors.success
                    : isCurrent ? currentStep.color
                    : AppColors.surfaceLight,
                border: Border.all(
                  color: isComplete ? AppColors.success
                      : isCurrent ? currentStep.color
                      : AppColors.border,
                  width: 1.5),
              ),
              child: Center(child: isComplete
                ? const Icon(Icons.check, size: 12, color: Colors.white)
                : Text('${i + 1}', style: TextStyle(
                    fontSize: 9, fontWeight: FontWeight.w700,
                    color: isCurrent ? Colors.white : AppColors.textSecondary))),
            ),
            // Connecting line (not after last)
            if (i < 4) Expanded(child: Container(
              height: 2,
              color: isComplete ? AppColors.success : AppColors.border,
            )),
          ]),
        );
      }),
    );
  }
}

/// Inline lease settings screen per wireframes E1/E2
class _LeaseSettingsScreen extends StatefulWidget {
  final int propertyId;
  const _LeaseSettingsScreen({required this.propertyId});

  @override
  State<_LeaseSettingsScreen> createState() => _LeaseSettingsScreenState();
}

class _LeaseSettingsScreenState extends State<_LeaseSettingsScreen> {
  Map<String, dynamic>? _settings;
  bool _loading = true;
  bool _editing = false;
  bool _autoRenewal = false;
  final _termC = TextEditingController();
  final _rentC = TextEditingController();
  final _depositC = TextEditingController();
  final _dueDayC = TextEditingController();
  final _graceC = TextEditingController();
  final _lateFeeC = TextEditingController();

  @override
  void dispose() {
    _termC.dispose(); _rentC.dispose(); _depositC.dispose();
    _dueDayC.dispose(); _graceC.dispose(); _lateFeeC.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final s = await ApiService.get('/properties/${widget.propertyId}/lease-settings');
      if (mounted) setState(() { _settings = s; _loading = false; _populateFields(s); });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load lease settings'), backgroundColor: Colors.red));
        setState(() => _loading = false);
      }
    }
  }

  void _populateFields(Map<String, dynamic> s) {
    _termC.text = '${s['defaultLeaseTermMonths'] ?? 12}';
    _rentC.text = '${s['defaultMonthlyRent'] ?? ''}';
    _depositC.text = '${s['defaultSecurityDeposit'] ?? ''}';
    _dueDayC.text = '${s['paymentDueDay'] ?? 1}';
    _graceC.text = '${s['gracePeriodDays'] ?? 5}';
    _lateFeeC.text = '${s['lateFeeAmount'] ?? 0}';
  }

  Future<void> _save() async {
    try {
      await ApiService.put('/properties/${widget.propertyId}/lease-settings', body: {
        'defaultLeaseTermMonths': int.tryParse(_termC.text),
        'defaultMonthlyRent': double.tryParse(_rentC.text),
        'defaultSecurityDeposit': double.tryParse(_depositC.text),
        'paymentDueDay': int.tryParse(_dueDayC.text),
        'gracePeriodDays': int.tryParse(_graceC.text),
        'lateFeeAmount': double.tryParse(_lateFeeC.text),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings saved'), backgroundColor: AppColors.success));
        setState(() => _editing = false);
        _load();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lease Settings'),
        actions: [
          if (!_editing)
            TextButton(onPressed: () => setState(() => _editing = true),
              child: const Text('Edit Defaults'))
          else
            TextButton(onPressed: _save, child: const Text('Save')),
        ],
      ),
      body: _loading ? const Center(child: CircularProgressIndicator())
        : ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text('Global Lease Defaults',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              const Text('These settings apply to all new lease agreements created on your account.',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
              const SizedBox(height: 24),
              // FINANCIAL TERMS section
              const Row(children: [
                Icon(Icons.attach_money, size: 18, color: AppColors.primary),
                SizedBox(width: 8),
                Text('Financial Terms', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ]),
              if (!_editing) ...[
                const SizedBox(height: 12),
                _SettingDisplay('Rent Due Day', '${_dueDayC.text}st of month'),
                _SettingDisplay('Security Deposit', '\$${_depositC.text}'),
                _SettingDisplay('Late Fee', '\$${_lateFeeC.text}'),
              ] else ...[
                const SizedBox(height: 12),
                _SettingField('Default Lease Term', _termC, suffix: 'Months', enabled: true),
                Row(children: [
                  Checkbox(value: _autoRenewal, onChanged: (v) => setState(() => _autoRenewal = v!),
                    activeColor: AppColors.primary),
                  const Expanded(child: Text('Enable month-to-month auto-renewal',
                    style: TextStyle(fontSize: 13))),
                ]),
                _SettingField('Base Rent', _rentC, prefix: '\$', enabled: true),
                _SettingField('Security Deposit', _depositC, prefix: '\$', enabled: true),
                _SettingField('Rent Due Day', _dueDayC, enabled: true),
              ],
              const SizedBox(height: 20),
              // GENERAL POLICIES section
              const Row(children: [
                Icon(Icons.policy, size: 18, color: AppColors.primary),
                SizedBox(width: 8),
                Text('General Policies', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ]),
              const SizedBox(height: 12),
              if (!_editing) ...[
                _SettingDisplay('Grace Period', '${_graceC.text} Days'),
                _SettingDisplay('Occupancy Limit', '2 Per Room'),
              ] else ...[
                _SettingField('Grace Period (Days)', _graceC, enabled: true),
                _SettingField('Late Fee Amount', _lateFeeC, prefix: '\$', enabled: true),
                // Policy preview
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppColors.warning.withAlpha(10),
                    borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.warning.withAlpha(30))),
                  child: Row(children: [
                    const Icon(Icons.info_outline, color: AppColors.warning, size: 16),
                    const SizedBox(width: 8),
                    Expanded(child: Text(
                      'POLICY PREVIEW: Late after ${_graceC.text} days, \$${_lateFeeC.text} flat fee.',
                      style: const TextStyle(fontSize: 12, color: AppColors.warning, fontWeight: FontWeight.w600))),
                  ]),
                ),
              ],
              const SizedBox(height: 20),
              // STANDARD CLAUSES section
              const Row(children: [
                Icon(Icons.gavel, size: 18, color: AppColors.primary),
                SizedBox(width: 8),
                Text('Standard Clauses', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ]),
              const SizedBox(height: 12),
              _ClauseItem('Maintenance Responsibilities', true),
              _ClauseItem('Right of Entry (24hr notice)', true),
              _ClauseItem('Pet Policy (Standard)', false),
              _ClauseItem('Subletting Prohibition', true),
              const SizedBox(height: 8),
              TextButton.icon(onPressed: () => showDialog(context: context, builder: (_) => AlertDialog(
                title: const Text('Custom Clauses'),
                content: const Text('Custom clause management allows you to add property-specific terms beyond the standard set. This feature will be available in a future update.'),
                actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
              )),
                icon: const Icon(Icons.add, size: 16), label: const Text('Manage Custom Clauses', style: TextStyle(fontSize: 13))),
              if (_editing) ...[
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 52)),
                  child: const Text('Update Global Settings'),
                ),
              ],
              const SizedBox(height: 16),
              const Text('Changes will not affect signed leases, only new drafts created after saving.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                textAlign: TextAlign.center),
            ],
          ),
    );
  }
}

class _SettingField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? prefix;
  final String? suffix;
  final bool enabled;
  const _SettingField(this.label, this.controller, {this.prefix, this.suffix, this.enabled = true});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            enabled: enabled,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              prefixText: prefix != null ? '$prefix ' : null,
              suffixText: suffix,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingDisplay extends StatelessWidget {
  final String label; final String value;
  const _SettingDisplay(this.label, this.value);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
      Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
    ]));
}

class _ClauseItem extends StatelessWidget {
  final String label; final bool active;
  const _ClauseItem(this.label, this.active);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(children: [
      Icon(active ? Icons.check_circle : Icons.radio_button_unchecked,
        size: 18, color: active ? AppColors.success : AppColors.textSecondary),
      const SizedBox(width: 10),
      Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: (active ? AppColors.success : AppColors.textSecondary).withAlpha(15),
          borderRadius: BorderRadius.circular(6)),
        child: Text(active ? 'Active' : 'Optional', style: TextStyle(
          fontSize: 10, fontWeight: FontWeight.w700,
          color: active ? AppColors.success : AppColors.textSecondary)),
      ),
    ]));
}
