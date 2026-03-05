import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../presentation/screens/dashboard_screen.dart';
import '../viewmodels/admin_dashboard_viewmodel.dart';
import '../viewmodels/admin_users_viewmodel.dart';
import '../viewmodels/admin_emi_viewmodel.dart';
import 'admin_dashboard_screen.dart';
import 'admin_users_screen.dart';
import 'admin_emi_screen.dart';
import 'admin_lock_control_screen.dart';
 // 👈 add your user home import

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _selectedIndex = 0;
  bool _isInitialized = false;
  bool _isLoading = true;

  final List<AdminNavItem> _navItems = [
    AdminNavItem(Icons.dashboard_rounded, 'Dashboard'),
    AdminNavItem(Icons.people_rounded, 'Users'),
    AdminNavItem(Icons.account_balance_wallet_rounded, 'EMI Management'),
    AdminNavItem(Icons.lock_rounded, 'Lock Control'),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    if (_isInitialized) return;

    try {
      await Future.wait([
        context.read<AdminDashboardViewModel>().loadStats(),
        context.read<AdminUsersViewModel>().loadUsers(),
        context.read<AdminEmiViewModel>().loadEmis(),
      ]);

      if (mounted) {
        setState(() {
          _isInitialized = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Initialization failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildCurrentScreen() {
    switch (_selectedIndex) {
      case 0:
        return const AdminDashboardScreen();
      case 1:
        return const AdminUsersScreen();
      case 2:
        return const AdminEmiScreen();
      case 3:
        return const AdminLockControlScreen();
      default:
        return const AdminDashboardScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      appBar: AppBar(
        title: const Text("EMI Locker Admin"),
        actions: [
          IconButton(
            icon: const Icon(Icons.home_rounded),
            tooltip: "Go to User Home",
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const DashboardScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: "Logout",
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                    (route) => false,
              );
            },
          ),
        ],
      ),
      drawer: isDesktop ? null : _buildDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Row(
        children: [
          if (isDesktop)
            SizedBox(
              width: 250,
              child: _buildDrawerContent(),
            ),
          Expanded(child: _buildCurrentScreen()),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(child: _buildDrawerContent());
  }

  Widget _buildDrawerContent() {
    return Column(
      children: [
        DrawerHeader(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
          ),
          child: const Row(
            children: [
              Icon(Icons.admin_panel_settings,
                  color: Colors.white, size: 30),
              SizedBox(width: 10),
              Text(
                "Admin Panel",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _navItems.length,
            itemBuilder: (context, index) {
              final item = _navItems[index];
              final isSelected = _selectedIndex == index;

              return ListTile(
                leading: Icon(
                  item.icon,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
                title: Text(
                  item.label,
                  style: TextStyle(
                    fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                selected: isSelected,
                onTap: () {
                  setState(() {
                    _selectedIndex = index;
                  });

                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class AdminNavItem {
  final IconData icon;
  final String label;

  AdminNavItem(this.icon, this.label);
}