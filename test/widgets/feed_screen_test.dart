import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webtoon_diary/features/home/presentation/feed_screen.dart';
import 'package:webtoon_diary/core/models/diary.dart';
import 'package:webtoon_diary/core/models/comic.dart';
import 'package:webtoon_diary/core/models/diary_comic.dart';

/// FeedScreen 위젯 테스트
void main() {
  group('FeedScreen Widget Tests', () {
    testWidgets('피드 화면이 빌드되는지 확인', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FeedScreen(),
        ),
      );

      // FeedScreen이 빌드되었는지 확인
      expect(find.byType(FeedScreen), findsOneWidget);
    });

    testWidgets('로딩 상태 표시 확인', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FeedScreen(),
        ),
      );

      // 초기 로딩 상태에서는 스켈레톤이나 로딩 인디케이터가 표시될 수 있음
      await tester.pump();
    });

    testWidgets('FAB 버튼이 표시되는지 확인', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FeedScreen(),
          ),
        ),
      );

      await tester.pump();

      // FAB 버튼 찾기
      final fabFinder = find.byType(FloatingActionButton);
      expect(fabFinder, findsOneWidget);
    });
  });

  group('DiaryComic Model Tests', () {
    test('DiaryComic 생성 및 속성 테스트', () {
      final diary = Diary(
        id: 'test-diary',
        userId: 'user',
        content: '테스트 일기',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final diaryComic = DiaryComic(diary: diary);
      expect(diaryComic.diary.id, 'test-diary');
      expect(diaryComic.comic, null);
      expect(diaryComic.hasComic, false);
    });

    test('DiaryComic with Comic 테스트', () {
      final diary = Diary(
        id: 'test-diary',
        userId: 'user',
        content: '테스트 일기',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final comic = Comic(
        diaryId: diary.id,
        userId: diary.userId,
        title: '만화',
        imageUrl: 'https://example.com/comic.png',
        style: 'cute',
        status: ComicStatus.completed,
        completedAt: DateTime.now(),
      );

      final diaryComic = DiaryComic(diary: diary, comic: comic);
      expect(diaryComic.hasComic, true);
      expect(diaryComic.comicThumbnailUrl, 'https://example.com/comic.png');
    });
  });
}
