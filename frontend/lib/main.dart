import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'theme/app_theme.dart';
import 'screens/auth/splash_welcome_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/landlord/landlord_dashboard.dart';
import 'screens/landlord/property_list_screen.dart';
import 'screens/landlord/lease_list_screen.dart';
import 'screens/landlord/payment_list_screen.dart';
import 'screens/landlord/account_screen.dart';
import 'screens/tenant/tenant_dashboard.dart';
import 'screens/tenant/tenant_lease_screen.dart';
import 'screens/tenant/tenant_payment_screen.dart';
import 'screens/tenant/document_screen.dart';
import 'screens/shared/invite_screen.dart';
import 'screens/shared/move_out_screen.dart';
import 'screens/shared/notifications_screen.dart';
import 'screens/tenant/tenant_onboarding_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthProvider()..checkAuth(),
      child: const AyrnowApp(),
    ),
  );
}

class AyrnowApp extends StatelessWidget {
  const AyrnowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AYRNOW',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const _AuthGate(),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (_, auth, __) {
        if (auth.isLoading) return const _LoadingSplash();
        if (!auth.isLoggedIn) return const _AuthFlow();
        if (auth.isLandlord) return const LandlordShell();
        return const TenantShell();
      },
    );
  }
}

/// Simple loading state while checking stored token
class _LoadingSplash extends StatelessWidget {
  const _LoadingSplash();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset('assets/logo.png', width: 64, height: 64),
            ),
            const SizedBox(height: 16),
            const Text('AYRNOW', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.primary)),
            const SizedBox(height: 24),
            const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
          ],
        ),
      ),
    );
  }
}

/// Auth flow navigator: Splash Welcome -> Login -> Register -> Forgot Password
class _AuthFlow extends StatefulWidget {
  const _AuthFlow();

  @override
  State<_AuthFlow> createState() => _AuthFlowState();
}

class _AuthFlowState extends State<_AuthFlow> {
  String _currentScreen = 'welcome'; // welcome, login, register, forgot

  @override
  Widget build(BuildContext context) {
    return switch (_currentScreen) {
      'welcome' => SplashWelcomeScreen(
          onLogin: () => setState(() => _currentScreen = 'login'),
          onCreateAccount: () => setState(() => _currentScreen = 'register'),
        ),
      'login' => LoginScreen(
          onForgotPassword: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const ForgotPasswordScreen())),
          onCreateAccount: () => setState(() => _currentScreen = 'register'),
        ),
      'register' => RegisterScreen(),
      _ => SplashWelcomeScreen(
          onLogin: () => setState(() => _currentScreen = 'login'),
          onCreateAccount: () => setState(() => _currentScreen = 'register'),
        ),
    };
  }
}

/// Landlord bottom nav shell — matches wireframe: Dashboard | Properties | Leases | Payments | Account
class LandlordShell extends StatefulWidget {
  const LandlordShell({super.key});

  @override
  State<LandlordShell> createState() => _LandlordShellState();
}

class _LandlordShellState extends State<LandlordShell> {
  int _currentIndex = 0;

  final _pages = const [
    LandlordDashboard(),
    PropertyListScreen(),
    LeaseListScreen(),
    LandlordPaymentScreen(),
    AccountScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.apartment_outlined), selectedIcon: Icon(Icons.apartment), label: 'Properties'),
          NavigationDestination(icon: Icon(Icons.description_outlined), selectedIcon: Icon(Icons.description), label: 'Leases'),
          NavigationDestination(icon: Icon(Icons.payments_outlined), selectedIcon: Icon(Icons.payments), label: 'Payments'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Account'),
        ],
      ),
    );
  }
}

/// Tenant bottom nav shell — matches wireframe: Home | Lease | Pay | Docs | Account
class TenantShell extends StatefulWidget {
  const TenantShell({super.key});

  @override
  State<TenantShell> createState() => _TenantShellState();
}

class _TenantShellState extends State<TenantShell> {
  int _currentIndex = 0;

  final _pages = const [
    TenantDashboard(),
    TenantLeaseScreen(),
    TenantPaymentScreen(),
    DocumentScreen(),
    AccountScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.description_outlined), selectedIcon: Icon(Icons.description), label: 'Lease'),
          NavigationDestination(icon: Icon(Icons.payment_outlined), selectedIcon: Icon(Icons.payment), label: 'Pay'),
          NavigationDestination(icon: Icon(Icons.folder_outlined), selectedIcon: Icon(Icons.folder), label: 'Docs'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Account'),
        ],
      ),
    );
  }
}
