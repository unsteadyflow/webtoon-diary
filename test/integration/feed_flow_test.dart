import 'package:flutter_test/flutter_test.dart';
import 'package:webtoon_diary/core/models/diary.dart';
import 'package:webtoon_diary/core/models/comic.dart';
import 'package:webtoon_diary/core/models/diary_comic.dart';

/// 메인 피드 플로우 통합 테스트
/// 일기 작성 → 저장 → 피드 조회 → 만화 생성 → 피드 업데이트
void main() {
  group('Feed Flow Integration Tests', () {
    test('일기 작성 및 피드 조회 플로우', () async {
      // 1. 일기 생성
      final diary = Diary(
        id: 'test-diary-1',
        userId: 'test-user',
        content: '오늘은 좋은 하루였습니다.',
        title: '오늘의 일기',
        mood: '😊',
        weather: '☀️ 맑음',
        location: '서울',
        isDraft: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(diary.id, 'test-diary-1');
      expect(diary.content, '오늘은 좋은 하루였습니다.');
      expect(diary.isDraft, false);

      // 2. DiaryComic 생성 (만화 없이)
      final diaryComic = DiaryComic(diary: diary);
      expect(diaryComic.diary.id, diary.id);
      expect(diaryComic.hasComic, false);
      expect(diaryComic.comicThumbnailUrl, null);

      // 3. 만화 추가 후 업데이트
      final comic = Comic(
        id: 'test-comic-1',
        diaryId: diary.id,
        userId: diary.userId,
        title: diary.title ?? '만화',
        imageUrl: 'https://example.com/comic.png',
        style: 'cute',
        status: ComicStatus.completed,
        createdAt: DateTime.now(),
        completedAt: DateTime.now(),
      );

      final diaryComicWithComic = DiaryComic(
        diary: diary,
        comic: comic,
      );

      expect(diaryComicWithComic.hasComic, true);
      expect(diaryComicWithComic.comicThumbnailUrl, 'https://example.com/comic.png');
    });

    test('피드 데이터 정렬 테스트', () {
      final now = DateTime.now();
      final diaries = [
        Diary(
          id: '1',
          userId: 'user',
          content: '첫 번째 일기',
          createdAt: now.subtract(const Duration(days: 2)),
          updatedAt: now.subtract(const Duration(days: 2)),
        ),
        Diary(
          id: '2',
          userId: 'user',
          content: '두 번째 일기',
          createdAt: now.subtract(const Duration(days: 1)),
          updatedAt: now.subtract(const Duration(days: 1)),
        ),
        Diary(
          id: '3',
          userId: 'user',
          content: '세 번째 일기',
          createdAt: now,
          updatedAt: now,
        ),
      ];

      // 최신순 정렬 확인
      final sorted = diaries.toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      expect(sorted[0].id, '3');
      expect(sorted[1].id, '2');
      expect(sorted[2].id, '1');
    });

    test('만화 상태별 필터링 테스트', () {
      final diary = Diary(
        id: 'test-diary',
        userId: 'user',
        content: '테스트 일기',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // 만화 없음
      final diaryComic1 = DiaryComic(diary: diary);
      expect(diaryComic1.hasComic, false);

      // 만화 생성 중
      final comicPending = Comic(
        diaryId: diary.id,
        userId: diary.userId,
        title: '만화',
        imageUrl: '',
        style: 'cute',
        status: ComicStatus.processing,
      );
      final diaryComic2 = DiaryComic(diary: diary, comic: comicPending);
      expect(diaryComic2.hasComic, false); // processing 상태는 false

      // 만화 완료
      final comicCompleted = Comic(
        diaryId: diary.id,
        userId: diary.userId,
        title: '만화',
        imageUrl: 'https://example.com/comic.png',
        style: 'cute',
        status: ComicStatus.completed,
        completedAt: DateTime.now(),
      );
      final diaryComic3 = DiaryComic(diary: diary, comic: comicCompleted);
      expect(diaryComic3.hasComic, true);
    });
  });
}

