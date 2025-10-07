import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../core/models/comic.dart';
import 'supabase_service.dart';

/// AI 서버 호출 서비스
/// FastAPI 서버와의 통신을 담당
class AiServerService {
  static AiServerService? _instance;
  static AiServerService get instance => _instance ??= AiServerService._();

  AiServerService._();

  final SupabaseService _supabaseService = SupabaseService.instance;
  
  // AI 서버 URL
  String get _aiServerUrl => dotenv.env['AI_SERVER_URL'] ?? 'http://127.0.0.1:8000';

  /// 만화 생성 요청
  Future<ComicGenerationResponse> generateComic({
    required String diaryId,
    required String content,
    String? title,
    String? mood,
    String? weather,
    String? location,
    String style = 'cute',
  }) async {
    try {
      final request = ComicGenerationRequest(
        diaryId: diaryId,
        content: content,
        title: title,
        mood: mood,
        weather: weather,
        location: location,
        style: style,
      );

      final response = await http.post(
        Uri.parse('$_aiServerUrl/api/v1/comic/generate'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        return ComicGenerationResponse.fromJson(responseData);
      } else {
        throw Exception('만화 생성 요청 실패: ${response.statusCode}');
      }
    } catch (e) {
      if (e is SocketException) {
        throw Exception('네트워크 연결을 확인해주세요.');
      } else if (e.toString().contains('TimeoutException')) {
        throw Exception('요청 시간이 초과되었습니다. 다시 시도해주세요.');
      }
      rethrow;
    }
  }

  /// 만화 생성 상태 확인
  Future<Comic> getComicStatus(String comicId) async {
    try {
      final response = await http.get(
        Uri.parse('$_aiServerUrl/api/v1/comic/$comicId'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        return Comic.fromJson(responseData);
      } else {
        throw Exception('만화 상태 조회 실패: ${response.statusCode}');
      }
    } catch (e) {
      if (e is SocketException) {
        throw Exception('네트워크 연결을 확인해주세요.');
      } else if (e.toString().contains('TimeoutException')) {
        throw Exception('요청 시간이 초과되었습니다.');
      }
      rethrow;
    }
  }

  /// 만화 생성 진행 상태 폴링
  Stream<Comic> pollComicStatus(String comicId) async* {
    while (true) {
      try {
        final comic = await getComicStatus(comicId);
        yield comic;
        
        // 완료되거나 실패하면 폴링 중단
        if (comic.status == ComicStatus.completed || 
            comic.status == ComicStatus.failed) {
          break;
        }
        
        // 3초마다 상태 확인
        await Future.delayed(const Duration(seconds: 3));
      } catch (e) {
        // 오류 발생 시 실패 상태로 처리
        yield Comic(
          diaryId: '',
          userId: '',
          title: '',
          imageUrl: '',
          style: '',
          status: ComicStatus.failed,
          errorMessage: e.toString(),
        );
        break;
      }
    }
  }

  /// ETA 계산 (초 단위)
  int calculateETA(Comic comic) {
    if (comic.status == ComicStatus.completed) return 0;
    if (comic.status == ComicStatus.failed) return -1;
    
    if (comic.estimatedTimeSeconds != null) {
      final elapsed = DateTime.now().difference(comic.createdAt).inSeconds;
      final remaining = comic.estimatedTimeSeconds! - elapsed;
      return remaining > 0 ? remaining : 0;
    }
    
    // 기본 추정 시간 (30초)
    return 30;
  }

  /// 만화를 Supabase Storage에 저장
  Future<String> uploadComicToStorage({
    required String comicId,
    required String imageUrl,
  }) async {
    try {
      // AI 서버에서 생성된 이미지를 다운로드
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode != 200) {
        throw Exception('이미지 다운로드 실패');
      }

      // Supabase Storage에 업로드
      final fileName = 'comics/$comicId.png';
      final uploadResponse = await _supabaseService.client.storage
          .from('comic-images')
          .uploadBinary(fileName, response.bodyBytes);

      if (uploadResponse.isNotEmpty) {
        // 공개 URL 생성
        final publicUrl = _supabaseService.client.storage
            .from('comic-images')
            .getPublicUrl(fileName);
        
        return publicUrl;
      } else {
        throw Exception('Supabase Storage 업로드 실패');
      }
    } catch (e) {
      throw Exception('만화 이미지 저장 실패: $e');
    }
  }
}
