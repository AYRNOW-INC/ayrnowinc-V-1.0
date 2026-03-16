import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../tenant/invite_accept_screen.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onForgotPassword;
  final VoidCallback onCreateAccount;

  const LoginScreen({
    super.key,
    required this.onForgotPassword,
    required this.onCreateAccount,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailC = TextEditingController();
  final _passwordC = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailC.dispose();
    _passwordC.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.login(_emailC.text.trim(), _passwordC.text);
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error ?? 'Login failed'), backgroundColor: AppColors.error),
      );
    }
  }

  void _showInviteCodeDialog(BuildContext context) {
    final codeC = TextEditingController();
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Enter Invite Code'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('Enter the invite code from your landlord to view your invitation.',
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
        const SizedBox(height: 16),
        TextField(controller: codeC, textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(hintText: 'e.g. F410ACE1', prefixIcon: Icon(Icons.vpn_key, size: 20))),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ElevatedButton(onPressed: () {
          if (codeC.text.trim().isEmpty) return;
          Navigator.pop(ctx);
          Navigator.push(context, MaterialPageRoute(
            builder: (_) => InviteAcceptScreen(inviteCode: codeC.text.trim())));
        }, child: const Text('View Invitation')),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top logo bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.asset('assets/logo.png', width: 32, height: 32),
                ),
              ),
              const Divider(color: AppColors.border, height: 1),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      // Welcome heading
                      const Text(
                        'Welcome back',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Enter your credentials to manage your\nproperties and leases.',
                        style: TextStyle(fontSize: 16, color: AppColors.textSecondary, height: 1.5),
                      ),
                      const SizedBox(height: 32),
                      // Email field
                      const Text('Email or Phone',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textDark)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _emailC,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          hintText: 'john@example.com',
                          prefixIcon: Icon(Icons.mail_outline, color: AppColors.textSecondary, size: 20),
                        ),
                        validator: (v) => v == null || !v.contains('@') ? 'Valid email required' : null,
                      ),
                      const SizedBox(height: 24),
                      // Password field with forgot password link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Password',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textDark)),
                          GestureDetector(
                            onTap: widget.onForgotPassword,
                            child: const Text('Forgot password?',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _passwordC,
                        obscureText: _obscure,
                        decoration: InputDecoration(
                          hintText: '\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022',
                          prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textSecondary, size: 20),
                          suffixIcon: IconButton(
                            icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                              color: AppColors.textSecondary, size: 20),
                            onPressed: () => setState(() => _obscure = !_obscure),
                          ),
                        ),
                        validator: (v) => v == null || v.length < 8 ? 'Min 8 characters' : null,
                      ),
                      const SizedBox(height: 24),
                      // Sign In button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: auth.isLoading ? null : _signIn,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: auth.isLoading
                            ? const SizedBox(height: 20, width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text('Sign In', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                        ),
                      ),
                      const SizedBox(height: 32),
                      // OR CONTINUE WITH divider
                      Row(
                        children: [
                          const Expanded(child: Divider(color: AppColors.border)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text('OR CONTINUE WITH',
                              style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary, letterSpacing: 1.2)),
                          ),
                          const Expanded(child: Divider(color: AppColors.border)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Google button (deferred — native OAuth planned for future release)
                      _SocialButton(
                        icon: Icons.g_mobiledata,
                        label: 'Google',
                        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Google sign-in coming soon'))),
                      ),
                      const SizedBox(height: 12),
                      // Apple button (deferred — native OAuth planned for future release)
                      _SocialButton(
                        icon: Icons.apple,
                        label: 'Apple',
                        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Apple sign-in coming soon'))),
                      ),
                      const SizedBox(height: 40),
                      // Create account footer
                      Center(
                        child: Column(
                          children: [
                            const Text('New to AYRNOW?',
                              style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                            const SizedBox(height: 4),
                            GestureDetector(
                              onTap: widget.onCreateAccount,
                              child: const Text('Create an account',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary)),
                            ),
                            const SizedBox(height: 16),
                            GestureDetector(
                              onTap: () => _showInviteCodeDialog(context),
                              child: const Text('Have an invite code?',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.teal)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SocialButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: AppColors.textDark, size: 20),
        label: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
    );
  }
}
