import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

/// Wireframe F2: E-Sign Lease with signature pad
class LeaseSigningScreen extends StatefulWidget {
  final Map<String, dynamic> lease;
  final VoidCallback onSigned;
  const LeaseSigningScreen({super.key, required this.lease, required this.onSigned});

  @override
  State<LeaseSigningScreen> createState() => _LeaseSigningScreenState();
}

class _LeaseSigningScreenState extends State<LeaseSigningScreen> {
  final SignatureController _sigC = SignatureController(
    penStrokeWidth: 3,
    penColor: AppColors.textDark,
    exportBackgroundColor: Colors.white,
  );
  bool _agreeTerms = false;
  bool _agreeElectronic = false;
  bool _signing = false;

  @override
  void dispose() { _sigC.dispose(); super.dispose(); }

  bool get _canSign => _sigC.isNotEmpty && _agreeTerms && _agreeElectronic;

  Future<void> _sign() async {
    if (!_canSign) return;
    setState(() => _signing = true);
    try {
      await ApiService.post('/leases/${widget.lease['id']}/sign');
      widget.onSigned();
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (_) => _LeaseSignedSuccess(lease: widget.lease)));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error));
    }
    if (mounted) setState(() => _signing = false);
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.lease;
    return Scaffold(
      appBar: AppBar(title: const Text('E-Sign Lease')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Document Summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(12)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('DOCUMENT SUMMARY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                color: AppColors.textSecondary, letterSpacing: 0.5)),
              const SizedBox(height: 8),
              Text('${l['propertyName']}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              Text('${l['unitName']}', style: const TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              Row(children: [
                const Icon(Icons.schedule, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text('${l['leaseTermMonths']} Months (Fixed)', style: const TextStyle(fontSize: 13)),
                const SizedBox(width: 16),
                const Icon(Icons.attach_money, size: 14, color: AppColors.textSecondary),
                Text('Monthly Rent: \$${l['monthlyRent']}', style: const TextStyle(fontSize: 13)),
              ]),
            ]),
          ),
          const SizedBox(height: 20),
          // Signer Identity
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border, width: 0.5)),
            child: Row(children: [
              CircleAvatar(radius: 24, backgroundColor: AppColors.primary.withAlpha(20),
                child: const Icon(Icons.person, color: AppColors.primary)),
              const SizedBox(width: 12),
              const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Your Signature', style: TextStyle(fontWeight: FontWeight.w600)),
                Row(children: [
                  Icon(Icons.verified, color: AppColors.success, size: 14),
                  SizedBox(width: 4),
                  Text('ID VERIFIED BY AYRNOW', style: TextStyle(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.w600)),
                ]),
              ])),
            ]),
          ),
          const SizedBox(height: 20),
          // E-Signature pad
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('E-SIGNATURE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
              color: AppColors.textSecondary, letterSpacing: 0.5)),
            GestureDetector(
              onTap: () => _sigC.clear(),
              child: const Text('Clear', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
            ),
          ]),
          const SizedBox(height: 8),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.inputBg, borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withAlpha(30))),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Signature(
                controller: _sigC,
                backgroundColor: AppColors.inputBg,
              ),
            ),
          ),
          const Center(child: Padding(
            padding: EdgeInsets.symmetric(vertical: 6),
            child: Text('Draw your signature here. Use your finger or a stylus.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          )),
          const SizedBox(height: 16),
          // Consent checkboxes
          _ConsentCheck(
            value: _agreeTerms,
            onChanged: (v) => setState(() => _agreeTerms = v!),
            text: 'I have read and agree to the Lease Agreement, Rules & Regulations, and Privacy Policy.',
          ),
          const SizedBox(height: 8),
          _ConsentCheck(
            value: _agreeElectronic,
            onChanged: (v) => setState(() => _agreeElectronic = v!),
            text: 'I consent to receive all legal communications and notices electronically as per the Electronic Disclosure Consent.',
          ),
          const SizedBox(height: 24),
          // Sign button
          ElevatedButton(
            onPressed: _canSign && !_signing ? _sign : null,
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
            child: _signing
              ? const SizedBox(height: 20, width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Sign & Confirm Lease'),
          ),
          const SizedBox(height: 12),
          const Center(child: Text(
            'A SECURE COPY OF THIS DOCUMENT WILL BE SENT TO YOUR EMAIL AFTER SIGNING.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10, color: AppColors.textSecondary, letterSpacing: 0.3),
          )),
        ]),
      ),
    );
  }
}

class _ConsentCheck extends StatelessWidget {
  final bool value; final ValueChanged<bool?> onChanged; final String text;
  const _ConsentCheck({required this.value, required this.onChanged, required this.text});
  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Checkbox(value: value, onChanged: onChanged, activeColor: AppColors.primary),
      Expanded(child: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Text(text, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4)),
      )),
    ]);
  }
}

/// Wireframe F4: Lease Signed Success
class _LeaseSignedSuccess extends StatelessWidget {
  final Map<String, dynamic> lease;
  const _LeaseSignedSuccess({required this.lease});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(children: [
            Container(width: 80, height: 80,
              decoration: BoxDecoration(color: AppColors.primary.withAlpha(20), shape: BoxShape.circle),
              child: const Icon(Icons.check_circle, color: AppColors.primary, size: 48)),
            const SizedBox(height: 20),
            const Text('Lease Signed!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text("Congratulations! You've successfully signed your lease for ${lease['unitName']} at ${lease['propertyName']}.",
              textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 24),
            // Signed copy card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(12)),
              child: const Row(children: [
                Icon(Icons.description, color: AppColors.primary),
                SizedBox(width: 10),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Standard_Lease_Agreement.pdf', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  Text('PDF DOCUMENT', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                ]),
              ]),
            ),
            const SizedBox(height: 24),
            // Finalize onboarding
            const Align(alignment: Alignment.centerLeft,
              child: Text('FINALIZE ONBOARDING', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                color: AppColors.textSecondary, letterSpacing: 0.5))),
            const SizedBox(height: 12),
            _OnboardingStep(Icons.payment, 'Setup Rent Payments', 'Required', () {}),
            const SizedBox(height: 8),
            _OnboardingStep(Icons.upload_file, 'Upload Remaining Docs', 'Required', () {}),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
              icon: const Icon(Icons.grid_view, size: 18),
              label: const Text('Go to Dashboard'),
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            ),
          ]),
        )),
      ),
    );
  }
}

class _OnboardingStep extends StatelessWidget {
  final IconData icon; final String title; final String badge; final VoidCallback onTap;
  const _OnboardingStep(this.icon, this.title, this.badge, this.onTap);
  @override
  Widget build(BuildContext context) {
    return InkWell(onTap: onTap, child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5)),
      child: Row(children: [
        Icon(icon, color: AppColors.primary, size: 22),
        const SizedBox(width: 12),
        Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600))),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(color: AppColors.error.withAlpha(15), borderRadius: BorderRadius.circular(6)),
          child: Text(badge, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.error)),
        ),
        const SizedBox(width: 4),
        const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 18),
      ]),
    ));
  }
}
