import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/constants.dart';
import '../../providers/order_provider.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().loadDashboardStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (context, orderProvider, _) {
        if (orderProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.gold),
          );
        }

        final stats = orderProvider.dashboardStats;

        return RefreshIndicator(
          color: AppColors.gold,
          onRefresh: () => orderProvider.loadDashboardStats(),
          child: ListView(
            padding: const EdgeInsets.all(AppSizes.paddingM),
            children: [
              Text(
                'Dashboard',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ).animate().fadeIn(),
              const SizedBox(height: 8),
              Text(
                'Resumen general de tu tienda',
                style: GoogleFonts.inter(
                  color: AppColors.textMuted,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),

              // Stats cards
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  _buildStatCard(
                    'Ventas Totales',
                    '€${((stats['totalRevenue'] ?? 0) / 100).toStringAsFixed(2)}',
                    Icons.attach_money,
                    AppColors.gold,
                    0,
                  ),
                  _buildStatCard(
                    'Pedidos',
                    '${stats['totalOrders'] ?? 0}',
                    Icons.receipt_long,
                    Colors.blue,
                    1,
                  ),
                  _buildStatCard(
                    'Pendientes',
                    '${stats['pendingOrders'] ?? 0}',
                    Icons.hourglass_empty,
                    Colors.orange,
                    2,
                  ),
                  _buildStatCard(
                    'Productos',
                    '${stats['totalProducts'] ?? 0}',
                    Icons.inventory_2,
                    Colors.teal,
                    3,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Recent orders
              Text(
                'Pedidos recientes',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 18,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              if (stats['recentOrders'] != null)
                ...((stats['recentOrders'] as List).take(5).map((orderMap) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.navyCard,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '#${(orderMap['id'] ?? '').toString().substring(0, 8)}',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                orderMap['customer_email'] ?? '',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '€${((orderMap['total_amount'] ?? 0) / 100).toStringAsFixed(2)}',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.gold,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList())
              else
                Center(
                  child: Text(
                    'No hay pedidos recientes',
                    style: GoogleFonts.inter(color: AppColors.textMuted),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    int index,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.navyCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted),
          ),
        ],
      ),
    ).animate(delay: (100 * index).ms).fadeIn().slideY(begin: 0.1);
  }
}
