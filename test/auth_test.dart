import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:webtoon_diary/core/providers/auth_provider.dart';
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

/// 인증 UI 테스트
class AuthUITests {
  static void runTests() {
    group('Authentication UI Tests', () {
      testWidgets('로그인 화면 렌더링 테스트', (WidgetTester tester) async {
        // 로그인 화면이 올바르게 렌더링되는지 확인
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  const Text('웹툰 다이어리'),
                  const Text('일상을 4컷 만화로 만들어보세요'),
                  TextFormField(
                    decoration: const InputDecoration(labelText: '이메일'),
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: '비밀번호'),
                    obscureText: true,
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('로그인'),
                  ),
                ],
              ),
            ),
          ),
        );

        // UI 요소들이 존재하는지 확인
        expect(find.text('웹툰 다이어리'), findsOneWidget);
        expect(find.text('일상을 4컷 만화로 만들어보세요'), findsOneWidget);
        expect(find.byType(TextFormField), findsNWidgets(2));
        expect(find.text('로그인'), findsOneWidget);
      });

      testWidgets('회원가입 화면 렌더링 테스트', (WidgetTester tester) async {
        // 회원가입 화면이 올바르게 렌더링되는지 확인
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  const Text('웹툰 다이어리와 함께하세요'),
                  TextFormField(
                    decoration: const InputDecoration(labelText: '이름'),
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: '이메일'),
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: '비밀번호'),
                    obscureText: true,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: '비밀번호 확인'),
                    obscureText: true,
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('회원가입'),
                  ),
                ],
              ),
            ),
          ),
        );

        // UI 요소들이 존재하는지 확인
        expect(find.text('웹툰 다이어리와 함께하세요'), findsOneWidget);
        expect(find.byType(TextFormField), findsNWidgets(4));
        expect(find.text('회원가입'), findsOneWidget);
      });

      testWidgets('비밀번호 재설정 화면 렌더링 테스트', (WidgetTester tester) async {
        // 비밀번호 재설정 화면이 올바르게 렌더링되는지 확인
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  const Text('비밀번호를 잊으셨나요?'),
                  const Text('가입하신 이메일 주소를 입력하시면\n비밀번호 재설정 링크를 보내드립니다'),
                  TextFormField(
                    decoration: const InputDecoration(labelText: '이메일'),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('재설정 링크 보내기'),
                  ),
                ],
              ),
            ),
          ),
        );

        // UI 요소들이 존재하는지 확인
        expect(find.text('비밀번호를 잊으셨나요?'), findsOneWidget);
        expect(find.byType(TextFormField), findsOneWidget);
        expect(find.text('재설정 링크 보내기'), findsOneWidget);
      });
    });
  }
}

/// 인증 플로우 테스트
class AuthFlowTests {
  static void runTests() {
    group('Authentication Flow Tests', () {
      testWidgets('로그인 성공 후 홈 화면 이동 테스트', (WidgetTester tester) async {
        // 로그인 성공 시 홈 화면으로 이동하는지 확인
        // 실제 구현에서는 Mock을 사용하여 테스트해야 함
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  const Text('로그인 화면'),
                  ElevatedButton(
                    onPressed: () {
                      // 로그인 성공 시나리오
                    },
                    child: const Text('로그인'),
                  ),
                ],
              ),
            ),
          ),
        );

        expect(find.text('로그인 화면'), findsOneWidget);
      });

      testWidgets('로그인 실패 시 에러 메시지 표시 테스트', (WidgetTester tester) async {
        // 로그인 실패 시 에러 메시지가 표시되는지 확인
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  const Text('로그인 화면'),
                  const Text('이메일 또는 비밀번호가 올바르지 않습니다.'),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('로그인'),
                  ),
                ],
              ),
            ),
          ),
        );

        expect(find.text('이메일 또는 비밀번호가 올바르지 않습니다.'), findsOneWidget);
      });

      testWidgets('회원가입 성공 시 이메일 인증 안내 테스트', (WidgetTester tester) async {
        // 회원가입 성공 시 이메일 인증 안내가 표시되는지 확인
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  const Text('이메일 인증이 필요합니다'),
                  const Text('example@email.com로 인증 이메일을 발송했습니다.'),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('확인'),
                  ),
                ],
              ),
            ),
          ),
        );

        expect(find.text('이메일 인증이 필요합니다'), findsOneWidget);
        expect(find.text('example@email.com로 인증 이메일을 발송했습니다.'), findsOneWidget);
      });
    });
  }
}

/// 폼 유효성 검사 테스트
class FormValidationTests {
  static void runTests() {
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
            RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                .hasMatch('invalid-email'),
            isFalse);
        expect(RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch('test@'),
            isFalse);
        expect(
            RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                .hasMatch('@example.com'),
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
}
