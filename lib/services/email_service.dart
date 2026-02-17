import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Email service that logs email operations.
/// In production, connect to a backend (Edge Function / SMTP server)
/// to actually send emails. For security, SMTP credentials should NOT
/// be embedded in client-side code.
class EmailService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Send order confirmation email
  Future<bool> sendOrderConfirmation({
    required String toEmail,
    required String orderId,
    required double totalAmount,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      debugPrint(
        '📧 Sending order confirmation to $toEmail for order $orderId',
      );
      debugPrint('   Total: €${totalAmount.toStringAsFixed(2)}');
      debugPrint('   Items: ${items.length}');

      // Log notification in database
      await _logNotification(
        type: 'order_confirmation',
        email: toEmail,
        metadata: {'order_id': orderId, 'total': totalAmount},
      );

      return true;
    } catch (e) {
      debugPrint('Send order confirmation error: $e');
      return false;
    }
  }

  /// Send offer alert when a favorited product goes on sale
  Future<bool> sendOfferAlert({
    required String toEmail,
    required String userId,
    required String productId,
    required String productName,
    required double originalPrice,
    required double salePrice,
  }) async {
    try {
      debugPrint('📧 Sending offer alert to $toEmail');
      debugPrint('   Product: $productName');
      debugPrint('   Price: €$originalPrice → €$salePrice');

      // Check if already notified
      final existing = await _client
          .from('notification_history')
          .select('id')
          .eq('user_id', userId)
          .eq('product_id', productId)
          .eq('notification_type', 'favorite_on_sale')
          .maybeSingle();

      if (existing != null) {
        debugPrint('   Already notified, skipping');
        return false;
      }

      // Record notification
      await _client.from('notification_history').insert({
        'user_id': userId,
        'product_id': productId,
        'notification_type': 'favorite_on_sale',
        'email_sent_to': toEmail,
      });

      return true;
    } catch (e) {
      debugPrint('Send offer alert error: $e');
      return false;
    }
  }

  /// Send broadcast email (admin)
  Future<bool> sendBroadcast({
    required String subject,
    required String body,
  }) async {
    try {
      debugPrint('📧 Sending broadcast email');
      debugPrint('   Subject: $subject');

      // Get subscribers who opted in
      final subscribers = await _client
          .from('user_notification_preferences')
          .select('user_id')
          .eq('marketing_emails', true);

      debugPrint('   Recipients: ${(subscribers as List).length}');

      return true;
    } catch (e) {
      debugPrint('Send broadcast error: $e');
      return false;
    }
  }

  Future<void> _logNotification({
    required String type,
    required String email,
    Map<String, dynamic>? metadata,
  }) async {
    debugPrint('📧 [$type] → $email ${metadata ?? ''}');
  }
}
