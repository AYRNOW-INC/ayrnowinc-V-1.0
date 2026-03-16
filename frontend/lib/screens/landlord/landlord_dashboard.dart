import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../shared/notifications_screen.dart';
import '../shared/invite_screen.dart';
import 'add_property_screen.dart';
import 'lease_list_screen.dart';

class LandlordDashboard extends StatefulWidget {
  const LandlordDashboard({super.key});

  @override
  State<LandlordDashboard> createState() => _LandlordDashboardState();
}

class _LandlordDashboardState extends State<LandlordDashboard> {
  Map<String, dynamic>? _stats;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() { _loading = true; _error = null; });
    try {
      final stats = await ApiService.get('/dashboard/landlord');
      if (mounted) setState(() { _stats = stats; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  bool get _isEmpty =>
    (_stats?['totalProperties'] ?? 0) == 0;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset('assets/logo.png', width: 32, height: 32),
          ),
        ),
        title: const Text('Dashboard'),
        actions: [
          IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: () =>
              Navigator.push(context, MaterialPageRoute(builder: (_) => AddPropertyScreen(onCreated: _loadDashboard)))),
          IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () =>
              Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()))),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboard,
        child: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
            ? Center(child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 12),
                  TextButton(onPressed: _loadDashboard, child: const Text('Retry')),
                ],
              ))
            : _isEmpty
              ? _buildEmptyDashboard(auth)
              : _buildPopulatedDashboard(auth),
      ),
    );
  }

  /// Wireframe B1: Empty dashboard
  Widget _buildEmptyDashboard(AuthProvider auth) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // 4 stat cards (all zero)
        Row(children: [
          _StatCard(icon: Icons.home_work, color: AppColors.primary, label: 'PROPERTIES', value: '0'),
          const SizedBox(width: 12),
          _StatCard(icon: Icons.people, color: AppColors.teal, label: 'TENANTS', value: '0'),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          _StatCard(icon: Icons.description, color: AppColors.textSecondary, label: 'ACTIVE LEASES', value: '0'),
          const SizedBox(width: 12),
          _StatCard(icon: Icons.trending_up, color: AppColors.success, label: 'MONTHLY RENT', value: '\$0'),
        ]),
        const SizedBox(height: 32),
        // Start Your Portfolio CTA
        Center(
          child: Column(
            children: [
              Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(15),
                  shape: BoxShape.circle,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(Icons.apartment, size: 48, color: AppColors.primary),
                    Positioned(
                      bottom: 16, right: 16,
                      child: Container(
                        width: 28, height: 28,
                        decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
                        child: const Icon(Icons.add, color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text('Start Your Portfolio',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textDark)),
              const SizedBox(height: 8),
              const Text(
                'Ready to streamline your management?\nAdd your first property to begin tracking\nleases and payments.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: AppColors.textSecondary, height: 1.5),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => AddPropertyScreen(onCreated: _loadDashboard))),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(280, 52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Add My First Property'),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, size: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        // Quick Setup Guide
        const Row(
          children: [
            Icon(Icons.info_outline, color: AppColors.primary, size: 18),
            SizedBox(width: 8),
            Text('QUICK SETUP GUIDE',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 0.5)),
          ],
        ),
        const SizedBox(height: 12),
        _SetupStep(number: '1', title: 'Create Property Record', subtitle: 'Enter address and unit details.'),
        const SizedBox(height: 8),
        _SetupStep(number: '2', title: 'Configure Lease Rules', subtitle: 'Set defaults for rent and deposits.'),
      ],
    );
  }

  /// Wireframe B2: Populated dashboard
  Widget _buildPopulatedDashboard(AuthProvider auth) {
    final s = _stats!;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Greeting
        Text('Welcome back, ${auth.user?['firstName'] ?? ''}',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textDark)),
        const SizedBox(height: 4),
        const Text("Here's what's happening today.",
          style: TextStyle(fontSize: 15, color: AppColors.textSecondary)),
        const SizedBox(height: 20),
        // 4 stat cards with values
        Row(children: [
          _StatCard(
            icon: Icons.attach_money, color: AppColors.success,
            label: 'RENT COLLECTED', value: '\$${s['totalRevenue'] ?? '0'}',
          ),
          const SizedBox(width: 12),
          _StatCard(
            icon: Icons.apartment, color: AppColors.primary,
            label: 'OCCUPANCY',
            value: '${s['totalUnits'] != null && s['totalUnits'] > 0 ? ((s['occupiedUnits'] ?? 0) * 100 ~/ s['totalUnits']) : 0}%',
          ),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          _StatCard(
            icon: Icons.people_outline, color: AppColors.warning,
            label: 'PENDING INVITES', value: '${s['pendingInvitations'] ?? 0}'.padLeft(2, '0'),
          ),
          const SizedBox(width: 12),
          _StatCard(
            icon: Icons.description, color: AppColors.primary,
            label: 'ACTIVE LEASES', value: '${s['activeLeases'] ?? 0}',
          ),
        ]),
        const SizedBox(height: 24),
        // Quick Actions (per wireframe: 3 square buttons)
        const Text('Quick Actions',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textDark)),
        const SizedBox(height: 12),
        Row(
          children: [
            _QuickAction(icon: Icons.add, label: 'Add\nProperty', color: AppColors.success,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddPropertyScreen(onCreated: _loadDashboard)))),
            const SizedBox(width: 12),
            _QuickAction(icon: Icons.person_add, label: 'Invite\nTenant', color: AppColors.primary,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InviteScreen()))),
            const SizedBox(width: 12),
            _QuickAction(icon: Icons.description, label: 'Create\nLease', color: Color(0xFF7C3AED),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LeaseListScreen()))),
          ],
        ),
        const SizedBox(height: 24),
        // Recent Activity
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Recent Activity',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textDark)),
            TextButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Full activity feed coming soon'))), child: const Text('View All')),
          ],
        ),
        // Activity items (static for now, will be dynamic with backend addition)
        _ActivityItem(
          icon: Icons.attach_money, color: AppColors.success,
          title: 'Rent Received', subtitle: 'Check your payments tab', time: 'Recent'),
        _ActivityItem(
          icon: Icons.description, color: AppColors.primary,
          title: 'Lease Activity', subtitle: 'Review your leases', time: 'Recent'),
        const SizedBox(height: 16),
        // Promo card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withAlpha(30)),
          ),
          child: Row(
            children: [
              Image.asset('assets/logo.png', width: 24, height: 24),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Automate Rent Reminders',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                    SizedBox(height: 2),
                    Text('Save time by enabling automatic email reminders for upcoming rent payments.',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              TextButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Automatic rent reminders available in Settings'))), child: const Text('Learn how >')),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;

  const _StatCard({required this.icon, required this.color, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const Spacer(),
                Text('Total', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textDark)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500,
              color: AppColors.textSecondary, letterSpacing: 0.3)),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: color.withAlpha(15),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(height: 8),
              Text(label, textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark, height: 1.3)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String time;

  const _ActivityItem({required this.icon, required this.color, required this.title, required this.subtitle, required this.time});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          CircleAvatar(radius: 20, backgroundColor: color.withAlpha(20),
            child: Icon(icon, color: color, size: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                Text(subtitle, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Text(time, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 18),
        ],
      ),
    );
  }
}

class _SetupStep extends StatelessWidget {
  final String number;
  final String title;
  final String subtitle;

  const _SetupStep({required this.number, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
            child: Center(child: Text(number,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                Text(subtitle, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}
