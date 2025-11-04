import 'package:flutter/material.dart';
import '../widgets/app_snackbar.dart';
import '../services/sentry_service.dart';

/// 중앙화된 에러 핸들링 유틸리티
/// 앱 전반에서 일관된 에러 처리 제공
class ErrorHandler {
  /// 에러 타입 분류
  static ErrorType classifyError(dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('network') ||
        errorString.contains('connection') ||
        errorString.contains('timeout') ||
        errorString.contains('socket') ||
        errorString.contains('failed host lookup')) {
      return ErrorType.network;
    }

    if (errorString.contains('permission') ||
        errorString.contains('access denied')) {
      return ErrorType.permission;
    }

    if (errorString.contains('login') ||
        errorString.contains('auth') ||
        errorString.contains('credential') ||
        errorString.contains('unauthorized')) {
      return ErrorType.authentication;
    }

    if (errorString.contains('not found') ||
        errorString.contains('404')) {
      return ErrorType.notFound;
    }

    if (errorString.contains('validation') ||
        errorString.contains('invalid')) {
      return ErrorType.validation;
    }

    return ErrorType.unknown;
  }

  /// 사용자 친화적 에러 메시지 생성
  static String getErrorMessage(dynamic error, {String? customMessage}) {
    if (customMessage != null) {
      return customMessage;
    }

    final errorType = classifyError(error);
    switch (errorType) {
      case ErrorType.network:
        return '네트워크 연결을 확인해주세요.';
      case ErrorType.permission:
        return '권한이 필요합니다. 설정에서 권한을 허용해주세요.';
      case ErrorType.authentication:
        return '로그인이 필요합니다.';
      case ErrorType.notFound:
        return '요청한 데이터를 찾을 수 없습니다.';
      case ErrorType.validation:
        return '입력한 정보를 확인해주세요.';
      case ErrorType.unknown:
        return '오류가 발생했습니다. 잠시 후 다시 시도해주세요.';
    }
  }

  /// 에러를 사용자에게 표시
  static void showError(
    BuildContext context,
    dynamic error, {
    String? customMessage,
    SnackBarAction? action,
  }) {
    final message = getErrorMessage(error, customMessage: customMessage);
    AppSnackbar.showError(
      context,
      message,
      action: action,
    );
  }

  /// 에러 로깅 (Sentry 통합)
  static void logError(dynamic error, {StackTrace? stackTrace}) {
    // 개발 모드에서는 콘솔에 출력
    debugPrint('Error: $error');
    if (stackTrace != null) {
      debugPrint('Stack trace: $stackTrace');
    }

    // Sentry로 전송
    try {
      SentryService.captureException(
        error,
        stackTrace: stackTrace,
        extra: {
          'error_type': classifyError(error).toString(),
        },
      );
    } catch (e) {
      // Sentry 전송 실패는 무시
      debugPrint('Failed to send error to Sentry: $e');
    }
  }

  /// 에러 처리 및 표시 (통합 메서드)
  static void handleError(
    BuildContext? context,
    dynamic error, {
    String? customMessage,
    SnackBarAction? action,
    StackTrace? stackTrace,
  }) {
    // 에러 로깅
    logError(error, stackTrace: stackTrace);

    // 컨텍스트가 있으면 사용자에게 표시
    if (context != null) {
      showError(context, error, customMessage: customMessage, action: action);
    }
  }
}

/// 에러 타입 열거형
enum ErrorType {
  network,
  permission,
  authentication,
  notFound,
  validation,
  unknown,
}

