import 'dart:io';
import '../core/models/user_profile.dart';
import '../../services/supabase_service.dart';

/// 사용자 프로필 서비스
///
/// 사용자 프로필 정보의 CRUD 작업을 담당합니다.
class ProfileService {
  static final ProfileService _instance = ProfileService._internal();
  factory ProfileService() => _instance;
  ProfileService._internal();

  final SupabaseService _supabaseService = SupabaseService.instance;

  /// 현재 사용자의 프로필 조회
  Future<UserProfile?> getCurrentUserProfile() async {
    try {
      final user = _supabaseService.currentUser;
      if (user == null) return null;

      final response = await _supabaseService.client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      return UserProfile.fromJson(response);
    } catch (e) {
      // 프로필이 없는 경우 null 반환
      return null;
    }
  }

  /// 프로필 생성
  Future<UserProfile> createProfile({
    required String userId,
    String? name,
    String? avatarUrl,
  }) async {
    try {
      final profileData = {
        'id': userId,
        'name': name,
        'avatar_url': avatarUrl,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabaseService.client
          .from('profiles')
          .insert(profileData)
          .select()
          .single();

      return UserProfile.fromJson(response);
    } catch (e) {
      throw Exception('프로필 생성에 실패했습니다: $e');
    }
  }

  /// 프로필 업데이트
  Future<UserProfile> updateProfile({
    required String userId,
    String? name,
    String? avatarUrl,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (name != null) updateData['name'] = name;
      if (avatarUrl != null) updateData['avatar_url'] = avatarUrl;

      final response = await _supabaseService.client
          .from('profiles')
          .update(updateData)
          .eq('id', userId)
          .select()
          .single();

      return UserProfile.fromJson(response);
    } catch (e) {
      throw Exception('프로필 업데이트에 실패했습니다: $e');
    }
  }

  /// 프로필 삭제
  Future<void> deleteProfile(String userId) async {
    try {
      await _supabaseService.client.from('profiles').delete().eq('id', userId);
    } catch (e) {
      throw Exception('프로필 삭제에 실패했습니다: $e');
    }
  }

  /// 아바타 이미지 업로드
  Future<String> uploadAvatar({
    required String userId,
    required File file,
  }) async {
    try {
      // 파일 확장자 추출
      final fileName = file.path.split('/').last;
      final fileExtension = fileName.split('.').last;

      // 고유한 파일명 생성
      final uniqueFileName =
          '${userId}_${DateTime.now().millisecondsSinceEpoch}.$fileExtension';

      // Supabase Storage에 업로드
      await _supabaseService.client.storage
          .from('avatars')
          .upload(uniqueFileName, file);

      // 공개 URL 반환
      final publicUrl = _supabaseService.client.storage
          .from('avatars')
          .getPublicUrl(uniqueFileName);

      return publicUrl;
    } catch (e) {
      throw Exception('아바타 업로드에 실패했습니다: $e');
    }
  }

  /// 아바타 이미지 삭제
  Future<void> deleteAvatar(String fileName) async {
    try {
      await _supabaseService.client.storage.from('avatars').remove([fileName]);
    } catch (e) {
      throw Exception('아바타 삭제에 실패했습니다: $e');
    }
  }

  /// 사용자 로그인 시 프로필 자동 생성
  Future<UserProfile?> ensureProfileExists() async {
    try {
      final user = _supabaseService.currentUser;
      if (user == null) return null;

      // 기존 프로필 확인
      UserProfile? existingProfile = await getCurrentUserProfile();

      if (existingProfile != null) {
        return existingProfile;
      }

      // 프로필이 없으면 새로 생성
      return await createProfile(
        userId: user.id,
        name: user.userMetadata?['name'] ?? user.email?.split('@').first,
        avatarUrl: user.userMetadata?['avatar_url'],
      );
    } catch (e) {
      throw Exception('프로필 확인/생성에 실패했습니다: $e');
    }
  }
}
