import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Sentry 서비스
/// 런타임 오류 로깅 및 모니터링
class SentryService {
  static SentryService? _instance;
  static SentryService get instance => _instance ??= SentryService._();

  SentryService._();

  bool _isInitialized = false;

  /// Sentry 초기화
  /// 환경 변수에서 DSN을 읽어와 초기화합니다.
  static Future<void> initialize() async {
    if (instance._isInitialized) {
      return;
    }

    // 개발 모드에서는 Sentry 비활성화 (선택사항)
    if (kDebugMode) {
      debugPrint('Sentry is disabled in debug mode');
      instance._isInitialized = true;
      return;
    }

    try {
      // 환경 변수에서 Sentry DSN 읽기
      // NOTE: Sentry DSN은 선택적입니다. 필요시 config.env에 SENTRY_DSN을 추가하세요.
      // 예: SENTRY_DSN=https://your-sentry-dsn@sentry.io/project-id
      // final sentryDsn = dotenv.env['SENTRY_DSN'];

      // DSN이 없으면 초기화하지 않음
      // if (sentryDsn == null || sentryDsn.isEmpty) {
      //   debugPrint('Sentry DSN not found, skipping initialization');
      //   instance._isInitialized = true;
      //   return;
      // }

      await SentryFlutter.init(
        (options) {
          // DSN 설정
          // options.dsn = sentryDsn;

          // 환경 설정
          options.environment = kDebugMode ? 'development' : 'production';

          // 트레이스 샘플링 (성능 모니터링)
          options.tracesSampleRate = 1.0; // 100% 샘플링 (프로덕션에서는 낮춤)

          // 릴리즈 정보
          options.release = 'webtoon-diary@1.0.0';

          // 에러 필터링 (필요시 주석 해제)
          // options.beforeSend = (event, {hint}) {
          //   // 모든 이벤트 전송 (필요시 필터링 로직 추가)
          //   return event;
          // };
        },
        appRunner: () {
          // 앱 실행은 main.dart에서 처리
        },
      );

      instance._isInitialized = true;
      debugPrint('Sentry initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize Sentry: $e');
      instance._isInitialized = true; // 실패해도 앱은 계속 실행
    }
  }

  /// 에러 캡처
  static Future<void> captureException(
    dynamic exception, {
    dynamic stackTrace,
    Map<String, dynamic>? extra,
    String? level,
  }) async {
    if (!instance._isInitialized || kDebugMode) {
      return;
    }

    try {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
        hint: extra != null ? Hint.withMap(extra) : null,
      );
    } catch (e) {
      debugPrint('Failed to capture exception to Sentry: $e');
    }
  }

  /// 메시지 캡처
  static Future<void> captureMessage(
    String message, {
    SentryLevel level = SentryLevel.info,
    Map<String, dynamic>? extra,
  }) async {
    if (!instance._isInitialized || kDebugMode) {
      return;
    }

    try {
      await Sentry.captureMessage(
        message,
        level: level,
        hint: extra != null ? Hint.withMap(extra) : null,
      );
    } catch (e) {
      debugPrint('Failed to capture message to Sentry: $e');
    }
  }

  /// 사용자 정보 설정
  static Future<void> setUser({
    String? id,
    String? email,
    String? username,
    Map<String, dynamic>? data,
  }) async {
    if (!instance._isInitialized || kDebugMode) {
      return;
    }

    try {
      await Sentry.configureScope((scope) {
        scope.setUser(
          SentryUser(
            id: id,
            email: email,
            username: username,
            data: data,
          ),
        );
      });
    } catch (e) {
      debugPrint('Failed to set user in Sentry: $e');
    }
  }

  /// 컨텍스트 정보 추가
  static Future<void> setContext(
    String key,
    Map<String, dynamic> context,
  ) async {
    if (!instance._isInitialized || kDebugMode) {
      return;
    }

    try {
      await Sentry.configureScope((scope) {
        scope.setContexts(key, context);
      });
    } catch (e) {
      debugPrint('Failed to set context in Sentry: $e');
    }
  }

  /// Breadcrumb 추가 (사용자 액션 추적)
  static Future<void> addBreadcrumb(
    String message, {
    Map<String, dynamic>? data,
    String? category,
    SentryLevel level = SentryLevel.info,
  }) async {
    if (!instance._isInitialized || kDebugMode) {
      return;
    }

    try {
      await Sentry.configureScope((scope) {
        scope.addBreadcrumb(
          Breadcrumb(
            message: message,
            data: data,
            category: category ?? '',
            level: level,
          ),
        );
      });
    } catch (e) {
      debugPrint('Failed to add breadcrumb to Sentry: $e');
    }
  }
}
