import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../auth/register_screen.dart';

/// Wireframes D5 (Acceptance) → D6 (Verification) → D3 (Expired)
/// 3-state flow: acceptance → verification → register
class InviteAcceptScreen extends StatefulWidget {
  final String inviteCode;
  const InviteAcceptScreen({super.key, required this.inviteCode});

  @override
  State<InviteAcceptScreen> createState() => _InviteAcceptScreenState();
}

class _InviteAcceptScreenState extends State<InviteAcceptScreen> {
  Map<String, dynamic>? _invite;
  bool _loading = true;
  bool _expired = false;
  String _step = 'acceptance'; // acceptance, verification
  final _passwordC = TextEditingController();
  final _confirmC = TextEditingController();
  bool _obscure1 = true;
  bool _obscure2 = true;

  @override
  void initState() { super.initState(); _loadInvite(); }

  @override
  void dispose() { _passwordC.dispose(); _confirmC.dispose(); super.dispose(); }

  Future<void> _loadInvite() async {
    try {
      _invite = await ApiService.get('/invitations/accept/${widget.inviteCode}');
      if (_invite?['status'] == 'EXPIRED' || _invite?['status'] == 'CANCELLED') _expired = true;
    } catch (e) {
      _expired = true;
    }
    if (mounted) setState(() => _loading = false);
  }

