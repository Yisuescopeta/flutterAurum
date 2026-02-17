import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/constants.dart';
import '../../services/email_service.dart';

class AdminOffersScreen extends StatefulWidget {
  const AdminOffersScreen({super.key});

  @override
  State<AdminOffersScreen> createState() => _AdminOffersScreenState();
}

class _AdminOffersScreenState extends State<AdminOffersScreen> {
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isSending = false;
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      final data = await Supabase.instance.client
          .from('notification_history')
          .select()
          .order('sent_at', ascending: false)
          .limit(20);
      _notifications = List<Map<String, dynamic>>.from(data);
    } catch (e) {
      debugPrint('Load notifications error: $e');
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _sendBroadcast() async {
    if (_subjectController.text.isEmpty || _messageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos')),
      );
      return;
    }

    setState(() => _isSending = true);

    try {
      final emailService = EmailService();
      await emailService.sendBroadcast(
        subject: _subjectController.text,
        body: _messageController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Oferta enviada correctamente')),
        );
        _subjectController.clear();
        _messageController.clear();
        await _loadNotifications();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al enviar la oferta')),
        );
      }
    }

    if (mounted) setState(() => _isSending = false);
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        children: [
          Text(
            'Ofertas y Correos',
            style: GoogleFonts.playfairDisplay(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Envía ofertas y notificaciones a los clientes',
            style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 14),
          ),
          const SizedBox(height: 24),

          // New offer form
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.navyCard,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nueva Oferta',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 18,
                    color: AppColors.gold,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _subjectController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Asunto',
                    prefixIcon: Icon(
                      Icons.mail_outline,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _messageController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(labelText: 'Mensaje'),
                  maxLines: 3,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _isSending ? null : _sendBroadcast,
                    icon: _isSending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(
                                AppColors.navy,
                              ),
                            ),
                          )
                        : const Icon(Icons.send, size: 18),
                    label: Text(_isSending ? 'Enviando...' : 'ENVIAR OFERTA'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // History
          Text(
            'Historial de notificaciones',
            style: GoogleFonts.playfairDisplay(
              fontSize: 18,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: AppColors.gold),
            )
          else if (_notifications.isEmpty)
            Center(
              child: Text(
                'No hay notificaciones',
                style: GoogleFonts.inter(color: AppColors.textMuted),
              ),
            )
          else
            ..._notifications.map(
              (n) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.navyCard,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      n['type'] == 'offer' ? Icons.local_offer : Icons.email,
                      color: AppColors.gold,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            n['subject']?.toString() ??
                                n['type']?.toString() ??
                                '',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            n['sent_at']?.toString().substring(0, 10) ?? '',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
