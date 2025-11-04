import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/models/diary.dart';
import '../core/models/diary_comic.dart';
import '../core/models/comic.dart';
import 'supabase_service.dart';

/// 일기 서비스 클래스
/// Supabase와 로컬 캐시를 통한 일기 CRUD 작업을 담당
class DiaryService {
  static DiaryService? _instance;
  static DiaryService get instance => _instance ??= DiaryService._();

  DiaryService._();

  final SupabaseService _supabaseService = SupabaseService.instance;

  // 로컬 캐시 키
  static const String _draftDiariesKey = 'draft_diaries';
  static const String _lastAutoSaveKey = 'last_auto_save';

  /// 새 일기 생성
  Future<Diary> createDiary({
    required String content,
    String? title,
    String? mood,
    String? weather,
    String? location,
    bool isDraft = false,
  }) async {
    try {
      final user = _supabaseService.currentUser;
      if (user == null) {
        throw Exception('로그인이 필요합니다.');
      }

      final now = DateTime.now();
      final diaryData = {
        'user_id': user.id,
        'content': content,
        'title': title,
        'mood': mood,
        'weather': weather,
        'location': location,
        'is_draft': isDraft,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };

      final response = await _supabaseService.client
          .from('diaries')
          .insert(diaryData)
          .select()
          .single();

      return Diary.fromJson(response);
    } catch (e) {
      // 네트워크 오류 시 로컬에 임시 저장
      if (e.toString().contains('network') ||
          e.toString().contains('connection')) {
        return await _saveDraftLocally(content, title, mood, weather, location);
      }
      rethrow;
    }
  }

  /// 일기 수정
  Future<Diary> updateDiary({
    required String diaryId,
    required String content,
    String? title,
    String? mood,
    String? weather,
    String? location,
    bool? isDraft,
  }) async {
    try {
      final now = DateTime.now();
      final updateData = <String, dynamic>{
        'content': content,
        'title': title,
        'mood': mood,
        'weather': weather,
        'location': location,
        'updated_at': now.toIso8601String(),
      };

      if (isDraft != null) {
        updateData['is_draft'] = isDraft;
      }

      final response = await _supabaseService.client
          .from('diaries')
          .update(updateData)
          .eq('id', diaryId)
          .select()
          .single();

      return Diary.fromJson(response);
    } catch (e) {
      // 네트워크 오류 시 로컬에 임시 저장
      if (e.toString().contains('network') ||
          e.toString().contains('connection')) {
        return await _updateDraftLocally(
            diaryId, content, title, mood, weather, location);
      }
      rethrow;
    }
  }

  /// 일기 삭제
  Future<void> deleteDiary(String diaryId) async {
    try {
      await _supabaseService.client.from('diaries').delete().eq('id', diaryId);
    } catch (e) {
      // 로컬에서도 삭제
      await _deleteDraftLocally(diaryId);
      rethrow;
    }
  }

  /// 사용자의 모든 일기 조회
  Future<List<Diary>> getUserDiaries({bool includeDrafts = false}) async {
    try {
      final user = _supabaseService.currentUser;
      if (user == null) {
        throw Exception('로그인이 필요합니다.');
      }

      final response = await _supabaseService.client
          .from('diaries')
          .select()
          .eq('user_id', user.id)
          .eq('is_draft', includeDrafts)
          .order('created_at', ascending: false);
      return response.map<Diary>((json) => Diary.fromJson(json)).toList();
    } catch (e) {
      // 네트워크 오류 시 로컬 데이터 반환
      if (e.toString().contains('network') ||
          e.toString().contains('connection')) {
        return await _getLocalDrafts();
      }
      rethrow;
    }
  }

  /// 특정 일기 조회
  Future<Diary?> getDiary(String diaryId) async {
    try {
      final response = await _supabaseService.client
          .from('diaries')
          .select()
          .eq('id', diaryId)
          .single();

      return Diary.fromJson(response);
    } catch (e) {
      // 로컬에서 찾기
      return await _getLocalDraft(diaryId);
    }
  }

  /// 메인 피드용 일기와 만화 조회
  /// 날짜/최신순으로 정렬된 일기와 해당 만화를 함께 반환
  Future<List<DiaryComic>> getDiaryComicsFeed({
    bool includeDrafts = false,
    int? limit,
    int? offset,
  }) async {
    try {
      final user = _supabaseService.currentUser;
      if (user == null) {
        throw Exception('로그인이 필요합니다.');
      }

      // 일기 조회 (최신순 정렬)
      var diaryQuery = _supabaseService.client
          .from('diaries')
          .select()
          .eq('user_id', user.id)
          .eq('is_draft', includeDrafts)
          .order('created_at', ascending: false);

      if (limit != null) {
        diaryQuery = diaryQuery.limit(limit);
      }
      if (offset != null) {
        diaryQuery = diaryQuery.range(offset, offset + (limit ?? 100) - 1);
      }

      final diariesResponse = await diaryQuery;
      final diaries = (diariesResponse as List)
          .map<Diary>((json) => Diary.fromJson(json))
          .toList();

      // 각 일기에 대해 만화 조회
      final diaryComics = <DiaryComic>[];
      for (final diary in diaries) {
        try {
          // 해당 일기의 만화 조회 (완료된 만화만)
          final comicsResponse = await _supabaseService.client
              .from('comics')
              .select()
              .eq('diary_id', diary.id)
              .eq('status', 'completed')
              .order('created_at', ascending: false)
              .limit(1)
              .maybeSingle();

          Comic? comic;
          if (comicsResponse != null) {
            comic = Comic.fromJson(comicsResponse);
          }

          diaryComics.add(DiaryComic(diary: diary, comic: comic));
        } catch (e) {
          // 만화 조회 실패 시 만화 없이 일기만 추가
          diaryComics.add(DiaryComic(diary: diary));
        }
      }

      return diaryComics;
    } catch (e) {
      // 네트워크 오류 시 로컬 데이터 반환 (만화는 제외)
      if (e.toString().contains('network') ||
          e.toString().contains('connection')) {
        final localDrafts = await _getLocalDrafts();
        return localDrafts.map((diary) => DiaryComic(diary: diary)).toList();
      }
      rethrow;
    }
  }

