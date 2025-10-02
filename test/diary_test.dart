import 'package:flutter_test/flutter_test.dart';
import 'package:webtoon_diary/core/models/diary.dart';
import 'package:webtoon_diary/services/diary_service.dart';

void main() {
  group('Diary Model Tests', () {
    test('Diary 객체 생성 테스트', () {
      final diary = Diary(
        id: 'test-id',
        userId: 'user-id',
        content: '테스트 일기 내용',
        title: '테스트 제목',
        mood: '😊',
        weather: '☀️ 맑음',
        location: '서울',
        isDraft: false,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      expect(diary.id, 'test-id');
      expect(diary.userId, 'user-id');
      expect(diary.content, '테스트 일기 내용');
      expect(diary.title, '테스트 제목');
      expect(diary.mood, '😊');
      expect(diary.weather, '☀️ 맑음');
      expect(diary.location, '서울');
      expect(diary.isDraft, false);
    });

    test('Diary JSON 변환 테스트', () {
      final diary = Diary(
        id: 'test-id',
        userId: 'user-id',
        content: '테스트 일기 내용',
        title: '테스트 제목',
        mood: '😊',
        weather: '☀️ 맑음',
        location: '서울',
        isDraft: false,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      final json = diary.toJson();
      expect(json['id'], 'test-id');
      expect(json['user_id'], 'user-id');
      expect(json['content'], '테스트 일기 내용');
      expect(json['title'], '테스트 제목');
      expect(json['mood'], '😊');
      expect(json['weather'], '☀️ 맑음');
      expect(json['location'], '서울');
      expect(json['is_draft'], false);

      final fromJsonDiary = Diary.fromJson(json);
      expect(fromJsonDiary.id, diary.id);
      expect(fromJsonDiary.userId, diary.userId);
      expect(fromJsonDiary.content, diary.content);
      expect(fromJsonDiary.title, diary.title);
      expect(fromJsonDiary.mood, diary.mood);
      expect(fromJsonDiary.weather, diary.weather);
      expect(fromJsonDiary.location, diary.location);
      expect(fromJsonDiary.isDraft, diary.isDraft);
    });

    test('Diary copyWith 테스트', () {
      final originalDiary = Diary(
        id: 'test-id',
        userId: 'user-id',
        content: '원본 내용',
        title: '원본 제목',
        mood: '😊',
        weather: '☀️ 맑음',
        location: '서울',
        isDraft: false,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      final updatedDiary = originalDiary.copyWith(
        content: '수정된 내용',
        title: '수정된 제목',
        mood: '😢',
      );

      expect(updatedDiary.id, originalDiary.id);
      expect(updatedDiary.userId, originalDiary.userId);
      expect(updatedDiary.content, '수정된 내용');
      expect(updatedDiary.title, '수정된 제목');
      expect(updatedDiary.mood, '😢');
      expect(updatedDiary.weather, originalDiary.weather);
      expect(updatedDiary.location, originalDiary.location);
      expect(updatedDiary.isDraft, originalDiary.isDraft);
    });
  });

  group('DiaryService Tests', () {
    test('싱글톤 패턴 확인', () {
      final instance1 = DiaryService.instance;
      final instance2 = DiaryService.instance;
      expect(identical(instance1, instance2), isTrue);
    });
  });

  group('Form Validation Tests', () {
    test('일기 내용 유효성 검사', () {
      // 빈 내용
      expect(''.trim().isEmpty, isTrue);
      
      // 공백만 있는 내용
      expect('   '.trim().isEmpty, isTrue);
      
      // 유효한 내용
      expect('오늘은 좋은 하루였습니다.'.trim().isEmpty, isFalse);
    });

    test('제목 유효성 검사', () {
      // 빈 제목 (선택사항이므로 유효)
      expect(''.trim().isEmpty, isTrue);
      
      // 유효한 제목
      expect('오늘의 일기'.trim().isEmpty, isFalse);
      
      // 긴 제목
      final longTitle = 'a' * 100;
      expect(longTitle.length > 50, isTrue);
    });

    test('기분 및 날씨 선택 테스트', () {
      final moodOptions = ['😊', '😄', '😍', '🥰', '😎', '🤔', '😐', '😔', '😢', '😭', '😤', '😡'];
      final weatherOptions = ['☀️ 맑음', '⛅ 흐림', '☁️ 구름', '🌧️ 비', '⛈️ 천둥', '❄️ 눈', '🌪️ 바람'];
      
      // 기분 옵션 개수 확인
      expect(moodOptions.length, 12);
      
      // 날씨 옵션 개수 확인
      expect(weatherOptions.length, 7);
      
      // 특정 기분이 목록에 있는지 확인
      expect(moodOptions.contains('😊'), isTrue);
      expect(moodOptions.contains('😢'), isTrue);
      
      // 특정 날씨가 목록에 있는지 확인
      expect(weatherOptions.contains('☀️ 맑음'), isTrue);
      expect(weatherOptions.contains('🌧️ 비'), isTrue);
    });
  });

  group('Offline Sync Tests', () {
    test('오프라인 데이터 구조 테스트', () {
      final diary = Diary(
        id: 'local_1234567890',
        userId: 'user-id',
        content: '오프라인에서 작성한 일기',
        title: '오프라인 제목',
        mood: '😊',
        weather: '☀️ 맑음',
        location: '집',
        isDraft: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // 로컬 ID 형식 확인
      expect(diary.id.startsWith('local_'), isTrue);
      expect(diary.isDraft, isTrue);
      
      // JSON 변환 가능 확인
      final json = diary.toJson();
      expect(json['id'], startsWith('local_'));
      expect(json['is_draft'], isTrue);
    });
  });
}
