import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  int _step = 1; // 1 = personal info, 2 = role selection
  final _formKey = GlobalKey<FormState>();
  final _firstNameC = TextEditingController();
  final _lastNameC = TextEditingController();
  final _emailC = TextEditingController();
  final _passwordC = TextEditingController();
  final _inviteCodeC = TextEditingController();
  String _selectedRole = 'LANDLORD';
  bool _obscure = true;

  @override
  void dispose() {
    _firstNameC.dispose();
    _lastNameC.dispose();
    _emailC.dispose();
    _passwordC.dispose();
    _inviteCodeC.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_step == 1) {
      if (!_formKey.currentState!.validate()) return;
      setState(() => _step = 2);
    }
  }

  Future<void> _register() async {
    final auth = context.read<AuthProvider>();
    final success = await auth.register(
      _emailC.text.trim(),
      _passwordC.text,
      _firstNameC.text.trim(),
      _lastNameC.text.trim(),
      _selectedRole,
      inviteCode: _inviteCodeC.text.isNotEmpty ? _inviteCodeC.text.trim() : null,
    );
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error ?? 'Registration failed'), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_step > 1) {
              setState(() => _step--);
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: const Text('Create Account'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text('STEP $_step OF 2',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: _step == 1 ? _buildStep1(auth) : _buildStep2(auth),
      ),
    );
  }

  Widget _buildStep1(AuthProvider auth) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: 0.5,
                minHeight: 4,
                backgroundColor: AppColors.border,
                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Personal Information',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textDark)),
            const SizedBox(height: 8),
            const Text("Let's get to know you. This information will be used for your account.",
              style: TextStyle(fontSize: 15, color: AppColors.textSecondary, height: 1.5)),
            const SizedBox(height: 28),
            // First name
            const Text('First Name', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _firstNameC,
              decoration: const InputDecoration(hintText: 'e.g. John'),
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 20),
            // Last name
            const Text('Last Name', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _lastNameC,
              decoration: const InputDecoration(hintText: 'e.g. Smith'),
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 20),
            // Email
            const Text('Email Address', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
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
            const SizedBox(height: 20),
            // Password
            const Text('Create Password', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _passwordC,
              obscureText: _obscure,
              decoration: InputDecoration(
                hintText: 'At least 8 characters',
                prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textSecondary, size: 20),
                suffixIcon: IconButton(
                  icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 20),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
              validator: (v) => v == null || v.length < 6 ? 'Min 6 characters' : null,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _nextStep,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Next: Account Type'),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, size: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2(AuthProvider auth) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: 1.0,
              minHeight: 4,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
          const SizedBox(height: 24),
          const Text('How will you use AYRNOW?',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          const SizedBox(height: 8),
          const Text("We'll customize your experience based on your role. Don't worry, you can change this later.",
            style: TextStyle(fontSize: 15, color: AppColors.textSecondary, height: 1.5)),
          const SizedBox(height: 28),
          // Landlord card
          _RoleCard(
            icon: Icons.home_work,
            title: 'I am a Landlord',
            description: 'Perfect for property owners and managers looking to automate their rental business.',
            tags: const ['Unlimited Properties', 'Lease Automation', 'Rent Collection'],
            isSelected: _selectedRole == 'LANDLORD',
            onTap: () => setState(() => _selectedRole = 'LANDLORD'),
          ),
          const SizedBox(height: 16),
          // Tenant card
          _RoleCard(
            icon: Icons.person_outline,
            title: 'I am a Tenant',
            description: 'Ideal for renters who want a secure way to pay rent and manage their home documents.',
            tags: const ['Easy Rent Payments', 'Digital Leases', 'Maintenance Requests'],
            isSelected: _selectedRole == 'TENANT',
            onTap: () => setState(() => _selectedRole = 'TENANT'),
          ),
          // Invite code for tenants
          if (_selectedRole == 'TENANT') ...[
            const SizedBox(height: 20),
            const Text('Invite Code (optional)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _inviteCodeC,
              decoration: const InputDecoration(hintText: 'Enter code from landlord'),
            ),
          ],
          const SizedBox(height: 24),
          // Trust badge
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withAlpha(30)),
            ),
            child: const Row(
              children: [
                Icon(Icons.verified_user_outlined, color: AppColors.primary, size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('SECURE & VERIFIED',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary, letterSpacing: 0.5)),
                      SizedBox(height: 2),
                      Text('AYRNOW uses bank-grade encryption to protect your data and verify all users on our platform.',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Continue button
          ElevatedButton(
            onPressed: auth.isLoading ? null : _register,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: auth.isLoading
              ? const SizedBox(height: 20, width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Continue'),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, size: 20),
                  ],
                ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text('By continuing, you agree to our Terms of Service and Privacy Policy.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary.withAlpha(153))),
          ),
        ],
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final List<String> tags;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.tags,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected ? AppColors.primary.withAlpha(8) : AppColors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary.withAlpha(25) : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: isSelected ? AppColors.primary : AppColors.textSecondary, size: 24),
                ),
                const Spacer(),
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('SELECTED', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark)),
            const SizedBox(height: 6),
            Text(description, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.4)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: tags.map((t) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary.withAlpha(20) : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(t, style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w500,
                  color: isSelected ? AppColors.primary : AppColors.textSecondary)),
              )).toList(),
            ),
            if (isSelected) ...[
              const SizedBox(height: 12),
              const Row(
                children: [
                  Text('SELECTED ROLE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
                  SizedBox(width: 4),
                  Icon(Icons.chevron_right, color: AppColors.primary, size: 16),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
