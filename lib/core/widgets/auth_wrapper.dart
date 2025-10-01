import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/home/presentation/home_screen.dart';

/// 인증 상태에 따른 라우팅을 처리하는 래퍼 위젯
///
/// 사용자의 로그인 상태에 따라 적절한 화면을 표시합니다.
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // 로딩 중일 때
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFF00D884)),
                  ),
                  SizedBox(height: 16),
                  Text(
                    '로딩 중...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF5B5B66),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // 로그인된 사용자
        if (authProvider.isLoggedIn) {
          return const HomeScreen();
        }

        // 로그인되지 않은 사용자
        return const LoginScreen();
      },
    );
  }
}
