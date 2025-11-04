import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase 클라이언트 서비스
///
/// Supabase 초기화 및 인증 관리를 담당하는 서비스 클래스입니다.
class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseService get instance => _instance ??= SupabaseService._();

  SupabaseService._();

  SupabaseClient get client => Supabase.instance.client;

  /// Supabase 초기화
  ///
  /// 환경 변수에서 Supabase URL과 키를 읽어와 초기화합니다.
  /// LOCAL_DEV 모드일 때는 인메모리 클라이언트를 사용합니다.
  static Future<void> initialize() async {
    final supabaseUrl = dotenv.env['SUPABASE_URL'];
    final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];
    final localDev = dotenv.env['LOCAL_DEV']?.toLowerCase() == 'true';

    if (localDev) {
      // 개발 모드: 인메모리 클라이언트 사용
      await Supabase.initialize(
        url: 'https://dummy.supabase.co',
        anonKey: 'dummy-key-for-local-dev',
        debug: true,
      );
      // 🔧 LOCAL_DEV 모드: Supabase 인메모리 클라이언트 사용
    } else if (supabaseUrl != null && supabaseAnonKey != null) {
      // 프로덕션 모드: 실제 Supabase 클라이언트 사용
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
        debug: dotenv.env['DEBUG_MODE']?.toLowerCase() == 'true',
      );
      // 🚀 프로덕션 모드: Supabase 클라이언트 초기화 완료
    } else {
      throw Exception('Supabase 설정이 누락되었습니다. config.env 파일에 '
          'SUPABASE_URL과 SUPABASE_ANON_KEY를 설정해주세요.');
    }
  }

  /// 현재 사용자 인증 상태 확인
  User? get currentUser => client.auth.currentUser;

  /// 사용자 로그인 여부 확인
  bool get isLoggedIn => currentUser != null;

  /// 이메일로 회원가입
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) async {
    return await client.auth.signUp(
      email: email,
      password: password,
      data: data,
    );
  }

  /// 이메일로 로그인
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      // 상세 에러 정보 로깅
      print('Supabase signInWithPassword error:');
      print('Error: $e');
      if (e is AuthException) {
        print('AuthException message: ${e.message}');
      }
      rethrow;
    }
  }

  /// 로그아웃
  Future<void> signOut() async {
    await client.auth.signOut();
  }

  /// 현재 사용자 세션 새로고침
  Future<AuthResponse> refreshSession() async {
    return await client.auth.refreshSession();
  }

  /// 인증 상태 변화 스트림
  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;
}
