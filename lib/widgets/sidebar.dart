import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../features/auth/providers/auth_provider.dart';

class Sidebar extends StatelessWidget {
  final String currentRoute;

  const Sidebar({super.key, this.currentRoute = ''});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Agamudayar Admin',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Content Approval System',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          _buildNavItem(
            context,
            'Dashboard',
            Icons.dashboard,
            '/dashboard',
            currentRoute == '/dashboard',
          ),
          _buildNavItem(
            context,
            'News Approval',
            Icons.article,
            '/news',
            currentRoute == '/news',
          ),
          _buildNavItem(
            context,
            'News API',
            Icons.cloud_download,
            '/news/api',
            currentRoute == '/news/api',
          ),
          _buildNavItem(
            context,
            'Jobs Approval',
            Icons.work,
            '/jobs',
            currentRoute == '/jobs',
          ),
          _buildNavItem(
            context,
            'Advertisements Approval',
            Icons.campaign,
            '/advertisements',
            currentRoute == '/advertisements',
          ),
          _buildNavItem(
            context,
            'Matrimony Approval',
            Icons.favorite,
            '/matrimony',
            currentRoute == '/matrimony',
          ),
          const Divider(),
          _buildLogoutItem(context),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    String title,
    IconData icon,
    String route,
    bool isSelected,
  ) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected
            ? Theme.of(context).colorScheme.primary
            : AppColors.grey.withOpacity(0.7),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : AppColors.grey.withOpacity(0.9),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      tileColor: isSelected ? const Color(0xFFF3E5F5) : null, // Light lavender background for selected items
      onTap: () {
        if (route != currentRoute) {
          context.go(route);
        }
        Navigator.pop(context); // Close the drawer
      },
    );
  }

  Widget _buildLogoutItem(BuildContext context) {
    return ListTile(
      leading: Icon(
        Icons.logout,
        color: AppColors.grey.withOpacity(0.7),
      ),
      title: Text(
        'Logout',
        style: TextStyle(
          color: AppColors.grey.withOpacity(0.9),
          fontWeight: FontWeight.normal,
        ),
      ),
      onTap: () async {
        Navigator.pop(context); // Close the drawer first
        
        // Show confirmation dialog
        final shouldLogout = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Logout'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Logout'),
              ),
            ],
          ),
        );
        
        if (shouldLogout == true) {
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          await authProvider.signOut();
          // Navigation will be handled automatically by the router redirect
        }
      },
    );
  }
}