import 'package:flutter_test/flutter_test.dart';
import 'package:webtoon_diary/services/auth_service.dart';
import 'package:webtoon_diary/services/social_auth_service.dart';

/// 인증 관련 테스트
void main() {
  group('AuthService Tests', () {
    test('싱글톤 패턴 확인', () {
      final instance1 = AuthService();
      final instance2 = AuthService();
      expect(identical(instance1, instance2), isTrue);
    });
  });

  group('SocialAuthService Tests', () {
    test('싱글톤 패턴 확인', () {
      final instance1 = SocialAuthService();
      final instance2 = SocialAuthService();
      expect(identical(instance1, instance2), isTrue);
    });

    test('Google 로그인 상태 확인', () {
      final socialAuthService = SocialAuthService();
      expect(socialAuthService.isGoogleSignedIn, isFalse);
      expect(socialAuthService.googleUser, isNull);
    });
  });

  group('Form Validation Tests', () {
    test('이메일 유효성 검사', () {
      // 유효한 이메일
      expect(
          RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
              .hasMatch('test@example.com'),
          isTrue);
      expect(
          RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
              .hasMatch('user.name@domain.co.kr'),
          isTrue);

      // 유효하지 않은 이메일
      expect(
          RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch('invalid-email'),
          isFalse);
      expect(RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch('test@'),
          isFalse);
      expect(
          RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch('@example.com'),
          isFalse);
    });

    test('비밀번호 유효성 검사', () {
      // 유효한 비밀번호 (6자 이상)
      expect('password123'.length >= 6, isTrue);
      expect('123456'.length >= 6, isTrue);

      // 유효하지 않은 비밀번호 (6자 미만)
      expect('12345'.length >= 6, isFalse);
      expect('pass'.length >= 6, isFalse);
    });

    test('이름 유효성 검사', () {
      // 유효한 이름 (2자 이상)
      expect('홍길동'.length >= 2, isTrue);
      expect('John'.length >= 2, isTrue);

      // 유효하지 않은 이름 (2자 미만)
      expect('홍'.length >= 2, isFalse);
      expect('J'.length >= 2, isFalse);
    });
  });
}
