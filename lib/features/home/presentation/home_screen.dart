import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../profile/presentation/profile_screen.dart';
import '../../diary/presentation/diary_list_screen.dart';
import '../../comic/presentation/saved_images_screen.dart';
import 'feed_screen.dart';

/// 홈 화면
///
/// 로그인된 사용자가 보는 메인 화면입니다.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF00D884),
        foregroundColor: Colors.white,
        title: const Text(
          '웹툰 다이어리',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          // 일기 목록 버튼
          IconButton(
            onPressed: () => _navigateToDiaryList(context),
            icon: const Icon(Icons.book),
            tooltip: '내 일기',
          ),
          // 프로필 버튼
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return PopupMenuButton<String>(
                icon: const Icon(Icons.account_circle),
                onSelected: (value) {
                  if (value == 'logout') {
                    _handleLogout(context);
                  } else if (value == 'profile') {
                    _navigateToProfile(context);
                  } else if (value == 'saved_images') {
                    _navigateToSavedImages(context);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'profile',
                    child: Row(
                      children: [
                        Icon(Icons.person_outline),
                        SizedBox(width: 8),
                        Text('프로필'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'saved_images',
                    child: Row(
                      children: [
                        Icon(Icons.image),
                        SizedBox(width: 8),
                        Text('저장된 이미지'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout),
                        SizedBox(width: 8),
                        Text('로그아웃'),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: const FeedScreen(),
    );
  }

  /// 로그아웃 처리
  Future<void> _handleLogout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // 로그아웃 확인 다이얼로그
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('로그아웃'),
        content: const Text('정말 로그아웃하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              '로그아웃',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await authProvider.signOut();

      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  /// 프로필 화면으로 이동
  void _navigateToProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProfileScreen(),
      ),
    );
  }

  /// 일기 목록 화면으로 이동
  void _navigateToDiaryList(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DiaryListScreen(),
      ),
    );
  }

  /// 저장된 이미지 화면으로 이동
  void _navigateToSavedImages(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SavedImagesScreen(),
      ),
    );
  }
}
