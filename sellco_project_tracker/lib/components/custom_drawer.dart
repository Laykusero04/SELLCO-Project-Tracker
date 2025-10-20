import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../screens/expenses_screen.dart';

class CustomDrawer extends StatelessWidget {
  final String currentRoute;

  const CustomDrawer({
    super.key,
    this.currentRoute = '/',
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        String userEmail = 'Unknown';
        
        if (state is AuthAuthenticated) {
          userEmail = state.user.email ?? 'Unknown';
        }

        return Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      child: Text(
                        userEmail[0].toUpperCase(),
                        style: TextStyle(
                          fontSize: 40,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      userEmail,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              _buildDrawerItem(
                context,
                icon: Icons.dashboard,
                title: 'Dashboard',
                route: '/',
                onTap: () {
                  Navigator.pop(context);
                  if (currentRoute != '/') {
                    Navigator.pushReplacementNamed(context, '/');
                  }
                },
              ),
              _buildDrawerItem(
                context,
                icon: Icons.folder_outlined,
                title: 'Projects',
                route: '/projects',
                onTap: () {
                  Navigator.pop(context);
                  if (currentRoute != '/projects') {
                    // TODO: Navigate to Projects
                    _showComingSoon(context, 'Projects');
                  }
                },
              ),
              _buildDrawerItem(
                context,
                icon: Icons.people_outline,
                title: 'Developers',
                route: '/developers',
                onTap: () {
                  Navigator.pop(context);
                  if (currentRoute != '/developers') {
                    // TODO: Navigate to Developers
                    _showComingSoon(context, 'Developers');
                  }
                },
              ),
              _buildDrawerItem(
                context,
                icon: Icons.task_outlined,
                title: 'Tasks',
                route: '/tasks',
                onTap: () {
                  Navigator.pop(context);
                  if (currentRoute != '/tasks') {
                    // TODO: Navigate to Tasks
                    _showComingSoon(context, 'Tasks');
                  }
                },
              ),
              _buildDrawerItem(
                context,
                icon: Icons.receipt_long_outlined,
                title: 'Expenses',
                route: '/expenses',
                onTap: () {
                  Navigator.pop(context);
                  if (currentRoute != '/expenses') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ExpensesScreen(),
                      ),
                    );
                  }
                },
              ),
              _buildDrawerItem(
                context,
                icon: Icons.payments_outlined,
                title: 'Payments',
                route: '/payments',
                onTap: () {
                  Navigator.pop(context);
                  if (currentRoute != '/payments') {
                    // TODO: Navigate to Payments
                    _showComingSoon(context, 'Payments');
                  }
                },
              ),
              _buildDrawerItem(
                context,
                icon: Icons.analytics_outlined,
                title: 'Reports',
                route: '/reports',
                onTap: () {
                  Navigator.pop(context);
                  if (currentRoute != '/reports') {
                    // TODO: Navigate to Reports
                    _showComingSoon(context, 'Reports');
                  }
                },
              ),
              const Divider(),
              _buildDrawerItem(
                context,
                icon: Icons.settings_outlined,
                title: 'Settings',
                route: '/settings',
                onTap: () {
                  Navigator.pop(context);
                  if (currentRoute != '/settings') {
                    // TODO: Navigate to Settings
                    _showComingSoon(context, 'Settings');
                  }
                },
              ),
              _buildDrawerItem(
                context,
                icon: Icons.help_outline,
                title: 'Help & Support',
                route: '/help',
                onTap: () {
                  Navigator.pop(context);
                  if (currentRoute != '/help') {
                    // TODO: Navigate to Help
                    _showComingSoon(context, 'Help & Support');
                  }
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showLogoutDialog(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
    required VoidCallback onTap,
  }) {
    final bool isSelected = currentRoute == route;
    
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected 
          ? Theme.of(context).colorScheme.primary 
          : null,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected 
            ? Theme.of(context).colorScheme.primary 
            : null,
        ),
      ),
      selected: isSelected,
      selectedTileColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      onTap: onTap,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<AuthBloc>().add(AuthSignOutRequested());
              },
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature feature coming soon'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

