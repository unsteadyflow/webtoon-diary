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
      return false;
    } catch (e) {
      _setError(_getErrorMessage(e));
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
    if (error is AuthException) {
      switch (error.message) {
        case 'Invalid login credentials':
          return '이메일 또는 비밀번호가 올바르지 않습니다.';
        case 'Email not confirmed':
          return '이메일 인증이 필요합니다. 이메일을 확인해주세요.';
        case 'User already registered':
          return '이미 등록된 이메일입니다.';
        case 'Password should be at least 6 characters':
          return '비밀번호는 최소 6자 이상이어야 합니다.';
        case 'Invalid email':
          return '올바른 이메일 형식이 아닙니다.';
        case 'Signup is disabled':
          return '회원가입이 비활성화되어 있습니다.';
        case 'Email rate limit exceeded':
          return '이메일 발송 횟수를 초과했습니다. 잠시 후 다시 시도해주세요.';
        default:
          return error.message;
      }
    }

    // 소셜 로그인 관련 에러 처리
    if (error.toString().contains('sign_in_failed')) {
      return '소셜 로그인에 실패했습니다. 다시 시도해주세요.';
    }
    if (error.toString().contains('network_error')) {
      return '네트워크 연결을 확인해주세요.';
    }

    return error.toString();
  }
}
