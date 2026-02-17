import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/constants.dart';

class AdminShell extends StatelessWidget {
  final Widget child;
  const AdminShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        title: Text(
          'AURUM ADMIN',
          style: GoogleFonts.playfairDisplay(
            color: AppColors.gold,
            fontSize: 18,
            letterSpacing: 2,
          ),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: AppColors.gold),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => context.go('/'),
            icon: const Icon(Icons.storefront, size: 18),
            label: const Text('Tienda'),
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: child,
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;

    return Drawer(
      backgroundColor: AppColors.navy,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: AppColors.background,
              border: Border(bottom: BorderSide(color: AppColors.divider)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.gold, width: 1.5),
                  ),
                  child: Center(
                    child: Text(
                      'A',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 24,
                        color: AppColors.gold,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Panel de Administración',
                  style: GoogleFonts.inter(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'AURUM',
                  style: GoogleFonts.inter(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          _drawerItem(
            context,
            icon: Icons.dashboard_outlined,
            label: 'Dashboard',
            route: '/admin',
            isSelected: location == '/admin',
          ),
          _drawerItem(
            context,
            icon: Icons.inventory_2_outlined,
            label: 'Productos',
            route: '/admin/products',
            isSelected: location.startsWith('/admin/products'),
          ),
          _drawerItem(
            context,
            icon: Icons.receipt_long_outlined,
            label: 'Pedidos',
            route: '/admin/orders',
            isSelected: location.startsWith('/admin/orders'),
          ),
          _drawerItem(
            context,
            icon: Icons.people_outline,
            label: 'Clientes',
            route: '/admin/clients',
            isSelected: location == '/admin/clients',
          ),
          _drawerItem(
            context,
            icon: Icons.local_offer_outlined,
            label: 'Ofertas',
            route: '/admin/offers',
            isSelected: location == '/admin/offers',
          ),
          const Divider(color: AppColors.divider),
          _drawerItem(
            context,
            icon: Icons.storefront_outlined,
            label: 'Volver a la Tienda',
            route: '/',
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String route,
    bool isSelected = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppColors.gold : AppColors.textMuted,
        size: 22,
      ),
      title: Text(
        label,
        style: GoogleFonts.inter(
          color: isSelected ? AppColors.gold : AppColors.textSecondary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          fontSize: 14,
        ),
      ),
      selected: isSelected,
      selectedTileColor: AppColors.gold.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onTap: () {
        Navigator.of(context).pop(); // Close drawer
        context.go(route);
      },
    );
  }
}
