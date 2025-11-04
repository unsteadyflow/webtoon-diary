import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// 사용자 친화적 피드백을 위한 Snackbar 위젯 래퍼
/// Design Guide 기반: Toast 하단 2초, Snack/Inline 액션 포함 시 4초
class AppSnackbar {
  /// 성공 메시지 표시
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration? duration,
    SnackBarAction? action,
  }) {
    _show(
      context,
      message: message,
      backgroundColor: AppTheme.success,
      icon: Icons.check_circle_outline,
      duration: duration ?? const Duration(seconds: 2),
      action: action,
    );
  }

  /// 에러 메시지 표시
  static void showError(
    BuildContext context,
    String message, {
    Duration? duration,
    SnackBarAction? action,
  }) {
    _show(
      context,
      message: message,
      backgroundColor: AppTheme.error,
      icon: Icons.error_outline,
      duration: duration ?? const Duration(seconds: 3),
      action: action,
    );
  }

  /// 경고 메시지 표시
  static void showWarning(
    BuildContext context,
    String message, {
    Duration? duration,
    SnackBarAction? action,
  }) {
    _show(
      context,
      message: message,
      backgroundColor: AppTheme.warning,
      icon: Icons.warning_amber_outlined,
      duration: duration ?? const Duration(seconds: 3),
      action: action,
    );
  }

  /// 정보 메시지 표시
  static void showInfo(
    BuildContext context,
    String message, {
    Duration? duration,
    SnackBarAction? action,
  }) {
    _show(
      context,
      message: message,
      backgroundColor: AppTheme.primaryColor,
      icon: Icons.info_outline,
      duration: duration ?? const Duration(seconds: 2),
      action: action,
    );
  }

  /// 일반 메시지 표시
  static void show(
    BuildContext context,
    String message, {
    Color? backgroundColor,
    IconData? icon,
    Duration? duration,
    SnackBarAction? action,
  }) {
    _show(
      context,
      message: message,
      backgroundColor: backgroundColor ?? AppTheme.textPrimary,
      icon: icon,
      duration: duration ?? const Duration(seconds: 2),
      action: action,
    );
  }

  /// 내부 메서드: Snackbar 표시
  static void _show(
    BuildContext context, {
    required String message,
    required Color backgroundColor,
    IconData? icon,
    required Duration duration,
    SnackBarAction? action,
  }) {
    // 액션이 있으면 4초, 없으면 지정된 duration
    final displayDuration = action != null
        ? const Duration(seconds: 4)
        : duration;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: displayDuration,
        behavior: SnackBarBehavior.fixed,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        action: action,
      ),
    );
  }
}

