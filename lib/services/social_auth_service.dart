// 조건부 import - 테스트 환경에서는 사용하지 않음
import 'package:google_sign_in/google_sign_in.dart' if (dart.library.io) 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart' if (dart.library.io) 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

/// 소셜 로그인 서비스
///
/// Google, Apple 등 소셜 로그인 기능을 제공합니다.
class SocialAuthService {
  static final SocialAuthService _instance = SocialAuthService._internal();
  factory SocialAuthService() => _instance;
  SocialAuthService._internal();

  final SupabaseService _supabaseService = SupabaseService.instance;
  GoogleSignIn? _googleSignIn;

  GoogleSignIn get _googleSignInInstance {
    _googleSignIn ??= GoogleSignIn(
      scopes: ['email', 'profile'],
    );
    return _googleSignIn!;
  }

  /// Google 로그인
  Future<AuthResponse?> signInWithGoogle() async {
    try {
      // Google 로그인 실행
      final GoogleSignInAccount? googleUser =
          await _googleSignInInstance.signIn();
      if (googleUser == null) {
        // 사용자가 로그인을 취소한 경우
        return null;
      }

      // Google 인증 정보 가져오기
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Supabase에 Google 로그인 정보 전달
      final AuthResponse response =
          await _supabaseService.client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: googleAuth.idToken!,
        accessToken: googleAuth.accessToken,
      );

      return response;
    } catch (e) {
      // Google 로그인 실패 시 로그아웃 처리
      await _googleSignInInstance.signOut();
      rethrow;
    }
  }

  /// Apple 로그인
  Future<AuthResponse?> signInWithApple() async {
    try {
      // Apple 로그인 실행
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Supabase에 Apple 로그인 정보 전달
      final AuthResponse response =
          await _supabaseService.client.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: credential.identityToken!,
        accessToken: credential.authorizationCode,
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// 소셜 로그아웃
  Future<void> signOut() async {
    try {
      // Google 로그아웃
      await _googleSignInInstance.signOut();

      // Supabase 로그아웃
      await _supabaseService.signOut();
    } catch (e) {
      rethrow;
    }
  }

  /// 현재 Google 로그인 상태 확인
  bool get isGoogleSignedIn => _googleSignIn?.currentUser != null;

  /// Google 사용자 정보
  GoogleSignInAccount? get googleUser => _googleSignIn?.currentUser;
}
