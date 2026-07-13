import 'package:flutter/material.dart';
import 'package:profinch_mobile_application/core/constants/colors.dart';

enum AppNotificationType { success, error, info, warning }

class AppNotification {
  /// Shows a styled notification banner from the TOP of the screen.
  static void show(
    BuildContext context, {
    required String message,
    AppNotificationType type = AppNotificationType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    Color bg;
    IconData icon;
    switch (type) {
      case AppNotificationType.success:
        bg   = Colors.green.shade600;
        icon = Icons.check_circle_outline;
        break;
      case AppNotificationType.error:
        bg   = Colors.red.shade600;
        icon = Icons.error_outline;
        break;
      case AppNotificationType.warning:
        bg   = Colors.orange.shade700;
        icon = Icons.warning_amber_outlined;
        break;
      case AppNotificationType.info:
        bg   = AppColors.primaryDark;
        icon = Icons.info_outline;
        break;
    }

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: bg,
          behavior: SnackBarBehavior.floating,
          // margin pushes it to the TOP — large bottom margin + zero top
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height - 120,
            left: 16,
            right: 16,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: duration,
          elevation: 6,
        ),
      );
  }

  /// Shows a centered dialog for destructive / important single-action messages
  /// (e.g. "No active policies" when trying to raise a claim).
  static void showDialog(
    BuildContext context, {
    required String title,
    required String message,
    AppNotificationType type = AppNotificationType.info,
    String buttonLabel = 'OK',
    VoidCallback? onButtonTap,
  }) {
    Color color;
    IconData icon;
    switch (type) {
      case AppNotificationType.success:
        color = Colors.green.shade600;
        icon  = Icons.check_circle_outline;
        break;
      case AppNotificationType.error:
        color = Colors.red.shade600;
        icon  = Icons.error_outline;
        break;
      case AppNotificationType.warning:
        color = Colors.orange.shade700;
        icon  = Icons.warning_amber_outlined;
        break;
      case AppNotificationType.info:
        color = AppColors.primaryDark;
        icon  = Icons.info_outline;
        break;
    }

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 220),
      transitionBuilder: (context, anim, _, child) => ScaleTransition(
        scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
        child: child,
      ),
      pageBuilder: (context, _, __) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 24),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.4),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onButtonTap?.call();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(buttonLabel,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}