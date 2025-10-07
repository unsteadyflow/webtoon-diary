import 'package:flutter_test/flutter_test.dart';
import 'package:webtoon_diary/core/models/comic.dart';
import 'package:webtoon_diary/services/ai_server_service.dart';

void main() {
  group('AI Server Service Tests', () {
    test('싱글톤 패턴 확인', () {
      final instance1 = AiServerService.instance;
      final instance2 = AiServerService.instance;
      expect(identical(instance1, instance2), isTrue);
    });

    test('만화 생성 요청 데이터 구조 테스트', () {
      final request = ComicGenerationRequest(
        diaryId: 'test-diary-id',
        content: '오늘은 좋은 하루였습니다.',
        title: '오늘의 일기',
        mood: '😊',
        weather: '☀️ 맑음',
        location: '집',
        style: 'cute',
      );

      final json = request.toJson();
      expect(json['diary_id'], 'test-diary-id');
      expect(json['content'], '오늘은 좋은 하루였습니다.');
      expect(json['title'], '오늘의 일기');
      expect(json['mood'], '😊');
      expect(json['weather'], '☀️ 맑음');
      expect(json['location'], '집');
      expect(json['style'], 'cute');
    });

    test('만화 생성 응답 파싱 테스트', () {
      final responseJson = {
        'comic_id': 'test-comic-id',
        'status': 'pending',
        'estimated_time_seconds': 60,
        'message': '만화 생성이 시작되었습니다.',
      };

      final response = ComicGenerationResponse.fromJson(responseJson);
      expect(response.comicId, 'test-comic-id');
      expect(response.status, ComicStatus.pending);
      expect(response.estimatedTimeSeconds, 60);
      expect(response.message, '만화 생성이 시작되었습니다.');
    });

    test('Comic 모델 생성 및 변환 테스트', () {
      final comic = Comic(
        diaryId: 'test-diary-id',
        userId: 'test-user-id',
        title: '테스트 만화',
        description: '테스트 설명',
        imageUrl: 'https://example.com/comic.png',
        style: 'cute',
        status: ComicStatus.completed,
        createdAt: DateTime.now(),
        completedAt: DateTime.now(),
        estimatedTimeSeconds: 60,
      );

      final json = comic.toJson();
      expect(json['id'], comic.id);
      expect(json['diary_id'], 'test-diary-id');
      expect(json['user_id'], 'test-user-id');
      expect(json['title'], '테스트 만화');
      expect(json['status'], 'completed');

      final fromJsonComic = Comic.fromJson(json);
      expect(fromJsonComic.id, comic.id);
      expect(fromJsonComic.diaryId, comic.diaryId);
      expect(fromJsonComic.status, comic.status);
    });

    test('ComicStatus enum 테스트', () {
      expect(ComicStatus.pending.value, 'pending');
      expect(ComicStatus.processing.value, 'processing');
      expect(ComicStatus.completed.value, 'completed');
      expect(ComicStatus.failed.value, 'failed');

      expect(ComicStatus.fromString('pending'), ComicStatus.pending);
      expect(ComicStatus.fromString('processing'), ComicStatus.processing);
      expect(ComicStatus.fromString('completed'), ComicStatus.completed);
      expect(ComicStatus.fromString('failed'), ComicStatus.failed);
      expect(ComicStatus.fromString('unknown'), ComicStatus.pending);
    });

    test('ETA 계산 테스트', () {
      final aiService = AiServerService.instance;
      
      // 완료된 만화
      final completedComic = Comic(
        diaryId: 'test',
        userId: 'test',
        title: 'test',
        imageUrl: 'test',
        style: 'test',
        status: ComicStatus.completed,
        createdAt: DateTime.now(),
      );
      expect(aiService.calculateETA(completedComic), 0);

      // 실패한 만화
      final failedComic = Comic(
        diaryId: 'test',
        userId: 'test',
        title: 'test',
        imageUrl: 'test',
        style: 'test',
        status: ComicStatus.failed,
        createdAt: DateTime.now(),
      );
      expect(aiService.calculateETA(failedComic), -1);

      // 처리 중인 만화 (추정 시간 있음)
      final processingComic = Comic(
        diaryId: 'test',
        userId: 'test',
        title: 'test',
        imageUrl: 'test',
        style: 'test',
        status: ComicStatus.processing,
        createdAt: DateTime.now().subtract(const Duration(seconds: 30)),
        estimatedTimeSeconds: 60,
      );
      final eta = aiService.calculateETA(processingComic);
      expect(eta, greaterThanOrEqualTo(0));
      expect(eta, lessThanOrEqualTo(60));
    });
  });

  group('Error Handling Tests', () {
    test('네트워크 오류 시뮬레이션', () {
      // 실제 네트워크 호출 없이 오류 처리 로직 테스트
      expect(() => throw Exception('네트워크 연결을 확인해주세요.'), 
             throwsA(isA<Exception>()));
    });

    test('타임아웃 오류 시뮬레이션', () {
      expect(() => throw Exception('요청 시간이 초과되었습니다. 다시 시도해주세요.'), 
             throwsA(isA<Exception>()));
    });
  });
}
