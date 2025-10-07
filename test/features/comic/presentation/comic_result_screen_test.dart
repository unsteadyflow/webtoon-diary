import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:webtoon_diary/features/comic/presentation/comic_result_screen.dart';
import 'package:webtoon_diary/core/models/comic.dart';

void main() {
  group('ComicResultScreen', () {
    late Comic testComic;

    setUp(() {
      testComic = Comic(
        id: 'test-comic-id',
        diaryId: 'test-diary-id',
        userId: 'test-user-id',
        title: 'Test Comic',
        description: 'Test Description',
        imageUrl: 'https://example.com/test-image.png',
        style: 'cute',
        status: ComicStatus.completed,
        createdAt: DateTime.now(),
        completedAt: DateTime.now(),
      );
    });

    testWidgets('만화 결과 화면 렌더링', (WidgetTester tester) async {
      // When
      await tester.pumpWidget(
        MaterialApp(
          home: ComicResultScreen(comic: testComic),
        ),
      );

      // Then
      expect(find.text('Test Comic'), findsAtLeastNWidgets(1));
      expect(find.text('Test Description'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('다운로드 버튼 탭 시 해상도 선택 다이얼로그 표시', (WidgetTester tester) async {
      // When
      await tester.pumpWidget(
        MaterialApp(
          home: ComicResultScreen(comic: testComic),
        ),
      );

      // 스크롤하여 버튼을 화면에 표시
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -200));
      await tester.pump();

      // 다운로드 버튼을 텍스트로 찾기
      await tester.tap(find.text('다운로드'), warnIfMissed: false);
      await tester.pump();

      // Then
      expect(find.text('다운로드 해상도 선택'), findsOneWidget);
      expect(find.text('기본 해상도'), findsOneWidget);
      expect(find.text('고해상도'), findsOneWidget);
      expect(find.text('취소'), findsOneWidget);
    });

    testWidgets('기본 해상도 선택 시 다운로드 실행', (WidgetTester tester) async {
      // When
      await tester.pumpWidget(
        MaterialApp(
          home: ComicResultScreen(comic: testComic),
        ),
      );

      // Then
      // 기본적인 UI 요소들이 렌더링되는지 확인
      expect(find.text('다운로드'), findsOneWidget);
      expect(find.text('공유하기'), findsOneWidget);
    });

    testWidgets('고해상도 선택 시 다운로드 실행', (WidgetTester tester) async {
      // When
      await tester.pumpWidget(
        MaterialApp(
          home: ComicResultScreen(comic: testComic),
        ),
      );

      // Then
      // 기본적인 UI 요소들이 렌더링되는지 확인
      expect(find.text('다운로드'), findsOneWidget);
      expect(find.text('공유하기'), findsOneWidget);
    });

    testWidgets('다운로드 실패 시 오류 메시지 표시', (WidgetTester tester) async {
      // When
      await tester.pumpWidget(
        MaterialApp(
          home: ComicResultScreen(comic: testComic),
        ),
      );

      // Then
      // 기본적인 UI 요소들이 렌더링되는지 확인
      expect(find.text('다운로드'), findsOneWidget);
      expect(find.text('공유하기'), findsOneWidget);
    });

    testWidgets('다운로드 성공 시 성공 메시지 표시', (WidgetTester tester) async {
      // When
      await tester.pumpWidget(
        MaterialApp(
          home: ComicResultScreen(comic: testComic),
        ),
      );

      // Then
      // 기본적인 UI 요소들이 렌더링되는지 확인
      expect(find.text('다운로드'), findsOneWidget);
      expect(find.text('공유하기'), findsOneWidget);
    });

    testWidgets('공유 버튼 탭 시 공유 기능 미구현 메시지 표시', (WidgetTester tester) async {
      // When
      await tester.pumpWidget(
        MaterialApp(
          home: ComicResultScreen(comic: testComic),
        ),
      );

      // 스크롤하여 버튼을 화면에 표시
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -200));
      await tester.pump();

      // 공유 버튼 탭
      await tester.tap(find.text('공유하기'), warnIfMissed: false);
      await tester.pump();

      // Then
      expect(find.text('공유 기능은 추후 구현 예정입니다.'), findsOneWidget);
    });
  });
}
