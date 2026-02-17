import 'package:flutter/material.dart';

class AppColors {
  // Primary palette
  static const Color navy = Color(0xFF0A1628);
  static const Color navyLight = Color(0xFF0F1D32);
  static const Color navySurface = Color(0xFF152238);
  static const Color navyCard = Color(0xFF1A2942);

  // Accent
  static const Color gold = Color(0xFFC8A96E);
  static const Color goldLight = Color(0xFFD4BC8E);
  static const Color goldDark = Color(0xFFB08D4F);

  // Backgrounds
  static const Color background = Color(0xFF060D18);
  static const Color surface = Color(0xFF0F1D32);

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0BEC5);
  static const Color textMuted = Color(0xFF6B7B8D);

  // Status
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFCF6679);
  static const Color warning = Color(0xFFFFC107);
  static const Color info = Color(0xFF29B6F6);

  // Misc
  static const Color divider = Color(0xFF1E3050);
  static const Color shimmerBase = Color(0xFF152238);
  static const Color shimmerHighlight = Color(0xFF1E3050);
}

class AppSizes {
  static const double borderRadius = 12.0;
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusLarge = 16.0;
  static const double borderRadiusPill = 24.0;

  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;

  static const double iconS = 16.0;
  static const double iconM = 24.0;
  static const double iconL = 32.0;

  static const double productCardHeight = 280.0;
  static const double productImageHeight = 200.0;
  static const double bottomNavHeight = 64.0;
}

class AppStrings {
  static const String appName = 'AURUM';
  static const String tagline = 'Para el hombre moderno';

  // Order statuses
  static const Map<String, String> orderStatuses = {
    'pending': 'Pendiente',
    'paid': 'Pagado',
    'confirmed': 'Confirmado',
    'processing': 'En Proceso',
    'shipped': 'Enviado',
    'delivered': 'Entregado',
    'cancelled': 'Cancelado',
    'refunded': 'Reembolsado',
  };

  static const Map<String, String> orderStatusLabels = {
    'pendiente': 'Pendiente',
    'confirmado': 'Confirmado',
    'enviado': 'Enviado',
    'entregado': 'Entregado',
    'cancelado': 'Cancelado',
  };
}
