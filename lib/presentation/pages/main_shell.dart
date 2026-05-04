import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth/auth_bloc.dart';
import 'dashboard/dashboard_page.dart';
import 'kandang/kandang_list_page.dart';
import 'produksi/produksi_page.dart';
import 'stok/stok_page.dart';
import 'profile/profile_page.dart';
import 'feedback/feedback_page.dart';
 
class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}
 
class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
 
  final _pages = const [
    DashboardPage(),
    KandangListPage(),
    ProduksiPage(),
    StokPage(),
    ProfilePage(),
    FeedbackPage(),
  ];
 
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
 
    return BlocListener<AuthBloc, AuthState>(
      listener: (ctx, state) {
        if (state is AuthLoggedOut) {
          Navigator.pushReplacementNamed(ctx, '/login');
        }
      },
      child: Scaffold(
        body: IndexedStack(index: _currentIndex, children: _pages),
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: (i) => setState(() => _currentIndex = i),
              destinations: const [
                NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Dashboard'),
                NavigationDestination(icon: Icon(Icons.home_outlined),      selectedIcon: Icon(Icons.home),           label: 'Kandang'),
                NavigationDestination(icon: Icon(Icons.egg_outlined),       selectedIcon: Icon(Icons.egg),            label: 'Produksi'),
                NavigationDestination(icon: Icon(Icons.inventory_2_outlined), selectedIcon: Icon(Icons.inventory_2), label: 'Stok'),
                NavigationDestination(icon: Icon(Icons.person_outlined),    selectedIcon: Icon(Icons.person),         label: 'Profil'),
                NavigationDestination(icon: Icon(Icons.feedback_outlined),  selectedIcon: Icon(Icons.feedback),       label: 'Feedback'),
              ],
            ),
            // Logout di bawah nav bar sebagai TextButton
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: TextButton.icon(
                  onPressed: () => _confirmLogout(context),
                  icon: Icon(Icons.logout_rounded, size: 18, color: cs.error),
                  label: Text('Keluar', style: TextStyle(color: cs.error, fontSize: 12)),
                  style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
 
  void _confirmLogout(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Keluar Aplikasi'),
        content: const Text('Apakah kamu yakin ingin keluar?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(LogoutEvent());
            },
            style: FilledButton.styleFrom(backgroundColor: cs.error),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }
}
 