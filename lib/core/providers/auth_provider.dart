import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/auth_service.dart';
import '../../services/social_auth_service.dart';

/// 인증 상태 관리 Provider
///
/// 사용자의 인증 상태를 관리하고 UI에서 사용할 수 있도록 제공합니다.
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final SocialAuthService _socialAuthService = SocialAuthService();

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  /// 현재 사용자
  User? get user => _user;

  /// 로딩 상태
  bool get isLoading => _isLoading;

  /// 에러 메시지
  String? get errorMessage => _errorMessage;

  /// 로그인 상태
  bool get isLoggedIn => _user != null;

  /// 사용자 이메일
  String? get userEmail => _user?.email;

  /// 사용자 ID
  String? get userId => _user?.id;

  AuthProvider() {
    _initializeAuth();
  }

  /// 인증 상태 초기화
  void _initializeAuth() {
    _user = _authService.currentUser;
    _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  /// 인증 상태 변화 감지
  void _onAuthStateChanged(AuthState authState) {
    _user = authState.session?.user;
    _clearError();
    notifyListeners();
  }

  /// 에러 메시지 초기화
  void _clearError() {
    _errorMessage = null;
  }

  /// 로딩 상태 설정
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// 에러 메시지 설정
  void _setError(String error) {
    _errorMessage = error;
    _isLoading = false;
    notifyListeners();
  }

  /// 이메일로 회원가입
  Future<bool> signUp({
    required String email,
    required String password,
    String? name,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _authService.signUp(
        email: email,
        password: password,
        name: name,
      );

      if (response.user != null) {
        _user = response.user;
        return true;
      }
      return false;
    } catch (e) {
      _setError(_getErrorMessage(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 이메일로 로그인
  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _authService.signInWithEmail(
        email: email,
        password: password,
      );

      if (response.user != null) {
        _user = response.user;
        return true;
      }

      // 응답에는 user가 없지만 세션이 있을 수 있음
      if (response.session != null) {
        _user = response.session?.user;
        return true;
      }

      return false;
    } catch (e) {
      // 에러 메시지 변환 (콘솔 로그는 최소화)
      final errorMessage = _getErrorMessage(e);
      _setError(errorMessage);
      
      // 개발 모드에서만 상세 로그 출력
      if (kDebugMode) {
        debugPrint('Sign in error: $errorMessage');
        if (e is AuthException) {
          debugPrint('AuthException code: ${e.statusCode}');
        }
      }
      
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 로그아웃
  Future<void> signOut() async {
    try {
      _setLoading(true);
      _clearError();

      await _authService.signOut();
      _user = null;
    } catch (e) {
      _setError(_getErrorMessage(e));
    } finally {
      _setLoading(false);
    }
  }

  /// 비밀번호 재설정 이메일 발송
  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);
      _clearError();

      await _authService.resetPassword(email);
      return true;
    } catch (e) {
      _setError(_getErrorMessage(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Google 로그인
  Future<bool> signInWithGoogle() async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _socialAuthService.signInWithGoogle();

      if (response?.user != null) {
        _user = response!.user;
        return true;
      }
      return false;
    } catch (e) {
      _setError(_getErrorMessage(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Apple 로그인
  Future<bool> signInWithApple() async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _socialAuthService.signInWithApple();

      if (response?.user != null) {
        _user = response!.user;
        return true;
      }
      return false;
    } catch (e) {
      _setError(_getErrorMessage(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 에러 메시지 변환
  String _getErrorMessage(dynamic error) {
    // Supabase AuthException 처리
    if (error is AuthException) {
      final message = error.message.toLowerCase();

      // 에러 메시지 패턴 매칭
      if (message.contains('invalid login credentials') ||
          message.contains('invalid credentials') ||
          error.code == 'invalid_credentials') {
        return '이메일 또는 비밀번호가 올바르지 않습니다.\n계정이 없으시다면 회원가입을 먼저 진행해주세요.';
      }

      if (message.contains('email not confirmed') ||
          message.contains('email_not_confirmed')) {
        return '이메일 인증이 필요합니다. 회원가입 시 발송된 이메일을 확인해주세요.';
      }

      if (message.contains('user already registered') ||
          message.contains('user_already_registered')) {
        return '이미 등록된 이메일입니다.';
      }

      if (message.contains('password should be at least') ||
          message.contains('password_too_short')) {
        return '비밀번호는 최소 6자 이상이어야 합니다.';
      }

      if (message.contains('invalid email') ||
          message.contains('invalid_email')) {
        return '올바른 이메일 형식이 아닙니다.';
      }

      if (message.contains('signup is disabled') ||
          message.contains('signup_disabled')) {
        return '회원가입이 비활성화되어 있습니다.';
      }

      if (message.contains('email rate limit') ||
          message.contains('email_rate_limit')) {
        return '이메일 발송 횟수를 초과했습니다. 잠시 후 다시 시도해주세요.';
      }

      if (message.contains('bad request') || message.contains('400')) {
        return '요청이 잘못되었습니다. 이메일과 비밀번호를 확인해주세요.';
      }

      // 원본 메시지 반환
      return error.message.isNotEmpty ? error.message : '인증 오류가 발생했습니다.';
    }

    // 문자열 에러 메시지 처리
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('sign_in_failed') ||
        errorString.contains('sign_in_failure')) {
      return '소셜 로그인에 실패했습니다. 다시 시도해주세요.';
    }

    if (errorString.contains('network_error') ||
        errorString.contains('network') ||
        errorString.contains('connection')) {
      return '네트워크 연결을 확인해주세요.';
    }

    if (errorString.contains('bad request') || errorString.contains('400')) {
      return '요청이 잘못되었습니다. 입력 정보를 확인해주세요.';
    }

    if (errorString.contains('unauthorized') || errorString.contains('401')) {
      return '인증에 실패했습니다. 이메일과 비밀번호를 확인해주세요.';
    }

    // 기본 에러 메시지
    return error.toString().isNotEmpty
        ? error.toString()
        : '알 수 없는 오류가 발생했습니다.';
  }
}
