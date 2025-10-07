import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:webtoon_diary/features/comic/presentation/saved_images_screen.dart';
import 'package:webtoon_diary/services/image_download_service.dart';

// Mock 클래스 생성
@GenerateMocks([ImageDownloadService])
import 'saved_images_screen_test.mocks.dart';

void main() {
  group('SavedImagesScreen', () {
    late MockImageDownloadService mockImageDownloadService;

    setUp(() {
      mockImageDownloadService = MockImageDownloadService();
    });

    testWidgets('저장된 이미지가 없을 때 빈 상태 표시', (WidgetTester tester) async {
      // Given
      when(mockImageDownloadService.getSavedImages()).thenAnswer((_) async => []);
      when(mockImageDownloadService.getStorageUsage()).thenAnswer((_) async => 0);

      // When
      await tester.pumpWidget(
        MaterialApp(
          home: SavedImagesScreen(),
        ),
      );

      // Then
      expect(find.text('저장된 이미지가 없습니다'), findsOneWidget);
      expect(find.text('만화를 다운로드하면 여기에 표시됩니다'), findsOneWidget);
      expect(find.byIcon(Icons.image_not_supported), findsOneWidget);
    });

    testWidgets('저장 공간 사용량 표시', (WidgetTester tester) async {
      // Given
      when(mockImageDownloadService.getSavedImages()).thenAnswer((_) async => []);
      when(mockImageDownloadService.getStorageUsage()).thenAnswer((_) async => 1024 * 1024); // 1MB
      when(mockImageDownloadService.formatStorageSize(1024 * 1024)).thenReturn('1.0 MB');

      // When
      await tester.pumpWidget(
        MaterialApp(
          home: SavedImagesScreen(),
        ),
      );

      // Then
      expect(find.text('저장된 이미지: 0개'), findsOneWidget);
      expect(find.text('사용 공간: 1.0 MB'), findsOneWidget);
    });

    testWidgets('새로고침 버튼 동작', (WidgetTester tester) async {
      // Given
      when(mockImageDownloadService.getSavedImages()).thenAnswer((_) async => []);
      when(mockImageDownloadService.getStorageUsage()).thenAnswer((_) async => 0);

      await tester.pumpWidget(
        MaterialApp(
          home: SavedImagesScreen(),
        ),
      );

      // When
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pump();

      // Then
      verify(mockImageDownloadService.getSavedImages()).called(2); // 초기 로드 + 새로고침
      verify(mockImageDownloadService.getStorageUsage()).called(2);
    });
  });

  group('ImageViewerScreen', () {
    testWidgets('이미지 상세 보기 화면 렌더링', (WidgetTester tester) async {
      // Given
      const testImagePath = '/test/path/image.png';
      final testFile = File(testImagePath);

      // When
      await tester.pumpWidget(
        MaterialApp(
          home: ImageViewerScreen(imageFile: testFile),
        ),
      );

      // Then
      expect(find.text('image.png'), findsOneWidget);
      expect(find.byType(InteractiveViewer), findsOneWidget);
    });

    testWidgets('이미지 로드 실패 시 오류 표시', (WidgetTester tester) async {
      // Given
      const testImagePath = '/nonexistent/path/image.png';
      final testFile = File(testImagePath);

      // When
      await tester.pumpWidget(
        MaterialApp(
          home: ImageViewerScreen(imageFile: testFile),
        ),
      );

      // Then
      expect(find.text('이미지를 불러올 수 없습니다'), findsOneWidget);
      expect(find.byIcon(Icons.error), findsOneWidget);
    });
  });
}
