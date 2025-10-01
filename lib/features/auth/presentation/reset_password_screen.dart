import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/auth_provider.dart';

/// 비밀번호 재설정 화면
///
/// 사용자가 비밀번호를 재설정할 수 있는 화면입니다.
class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF111318)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '비밀번호 재설정',
          style: TextStyle(
            color: Color(0xFF111318),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),

                // 헤더
                _buildHeader(),

                const SizedBox(height: 48),

                if (!_emailSent) ...[
                  // 이메일 입력 폼
                  _buildEmailForm(),

                  const SizedBox(height: 24),

                  // 재설정 버튼
                  _buildResetButton(),
                ] else ...[
                  // 이메일 발송 완료 메시지
                  _buildEmailSentMessage(),

                  const SizedBox(height: 24),

                  // 다시 보내기 버튼
                  _buildResendButton(),
                ],

                const SizedBox(height: 32),

                // 로그인으로 돌아가기
                _buildBackToLoginButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 헤더 섹션
  Widget _buildHeader() {
    return Column(
      children: [
        // 아이콘
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFF00D884).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.lock_reset,
            color: Color(0xFF00D884),
            size: 40,
          ),
        ),

        const SizedBox(height: 24),

        // 제목
        Text(
          _emailSent ? '이메일을 확인해주세요' : '비밀번호를 잊으셨나요?',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111318),
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 12),

        // 부제목
        Text(
          _emailSent
              ? '비밀번호 재설정 링크를 이메일로 보내드렸습니다'
              : '가입하신 이메일 주소를 입력하시면\n비밀번호 재설정 링크를 보내드립니다',
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF5B5B66),
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// 이메일 입력 폼
  Widget _buildEmailForm() {
    return Column(
      children: [
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
      ],
    );
  }

  /// 재설정 버튼
  Widget _buildResetButton() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return SizedBox(
          height: 48,
          child: ElevatedButton(
            onPressed: authProvider.isLoading ? null : _handleResetPassword,
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
                    '재설정 링크 보내기',
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

  /// 이메일 발송 완료 메시지
  Widget _buildEmailSentMessage() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF00D884).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF00D884).withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.check_circle_outline,
            color: Color(0xFF00D884),
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            '${_emailController.text}로\n비밀번호 재설정 링크를 보내드렸습니다',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111318),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            '이메일을 확인하고 링크를 클릭하여\n새로운 비밀번호를 설정해주세요',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF5B5B66),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 다시 보내기 버튼
  Widget _buildResendButton() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return SizedBox(
          height: 48,
          child: OutlinedButton(
            onPressed: authProvider.isLoading ? null : _handleResendEmail,
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF00D884),
              side: const BorderSide(color: Color(0xFF00D884)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: authProvider.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFF00D884)),
                    ),
                  )
                : const Text(
                    '다시 보내기',
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

  /// 로그인으로 돌아가기 버튼
  Widget _buildBackToLoginButton() {
    return TextButton(
      onPressed: () => Navigator.pop(context),
      child: const Text(
        '로그인 화면으로 돌아가기',
        style: TextStyle(
          color: Color(0xFF5B5B66),
          fontSize: 14,
        ),
      ),
    );
  }

  /// 비밀번호 재설정 처리
  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success =
        await authProvider.resetPassword(_emailController.text.trim());

    if (success && mounted) {
      setState(() {
        _emailSent = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('비밀번호 재설정 이메일을 발송했습니다'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? '이메일 발송에 실패했습니다'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// 이메일 다시 보내기 처리
  Future<void> _handleResendEmail() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success =
        await authProvider.resetPassword(_emailController.text.trim());

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('비밀번호 재설정 이메일을 다시 발송했습니다'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? '이메일 발송에 실패했습니다'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
