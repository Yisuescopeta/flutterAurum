import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/client/home_screen.dart';
import '../screens/client/catalog_screen.dart';
import '../screens/client/product_detail_screen.dart';
import '../screens/client/cart_screen.dart';
import '../screens/client/checkout_screen.dart';
import '../screens/client/order_success_screen.dart';
import '../screens/client/profile_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/admin/admin_products_screen.dart';
import '../screens/admin/admin_product_form_screen.dart';
import '../screens/admin/admin_orders_screen.dart';
import '../screens/admin/admin_order_detail_screen.dart';
import '../screens/admin/admin_clients_screen.dart';
import '../screens/admin/admin_offers_screen.dart';
import '../screens/shared/client_shell.dart';
import '../screens/shared/admin_shell.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _clientShellKey = GlobalKey<NavigatorState>();
  static final _adminShellKey = GlobalKey<NavigatorState>();

  static GoRouter router(BuildContext context) {
    final authProvider = context.read<AuthProvider>();

    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/splash',
      debugLogDiagnostics: true,
      refreshListenable: authProvider,
      redirect: (context, state) {
        final isAuthenticated = authProvider.isAuthenticated;
        final isAdmin = authProvider.isAdmin;
        final isLoading = authProvider.isLoading;
        final location = state.matchedLocation;

        // While loading, stay on splash
        if (isLoading && location == '/splash') return null;

        // Auth pages
        if (location == '/login' || location == '/register') {
          if (isAuthenticated) return '/';
          return null;
        }

        // Splash
        if (location == '/splash') {
          if (!isLoading && isAuthenticated) return '/';
          if (!isLoading && !isAuthenticated) return '/login';
          return null;
        }

        // Admin routes
        if (location.startsWith('/admin')) {
          if (!isAuthenticated) return '/login';
          if (!isAdmin) return '/';
          return null;
        }

        // Protected routes
        if (!isAuthenticated &&
            (location.startsWith('/cart') ||
                location.startsWith('/checkout') ||
                location.startsWith('/profile'))) {
          return '/login';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),

        // Client Shell with BottomNav
        ShellRoute(
          navigatorKey: _clientShellKey,
          builder: (context, state, child) => ClientShell(child: child),
          routes: [
            GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
            GoRoute(
              path: '/catalog',
              builder: (context, state) => const CatalogScreen(),
            ),
            GoRoute(
              path: '/cart',
              builder: (context, state) => const CartScreen(),
            ),
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),

        // Full-screen routes (outside shell)
        GoRoute(
          path: '/product/:id',
          builder: (context, state) =>
              ProductDetailScreen(productId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/checkout',
          builder: (context, state) => const CheckoutScreen(),
        ),
        GoRoute(
          path: '/order-success',
          builder: (context, state) => const OrderSuccessScreen(),
        ),

        // Admin Shell
        ShellRoute(
          navigatorKey: _adminShellKey,
          builder: (context, state, child) => AdminShell(child: child),
          routes: [
            GoRoute(
              path: '/admin',
              builder: (context, state) => const AdminDashboardScreen(),
            ),
            GoRoute(
              path: '/admin/products',
              builder: (context, state) => const AdminProductsScreen(),
            ),
            GoRoute(
              path: '/admin/products/new',
              builder: (context, state) => const AdminProductFormScreen(),
            ),
            GoRoute(
              path: '/admin/products/:id',
              builder: (context, state) =>
                  AdminProductFormScreen(productId: state.pathParameters['id']),
            ),
            GoRoute(
              path: '/admin/orders',
              builder: (context, state) => const AdminOrdersScreen(),
            ),
            GoRoute(
              path: '/admin/orders/:id',
              builder: (context, state) =>
                  AdminOrderDetailScreen(orderId: state.pathParameters['id']!),
            ),
            GoRoute(
              path: '/admin/clients',
              builder: (context, state) => const AdminClientsScreen(),
            ),
            GoRoute(
              path: '/admin/offers',
              builder: (context, state) => const AdminOffersScreen(),
            ),
          ],
        ),
      ],
    );
  }
}
