import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

/// Wireframe L1: Notifications
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<dynamic> _notifications = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try { _notifications = await ApiService.getList('/notifications'); } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load notifications'), backgroundColor: Colors.red));
    }
    if (mounted) setState(() => _loading = false);
  }

  int get _unread => _notifications.where((n) => n['read'] == false).length;

  Color _typeColor(String t) => switch (t) {
    'LEASE' => AppColors.primary,
    'PAYMENT' => AppColors.success,
    'INVITE' || 'TENANT' => AppColors.teal,
    'DOCUMENT' => AppColors.warning,
    'MOVE_OUT' => AppColors.error,
    _ => AppColors.textSecondary,
  };

  IconData _typeIcon(String t) => switch (t) {
    'LEASE' => Icons.description,
    'PAYMENT' => Icons.attach_money,
    'INVITE' || 'TENANT' => Icons.person,
    'DOCUMENT' => Icons.folder,
    'MOVE_OUT' => Icons.exit_to_app,
    _ => Icons.notifications,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(icon: const Icon(Icons.settings_outlined), onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notification preferences available in Account settings')))),
          PopupMenuButton(itemBuilder: (_) => [
            const PopupMenuItem(value: 'read', child: Text('Mark all read')),
          ], onSelected: (v) async {
            if (v == 'read') { await ApiService.put('/notifications/read-all'); _load(); }
          }),
        ],
      ),
      body: RefreshIndicator(onRefresh: _load,
        child: _loading ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
            ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.notifications_none, size: 56, color: AppColors.textSecondary),
                SizedBox(height: 12),
                Text("You're all caught up!", style: TextStyle(fontSize: 18, color: AppColors.textSecondary)),
              ]))
            : ListView(padding: const EdgeInsets.all(16), children: [
                if (_unread > 0) Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('You have $_unread unread notifications',
                      style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                    GestureDetector(
                      onTap: () async { await ApiService.put('/notifications/read-all'); _load(); },
                      child: const Text('Mark all read', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 14)),
                    ),
                  ]),
                ),
                ..._notifications.map((n) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: n['read'] == false ? AppColors.primary.withAlpha(5) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: n['read'] == false ? AppColors.primary.withAlpha(30) : AppColors.border, width: 0.5),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    leading: CircleAvatar(radius: 20,
                      backgroundColor: _typeColor(n['type'] ?? '').withAlpha(20),
                      child: Icon(_typeIcon(n['type'] ?? ''), color: _typeColor(n['type'] ?? ''), size: 20)),
                    title: Text(n['title'] ?? '', style: TextStyle(
                      fontWeight: n['read'] == false ? FontWeight.w700 : FontWeight.w500, fontSize: 15)),
                    subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const SizedBox(height: 2),
                      Text(n['message'] ?? '', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                      const SizedBox(height: 4),
                      Row(children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _typeColor(n['type'] ?? '').withAlpha(15),
                            borderRadius: BorderRadius.circular(4)),
                          child: Text(n['type'] ?? '', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                            color: _typeColor(n['type'] ?? ''))),
                        ),
                      ]),
                    ]),
                    onTap: () async {
                      if (n['read'] == false) {
                        await ApiService.put('/notifications/${n['id']}/read');
                        _load();
                      }
                    },
                  ),
                )),
                const SizedBox(height: 20),
                const Center(child: Text("You're all caught up!",
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 14))),
              ])),
    );
  }
}
