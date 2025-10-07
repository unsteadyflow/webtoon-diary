import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../core/providers/auth_provider.dart';
import '../../../core/models/user_profile.dart';
import '../../../services/profile_service.dart';

/// 프로필 관리 화면
///
/// 사용자가 자신의 프로필 정보를 수정할 수 있는 화면입니다.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _profileService = ProfileService();

  UserProfile? _userProfile;
  bool _isLoading = false;
  String? _errorMessage;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF00D884),
        foregroundColor: Colors.white,
        title: const Text(
          '프로필 관리',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: const Text(
              '저장',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 프로필 이미지
                    _buildProfileImage(),

                    const SizedBox(height: 32),

                    // 프로필 정보 폼
                    _buildProfileForm(),

                    const SizedBox(height: 24),

                    // 에러 메시지
                    if (_errorMessage != null) _buildErrorMessage(),

                    const SizedBox(height: 32),

                    // 계정 정보
                    _buildAccountInfo(),
                  ],
                ),
              ),
            ),
    );
  }

  /// 프로필 이미지 섹션
  Widget _buildProfileImage() {
    return Center(
      child: Stack(
        children: [
          // 프로필 이미지
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF00D884),
                width: 3,
              ),
            ),
            child: ClipOval(
              child: _getProfileImageWidget(),
            ),
          ),

          // 이미지 변경 버튼
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Color(0xFF00D884),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: _showImagePicker,
                padding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 프로필 이미지 위젯
  Widget _getProfileImageWidget() {
    if (_selectedImage != null) {
      return Image.file(
        _selectedImage!,
        fit: BoxFit.cover,
        width: 120,
        height: 120,
      );
    }

    if (_userProfile?.avatarUrl != null &&
        _userProfile!.avatarUrl!.isNotEmpty) {
      return Image.network(
        _userProfile!.avatarUrl!,
        fit: BoxFit.cover,
        width: 120,
        height: 120,
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultAvatar();
        },
      );
    }

    return _buildDefaultAvatar();
  }

  /// 기본 아바타
  Widget _buildDefaultAvatar() {
    return Container(
      width: 120,
      height: 120,
      color: const Color(0xFF00D884).withValues(alpha: 0.1),
      child: const Icon(
        Icons.person,
        size: 60,
        color: Color(0xFF00D884),
      ),
    );
  }

  /// 프로필 폼
  Widget _buildProfileForm() {
    return Column(
      children: [
        // 이름 입력 필드
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: '이름',
            hintText: '이름을 입력하세요',
            prefixIcon: const Icon(Icons.person_outlined),
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
              return '이름을 입력해주세요';
            }
            if (value.length < 2) {
              return '이름은 최소 2자 이상이어야 합니다';
            }
            return null;
          },
        ),
      ],
    );
  }

  /// 에러 메시지
  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  /// 계정 정보
  Widget _buildAccountInfo() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '계정 정보',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111318),
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow('이메일', authProvider.userEmail ?? ''),
          const SizedBox(height: 8),
          _buildInfoRow('사용자 ID', authProvider.userId ?? ''),
          const SizedBox(height: 8),
          _buildInfoRow(
              '가입일',
              _formatDate(authProvider.user?.createdAt != null
                  ? DateTime.tryParse(authProvider.user!.createdAt)
                  : null)),
        ],
      ),
    );
  }

  /// 정보 행
  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Color(0xFF5B5B66),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFF111318),
            ),
          ),
        ),
      ],
    );
  }

  /// 이미지 선택기 표시
  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            const Text(
              '프로필 이미지 선택',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildImagePickerOption(
                  icon: Icons.camera_alt,
                  label: '카메라',
                  onTap: () => _pickImage(ImageSource.camera),
                ),
                _buildImagePickerOption(
                  icon: Icons.photo_library,
                  label: '갤러리',
                  onTap: () => _pickImage(ImageSource.gallery),
                ),
                if (_userProfile?.avatarUrl != null &&
                    _userProfile!.avatarUrl!.isNotEmpty)
                  _buildImagePickerOption(
                    icon: Icons.delete,
                    label: '삭제',
                    onTap: _removeImage,
                  ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  /// 이미지 선택 옵션
  Widget _buildImagePickerOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF00D884).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF00D884),
              size: 30,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// 이미지 선택
  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _errorMessage = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '이미지 선택에 실패했습니다: $e';
      });
    }
  }

  /// 이미지 제거
  void _removeImage() {
    setState(() {
      _selectedImage = null;
      _errorMessage = null;
    });
  }

  /// 사용자 프로필 로드
  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final profile = await _profileService.getCurrentUserProfile();
      setState(() {
        _userProfile = profile;
        _nameController.text = profile?.name ?? '';
      });
    } catch (e) {
      setState(() {
        _errorMessage = '프로필을 불러오는데 실패했습니다: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 프로필 저장
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.userId!;

      String? avatarUrl = _userProfile?.avatarUrl;

      // 새 이미지가 선택된 경우 업로드
      if (_selectedImage != null) {
        avatarUrl = await _profileService.uploadAvatar(
          userId: userId,
          file: _selectedImage!,
        );
      }

      // 프로필 업데이트 또는 생성
      if (_userProfile != null) {
        await _profileService.updateProfile(
          userId: userId,
          name: _nameController.text.trim(),
          avatarUrl: avatarUrl,
        );
      } else {
        await _profileService.createProfile(
          userId: userId,
          name: _nameController.text.trim(),
          avatarUrl: avatarUrl,
        );
      }

      // 성공 메시지
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('프로필이 성공적으로 저장되었습니다'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _errorMessage = '프로필 저장에 실패했습니다: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 날짜 포맷팅
  String _formatDate(DateTime? date) {
    if (date == null) return '알 수 없음';
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }
}
