import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/widgets/app_snackbar.dart';
import 'sign_up_screen.dart';
import 'reset_password_screen.dart';

/// 로그인 화면
///
/// 사용자가 이메일과 비밀번호로 로그인할 수 있는 화면입니다.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),

                // 앱 로고 및 제목
                _buildHeader(),

                const SizedBox(height: 48),

                // 로그인 폼
                _buildLoginForm(),

                const SizedBox(height: 24),

                // 로그인 버튼
                _buildLoginButton(),

                const SizedBox(height: 16),

                // 비밀번호 재설정 링크
                _buildForgotPasswordLink(),

                const SizedBox(height: 32),

                // 소셜 로그인
                _buildSocialLogin(),

                const SizedBox(height: 24),

                // 회원가입 링크
                _buildSignUpLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 헤더 섹션 (로고 및 제목)
  Widget _buildHeader() {
    return Column(
      children: [
        // 앱 아이콘
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFF00D884),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.auto_stories,
            color: Colors.white,
            size: 40,
          ),
        ),

        const SizedBox(height: 24),

        // 제목
        const Text(
          '웹툰 다이어리',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111318),
          ),
        ),

        const SizedBox(height: 8),

        // 부제목
        const Text(
          '일상을 4컷 만화로 만들어보세요',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF5B5B66),
          ),
        ),
      ],
    );
  }

  /// 로그인 폼
  Widget _buildLoginForm() {
    return Column(
      children: [
        // 이메일 입력 필드
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: '이메일',
            hintText: 'example@email.com',
            prefixIcon: const Icon(Icons.email_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF00D884), width: 2),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '이메일을 입력해주세요';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return '올바른 이메일 형식이 아닙니다';
            }
            return null;
          },
        ),

        const SizedBox(height: 16),

        // 비밀번호 입력 필드
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            labelText: '비밀번호',
            hintText: '비밀번호를 입력하세요',
            prefixIcon: const Icon(Icons.lock_outlined),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF00D884), width: 2),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '비밀번호를 입력해주세요';
            }
            if (value.length < 6) {
              return '비밀번호는 최소 6자 이상이어야 합니다';
            }
            return null;
          },
        ),
      ],
    );
  }

  /// 로그인 버튼
  Widget _buildLoginButton() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return SizedBox(
          height: 48,
          child: ElevatedButton(
            onPressed: authProvider.isLoading ? null : _handleLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00D884),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: authProvider.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    '로그인',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        );
      },
    );
  }

  /// 비밀번호 재설정 링크
  Widget _buildForgotPasswordLink() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ResetPasswordScreen(),
            ),
          );
        },
        child: const Text(
          '비밀번호를 잊으셨나요?',
          style: TextStyle(
            color: Color(0xFF00D884),
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  /// 소셜 로그인
  Widget _buildSocialLogin() {
    return Column(
      children: [
        // 구분선
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '또는',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ),
            const Expanded(child: Divider()),
          ],
        ),

        const SizedBox(height: 24),

        // 소셜 로그인 버튼들
        Row(
          children: [
            Expanded(
              child: _buildSocialButton(
                icon: Icons.g_mobiledata,
                label: 'Google',
                onPressed: _handleGoogleLogin,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSocialButton(
                icon: Icons.apple,
                label: 'Apple',
                onPressed: _handleAppleLogin,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 소셜 로그인 버튼
  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        side: const BorderSide(color: Color(0xFFEDECF2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF111318),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// 회원가입 링크
  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          '계정이 없으신가요? ',
          style: TextStyle(
            color: Color(0xFF5B5B66),
            fontSize: 14,
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SignUpScreen(),
              ),
            );
          },
          child: const Text(
            '회원가입',
            style: TextStyle(
              color: Color(0xFF00D884),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  /// 로그인 처리
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.signInWithEmail(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (success && mounted) {
      // 로그인 성공 시 홈 화면으로 이동
      Navigator.pushReplacementNamed(context, '/home');
    } else if (mounted) {
      // 에러 메시지 표시 (더 명확한 메시지)
      final errorMessage = authProvider.errorMessage ?? '로그인에 실패했습니다';

      // 에러 메시지가 "Invalid login credentials"인 경우 더 친절한 안내 추가
      final isInvalidCredentials = errorMessage.contains('올바르지 않습니다') ||
          errorMessage.toLowerCase().contains('invalid');

      // AppSnackBar를 사용하여 일관된 에러 메시지 표시
      AppSnackBar.error(
        context,
        errorMessage,
        duration: const Duration(seconds: 5),
        action: isInvalidCredentials
            ? SnackBarAction(
                label: '회원가입',
                textColor: Colors.white,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SignUpScreen(),
                    ),
                  );
                },
              )
            : null,
      );
    }
  }

  /// Google 로그인 처리
  Future<void> _handleGoogleLogin() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.signInWithGoogle();

    if (success && mounted) {
      // 로그인 성공 시 홈 화면으로 이동
      Navigator.pushReplacementNamed(context, '/home');
    } else if (mounted) {
      // 에러 메시지 표시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Google 로그인에 실패했습니다'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Apple 로그인 처리
  Future<void> _handleAppleLogin() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.signInWithApple();

    if (success && mounted) {
      // 로그인 성공 시 홈 화면으로 이동
      Navigator.pushReplacementNamed(context, '/home');
    } else if (mounted) {
      // 에러 메시지 표시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Apple 로그인에 실패했습니다'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