  bool get _hasUpper => _passwordC.text.contains(RegExp(r'[A-Z]'));
  bool get _hasNumber => _passwordC.text.contains(RegExp(r'[0-9]'));
  bool get _hasLength => _passwordC.text.length >= 8;
  bool get _matches => _passwordC.text == _confirmC.text && _confirmC.text.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    if (_loading) return Scaffold(appBar: AppBar(), body: const Center(child: CircularProgressIndicator()));
    if (_expired) return _buildExpired();
    if (_step == 'verification') return _buildVerification();
    return _buildAcceptance();
  }

  /// D3: Expired/Invalid
  Widget _buildExpired() {
    return Scaffold(
      appBar: AppBar(title: const Text('Access Denied')),
      body: Center(child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          Stack(alignment: Alignment.center, children: [
            Container(width: 80, height: 80,
              decoration: BoxDecoration(color: AppColors.error.withAlpha(20), shape: BoxShape.circle),
              child: const Icon(Icons.shield, color: AppColors.error, size: 40)),
            Positioned(bottom: 8, right: 8, child: Container(width: 24, height: 24,
              decoration: BoxDecoration(color: AppColors.surfaceLight, shape: BoxShape.circle),
              child: const Icon(Icons.schedule, size: 14, color: AppColors.textSecondary))),
          ]),
          const SizedBox(height: 20),
          const Text('Invitation Expired', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(color: AppColors.error.withAlpha(15), borderRadius: BorderRadius.circular(8)),
            child: const Text('Security Protocol: Link Timed Out',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.error)),
          ),
          const SizedBox(height: 16),
          const Text('For your security, onboarding links are only valid for 48 hours. This link has expired or has already been used.',
            textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary, height: 1.5)),
          if (_invite != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(12)),
              child: Row(children: [
                const Icon(Icons.location_on, color: AppColors.primary, size: 20),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('PROPERTY DETAILS', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  Text('${_invite!['propertyName']} - ${_invite!['unitName']}',
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                ])),
              ]),
            ),
          ],
          const SizedBox(height: 24),
          ElevatedButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Contact your landlord to request a new invitation'))),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('Request New Invitation')),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
            child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('Contact Landlord Directly'), SizedBox(width: 8), Icon(Icons.arrow_forward, size: 18)])),
        ]),
      )),
    );
  }

  /// D5: Acceptance
  Widget _buildAcceptance() {
    final inv = _invite!;
    return Scaffold(
      body: SafeArea(child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
            const Spacer(),
            Container(width: 36, height: 36,
              decoration: BoxDecoration(color: AppColors.primary.withAlpha(15), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.home, color: AppColors.primary, size: 20)),
          ]),
          const SizedBox(height: 16),
          Container(
            height: 160, width: double.infinity,
            decoration: BoxDecoration(color: AppColors.primary.withAlpha(15), borderRadius: BorderRadius.circular(16)),
            child: const Center(child: Icon(Icons.apartment, size: 56, color: AppColors.primary)),
          ),
          const SizedBox(height: 20),
          const Text("You're Invited!", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.primary)),
          const Text('Join the resident portal for your new home.', style: TextStyle(color: AppColors.textSecondary, fontSize: 15)),
          const SizedBox(height: 20),
          // Invitation card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border, width: 0.5)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('INVITATION FOR', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary, letterSpacing: 0.5)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: AppColors.warning.withAlpha(15), borderRadius: BorderRadius.circular(6)),
                  child: const Text('Pending', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.warning)),
                ),
              ]),
              const SizedBox(height: 8),
              Text(inv['propertyName'] ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              Row(children: [
                const Icon(Icons.location_on, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(inv['unitName'] ?? '', style: const TextStyle(color: AppColors.textSecondary)),
              ]),
              if (inv['tenantEmail'] != null) ...[
                const SizedBox(height: 8),
                Row(children: [
                  const Icon(Icons.mail_outline, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(inv['tenantEmail'], style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                ]),
              ],
            ]),
          ),
          const SizedBox(height: 24),
          const Text('Accept Invitation', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          const Text('Accepting this invitation will allow you to view your lease agreement, make payments, and submit maintenance requests directly from your phone.',
            style: TextStyle(color: AppColors.textSecondary, height: 1.5)),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: () => setState(() => _step = 'verification'),
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
            child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('Accept & Create Account'), SizedBox(width: 8), Icon(Icons.arrow_forward, size: 20)])),
          const SizedBox(height: 12),
          Center(child: Column(children: [
            const Text('ALREADY HAVE AN ACCOUNT?', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            TextButton(onPressed: () => Navigator.pop(context),
              child: const Text('Log In to Existing Account', style: TextStyle(fontWeight: FontWeight.w600))),
          ])),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: const [
            _TrustBadge(Icons.lock, 'Secure Data'),
            _TrustBadge(Icons.verified, 'Verified Host'),
            _TrustBadge(Icons.chat_bubble_outline, 'Easy Comms'),
          ]),
        ]),
      )),
    );
  }

  /// D6: Verification — password setup with property preview
  Widget _buildVerification() {
    final inv = _invite!;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back),
          onPressed: () => setState(() => _step = 'acceptance')),
        title: Row(children: [
          ClipRRect(borderRadius: BorderRadius.circular(6),
            child: Image.asset('assets/logo.png', width: 28, height: 28)),
          const SizedBox(width: 8),
          const Text('Verify Invite'),
        ]),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Welcome to your new home!',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          const Text('Please review your unit details and set up your secure account access.',
            style: TextStyle(color: AppColors.textSecondary, height: 1.5)),
          const SizedBox(height: 20),
          // Property preview with "Assigned Unit" badge
          Stack(children: [
            Container(
              height: 120, width: double.infinity,
              decoration: BoxDecoration(color: AppColors.primary.withAlpha(15), borderRadius: BorderRadius.circular(12)),
              child: const Center(child: Icon(Icons.apartment, size: 48, color: AppColors.primary)),
            ),
            Positioned(top: 8, right: 8, child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
              child: const Text('Assigned Unit', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
            )),
          ]),
          const SizedBox(height: 12),
          Text('${inv['propertyName']} — ${inv['unitName']}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          if (inv['tenantEmail'] != null) ...[
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.person, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              const Text('Landlord', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            ]),
          ],
          const SizedBox(height: 24),
          // Security Setup section
          const Row(children: [
            Icon(Icons.security, size: 18, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Security Setup', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: 16),
          const Text('Invitation Email', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(8)),
            child: Row(children: [
              const Icon(Icons.mail_outline, size: 18, color: AppColors.textSecondary),
              const SizedBox(width: 10),
              Text(inv['tenantEmail'] ?? 'tenant@example.com',
                style: const TextStyle(color: AppColors.textSecondary)),
            ]),
          ),
          const SizedBox(height: 4),
          const Text('This is the email your landlord used for the invite.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          // Create Password
          const Text('Create Password', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          TextField(
            controller: _passwordC,
            obscureText: _obscure1,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'At least 8 characters',
              prefixIcon: const Icon(Icons.lock_outline, size: 20, color: AppColors.textSecondary),
              suffixIcon: IconButton(icon: Icon(_obscure1 ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 20),
                onPressed: () => setState(() => _obscure1 = !_obscure1)),
            ),
          ),
          const SizedBox(height: 12),
          // Confirm Password
          const Text('Confirm Password', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          TextField(
            controller: _confirmC,
            obscureText: _obscure2,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Re-enter password',
              prefixIcon: const Icon(Icons.lock_outline, size: 20, color: AppColors.textSecondary),
              suffixIcon: IconButton(icon: Icon(_obscure2 ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 20),
                onPressed: () => setState(() => _obscure2 = !_obscure2)),
            ),
          ),
          const SizedBox(height: 12),
          // Requirements checklist
          const Text('REQUIREMENTS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
            color: AppColors.textSecondary, letterSpacing: 0.5)),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: _Req('8+ Characters', _hasLength)),
            Expanded(child: _Req('1 Uppercase', _hasUpper)),
          ]),
          const SizedBox(height: 4),
          Row(children: [
            Expanded(child: _Req('1 Number', _hasNumber)),
            Expanded(child: _Req('Matches', _matches)),
          ]),
          const SizedBox(height: 24),
          // Accept & Continue
          ElevatedButton(
            onPressed: _hasLength && _hasUpper && _hasNumber && _matches ? () {
              Navigator.pushReplacement(context, MaterialPageRoute(
                builder: (_) => RegisterScreen(
                  inviteCode: widget.inviteCode,
                  prefilledEmail: _invite?['tenantEmail'] as String?,
                )));
            } : null,
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
            child: const Text('Accept Invite & Continue'),
          ),
          const SizedBox(height: 8),
          Center(child: RichText(text: const TextSpan(
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            children: [
              TextSpan(text: 'By clicking "Accept Invite", you agree to the '),
              TextSpan(text: 'Terms of Service', style: TextStyle(color: AppColors.primary)),
              TextSpan(text: ' and '),
              TextSpan(text: 'Privacy Policy', style: TextStyle(color: AppColors.primary)),
              TextSpan(text: '.'),
            ],
          ))),
        ]),
      ),
    );
  }
}

class _TrustBadge extends StatelessWidget {
  final IconData icon; final String label;
  const _TrustBadge(this.icon, this.label);
  @override
  Widget build(BuildContext context) => Column(children: [
    Icon(icon, color: AppColors.textSecondary, size: 20),
    const SizedBox(height: 4),
    Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
  ]);
}

class _Req extends StatelessWidget {
  final String label; final bool met;
  const _Req(this.label, this.met);
  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(met ? Icons.check_circle : Icons.radio_button_unchecked,
      size: 16, color: met ? AppColors.success : AppColors.border),
    const SizedBox(width: 6),
    Text(label, style: TextStyle(fontSize: 12,
      color: met ? AppColors.success : AppColors.textSecondary)),
  ]);
}
