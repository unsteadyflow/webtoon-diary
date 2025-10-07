import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:webtoon_diary/features/comic/presentation/comic_result_screen.dart';
import 'package:webtoon_diary/core/models/comic.dart';
import 'package:webtoon_diary/services/image_download_service.dart';

// Mock 클래스 생성
@GenerateMocks([ImageDownloadService])
import 'comic_result_screen_test.mocks.dart';

void main() {
  group('ComicResultScreen', () {
    late MockImageDownloadService mockImageDownloadService;
    late Comic testComic;

    setUp(() {
      mockImageDownloadService = MockImageDownloadService();
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
      expect(find.text('Test Comic'), findsOneWidget);
      expect(find.text('Test Description'), findsOneWidget);
      expect(find.text('cute'), findsOneWidget);
      expect(find.byIcon(Icons.download), findsOneWidget);
      expect(find.byIcon(Icons.share), findsOneWidget);
    });

    testWidgets('다운로드 버튼 탭 시 해상도 선택 다이얼로그 표시', (WidgetTester tester) async {
      // Given
      when(mockImageDownloadService.downloadAndSaveImage(
        imageUrl: anyNamed('imageUrl'),
        fileName: anyNamed('fileName'),
        quality: anyNamed('quality'),
      )).thenAnswer((_) async => '/test/path/image.png');

      // When
      await tester.pumpWidget(
        MaterialApp(
          home: ComicResultScreen(comic: testComic),
        ),
      );

      await tester.tap(find.byIcon(Icons.download));
      await tester.pumpAndSettle();

      // Then
      expect(find.text('다운로드 해상도 선택'), findsOneWidget);
      expect(find.text('기본 해상도'), findsOneWidget);
      expect(find.text('고해상도'), findsOneWidget);
      expect(find.text('취소'), findsOneWidget);
    });

    testWidgets('기본 해상도 선택 시 다운로드 실행', (WidgetTester tester) async {
      // Given
      when(mockImageDownloadService.downloadAndSaveImage(
        imageUrl: anyNamed('imageUrl'),
        fileName: anyNamed('fileName'),
        quality: anyNamed('quality'),
      )).thenAnswer((_) async => '/test/path/image.png');

      // When
      await tester.pumpWidget(
        MaterialApp(
          home: ComicResultScreen(comic: testComic),
        ),
      );

      await tester.tap(find.byIcon(Icons.download));
      await tester.pumpAndSettle();

      await tester.tap(find.text('기본 해상도'));
      await tester.pumpAndSettle();

      // Then
      verify(mockImageDownloadService.downloadAndSaveImage(
        imageUrl: testComic.imageUrl,
        fileName: anyNamed('fileName'),
        quality: ImageQuality.standard,
      )).called(1);
    });

    testWidgets('고해상도 선택 시 다운로드 실행', (WidgetTester tester) async {
      // Given
      when(mockImageDownloadService.downloadAndSaveImage(
        imageUrl: anyNamed('imageUrl'),
        fileName: anyNamed('fileName'),
        quality: anyNamed('quality'),
      )).thenAnswer((_) async => '/test/path/image.png');

      // When
      await tester.pumpWidget(
        MaterialApp(
          home: ComicResultScreen(comic: testComic),
        ),
      );

      await tester.tap(find.byIcon(Icons.download));
      await tester.pumpAndSettle();

      await tester.tap(find.text('고해상도'));
      await tester.pumpAndSettle();

      // Then
      verify(mockImageDownloadService.downloadAndSaveImage(
        imageUrl: testComic.imageUrl,
        fileName: anyNamed('fileName'),
        quality: ImageQuality.high,
      )).called(1);
    });

    testWidgets('다운로드 실패 시 오류 메시지 표시', (WidgetTester tester) async {
      // Given
      when(mockImageDownloadService.downloadAndSaveImage(
        imageUrl: anyNamed('imageUrl'),
        fileName: anyNamed('fileName'),
        quality: anyNamed('quality'),
      )).thenThrow(Exception('다운로드 실패'));

      // When
      await tester.pumpWidget(
        MaterialApp(
          home: ComicResultScreen(comic: testComic),
        ),
      );

      await tester.tap(find.byIcon(Icons.download));
      await tester.pumpAndSettle();

      await tester.tap(find.text('기본 해상도'));
      await tester.pumpAndSettle();

      // Then
      expect(find.text('다운로드 실패: Exception: 다운로드 실패'), findsOneWidget);
      expect(find.text('재시도'), findsOneWidget);
    });

    testWidgets('다운로드 성공 시 성공 메시지 표시', (WidgetTester tester) async {
      // Given
      const savePath = '/test/path/image.png';
      when(mockImageDownloadService.downloadAndSaveImage(
        imageUrl: anyNamed('imageUrl'),
        fileName: anyNamed('fileName'),
        quality: anyNamed('quality'),
      )).thenAnswer((_) async => savePath);

      // When
      await tester.pumpWidget(
        MaterialApp(
          home: ComicResultScreen(comic: testComic),
        ),
      );

      await tester.tap(find.byIcon(Icons.download));
      await tester.pumpAndSettle();

      await tester.tap(find.text('기본 해상도'));
      await tester.pumpAndSettle();

      // Then
      expect(find.text('다운로드 완료!\n저장 위치: $savePath'), findsOneWidget);
      expect(find.text('확인'), findsOneWidget);
    });

    testWidgets('공유 버튼 탭 시 공유 기능 미구현 메시지 표시', (WidgetTester tester) async {
      // When
      await tester.pumpWidget(
        MaterialApp(
          home: ComicResultScreen(comic: testComic),
        ),
      );

      await tester.tap(find.byIcon(Icons.share));
      await tester.pumpAndSettle();

      // Then
      expect(find.text('공유 기능은 추후 구현 예정입니다.'), findsOneWidget);
    });
  });
}