  /// 자동 임시저장
  Future<void> autoSaveDraft({
    required String content,
    String? title,
    String? mood,
    String? weather,
    String? location,
  }) async {
    if (content.trim().isEmpty) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();

      // 마지막 자동저장 시간 확인 (5분마다 자동저장)
      final lastSaveStr = prefs.getString(_lastAutoSaveKey);
      if (lastSaveStr != null) {
        final lastSave = DateTime.parse(lastSaveStr);
        if (now.difference(lastSave).inMinutes < 5) {
          return;
        }
      }

      // 임시저장 실행
      await createDiary(
        content: content,
        title: title,
        mood: mood,
        weather: weather,
        location: location,
        isDraft: true,
      );

      await prefs.setString(_lastAutoSaveKey, now.toIso8601String());
    } catch (e) {
      // 로컬에만 저장
      await _saveDraftLocally(content, title, mood, weather, location);
    }
  }

  /// 오프라인 동기화
  Future<void> syncOfflineData() async {
    try {
      final localDrafts = await _getLocalDrafts();
      for (final draft in localDrafts) {
        try {
          // 서버에 업로드 시도
          await createDiary(
            content: draft.content,
            title: draft.title,
            mood: draft.mood,
            weather: draft.weather,
            location: draft.location,
            isDraft: draft.isDraft,
          );

          // 성공 시 로컬에서 삭제
          await _deleteDraftLocally(draft.id);
        } catch (e) {
          // 개별 항목 실패는 무시하고 계속 진행
          continue;
        }
      }
    } catch (e) {
      // 동기화 실패는 무시
    }
  }

  // ===== 로컬 캐시 관련 메서드들 =====

  /// 로컬에 임시저장
  Future<Diary> _saveDraftLocally(
    String content,
    String? title,
    String? mood,
    String? weather,
    String? location,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final diaryId = 'local_${now.millisecondsSinceEpoch}';

    final diary = Diary(
      id: diaryId,
      userId: _supabaseService.currentUser?.id ?? 'anonymous',
      content: content,
      title: title,
      mood: mood,
      weather: weather,
      location: location,
      isDraft: true,
      createdAt: now,
      updatedAt: now,
    );

    final localDrafts = await _getLocalDrafts();
    localDrafts.add(diary);

    final jsonList = localDrafts.map((d) => d.toJson()).toList();
    await prefs.setString(_draftDiariesKey, jsonEncode(jsonList));

    return diary;
  }

  /// 로컬 임시저장 업데이트
  Future<Diary> _updateDraftLocally(
    String diaryId,
    String content,
    String? title,
    String? mood,
    String? weather,
    String? location,
  ) async {
    final localDrafts = await _getLocalDrafts();
    final index = localDrafts.indexWhere((d) => d.id == diaryId);

    if (index != -1) {
      final updatedDiary = localDrafts[index].copyWith(
        content: content,
        title: title,
        mood: mood,
        weather: weather,
        location: location,
        updatedAt: DateTime.now(),
      );

      localDrafts[index] = updatedDiary;

      final prefs = await SharedPreferences.getInstance();
      final jsonList = localDrafts.map((d) => d.toJson()).toList();
      await prefs.setString(_draftDiariesKey, jsonEncode(jsonList));

      return updatedDiary;
    }

    throw Exception('로컬에서 일기를 찾을 수 없습니다.');
  }

  /// 로컬 임시저장 삭제
  Future<void> _deleteDraftLocally(String diaryId) async {
    final localDrafts = await _getLocalDrafts();
    localDrafts.removeWhere((d) => d.id == diaryId);

    final prefs = await SharedPreferences.getInstance();
    final jsonList = localDrafts.map((d) => d.toJson()).toList();
    await prefs.setString(_draftDiariesKey, jsonEncode(jsonList));
  }

  /// 로컬 임시저장 목록 조회
  Future<List<Diary>> _getLocalDrafts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_draftDiariesKey);

      if (jsonStr == null) return [];

      final jsonList = jsonDecode(jsonStr) as List;
      return jsonList.map((json) => Diary.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  /// 특정 로컬 임시저장 조회
  Future<Diary?> _getLocalDraft(String diaryId) async {
    final localDrafts = await _getLocalDrafts();
    try {
      return localDrafts.firstWhere((d) => d.id == diaryId);
    } catch (e) {
      return null;
    }
  }
}
