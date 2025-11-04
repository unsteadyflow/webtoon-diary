import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

/// 인증 서비스
///
/// 사용자 인증 관련 기능을 제공하는 서비스 클래스입니다.
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final SupabaseService _supabaseService = SupabaseService.instance;

  /// 현재 사용자 정보
  User? get currentUser => _supabaseService.currentUser;

  /// 로그인 상태 확인
  bool get isLoggedIn => _supabaseService.isLoggedIn;

  /// 사용자 ID
  String? get userId => currentUser?.id;

  /// 사용자 이메일
  String? get userEmail => currentUser?.email;

  /// 이메일로 회원가입
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? name,
  }) async {
    try {
      final response = await _supabaseService.signUp(
        email: email,
        password: password,
        data: name != null ? {'name': name} : null,
      );

      if (response.user != null) {
        // ✅ 회원가입 성공: ${response.user!.email}
      }

      return response;
    } catch (e) {
      // ❌ 회원가입 실패: $e
      rethrow;
    }
  }

  /// 이메일로 로그인
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabaseService.signInWithEmail(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // ✅ 로그인 성공: ${response.user!.email}
      }

      return response;
    } catch (e) {
      // ❌ 로그인 실패: $e
      // 디버깅을 위한 상세 로그
      if (e is AuthException) {
        print('AuthException: ${e.message}');
      } else {
        print('Login error: $e');
        print('Error type: ${e.runtimeType}');
      }
      rethrow;
    }
  }

  /// 로그아웃
  Future<void> signOut() async {
    try {
      await _supabaseService.signOut();
      // ✅ 로그아웃 완료
    } catch (e) {
      // ❌ 로그아웃 실패: $e
      rethrow;
    }
  }

  /// 비밀번호 재설정 이메일 발송
  Future<void> resetPassword(String email) async {
    try {
      await _supabaseService.client.auth.resetPasswordForEmail(email);
      // ✅ 비밀번호 재설정 이메일 발송: $email
    } catch (e) {
      // ❌ 비밀번호 재설정 실패: $e
      rethrow;
    }
  }

  /// 인증 상태 변화 스트림
  Stream<AuthState> get authStateChanges => _supabaseService.authStateChanges;

  /// 세션 새로고침
  Future<AuthResponse> refreshSession() async {
    try {
      final response = await _supabaseService.refreshSession();
      // ✅ 세션 새로고침 완료
      return response;
    } catch (e) {
      // ❌ 세션 새로고침 실패: $e
      rethrow;
    }
  }
}
